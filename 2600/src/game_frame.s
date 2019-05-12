; Frame loop, including calling out to other kernels.

SENTINEL = %010101010

; Reflected for Kernel A
G00 = %00000000
G01 = %01100000
G10 = %00000110
G11 = %01100110

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

; gems:     [g01,g00,g00,g11,g01,g11]
; cpu:      cpu(g01,g01,false,g00,g11,false)
; solved:   [bc_NOP,bc_STX,bc_STX,bc_STY,bc_VD1]

; gems:     [g11,g01,g01,g01,g01,g00]
; cpu:      cpu(g00,g01,false,g11,g00,false)
; solved:   [bc_STX,bc_VD1,bc_STX,bc_STX,bc_STX]

; gems:     [g10,g10,g11,g00,g11,g01]
; cpu:      cpu(g00,g00,false,g10,g11,false)
; solved:   [bc_STX,bc_STX,bc_STY,bc_RST,bc_STY]

; gems:     [g01,g00,g00,g11,g01,g11]
; cpu:      cpu(g00,g01,false,g01,g11,false)
; solved:   [bc_STX,bc_RST,bc_RST,bc_STY,bc_VD1]

; gems:     [g11,g10,g00,g01,g00,g01]
; cpu:      cpu(g11,g00,false,g10,g01,false)
; solved:   [bc_NOP,bc_STX,bc_RST,bc_STY,bc_VD1]

SHARD_LUT_RF1:
    .byte #0
SHARD_LUT_VD1:
    .byte #4 

GEM0:
    .byte G11
GEM1:
    .byte G10
GEM2:
    .byte G00
GEM3:
    .byte G01
GEM4:
    .byte G00
GEM5:
    .byte G01

; Y=Gemini Sprite
; processor flag Z=is RST opcode
KernelA_GenReset: subroutine
    cpy #$00
    beq .start
    rts
    ; Current Gemini = $00
.start:
    ldx BuildKernelRST
    cpx #SENTINEL
    bne .set_else
    ; We have found the first (and only) RST on this line, set the marker var
    ldx #$ff
    stx BuildKernelRST
.set_else
    ldx #$00
    rts

; Y=Gemini Sprite
KernelA_UpdateRegs: subroutine
    ; If equal to GRP0, return nop
    ; FIXME GRP0 might not always be up to date
    cpy BuildKernelGrp0
    bne .set_start
    ; TODO if this is stx + NOP value, then register doesn't have to change as
    ; often in GEM1ASWITCH
    ldy #BC_NOP
    rts

.set_start:
    ldx BuildKernelX
    cpx #SENTINEL
    bne .set_else
    sty BuildKernelX
    beq .set_end
.set_else
    ldx BuildKernelY
    cpx #SENTINEL
    bne .set_end
    sty BuildKernelY
.set_end:

    cpy BuildKernelX
    bne .op_else
    ldy #BC_STX
    rts
.op_else:
    cpy BuildKernelY
    bne .op_end
    ldy #BC_STY
.op_end:
    rts

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
BC_NOP = $04

NOP_REG = $79 ; TODO is there a better reg to write to with NOP effects

KernelA_D_W EQM [KernelA_D - $100]
KernelA_E_W EQM [KernelA_E - $100]
KernelA_G_W EQM [KernelA_G - $100]
KernelA_H_W EQM [KernelA_H - $100]
KernelA_I_W EQM [KernelA_I - $100]
KernelA_J_W EQM [KernelA_J - $100]
KernelA_K_W EQM [KernelA_K - $100]

