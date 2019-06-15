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

NOP_REG = Temp ; TODO is there a better reg to write to with NOP effects

    ; See if the current Gemini is g00. Allocate an RST to this Gemini if so
    ; processor flag Z is TRUE if this is RST.
    ; Args:
    ;   Y = Gemini Sprite
KernelA_GenReset: subroutine
    cmp #$00
    beq .start
    rts
    ; Current Gemini = $00
.start:
    NIBBLE_RAM_LOAD lda, BuildKernelRST
    cmp #SENTINEL
    bne .set_else
    ; We have found the first (and only) RST on this line, set the marker var
    lda #$ff
    NIBBLE_RAM_STORE sta, BuildKernelRST
.set_else
    lda #$00
    rts

; A=Gemini Sprite
; See if the current Gemini is g01 or g11. Allocate a PHP opcode to this Gemini
; Returns:
;    processor flag Z is TRUE if this is RST.
KernelB_GenPhp: subroutine
    cmp #G01
    beq .start
    cmp #G11
    beq .start
    rts
    ; Current Gemini = $00
.start:
    ldx BuildKernelRST
    cpx #SENTINEL
    bne .set_else
    ; We have found the first (and only) RST on this line, set the marker var
    sta BuildKernelRST

    ; Set Z flag
    lda #$00
.set_else
    rts

; Allocates build-time registers for a new Gemini sprite value.
;
; NibbleGrp0, NibbleX, NibbleY are compared in that order.
; NibbleX, NibbleY are upgraded if not set.
; A=Gemini Sprite
; returns A = the storage opcode to write to the result
Kernel_UpdateRegs: subroutine

    ; If equal to GRP0, return nop
    ; FIXME GRP0 might not always be up to date (should update each entry?)
    ; FIXME GOTTA REVERSE THE GRAPHICS ALSO
    cmp BuildNibbleGrp0
    bne .op_start
    ; TODO if this is stx + NOP value, then register doesn't have to change as
    ; often in GEM1ASWITCH
    lda #BC_NOP
    rts

.op_start:
    cmp BuildNibbleX
    bne .op_else
    lda #BC_STX
    rts
.op_else:
    cmp BuildNibbleY
    bne .op_end
    lda #BC_STY
    rts
.op_end:

.set_start:
    ldx BuildNibbleX
    cpx #SENTINEL
    bne .set_else

    ; KA Missile opcode determination
; DBG_CHECK_MISSILE_OPCODE:
;     sty NibbleX
;     ror NibbleX ; D0
;     ror NibbleX ; D1
;     ldx #BC_STX
;     bcs [. + 4]
;     ldx #BC_STY
;     stx NibbleMissile

    ; Set the X operator
    NIBBLE_RAM_STORE sta, NibbleX
    sta BuildNibbleX ; save local value
    lda #BC_STX
    rts
.set_else
    ldx BuildNibbleY
    cpx #SENTINEL
    bne .set_end
    NIBBLE_RAM_STORE sta, NibbleY
    sta BuildNibbleY ; save local value
    lda #BC_STY
    rts
.set_end:
    ; Failed all
    ASSERT_RUNTIME "0"

    brk

    ; Fallback
    lda #BC_STX
    rts

    ; Populate the Nibble kernel values for the current row.
    ; Args:
    ;   Y = row index
GameNibblePopulate: subroutine
    ; lda $f100
    ; sta DebugKernelID

    lda shard_map
    ldx #1 ; gemini counter, starting at 1
gemini_builder: subroutine
    cpx #1 ; TODO top two bits of shard_map
    bne .no_vd0
.no_vd0:

    ; Nibble Kernel A
    NIBBLE_START_KERNEL gem_kernel_a_1, 40
        NIBBLE_VAR NibbleGemini1
        NIBBLE_VAR NibbleGemini1Reg
        NIBBLE_VAR NibbleGemini2
        NIBBLE_VAR NibbleGemini2Reg
        NIBBLE_VAR NibbleGemini3
        NIBBLE_VAR NibbleGemini3Reg
        ; NIBBLE_VAR NibbleGemini4
        NIBBLE_VAR NibbleMissile
        ; NIBBLE_VAR NibbleVdel1
        NIBBLE_VAR NibbleGrp0
        NIBBLE_VAR NibbleX
        NIBBLE_VAR NibbleY

        lda #SENTINEL ; sentinel
        sta BuildKernelRST
        sta BuildNibbleX
        NIBBLE_VAR_STY NibbleX
        sta BuildNibbleY
        NIBBLE_VAR_STY NibbleY

        ; FIXME don't hard code this?
        lda #BC_STX
        NIBBLE_VAR_STY NibbleMissile

        ; Gemini 1A
