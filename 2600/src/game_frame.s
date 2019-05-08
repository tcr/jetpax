; Frame loop, including calling out to other kernels.

    ; Vertical Sync
VerticalSync: subroutine
    VERTICAL_SYNC

FrameStart: subroutine
    ASSERT_RUNTIME "_scan == #0"

VerticalBlank: subroutine
    TIMER_SETUP 37

    ; Scanline counter
    lda #ROW_COUNT
    sta LoopCount

    ; Frame counter
    inc FrameCount

    ; Skip every 8 frames for increasing demo index
    lda FrameCount
    and #FrameSkip
    cmp #FrameSkip
    bne .next_next_thing

    clc
    lda ROW_DEMO_INDEX
    adc #4
    cmp #[level_01_end - level_01]
    bcc .next_thing_local
    lda #0
.next_thing_local:
    sta ROW_DEMO_INDEX
.next_next_thing:
    sta WSYNC

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

frame_setup: subroutine
    ; Kernel A or B
    lda #01
    and FrameCount
    bne frame_setup_kernel_b

frame_setup_kernel_a: subroutine
    ; Load kernel into CBSRAM
    jsr LoadKernelA

    ; Move missile
    sta WSYNC
    sleep KERNEL_A_MISSILE_SLEEP
    sta EMERALD_MI_RESET
    lda #KERNEL_A_MISSILE_HMOVE
    sta EMERALD_MI_HMOVE

    ; DEBUG: Set per-kernel color
    ldx #COL_EMERALD
    stx EMERALD_SP_COLOR

    ; Set reflection for Jetpack.
    lda #%11111111
    sta REFP1

    ; Kernel: Set target of PHP instruction.
    lda #RESP1
    sta RamKernelPhpTarget

    ; Kernel: Set X register.
    lda #%00000110
    sta RamKernelX
    lda #%01100110
    sta RamKernelY

    jmp frame_setup_complete

frame_setup_kernel_b: subroutine
    ; Load kernel into CBSRAM
    jsr LoadKernelB

    ; Move missile
    sta WSYNC
    sleep KERNEL_B_MISSILE_SLEEP
    sta EMERALD_MI_RESET
    lda #KERNEL_B_MISSILE_HMOVE
    sta EMERALD_MI_HMOVE

    ; DEBUG: Set per-kernel color
    ldx #$e0
    stx EMERALD_SP_COLOR

    ; Disable reflection for Jetpack.
    lda #%11111111
    sta REFP1

    ; Kernel: Set target of PHP instruction.
    lda #GRP1
    sta RamKernelPhpTarget

    ; Kernel: Set X register.
    lda #%00000011
    sta RamKernelX
    lda #%00110011
    sta RamKernelY

frame_setup_complete:

    lda shard_map
    ldy #1 ; gemini counter, starting at 1
gemini_builder:
    cpy #1 ; TODO top two bits of shard_map
    bne .no_vd0
.no_vd0:

nibble_precompile_gem_kernel:
    ; Perform kernel Nibble calculations
    NIBBLE_START_KERNEL gem_kernel, 40
        ldx $f100
        cpx #$b
        NIBBLE_IF cs
            cpx #$ff
            NIBBLE_IF cs
                NIBBLE_WRITE_OPCODE [KernelB_D - $100 + 0], 1, php
                NIBBLE_WRITE_OPCODE [KernelB_D - $100 + 1], 2, sta EMERALD_SP_RESET
            NIBBLE_ELSE
                NIBBLE_WRITE_OPCODE [KernelB_H - $100 + 0], 1, php
                NIBBLE_WRITE_OPCODE [KernelB_H - $100 + 1], 2, sta EMERALD_SP_RESET
            NIBBLE_END_IF
        NIBBLE_END_IF
    NIBBLE_END_KERNEL
    rol
    rol
    rol
    rol
    rol
    rol
    sta RamNibbleVar1

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
    ASSERT_RUNTIME "_scan == (#37 + #192)"

    ; Overscan
Overscan: subroutine
    sta VBLANK
    TIMER_SETUP 29

    jsr MoveJoystick
    jsr SpeedCalculation

    TIMER_WAIT
    ASSERT_RUNTIME "_scan == (#37 + #192 + #29)"

    jmp VerticalSync
