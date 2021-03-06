    ; "Start" with overscan.
Overscan: subroutine
    sta VBLANK
    TIMER_SETUP 29

    ; Read inputs.
    jsr MoveJoystick
    ; Player physics.
    jsr SpeedCalculation
    ; Animation.
    jsr game_state_tick
    ; Load the ROM kernel into CBSRAM.
    jsr GameFrameKernelLoader

    ; Wait out overscan.
    TIMER_WAIT

    ; Vertical Sync (3 lines)
VerticalSync: subroutine
    VERTICAL_SYNC

    ; Start of NTSC frame.
FrameStart: subroutine
    ASSERT_RUNTIME "_scan == #0"

VerticalBlank: subroutine
    ; Setup frame timer and increment frame counter.
    ; FIXME TIMER_SETUP 37
    TIMER_SETUP 45
    inc FrameCount

    ; TODO Show TWO distinct gem rows, #32 and #48
ComputeRow4:
    ldy #48
    jsr GeminiPopulate
    jsr GameNibblePopulate

ComputeRow3:
    ldy #32
    jsr GeminiPopulate
    jsr GameNibblePopulate

ComputeRow2:
    ldy #16
    jsr GeminiPopulate
    jsr GameNibblePopulate

ComputeRow1:
    ldy #0
    jsr GeminiPopulate
    jsr GameNibblePopulate

    ; Immediately run populate for row 0.
    jsr GameNibbleRun

.continue:
    ; Setup frame. Jump and return
    jmp GameFrameSetup

VerticalBlankEnd:
    ; Wait until the end of Vertical blank.
    TIMER_WAIT
    ASSERT_RUNTIME "_scan == #37"

;;;;;;;;;;;;;;;;;;;;;;;;;;
; Visible frame
;;;;;;;;;;;;;;;;;;;;;;;;;;

GameFrameRender:
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

    ; Finish with overscan
    jmp Overscan


;;;;;;;;;;;;;;;;;;;;;;;;;;
; Other stuff
;;;;;;;;;;;;;;;;;;;;;;;;;;

    ; Load the ROM kernel into CBSRAM.
GameFrameKernelLoader: subroutine
    ; Kernel A or B
    lda #01
    IFNCONST ONLY_KERNEL_B
    IFNCONST ONLY_KERNEL_A
    and FrameCount
    bne .kernel_b
    ENDIF
.kernel_a:
    ; Load kernel A into CBSRAM
    jmp LoadKernelA
    ENDIF
.kernel_b:
    ; Load kernel B into CBSRAM
    jmp LoadKernelB

    ; Kernel-specific frame setup.
GameFrameSetup: subroutine
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

    ; Set RamRowPs for Kernel A
    ldx #$ff
    stx RamRowPs

    jmp .complete

.kernel_b:
    ; Move missile
    sta WSYNC
    sleep KERNEL_B_MISSILE_SLEEP
    sta EMERALD_MI_RESET
    lda #KERNEL_B_MISSILE_HMOVE
    sta EMERALD_MI_HMOVE

    ; Set RamRowPs for Kernel B
    ldx #$00
    stx RamRowPs

    ; Possibly override Missile position.
    ; TODO Document use of DO_MISS_B here, to check if M1 should be reset to a
    ; hidden position on Kernel B as a mechanism for offing the missile bit.
    lda DO_MISS_B
    bne .kernel_b_continue
    sta WSYNC
    sleep KERNEL_B_MISSILE_SLEEP + 8
    sta EMERALD_MI_RESET

.kernel_b_continue:
    ; DEBUG: Set per-kernel color
    ldx #$e4
    ; ldx #COL_EMERALD
    stx EMERALD_SP_COLOR

.complete:

    ; General frame setup.
FrameSetup: subroutine
    ; Save stack pointer
    tsx
    stx RamStackBkp

    ; Row counter
    lda #ROW_COUNT
    sta LoopCount

    ; let SpriteEnd = Frame Height - Y Position
    clc
    lda #HEIGHT_OFFSET
    sbc YPos
    sta SpriteEnd

    ; Position Player 1
    lda XPos
    ldx #0
    jsr SetHorizPos

    ; Set row offset to start with.
    lda #0
    sta RamRowOffset
    lda #COL_EMERALD
    sta RamRowColor

    jmp VerticalBlankEnd