.K_1A:
        lda [DO_GEMS_A + 0]
        jsr KernelA_GenReset
        NIBBLE_IF eq
            ; Special: Encoding RST0
            NIBBLE_WRITE_IMM [KernelA_B_W + 0], #BC_LDA_IMM
            NIBBLE_WRITE_IMM [KernelA_B_W + 1], #%10100000
            ; Store 1A in GRP0
            lda [DO_GEMS_A + 1]
            NIBBLE_VAR_STY NibbleGrp0
            sta BuildNibbleGrp0 ; For comparisons
            ; Gemini 1A is RESPx
            NIBBLE_WRITE_IMM [KernelA_C_W + 1], #EMERALD_SP_RESET
            ; Turn 3-cycle NOP into 4-cycle
            NIBBLE_WRITE_IMM [KernelA_D_W + 0], #$14 ; NOP zpx (4 cycles)
        NIBBLE_ELSE
            ; Store 0A in GRP0
            lda [DO_GEMS_A + 0]
            NIBBLE_VAR_STY NibbleGrp0
            sta BuildNibbleGrp0

            lda [DO_GEMS_A + 1]
            jsr KernelA_GenReset
            NIBBLE_IF eq
                ; GEM1ASWITCH
                NIBBLE_WRITE_IMM [KernelA_D_W + 0], #BC_STX
                NIBBLE_WRITE_IMM [KernelA_D_W + 1], #RESP1 ; RESET
            NIBBLE_ELSE
                ; Calculate the 1A value
                lda SHARD_LUT_RF1
                cmp #1
                .byte $D0, #3 ; bne +3
                lda #RESP1
                .byte $2C ; .bit (ABS)
                lda #GRP1
                NIBBLE_VAR_STY NibbleGemini1Reg

                ; Set opcode
                lda SHARD_LUT_RF1
                cmp #1
                lda #BC_STX ; Don't allocate
                .byte $F0, #5 ; beq +4
                lda [DO_GEMS_A + 1]
                jsr Kernel_UpdateRegs
                NIBBLE_VAR_STY NibbleGemini1

                NIBBLE_WRITE_VAR [KernelA_D_W + 0], NibbleGemini1
                NIBBLE_WRITE_VAR [KernelA_D_W + 1], NibbleGemini1Reg
            NIBBLE_END_IF
        NIBBLE_END_IF

        ; Stop reusing GRP0 by trashing our temp value
        lda #SENTINEL
        sta BuildNibbleGrp0

        ; NibbleX, NibbleY are upgraded if not set
        ; Gemini 2A
.K_2A
        lda [DO_GEMS_A + 2]
        jsr KernelA_GenReset
        NIBBLE_IF eq
            NIBBLE_WRITE_IMM [KernelA_E_W + 1], #NOP_REG   ; NOP
            NIBBLE_WRITE_IMM [KernelA_G_W + 1], #RESP1 ; RESET
        NIBBLE_ELSE
            ; Set opcode
            lda [DO_GEMS_A + 2]
            jsr Kernel_UpdateRegs
            NIBBLE_VAR_STY NibbleGemini2

            ; Set opcode target
            lda SHARD_LUT_RF1
            cmp #2
            .byte $D0, #3 ; bne +3
            lda #RESP1
            .byte $2C ; .bit (ABS)
            lda #GRP1
            NIBBLE_VAR_STY NibbleGemini2Reg

            NIBBLE_WRITE_IMM [KernelA_E_W + 1], #RESP1
            NIBBLE_WRITE_VAR [KernelA_G_W + 0], NibbleGemini2
            NIBBLE_WRITE_VAR [KernelA_G_W + 1], NibbleGemini2Reg ; STX
        NIBBLE_END_IF

        ; Gemini 3A
