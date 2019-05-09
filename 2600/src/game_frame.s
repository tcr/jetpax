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

    ; Kernel: Set X register.
    lda #%01100000
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
DBG_NIBBLE:
BC_STA = $85
BC_STX = $86
BC_STY = $84
BC_PHP = $08

KernelA_D_W EQM [KernelA_D - $100]
KernelA_G_W EQM [KernelA_G - $100]
KernelA_H_W EQM [KernelA_H - $100]
KernelA_I_W EQM [KernelA_I - $100]
KernelA_J_W EQM [KernelA_J - $100]
KernelA_K_W EQM [KernelA_K - $100]

KernelB_H_W EQM [KernelB_H - $100]

    ; Perform kernel Nibble calculations
    NIBBLE_START_KERNEL gem_kernel, 40
        ldx $f100
        cpx #$a
        NIBBLE_IF eq
            ; TEST: bc_NOP,bc_RST,bc_STX,bc_STY,bc_VD1, ??

            ; Kernel A
            NIBBLE_WRITE RamKernelPhpTarget, #VDELP1

            NIBBLE_WRITE KernelA_D_W, #BC_STY, #RESP1   ; 1A RST
            NIBBLE_WRITE KernelA_G_W, #BC_STX, #GRP1    ; 2A STX
            NIBBLE_WRITE KernelA_H_W, #BC_STY, #GRP1    ; 3A STY
            NIBBLE_WRITE KernelA_I_W, #BC_STA, #EMERALD_SP_RESET    ; 4A PHP
            NIBBLE_WRITE [KernelA_J_W + 1], #BC_STA, #PF1
            NIBBLE_WRITE [KernelA_K_W + 1], #BC_PHP

            ; End of NIBBLE_IF normalizing
            REPEAT 7
                rol
            REPEND
        NIBBLE_ELSE
            ; Kernel B
            cpx #$00
            NIBBLE_IF cs
                NIBBLE_WRITE RamKernelPhpTarget, #EMERALD_SP_RESET
                ; NIBBLE_WRITE [KernelB_H_W + 0], #BC_STA
                ; NIBBLE_WRITE [KernelB_H_W + 1], #EMERALD_SP
                ; NIBBLE_WRITE [KernelB_H_W + 2], #BC_PHP
            NIBBLE_ELSE
                NIBBLE_WRITE RamKernelPhpTarget, #EMERALD_SP
                ; NIBBLE_WRITE [KernelB_H_W + 0], #BC_PHP
                ; NIBBLE_WRITE [KernelB_H_W + 1], #BC_STA
                ; NIBBLE_WRITE [KernelB_H_W + 2], #EMERALD_SP_RESET
            NIBBLE_END_IF
            REPEAT 6
                rol
            REPEND
        NIBBLE_END_IF
    NIBBLE_END_KERNEL
    sta RamNibbleVar1

    ; TODO move this into kernel
    lda RamNibbleVar1
DBG_NIBBLEVM:
    NIBBLE_gem_kernel

VerticalBlankEnd:
    ; Wait until the end of Vertical blank.
    TIMER_WAIT
    ASSERT_RUNTIME "_scan == #37"

    ; Save stack pointer
    tsx
    stx RamStackBkp

    ; Start rendering the kernel.
    jmp KernelBorder

    align 256 ; TODO why

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
