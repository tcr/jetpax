; Frame loop, including calling out to other kernels.

SENTINEL = %010101010

; Reflected for Kernel A
G00 = %00000000
G01 = %01100000
G10 = %00000110
G11 = %01100110

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

KernelB_D_W EQM [KernelB_D - $100]
KernelB_E_W EQM [KernelB_E - $100]
KernelB_F_W EQM [KernelB_F - $100]
KernelB_G_W EQM [KernelB_G - $100]
KernelB_H_W EQM [KernelB_H - $100]
KernelB_I_W EQM [KernelB_I - $100]
KernelB_J_W EQM [KernelB_J - $100]
KernelB_K_W EQM [KernelB_K - $100]

        mac CALC_REGS_AND_STORE
.OFFSET SET {1}
.TARGET SET {2}
        ldy [DO_GEMS_B + .OFFSET]
        jsr KernelB_UpdateRegs
        sty .TARGET
        endm

; Y=Gemini Sprite
; See if the current Gemini is g00. Allocate an RST to this Gemini if so
; processor flag Z is TRUE if this is RST.
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
; See if the current Gemini is g00. Allocate an RST to this Gemini if so
; processor flag Z is TRUE if this is RST.
KernelB_GenPhp: subroutine
    cpy #G01
    beq .start
    cpy #G11
    beq .start
    rts
    ; Current Gemini = $00
.start:
    ldx BuildKernelRST
    cpx #SENTINEL
    bne .set_else
    ; We have found the first (and only) RST on this line, set the marker var
    sty BuildKernelRST

    ; Set Z flag
    ldx #$00
.set_else
    rts

; Allocates build-time registers for a new Gemini sprite value.
; register Y = the storage opcode to write to the result
;
; BuildKernelGrp0, BuildKernelX, BuildKernelY are compared in that order.
; BuildKernelX, BuildKernelY are upgraded if not set.
; Y=Gemini Sprite
KernelB_UpdateRegs:
KernelA_UpdateRegs: subroutine

    ; If equal to GRP0, return nop
    ; FIXME GRP0 might not always be up to date (should update each entry?)
    ; FIXME GOTTA REVERSE THE GRAPHICS ALSO
    cpy RamKernelGrp0
    bne .op_start
    ; TODO if this is stx + NOP value, then register doesn't have to change as
    ; often in GEM1ASWITCH
    ldy #BC_NOP
    rts

.op_start:
    cpy BuildKernelX
    bne .op_else
    ldy #BC_STX
    rts
.op_else:
    cpy BuildKernelY
    bne .op_end
    ldy #BC_STY
    rts
.op_end:

.set_start:
    ldx BuildKernelX
    cpx #SENTINEL
    bne .set_else

    ; KA Missile opcode determination
DBG_CHECK_MISSILE_OPCODE:
    sty BuildKernelX
    ror BuildKernelX ; D0
    ror BuildKernelX ; D1
    ldx #BC_STX
    bcs [. + 4]
    ldx #BC_STY
    stx BuildKernelMissile

    ; Set the X operator
    sty BuildKernelX
    ldy #BC_STX
    rts
.set_else
    ldx BuildKernelY
    cpx #SENTINEL
    bne .set_end
    sty BuildKernelY
    ldy #BC_STY
    rts
.set_end:
    ; Failed all
    ASSERT_RUNTIME "0"
    rts


game_nibble_populate:
    lda $f100
    sta DebugKernelID

    lda shard_map
    ldy #1 ; gemini counter, starting at 1
gemini_builder:
    cpy #1 ; TODO top two bits of shard_map
    bne .no_vd0
.no_vd0:

    ; Nibble Kernel A
    NIBBLE_START_KERNEL gem_kernel_a_1, 40
        ldx #SENTINEL ; sentinel
        stx BuildKernelX
        stx BuildKernelY
        stx BuildKernelRST

        ; Gemini 1A