.K_3A:
        lda [DO_GEMS_A + 3]
        jsr KernelA_GenReset
        NIBBLE_IF eq
            NIBBLE_WRITE_IMM [KernelA_H_W + 1], #RESP1 ; RESET
        NIBBLE_ELSE
            ; Set opcode
            lda [DO_GEMS_A + 3]
            jsr Kernel_UpdateRegs
            NIBBLE_VAR_STY NibbleGemini3

            ; Set opcode target
            lda SHARD_LUT_RF1
            cpy #3
            .byte $D0, #3 ; bne +3
            lda #RESP1
            .byte $2C ; .bit (ABS)
            lda #GRP1
            NIBBLE_VAR_STY NibbleGemini3Reg

            NIBBLE_WRITE_VAR [KernelA_H_W + 0], NibbleGemini3
            NIBBLE_WRITE_VAR [KernelA_H_W + 1], NibbleGemini3Reg
        NIBBLE_END_IF
    NIBBLE_END_KERNEL

    NIBBLE_START_KERNEL gem_kernel_a_2, 40
        ; NIBBLE_VAR NibbleGemini1
        ; NIBBLE_VAR NibbleGemini1Reg
        ; NIBBLE_VAR NibbleGemini2
        ; NIBBLE_VAR NibbleGemini2Reg
        ; NIBBLE_VAR NibbleGemini3
        ; NIBBLE_VAR NibbleGemini3Reg
        NIBBLE_VAR NibbleGemini4
        NIBBLE_VAR NibbleMissile
        NIBBLE_VAR NibbleVdel1
        NIBBLE_VAR NibbleGrp0
        NIBBLE_VAR NibblePhp

        ; VD1 default
        lda [DO_GEMS_A + 1]
        NIBBLE_VAR_STY NibbleVdel1

        ; Gemini 4A 
        lda SHARD_LUT_VD1
        cmp #4
        NIBBLE_IF ne
            NIBBLE_WRITE_IMM [KernelA_I_W + 0], #BC_STA, #EMERALD_SP_RESET
            NIBBLE_WRITE_IMM [KernelA_J_W + 1], #BC_STA, #PF1
            NIBBLE_WRITE_IMM [KernelA_K_W + 1], #BC_PHP

            ; Set PHP
            lda #VDELP1
            NIBBLE_VAR_STY NibblePhp

            ; Update VDEL1
            lda [DO_GEMS_A + 4]
            NIBBLE_VAR_STY NibbleVdel1
        NIBBLE_ELSE
            lda [DO_GEMS_A + 4]
            jsr Kernel_UpdateRegs
            NIBBLE_VAR_STY NibbleGemini4

            NIBBLE_WRITE_IMM [KernelA_I_W + 0], #BC_PHP
            NIBBLE_WRITE_IMM [KernelA_J_W + 0], #BC_STA, #PF1
            NIBBLE_WRITE_VAR [KernelA_K_W + 0], NibbleGemini4
            NIBBLE_WRITE_IMM [KernelA_K_W + 1], #EMERALD_SP

            ; Set PHP
            lda #RESP1
            NIBBLE_VAR_STY NibblePhp
        NIBBLE_END_IF

        ; Gemini 5A
        ; TODO eventually...?

        ; Missile
        lda DO_MISS_A
        ; FIXME Why doesn't this branch compile?
        ; bne .+4
        ; ldx #BC_NOP
        ; stx NibbleMissile
        NIBBLE_WRITE_VAR [KernelA_F_W + 0], NibbleMissile

        ; VD1
        NIBBLE_WRITE_VAR [KernelA_VDEL1_W + 0], NibbleVdel1
        ; GRP0
        NIBBLE_WRITE_VAR [KernelA_VDEL0_W + 0], NibbleGrp0

        lda #$ff
        NIBBLE_RAM_STORE sta, NibblePs
    NIBBLE_END_KERNEL

    ; Nibble Kernel B
    NIBBLE_START_KERNEL gem_kernel_b_1, 40
        ; NIBBLE_VAR NibbleGemini1
        ; NIBBLE_VAR NibbleGemini1Reg
        NIBBLE_VAR NibbleGemini2
        ; NIBBLE_VAR NibbleGemini2Reg
        NIBBLE_VAR NibbleGemini3
        ; NIBBLE_VAR NibbleGemini3Reg
        ; NIBBLE_VAR NibbleGemini4
        ; NIBBLE_VAR NibbleMissile
        ; NIBBLE_VAR NibbleVdel1
        NIBBLE_VAR NibbleGrp0

        lda #SENTINEL ; sentinel
        sta BuildKernelRST
        sta BuildNibbleX
        ; NIBBLE_VAR_STY NibbleX
        sta BuildNibbleY
        ; NIBBLE_VAR_STY NibbleY

        ; Php target default
        lda #RESP1
        NIBBLE_RAM_STORE sta, NibblePhp

        ; Gemini 0B
        lda [DO_GEMS_B + 0]
        NIBBLE_VAR_STY NibbleGrp0
        sta BuildNibbleGrp0
        ; NIBBLE_WRITE_IMM KernelB_D_W, RamKernelGemini0

        ; Gemini 1B
        lda [DO_GEMS_B + 1]
        jsr Kernel_UpdateRegs
        NIBBLE_RAM_STORE sta, NibbleGemini1

        ; Gemini 2B
        lda [DO_GEMS_B + 2]
        jsr KernelB_GenPhp
        NIBBLE_IF eq
            CALC_REGS_AND_STORE 3, NibbleGemini3

            ; Write to PHP in 2B
            lda #EMERALD_SP
            NIBBLE_RAM_STORE sta, NibblePhp
            NIBBLE_WRITE_IMM [KernelB_E_W + 0], #BC_STY
            NIBBLE_WRITE_IMM [KernelB_E_W + 1], #EMERALD_SP_RESET ; 2B
            NIBBLE_WRITE_IMM [KernelB_F_W + 1], #BC_PHP
            NIBBLE_WRITE_IMM [KernelB_G_W + 0], #BC_STA
            NIBBLE_WRITE_IMM [KernelB_G_W + 1], #PF1
            NIBBLE_WRITE_VAR [KernelB_H_W + 0], NibbleGemini3
            NIBBLE_WRITE_IMM [KernelB_H_W + 1], #EMERALD_SP ; 3B

            ; Update Grp0
            lda BuildKernelRST
            sta BuildNibbleGrp0
        NIBBLE_ELSE
            ; Gemini 3B
            lda [DO_GEMS_B + 3]
            jsr KernelB_GenPhp
            NIBBLE_IF eq
                ; Write to PHP in 3B
                CALC_REGS_AND_STORE 2, NibbleGemini2
                lda #EMERALD_SP
                NIBBLE_RAM_STORE sta, NibblePhp
                NIBBLE_WRITE_IMM [KernelB_E_W + 0], #BC_STY
                NIBBLE_WRITE_IMM [KernelB_E_W + 1], #EMERALD_SP_RESET
                NIBBLE_WRITE_VAR [KernelB_F_W + 1], NibbleGemini2
                NIBBLE_WRITE_IMM [KernelB_F_W + 2], #EMERALD_SP ; 2B
                NIBBLE_WRITE_IMM [KernelB_G_W + 1], #BC_STA
                NIBBLE_WRITE_IMM [KernelB_G_W + 2], #PF1
                NIBBLE_WRITE_IMM [KernelB_H_W + 1], #BC_PHP ; 3B
                
                ; Update Grp0
                ; NIBBLE_RAM_LOAD lda, BuildKernelRST
                lda [DO_GEMS_B + 3]
                sta BuildNibbleGrp0
            NIBBLE_ELSE
                ; Update 2B
                CALC_REGS_AND_STORE 2, NibbleGemini2
                NIBBLE_WRITE_VAR [KernelB_F_W + 0], NibbleGemini2
                NIBBLE_WRITE_IMM [KernelB_F_W + 1], #EMERALD_SP

                ; Update 3B
                CALC_REGS_AND_STORE 3, NibbleGemini3
                NIBBLE_WRITE_VAR [KernelB_H_W + 0], NibbleGemini3
                NIBBLE_WRITE_IMM [KernelB_H_W + 1], #EMERALD_SP
            NIBBLE_END_IF
        NIBBLE_END_IF

    NIBBLE_END_KERNEL

    ; Nibble Kernel B
    NIBBLE_START_KERNEL gem_kernel_b_2, 40
        NIBBLE_VAR NibbleGemini1
        ; NIBBLE_VAR NibbleGemini1Reg
        ; NIBBLE_VAR NibbleGemini2
        ; NIBBLE_VAR NibbleGemini2Reg
        ; NIBBLE_VAR NibbleGemini3
        ; NIBBLE_VAR NibbleGemini3Reg
        NIBBLE_VAR NibbleGemini4
        ; NIBBLE_VAR NibbleMissile
        ; NIBBLE_VAR NibbleVdel1
        NIBBLE_VAR NibbleGrp0

        ; Gemini 1B
        NIBBLE_WRITE_VAR KernelB_D_W, NibbleGemini1

        ; Write out PHP flag comparison
        lda BuildKernelRST
        cmp #G01
        NIBBLE_IF eq
            NIBBLE_WRITE_IMM [KernelB_C_W + 1], #RamFFByte
            lda BuildKernelRST
            sta BuildNibbleGrp0
        NIBBLE_ELSE
            NIBBLE_WRITE_IMM [KernelB_C_W + 1], #RamPF1Value
        NIBBLE_END_IF

        ; Missile
        ; ldy DO_MISS_B
        ; NIBBLE_IF eq ; Disabled
            ; NIBBLE_WRITE_IMM [KernelB_K_W + 0], #BC_STA
        ; NIBBLE_ELSE
        ;     NIBBLE_WRITE_IMM [KernelB_K_W + 0], NibbleMissile
        ; NIBBLE_END_IF

        ; Gemini 4B
        CALC_REGS_AND_STORE 4, NibbleGemini4
        NIBBLE_WRITE_VAR KernelB_J_W, NibbleGemini4

        ; TODO if no PHP, rewrite previous section:
        ; NIBBLE_IF cs
        ;     ; Write to PHP in reset command
        ;     NIBBLE_WRITE_IMM [KernelB_E_W + 0], #BC_PHP
        ;     NIBBLE_WRITE_IMM [KernelB_F_W + 0], #BC_STY, #EMERALD_SP ; 2B
        ;     NIBBLE_WRITE_IMM [KernelB_G_W + 0], #BC_STA, #PF1
        ;     NIBBLE_WRITE_IMM [KernelB_H_W + 0], #BC_STY, #EMERALD_SP ; 3B
        ; NIBBLE_END_IF

        ; Make adjustments for sprites.
        clc
        lda BuildNibbleGrp0
        ror
        NIBBLE_RAM_STORE sta, NibbleGrp0
        lda BuildNibbleX
        ror
        NIBBLE_RAM_STORE sta, NibbleX
        lda BuildNibbleY
        ror
        NIBBLE_RAM_STORE sta, NibbleY

        ; ; VD1
        ; NIBBLE_WRITE_IMM [KernelB_VDEL1_W + 0], NibbleVdel1
        ; GRP0
        NIBBLE_WRITE_VAR [KernelB_VDEL0_W + 0], NibbleGrp0

        lda #$00
        NIBBLE_RAM_STORE sta, NibblePs

    NIBBLE_END_KERNEL

    ; TODO do this for all rows
