
    ; Vertical Sync
VerticalSync: subroutine
    VERTICAL_SYNC

FrameStart: subroutine
    ; FIXME we can't skip this: ASSERT_RUNTIME "_scan == #0"

VerticalBlank: subroutine
    TIMER_SETUP 37

    ; Scanline counter
    lda #ROW_COUNT
    sta LoopCount

    ; Frame counter
    inc FrameCount

    ; Positioning
    SLEEP 40
    sta EMERALD_SP_RESET	; position 1st player
    sta WSYNC

    ; Misc
    lda #00
    sta EMERALD_MI_ENABLE

    ; Assign dervied SpriteEnd value
    clc
    lda #HEIGHT_OFFSET
    sbc YPos
    sta SpriteEnd

    ; Player 1
    lda XPos
    ldx #0
    jsr SetHorizPos

    ; Load the kernel into CBSRAM.
game_frame_kernel_loader: subroutine
    ; Kernel A or B
    lda #01
    IFNCONST ONLY_KERNEL_B
    IFNCONST ONLY_KERNEL_A
    ; FIXME disabled for test
    and FrameCount
    bne .kernel_b
    ENDIF
.kernel_a:
    ; Load kernel A into CBSRAM
    jsr LoadKernelA
    jmp .complete
    ENDIF
.kernel_b:
    ; Load kernel B into CBSRAM
    jsr LoadKernelB
.complete:

    ; Populate the kernel with gemini changes.
game_frame_populate: subroutine
    ; Extract 26-bit string to full Gemini profile
    jsr gemini_populate
    ; Run nibble populate.
    jsr game_nibble_populate

    ; Complete frame setup.
game_frame_setup: subroutine
    ; Kernel A or B reading directly from the kernel ID
    lda CBSRAM_KERNEL_READ
    cmp #$0a
    bne .kernel_b

.kernel_a:
    ; Move missile
    sta WSYNC
    sleep KERNEL_A_MISSILE_SLEEP
    sta EMERALD_MI_RESET
    lda #KERNEL_A_MISSILE_HMOVE
    sta EMERALD_MI_HMOVE

    ; DEBUG: Set per-kernel color
    ldx #COL_EMERALD
    stx EMERALD_SP_COLOR

    jmp .complete

.kernel_b:
    ; Move missile
    sta WSYNC
    sleep KERNEL_B_MISSILE_SLEEP
    sta EMERALD_MI_RESET
    lda #KERNEL_B_MISSILE_HMOVE
    sta EMERALD_MI_HMOVE

    lda DO_MISS_B
    bne .kernel_b_continue
    sta WSYNC
    sleep KERNEL_B_MISSILE_SLEEP + 8
    sta EMERALD_MI_RESET
    jmp .kernel_b_continue_2

.kernel_b_continue:
    sta WSYNC
.kernel_b_continue_2:
    ; DEBUG: Set per-kernel color
    ldx #$e4
    ; ldx #COL_EMERALD
    stx EMERALD_SP_COLOR

.complete:

VerticalBlankEnd:
    ; Wait until the end of Vertical blank.
    TIMER_WAIT
    ASSERT_RUNTIME "_scan == #37"

    ; Save stack pointer
    tsx
    stx RamStackBkp

    ; Start rendering the kernel.
    jmp KernelBorder

FrameEnd: subroutine
    sta WSYNC

    ; Blank all background colors.
    lda #0
    sta COLUPF
    sta PF2
    sta PF1
    sta EMERALD_SP

    ; Guide lines (2x)
    lda #SIGNAL_LINE
    sta COLUBK
    REPEAT 6
    sta WSYNC
    REPEND
    lda #$00
    sta COLUBK

    ; Restore stack pointer
    ldx RamStackBkp
    txs

    ; Display the rest of the blank screen.
    TIMER_SETUP 25
    sta WSYNC
    TIMER_WAIT
    ASSERT_RUNTIME "_scan == (#37 + #184)"

    ; Overscan
Overscan: subroutine
    sta VBLANK
    TIMER_SETUP 29

    jsr MoveJoystick
    jsr SpeedCalculation
    jsr game_state_tick

    TIMER_WAIT
    ASSERT_RUNTIME "_scan == (#37 + #184 + #29)"

    jmp VerticalSync