.K_1A:
        ldy [DO_GEMS_A + 0]
        jsr KernelA_GenReset
        NIBBLE_IF eq
            ; Special: Encoding RST0
            ; Rewrite lda RamKernelPF1 to be #immediate
            ldy #BC_LDA_IMM
            sty [KernelA_B - $100]
            ldy #%10100000
            sty [KernelA_B - $100 + 1]
            ; Store 1A in GRP0
            ldy [DO_GEMS_A + 1]
            sty BuildKernelGrp0
            sty RamKernelGrp0
            ; Gemini 1A is RESPx
            ldy #EMERALD_SP_RESET
            sty [KernelA_C - $100 + 1]
            ; Turn 3-cycle NOP into 4-cycle
            ldy #$14 ; TODO what is this
            sty [KernelA_D - $100]
        NIBBLE_ELSE
            ; Store 0A in GRP0
            ldy [DO_GEMS_A + 0]
            sty BuildKernelGrp0
            sty RamKernelGrp0

            ldy [DO_GEMS_A + 1]
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
                ldy #BC_STX ; Don't allocate
                .byte $F0, #5 ; beq +4
                ldy [DO_GEMS_A + 1]
                jsr KernelA_UpdateRegs
                sty RamKernelGemini1

                NIBBLE_WRITE KernelA_D_W, RamKernelGemini1, RamKernelGemini1Reg
            NIBBLE_END_IF
        NIBBLE_END_IF

        ; BuildKernelX, BuildKernelY are upgraded if not set
        ; Gemini 2A
.K_2A
        ldy [DO_GEMS_A + 2]
        jsr KernelA_GenReset
        NIBBLE_IF eq
            NIBBLE_WRITE KernelA_E_W + 1, #NOP_REG   ; NOP
            NIBBLE_WRITE KernelA_G_W + 1, #RESP1 ; RESET
        NIBBLE_ELSE
            ; Set opcode
            ldy [DO_GEMS_A + 2]
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

        ; Can't preserve Grp0 now
        ldy #SENTINEL
        sty RamKernelGrp0

        ; Gemini 3A