DBG_NIBBLE_BUILD: subroutine
    ldx CBSRAM_KERNEL_READ_ID
    cpx #$a
    beq [. + 5]
    jmp .kernel_b 
.kernel_a:
    NIBBLE_gem_kernel_a_1_BUILD ; TODO can this be implied
    lda RamNibbleBuildState
    NIBBLE_RAM_STORE sta, NibbleVar1
    NIBBLE_gem_kernel_a_2_BUILD ; TODO can this be implied
    lda RamNibbleBuildState
    NIBBLE_RAM_STORE sta, NibbleVar2
    jmp .next
.kernel_b:
DBG_K:
    NIBBLE_gem_kernel_b_1_BUILD ; TODO can this be implied
    lda RamNibbleBuildState
    NIBBLE_RAM_STORE sta, NibbleVar1
    NIBBLE_gem_kernel_b_2_BUILD ; TODO can this be implied
    lda RamNibbleBuildState
    NIBBLE_RAM_STORE sta, NibbleVar2
.next:
    rts
    
    
; NibbleCopyToRam: subroutine
;     ; Copy out
;     ldx #00
;     ldy #$00
; .loop:
;     lda NIBBLE_VAR_START,y
;     sta CBSRAM_NIBBLE_WRITE,y
;     stx NIBBLE_VAR_START,y
;     iny
;     cpy #NIBBLE_VAR_COUNT
;     bne .loop
;     rts