KernelB_H_W EQM [KernelB_H - $100]

    ; Nibble Kernel A
    NIBBLE_START_KERNEL gem_kernel_a_1, 40
        ldx #SENTINEL ; sentinel
        stx BuildKernelX
        stx BuildKernelY
        stx BuildKernelRST

        ; Gemini 1A
        ldy GEM0
        jsr KernelA_GenReset
        NIBBLE_IF eq
            ; Special: Encoding RST0
            ; Rewrite lda RamKernelPF1 to be #immediate
            ldy #BC_LDA_IMM
            sty [KernelA_B - $100]
            ldy #%10100000
            sty [KernelA_B - $100 + 1]
            ; Store 1A in GRP0
            ldy GEM1
            sty BuildKernelGrp0
            ; Gemini 1A is RESPx
            ldy #EMERALD_SP_RESET
            sty [KernelA_C - $100 + 1]
            ; Turn 3-cycle NOP into 4-cycle
            ldy #$14 ; TODO what is this
            sty [KernelA_D - $100]
        NIBBLE_ELSE
            ; Store 0A in GRP0
            ldy GEM0
            sty BuildKernelGrp0

            ldy GEM1
            jsr KernelA_GenReset
            NIBBLE_IF eq
                ; GEM1ASWITCH
                NIBBLE_WRITE KernelA_D_W, #BC_STX, #RESP1 ; RESET
            NIBBLE_ELSE
                ; Calculate the 1A value
                ldy SHARD_LUT_RF1
                cpy #1
                .byte $D0, #3 ; bne +3
                ldy #RESP1
                .byte $2C ; .bit (ABS)
                ldy #GRP1
                sty RamKernelGemini1Reg

                ; Set opcode
                ldx SHARD_LUT_RF1
                cpx #1
                ldy #BC_STX
                .byte $D0, #4 ; bne +5
                ldy GEM1
                jsr KernelA_UpdateRegs
                sty RamKernelGemini1

                NIBBLE_WRITE KernelA_D_W, RamKernelGemini1, RamKernelGemini1Reg
            NIBBLE_END_IF
        NIBBLE_END_IF

        ; Gemini 2A
        ldy GEM2
        jsr KernelA_GenReset
        NIBBLE_IF eq
            NIBBLE_WRITE KernelA_E_W + 1, #NOP_REG   ; NOP
            NIBBLE_WRITE KernelA_G_W + 1, #RESP1 ; RESET
        NIBBLE_ELSE
            ; Set opcode
            ldy GEM2
            jsr KernelA_UpdateRegs
            sty RamKernelGemini2

            ; Set opcode target
            ldy SHARD_LUT_RF1
            cpy #2
            .byte $D0, #3 ; bne +3
            ldy #RESP1
            .byte $2C ; .bit (ABS)
            ldy #GRP1
            sty RamKernelGemini2Reg

            NIBBLE_WRITE KernelA_E_W + 1, #RESP1
            NIBBLE_WRITE KernelA_G_W, RamKernelGemini2, RamKernelGemini2Reg ; STX
        NIBBLE_END_IF

        ; Gemini 3A
        ldy GEM3
        jsr KernelA_GenReset
        NIBBLE_IF eq
            NIBBLE_WRITE KernelA_H_W + 1, #RESP1 ; RESET
        NIBBLE_ELSE
            ; Set opcode
            ldy GEM3
            jsr KernelA_UpdateRegs
            sty RamKernelGemini3

            ; Set opcode target
            ldy SHARD_LUT_RF1
            cpy #3
            .byte $D0, #3 ; bne +3
            ldy #RESP1
            .byte $2C ; .bit (ABS)
            ldy #GRP1
            sty RamKernelGemini3Reg

            NIBBLE_WRITE KernelA_H_W, RamKernelGemini3, RamKernelGemini3Reg ; STY
        NIBBLE_END_IF
    NIBBLE_END_KERNEL

    NIBBLE_START_KERNEL gem_kernel_a_2, 40
        ; VD1 default
        ldx GEM1
        stx BuildKernelVdel1

        ; Gemini 4A 
        ldx SHARD_LUT_VD1
        cpx #4
        NIBBLE_IF ne
            NIBBLE_WRITE [KernelA_I_W + 0], #BC_STA, #EMERALD_SP_RESET
            NIBBLE_WRITE [KernelA_J_W + 1], #BC_STA, #PF1
            NIBBLE_WRITE [KernelA_K_W + 1], #BC_PHP

            ; Set PHP
            NIBBLE_WRITE RamKernelPhpTarget, #VDELP1

            ; Update VDEL1
            ldx GEM4
            stx BuildKernelVdel1
        NIBBLE_ELSE
            ldy GEM4
            jsr KernelA_UpdateRegs
            sty RamKernelGemini4

            NIBBLE_WRITE [KernelA_I_W + 0], #BC_PHP
            NIBBLE_WRITE [KernelA_J_W + 0], #BC_STA, #PF1
            NIBBLE_WRITE KernelA_K_W, RamKernelGemini4, #EMERALD_SP

            ; Set PHP
            NIBBLE_WRITE RamKernelPhpTarget, #RESP1
        NIBBLE_END_IF

        ; VD1
        ; ldy #SHARD_VD1
        ; sty [KernelA_VDEL1 - $100]
        ; FIXME read from BuildKernelVdel1
        NIBBLE_WRITE [KernelA_VDEL1 - $100], BuildKernelVdel1
        ; GRP0
        ; ldy #SHARD_GRP0
        ; sty [KernelA_VDEL0 - $100]
        NIBBLE_WRITE [KernelA_VDEL0 - $100], BuildKernelGrp0
        ; X
        ; ldy #SHARD_X
        ; sty RamKernelX
        NIBBLE_WRITE RamKernelX, BuildKernelX
        ; Y
        NIBBLE_WRITE [KernelA_STY - $100], BuildKernelY

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
    beq [. + 5]
    jmp .kernel_b 
.kernel_a:
    NIBBLE_gem_kernel_a_1_BUILD ; TODO can this be implied
    sta RamNibbleVar1
    NIBBLE_gem_kernel_a_2_BUILD ; TODO can this be implied
    sta RamNibbleVar2
    jmp .next
.kernel_b:
    NIBBLE_gem_kernel_b_BUILD ; TODO can this be implied
    sta RamNibbleVar1
.next:

    ; TODO move this into the row kernel
DBG_NIBBLE_RUN: subroutine
    ldx $f100
    cpx #$a
    beq [. + 5]
    jmp .kernel_b
.kernel_a:
    lda RamNibbleVar1
    NIBBLE_gem_kernel_a_1
    lda RamNibbleVar2
    NIBBLE_gem_kernel_a_2
    jmp .next
.kernel_b:
    lda RamNibbleVar1
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