.K_3A:
        ldy [DO_GEMS_A + 3]
        jsr KernelA_GenReset
        NIBBLE_IF eq
            NIBBLE_WRITE KernelA_H_W + 1, #RESP1 ; RESET
        NIBBLE_ELSE
            ; Set opcode
            ldy [DO_GEMS_A + 3]
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
        ldx [DO_GEMS_A + 1]
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
            ldx [DO_GEMS_A + 4]
            stx BuildKernelVdel1
        NIBBLE_ELSE
            ldy [DO_GEMS_A + 4]
            jsr KernelA_UpdateRegs
            sty RamKernelGemini4

            NIBBLE_WRITE [KernelA_I_W + 0], #BC_PHP
            NIBBLE_WRITE [KernelA_J_W + 0], #BC_STA, #PF1
            NIBBLE_WRITE KernelA_K_W, RamKernelGemini4, #EMERALD_SP

            ; Set PHP
            NIBBLE_WRITE RamKernelPhpTarget, #RESP1
        NIBBLE_END_IF

        ; Gemini 5A
        ; TODO eventually...?

        ; Missile
        ldy DO_MISS_A
        NIBBLE_IF eq ; Disabled
            NIBBLE_WRITE [KernelA_F - $100], #BC_NOP
        NIBBLE_ELSE
            NIBBLE_WRITE [KernelA_F - $100], BuildKernelMissile
        NIBBLE_END_IF

        ; VD1
        NIBBLE_WRITE [KernelA_VDEL1 - $100], BuildKernelVdel1
        ; GRP0
        NIBBLE_WRITE [KernelA_VDEL0 - $100], BuildKernelGrp0
        ; X
        NIBBLE_WRITE RamKernelX, BuildKernelX
        ; Y
        NIBBLE_WRITE RamKernelY, BuildKernelY

        NIBBLE_WRITE RamPSByte, #$ff
    NIBBLE_END_KERNEL

    ; Nibble Kernel B
    NIBBLE_START_KERNEL gem_kernel_b, 40
        ldx #SENTINEL ; sentinel
        stx BuildKernelX
        stx BuildKernelY
        stx BuildKernelRST

        ; Php target default
        ldx #RESP1
        stx RamKernelPhpTarget

        ; Gemini 0B
        ldy [DO_GEMS_B + 0]
        sty BuildKernelGrp0
        sty RamKernelGrp0
        ; NIBBLE_WRITE KernelB_D_W, RamKernelGemini0

        ; Gemini 1B
        ldy [DO_GEMS_B + 1]
        jsr KernelA_UpdateRegs
        sty RamKernelGemini1
        NIBBLE_WRITE KernelB_D_W, RamKernelGemini1

        ; Gemini 2B
        ldy [DO_GEMS_B + 2]
        jsr KernelB_GenPhp
        NIBBLE_IF eq
            CALC_REGS_AND_STORE 3, RamKernelGemini3

            ; Write to PHP in 2B
            NIBBLE_WRITE RamKernelPhpTarget, #EMERALD_SP
            NIBBLE_WRITE [KernelB_E_W + 0], #BC_STY, #EMERALD_SP_RESET ; 2B
            NIBBLE_WRITE [KernelB_F_W + 1], #BC_PHP
            NIBBLE_WRITE [KernelB_G_W + 0], #BC_STA, #PF1
            NIBBLE_WRITE [KernelB_H_W + 0], RamKernelGemini3, #EMERALD_SP ; 3B

            ; Update Grp0
            ldy BuildKernelRST
            sty RamKernelGrp0
        NIBBLE_ELSE
            CALC_REGS_AND_STORE 2, RamKernelGemini2
            NIBBLE_WRITE KernelB_F_W, RamKernelGemini2, #EMERALD_SP
        NIBBLE_END_IF

        ; Gemini 3B
        ldy [DO_GEMS_B + 3]
        jsr KernelB_GenPhp
        NIBBLE_IF eq
            ; Write to PHP in 3B
            CALC_REGS_AND_STORE 2, RamKernelGemini2
            NIBBLE_WRITE RamKernelPhpTarget, #EMERALD_SP
            NIBBLE_WRITE [KernelB_E_W + 0], #BC_STY, #EMERALD_SP_RESET
            NIBBLE_WRITE [KernelB_F_W + 1], RamKernelGemini2, #EMERALD_SP ; 2B
            NIBBLE_WRITE [KernelB_G_W + 1], #BC_STA, #PF1
            NIBBLE_WRITE [KernelB_H_W + 1], #BC_PHP ; 3B
            
            ; Update Grp0
            ldy BuildKernelRST
            sty RamKernelGrp0
        NIBBLE_ELSE
            CALC_REGS_AND_STORE 3, RamKernelGemini3
            NIBBLE_WRITE KernelB_H_W, RamKernelGemini3, #EMERALD_SP
        NIBBLE_END_IF

        ; Write out PHP flag comparison
        ldy BuildKernelRST
        cpy #G01
        NIBBLE_IF eq
            NIBBLE_WRITE [KernelB_C - $100 + 1], #RamFFByte
        NIBBLE_ELSE
            NIBBLE_WRITE [KernelB_C - $100 + 1], #RamPF1Value
        NIBBLE_END_IF

        ; Missile
        ; ldy DO_MISS_B
        ; NIBBLE_IF eq ; Disabled
            ; NIBBLE_WRITE [KernelB_K - $100], #BC_STA
        ; NIBBLE_ELSE
        ;     NIBBLE_WRITE [KernelB_K - $100], BuildKernelMissile
        ; NIBBLE_END_IF

        ; Gemini 4B
        ldy [DO_GEMS_B + 4]
        jsr KernelA_UpdateRegs
        sty RamKernelGemini4
        NIBBLE_WRITE KernelB_J_W, RamKernelGemini4

        ; TODO if no PHP, rewrite previous section:
        ; NIBBLE_IF cs
        ;     ; Write to PHP in reset command
        ;     NIBBLE_WRITE [KernelB_E_W + 0], #BC_PHP
        ;     NIBBLE_WRITE [KernelB_F_W + 0], #BC_STY, #EMERALD_SP ; 2B
        ;     NIBBLE_WRITE [KernelB_G_W + 0], #BC_STA, #PF1
        ;     NIBBLE_WRITE [KernelB_H_W + 0], #BC_STY, #EMERALD_SP ; 3B
        ; NIBBLE_END_IF

        ; Make adjustments for sprites.
        ror BuildKernelGrp0
        ror BuildKernelX
        ror BuildKernelY

        ; ; VD1
        ; NIBBLE_WRITE [KernelB_VDEL1 - $100], BuildKernelVdel1
        ; GRP0
        NIBBLE_WRITE [KernelB_VDEL0 - $100], BuildKernelGrp0
        ; X
        NIBBLE_WRITE RamKernelX, BuildKernelX
        ; Y
        NIBBLE_WRITE RamKernelY, BuildKernelY

        NIBBLE_WRITE RamPSByte, #$00

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
    rts


