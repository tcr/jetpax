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

frame_setup_complete:

    lda shard_map
    ldy #1 ; gemini counter, starting at 1
gemini_builder:
    cpy #1 ; TODO top two bits of shard_map
    bne .no_vd0
.no_vd0:

nibble_precompile_gem_kernel:
DBG_NIBBLE:
BC_LDA_IMM = $a9
BC_STA = $85
BC_STX = $86
BC_STY = $84
BC_PHP = $08

NOP_REG = $79 ; TODO is there a better reg to write to with NOP effects

KernelA_D_W EQM [KernelA_D - $100]
KernelA_E_W EQM [KernelA_E - $100]
KernelA_G_W EQM [KernelA_G - $100]
KernelA_H_W EQM [KernelA_H - $100]
KernelA_I_W EQM [KernelA_I - $100]
KernelA_J_W EQM [KernelA_J - $100]
KernelA_K_W EQM [KernelA_K - $100]

KernelB_H_W EQM [KernelB_H - $100]

; Reflected for Kernel A
G00 = %00000000
G01 = %01100000
G10 = %00000110
G11 = %01100110

; gems:     [g01,g00,g00,g11,g01,g11]
; cpu:      cpu(g00,g01,false,g01,g11,false)
; solved:   [bc_STX,bc_RST,bc_RST,bc_STY,bc_VD1]

; gems:     [g01,g00,g00,g11,g01,g11]
; cpu:      cpu(g01,g01,false,g00,g11,false)
; solved:   [bc_NOP,bc_STX,bc_STX,bc_STY,bc_VD1]

; gems:     [g11,g01,g01,g01,g01,g00]
; cpu:      cpu(g00,g01,false,g11,g00,false)
; solved:   [bc_STX,bc_VD1,bc_STX,bc_STX,bc_STX]

; gems:     [g01,g10,g01,g11,g00,g00]
; cpu:      cpu(g01,g00,false,g10,g11,false)
; solved:   [bc_NOP,bc_STX,bc_RF1,bc_STY,bc_VD1]

; gems:     [g00,g01,g10,g11,g00,g01]
; cpu:      cpu(g01,g00,false,g10,g11,false)
; solved:   [bc_RST,bc_NOP,bc_STX,bc_STY,bc_VD1]

; gems:     [g01,g10,g11,g00,g01,g10]
; cpu:      cpu(g01,g01,false,g10,g11,false)
; solved:   [bc_NOP,bc_STX,bc_STY,bc_RST,bc_VD1]

; gems:     [g10,g11,g00,g01,g10,g11]
; cpu:      cpu(g10,g10,false,g11,g01,false)
; solved:   [bc_NOP,bc_STX,bc_RST,bc_STY,bc_VD1]

SHARD_LUT_RF1 = 0
SHARD_LUT_VD1 = 4
GEM0 = G10
GEM1 = G11
GEM2 = G00
GEM3 = G01
GEM4 = G10
GEM5 = G11