; NibbleCopyFromRam: subroutine
; .INDEX SET 0
;     REPEAT NIBBLE_VAR_COUNT
;         lda [CBSRAM_NIBBLE_READ + .INDEX]
;         sta [NIBBLE_VAR_START + .INDEX]
; .INDEX SET .INDEX + 1
;     REPEND
;     rts

    ; Evaluate the kernel.
    ; TODO move this into the row kernel
GameNibbleRun: subroutine
    ; Row 0.
    ldy #0

    ; Select kernel A or B.
    ldx CBSRAM_KERNEL_READ_ID
    cpx #$a
    beq [. + 5]
    jmp .kernel_b
.kernel_a:
    NIBBLE_RAM_LOAD lda, NibbleVar1
    NIBBLE_gem_kernel_a_1
    NIBBLE_RAM_LOAD lda, NibbleVar2
    NIBBLE_gem_kernel_a_2
    jmp .next
.kernel_b:
    NIBBLE_RAM_LOAD lda, NibbleVar1
    NIBBLE_gem_kernel_b_1
    NIBBLE_RAM_LOAD lda, NibbleVar2
    NIBBLE_gem_kernel_b_2
.next:
    rts


; Populate Gemini array from level_for_game

    mac GEMINI_POPULATE
.TARGET SET {1}
    ldx #%00000011
    .byte $cb, $00 ; axs #0 : x = a&x - #0
    ldy GEMINI_LOOKUP,x
    sty .TARGET
    endm

    mac GEMINI_POPULATE_MISSILE