; Populate Gemini array from level_for_game

    mac GEMINI_POPULATE
.TARGET SET {1}
    lda RamNibbleTemp
    and #%00000011
    tay
    lda GEMINI_LOOKUP,y
    sta .TARGET
    endm

    mac GEMINI_POPULATE_MISSILE
.TARGET SET {1}
    lda RamNibbleTemp
    and #%00000001
    sta .TARGET
    endm

    align 256

gemini_populate:
    ldx level_for_game + 3
    stx RamNibbleTemp
    GEMINI_POPULATE DO_GEMS_B + 5
    ror RamNibbleTemp
    ror RamNibbleTemp
    GEMINI_POPULATE DO_GEMS_A + 5
    ror RamNibbleTemp
    ror RamNibbleTemp
    GEMINI_POPULATE DO_GEMS_B + 4
    ror RamNibbleTemp
    ror RamNibbleTemp
    GEMINI_POPULATE DO_GEMS_A + 4
    ror RamNibbleTemp
    ror RamNibbleTemp

    ldx level_for_game + 2
    stx RamNibbleTemp
    GEMINI_POPULATE_MISSILE DO_MISS_B
    ror RamNibbleTemp
    GEMINI_POPULATE DO_GEMS_B + 3
    ror RamNibbleTemp
    ror RamNibbleTemp
    GEMINI_POPULATE DO_GEMS_A + 3
    ror RamNibbleTemp
    ror RamNibbleTemp
    GEMINI_POPULATE DO_GEMS_B + 2
    ror RamNibbleTemp
    ror RamNibbleTemp

    ror RamNibbleTemp
    ldx level_for_game + 1
    stx RamNibbleTemp
    rol RamNibbleTemp
    GEMINI_POPULATE DO_GEMS_A + 2

    ldx level_for_game + 1
    stx RamNibbleTemp
    ror RamNibbleTemp
    GEMINI_POPULATE_MISSILE DO_MISS_A
    ror RamNibbleTemp
    GEMINI_POPULATE DO_GEMS_B + 1
    ror RamNibbleTemp
    ror RamNibbleTemp
    GEMINI_POPULATE DO_GEMS_A + 1
    ror RamNibbleTemp
    ror RamNibbleTemp
    GEMINI_POPULATE DO_GEMS_B + 0
    ror RamNibbleTemp
    ror RamNibbleTemp
    
    ldx level_for_game + 0
    stx RamNibbleTemp
    GEMINI_POPULATE DO_GEMS_A + 0
    ror RamNibbleTemp
    ror RamNibbleTemp

    rts
gemini_populate_end:

    align 16

GEMINI_LOOKUP:
    .byte G00, G01, G10, G11

SHARD_LUT_RF1:
    .byte #0
SHARD_LUT_VD1:
    .byte #0