SHARD_0A_RST    = [GEM0 == G00]
SHARD_1A_RST    = [!SHARD_0A_RST && GEM1 == G00]
SHARD_2A_RST    = [!SHARD_0A_RST && !SHARD_1A_RST && GEM2 == G00]
SHARD_3A_RST    = 0 ; TODO
; Sprites (may be reversed)
SHARD_VD1       = [SHARD_LUT_VD1 == 4 ? GEM4 - GEM1] + GEM1
SHARD_GRP0      = [SHARD_0A_RST ? [GEM1 << 1] - GEM0] + GEM0
SHARD_X         = %01100110
SHARD_Y         = %01100000
; Opcodes
; SHARD_0A        = BC_NOP
SHARD_1A        = BC_STX
SHARD_1A_REG_0  = [SHARD_LUT_RF1 == 1 ? REFP1 - GRP1] + GRP1
SHARD_1A_REG    = [SHARD_0A_RST ? NOP_REG - SHARD_1A_REG_0] + SHARD_1A_REG_0
SHARD_2A        = BC_STY
SHARD_2A_REG    = [SHARD_LUT_RF1 == 2 ? REFP1 - GRP1] + GRP1
SHARD_3A        = BC_STY
SHARD_3A_REG    = [SHARD_LUT_RF1 == 3 ? REFP1 - GRP1] + GRP1
SHARD_4A_VD1    = [SHARD_LUT_VD1 == 4]
SHARD_4A        = BC_STX

    ; Nibble Kernel A
    NIBBLE_START_KERNEL gem_kernel_a, 40
        ; VD1
        ldy #SHARD_VD1
        sty [KernelA_VDEL1 - $100]
        ; GRP0
        ldy #SHARD_GRP0
        sty [KernelA_VDEL0 - $100]
        ; X
        ldy #SHARD_X
        sty RamKernelX
        ; Y
        NIBBLE_WRITE [KernelA_STY - $100], #SHARD_Y

        ; Gemini 1A
        ldx #SHARD_0A_RST
        NIBBLE_IF ne
            ; Special: Encoding RST0
            ; Rewrite lda RamKernelPF1 to be #immediate
            ldy #BC_LDA_IMM
            sty [KernelA_B - $100]
            ldy #%10100000
            sty [KernelA_B - $100 + 1]
            ; Gemini 1A is RESPx
            ldy #EMERALD_SP_RESET
            sty [KernelA_C - $100 + 1]
            ; Turn 3-cycle NOP into 4-cycle
            ldy #$14
            sty [KernelA_D - $100]
        NIBBLE_ELSE
            ldx #SHARD_1A_RST
            NIBBLE_IF ne
                NIBBLE_WRITE KernelA_D_W + 1, #RESP1 ; RESET
            NIBBLE_ELSE
                ldy #SHARD_1A
                sty RamKernelGemini1
                NIBBLE_WRITE KernelA_D_W, RamKernelGemini1, #SHARD_1A_REG ; STY
            NIBBLE_END_IF
        NIBBLE_END_IF

        ; Gemini 2A
        ldx #SHARD_2A_RST
        NIBBLE_IF ne
            NIBBLE_WRITE KernelA_E_W + 1, #NOP_REG   ; NOP
            NIBBLE_WRITE KernelA_G_W + 1, #RESP1 ; RESET
        NIBBLE_ELSE
            NIBBLE_WRITE KernelA_E_W + 1, #RESP1
            ldy #SHARD_2A
            sty RamKernelGemini2
            NIBBLE_WRITE KernelA_G_W, RamKernelGemini2, #SHARD_2A_REG ; STX
        NIBBLE_END_IF

        ; Gemini 3A
        ldx #SHARD_3A_RST
        NIBBLE_IF ne
            NIBBLE_WRITE KernelA_H_W + 1, #RESP1 ; RESET
        NIBBLE_ELSE
            ldy #SHARD_3A
            sty RamKernelGemini3
            NIBBLE_WRITE KernelA_H_W, RamKernelGemini3, #SHARD_3A_REG ; STY
        NIBBLE_END_IF

        ; Gemini 4A 
        ldx #SHARD_4A_VD1
        NIBBLE_IF ne
            NIBBLE_WRITE [KernelA_I_W + 0], #BC_STA, #EMERALD_SP_RESET
            NIBBLE_WRITE [KernelA_J_W + 1], #BC_STA, #PF1
            NIBBLE_WRITE [KernelA_K_W + 1], #BC_PHP

            ; Set PHP
            NIBBLE_WRITE RamKernelPhpTarget, #VDELP1
        NIBBLE_ELSE
            NIBBLE_WRITE [KernelA_I_W + 0], #BC_PHP
            NIBBLE_WRITE [KernelA_J_W + 0], #BC_STA, #PF1
            NIBBLE_WRITE KernelA_K_W, #SHARD_4A, #EMERALD_SP

            ; Set PHP
            NIBBLE_WRITE RamKernelPhpTarget, #RESP1
        NIBBLE_END_IF

        ; Gemini 5A
        ; TODO eventually...?
    NIBBLE_END_KERNEL

    ; Nibble Kernel B
    NIBBLE_START_KERNEL gem_kernel_b, 40
        ; X
        ldy #%00000011
        sty RamKernelX
        ; Y
        ldy #%00110011
        sty [KernelB_STY - $100]
        
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
    NIBBLE_END_KERNEL

    ; TODO do this for all rows
DBG_NIBBLE_BUILD: subroutine
    ldx $f100
    cpx #$a
    bne .kernel_b
.kernel_a:
    NIBBLE_gem_kernel_a_BUILD ; TODO can this be implied
    jmp .next
.kernel_b:
    NIBBLE_gem_kernel_b_BUILD ; TODO can this be implied
.next:
    sta RamNibbleVar1

    ; TODO move this into the row kernel
DBG_NIBBLE_RUN: subroutine
    lda RamNibbleVar1
    ldx $f100
    cpx #$a
    beq [. + 5]
    jmp .kernel_b
.kernel_a:
    NIBBLE_gem_kernel_a
    jmp .next
.kernel_b:
    NIBBLE_gem_kernel_b
.next:

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