.TARGET SET {1}
    ldx #%00000001
    sax .TARGET
    endm

    align 256

GeminiPopulate: subroutine
    lda level_for_game + 3
    GEMINI_POPULATE DO_GEMS_B + 5
    ror
    ror
    GEMINI_POPULATE DO_GEMS_A + 5
    ror
    ror
    GEMINI_POPULATE DO_GEMS_B + 4
    ror
    ror
    GEMINI_POPULATE DO_GEMS_A + 4
    ; ror
    ; ror

    lda level_for_game + 2
    GEMINI_POPULATE_MISSILE DO_MISS_B
    ror
    GEMINI_POPULATE DO_GEMS_B + 3
    ror
    ror
    GEMINI_POPULATE DO_GEMS_A + 3
    ror
    ror
    GEMINI_POPULATE DO_GEMS_B + 2
    ror
    ror

    ; Join last bit and first bit
    ror
    lda level_for_game + 1
    rol
    GEMINI_POPULATE DO_GEMS_A + 2

    lda level_for_game + 1
    ror
    GEMINI_POPULATE_MISSILE DO_MISS_A
    ror
    GEMINI_POPULATE DO_GEMS_B + 1
    ror
    ror
    GEMINI_POPULATE DO_GEMS_A + 1
    ror
    ror
    GEMINI_POPULATE DO_GEMS_B + 0
    ; ror
    ; ror
    
    lda level_for_game + 0
    GEMINI_POPULATE DO_GEMS_A + 0
    ; ror
    ; ror

    rts
gemini_populate_end:

; FIXME this should be deleted
GeminiPopulateFull: subroutine
    lda #%11111111
    GEMINI_POPULATE DO_GEMS_B + 5
    ror
    ror
    GEMINI_POPULATE DO_GEMS_A + 5
    ror
    ror
    GEMINI_POPULATE DO_GEMS_B + 4
    ror
    ror
    GEMINI_POPULATE DO_GEMS_A + 4
    ; ror
    ; ror

    lda #%11111111
    GEMINI_POPULATE_MISSILE DO_MISS_B
    ror
    GEMINI_POPULATE DO_GEMS_B + 3
    ror
    ror
    GEMINI_POPULATE DO_GEMS_A + 3
    ror
    ror
    GEMINI_POPULATE DO_GEMS_B + 2
    ror
    ror

    ; Join last bit and first bit
    ror
    lda #%11111111
    rol
    GEMINI_POPULATE DO_GEMS_A + 2

    lda #%11111111
    ror
    GEMINI_POPULATE_MISSILE DO_MISS_A
    ror
    GEMINI_POPULATE DO_GEMS_B + 1
    ror
    ror
    GEMINI_POPULATE DO_GEMS_A + 1
    ror
    ror
    GEMINI_POPULATE DO_GEMS_B + 0
    ; ror
    ; ror
    
    lda #%11111111
    GEMINI_POPULATE DO_GEMS_A + 0
    ; ror
    ; ror

    rts


    align 16

GEMINI_LOOKUP:
    .byte G00, G01, G10, G11

SHARD_LUT_RF1:
    .byte #0
SHARD_LUT_VD1:
    .byte #0

