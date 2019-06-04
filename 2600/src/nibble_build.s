    MAC NIBBLE_gem_kernel_a_1_BUILD
    lda #0
    ; NIBBLE_VAR NibbleGemini4
    ; NIBBLE_VAR NibbleVdel1
    ldy #SENTINEL
    sty BuildKernelRST
    sty NibbleX
    sty NibbleY
    ; FIXME don't hard code this?
    ldy #BC_STX
    sty NibbleMissile
    ; Gemini 1A
.K_1A:
    ldy [DO_GEMS_A + 0]
    jsr KernelA_GenReset
.if_1:
    bne .else_1
    sec
    rol
    ; Special: Encoding RST0
    ; Store 1A in GRP0
    ldy [DO_GEMS_A + 1]
    sty NibbleGrp0
    sty RamKernelGrp0
    ; Gemini 1A is RESPx
    ; Turn 3-cycle NOP into 4-cycle
    rol
    jmp .endif_1
    ; [BIT DEPTH] #1 If-End @ 1
.else_1:
    clc
    rol
    ; Store 0A in GRP0
    ldy [DO_GEMS_A + 0]
    sty NibbleGrp0
    sty RamKernelGrp0
    ldy [DO_GEMS_A + 1]
    jsr KernelA_GenReset
.if_2:
    bne .else_2
    sec
    rol
    ; GEM1ASWITCH
    jmp .endif_2
    ; [BIT DEPTH] #2 If-End @ 2
.else_2:
    clc
    rol
    ; Calculate the 1A value
    ldy SHARD_LUT_RF1
    cpy #1
    .byte $D0, #3
    ldy #RESP1
    .byte $2C
    ldy #GRP1
    sty NibbleGemini1Reg
    ; Set opcode
    ldx SHARD_LUT_RF1
    cpx #1
    ldy #BC_STX
    .byte $F0, #5
    ldy [DO_GEMS_A + 1]
    jsr KernelA_UpdateRegs
    sty NibbleGemini1
    ; [BIT DEPTH] #2 *If-End @ 2
    ; [BIT DEPTH] #2 Else-End @ 2
.endif_2:
    ; [BIT DEPTH] #1 *If-End @ 1
    ; [BIT DEPTH] #2 Else-End @ 2
.endif_1:
    ; Stop preserving GRP0
    ldy #SENTINEL
    sty RamKernelGrp0
    ; NibbleX, NibbleY are upgraded if not set
    ; Gemini 2A
.K_2A
    ldy [DO_GEMS_A + 2]
    jsr KernelA_GenReset
.if_3:
    bne .else_3
    sec
    rol
    jmp .endif_3
    ; [BIT DEPTH] #3 If-End @ 3
.else_3:
    clc
    rol
    ; Set opcode
    ldy [DO_GEMS_A + 2]
    jsr KernelA_UpdateRegs
    sty NibbleGemini2
    ; Set opcode target
    ldy SHARD_LUT_RF1
    cpy #2
    .byte $D0, #3
    ldy #RESP1
    .byte $2C
    ldy #GRP1
    sty NibbleGemini2Reg
    ; [BIT DEPTH] #3 *If-End @ 3
    ; [BIT DEPTH] #3 Else-End @ 3
.endif_3:
    ; Gemini 3A
.K_3A:
    ldy [DO_GEMS_A + 3]
    jsr KernelA_GenReset
.if_4:
    bne .else_4
    sec
    rol
    jmp .endif_4
    ; [BIT DEPTH] #4 If-End @ 4
.else_4:
    clc
    rol
    ; Set opcode
    ldy [DO_GEMS_A + 3]
    jsr KernelA_UpdateRegs
    sty NibbleGemini3
    ; Set opcode target
    ldy SHARD_LUT_RF1
    cpy #3
    .byte $D0, #3
    ldy #RESP1
    .byte $2C
    ldy #GRP1
    sty NibbleGemini3Reg
    ; [BIT DEPTH] #4 *If-End @ 4
    ; [BIT DEPTH] #4 Else-End @ 4
.endif_4:
    ; [BIT DEPTH] Final: 4 (out of 8 bits)
    rol
    rol
    rol
    rol
    ENDM




    MAC NIBBLE_gem_kernel_a_2_BUILD
    lda #0
    ; NIBBLE_VAR NibbleGemini1
    ; NIBBLE_VAR NibbleGemini1Reg
    ; NIBBLE_VAR NibbleGemini2
    ; NIBBLE_VAR NibbleGemini2Reg
    ; NIBBLE_VAR NibbleGemini3
    ; NIBBLE_VAR NibbleGemini3Reg
    ; VD1 default
    ldy [DO_GEMS_A + 1]
    sty NibbleVdel1
    ; Gemini 4A
    ldx SHARD_LUT_VD1
    cpx #4
.if_1:
    beq .else_1
    sec
    rol
    ; Set PHP
    ldy #VDELP1
    sty NibblePhp
    ; Update VDEL1
    ldy [DO_GEMS_A + 4]
    sty NibbleVdel1
    jmp .endif_1
    ; [BIT DEPTH] #1 If-End @ 1
.else_1:
    clc
    rol
    ldy [DO_GEMS_A + 4]
    jsr KernelA_UpdateRegs
    sty NibbleGemini4
    ; Set PHP
    ldy #RESP1
    sty NibblePhp
    ; [BIT DEPTH] #1 *If-End @ 1
    ; [BIT DEPTH] #1 Else-End @ 1
.endif_1:
    ; Gemini 5A
    ; TODO eventually...?
    ; Missile
    ldy DO_MISS_A
    ; FIXME Why doesn't this branch compile?
    ; bne .+4
    ; ldx #BC_NOP
    ; stx NibbleMissile
    ; VD1
    ; GRP0
    ; [BIT DEPTH] Final: 1 (out of 8 bits)
    rol
    rol
    rol
    rol
    rol
    rol
    rol
    ENDM




    MAC NIBBLE_gem_kernel_b_1_BUILD
    lda #0
    ; NIBBLE_VAR NibbleGemini1
    ; NIBBLE_VAR NibbleGemini1Reg
    ; NIBBLE_VAR NibbleGemini2Reg
    ; NIBBLE_VAR NibbleGemini3Reg
    ; NIBBLE_VAR NibbleGemini4
    ; NIBBLE_VAR NibbleMissile
    ; NIBBLE_VAR NibbleVdel1
    ldx #SENTINEL
    stx NibbleX
    stx NibbleY
    stx BuildKernelRST
    ; Php target default
    ldy #RESP1
    sty NibblePhp
    ; Gemini 0B
    ldy [DO_GEMS_B + 0]
    sty NibbleGrp0
    sty RamKernelGrp0
    ; NIBBLE_WRITE_IMM KernelB_D_W, RamKernelGemini0
    ; Gemini 1B
    ldy [DO_GEMS_B + 1]
    jsr KernelA_UpdateRegs
    sty NibbleGemini1
    ; Gemini 2B
    ldy [DO_GEMS_B + 2]
    jsr KernelB_GenPhp
.if_1:
    bne .else_1
    sec
    rol
    CALC_REGS_AND_STORE 3, NibbleGemini3
    ; Write to PHP in 2B
    ldx #EMERALD_SP
    stx NibblePhp
    ; Update Grp0
    ldy BuildKernelRST
    sty RamKernelGrp0
    rol
    jmp .endif_1
    ; [BIT DEPTH] #1 If-End @ 1
.else_1:
    clc
    rol
    ; Gemini 3B
    ldy [DO_GEMS_B + 3]
    jsr KernelB_GenPhp
.if_2:
    bne .else_2
    sec
    rol
    ; Write to PHP in 3B
    CALC_REGS_AND_STORE 2, NibbleGemini2
    ldx #EMERALD_SP
    stx NibblePhp
     
    ; Update Grp0
    ldy BuildKernelRST
    sty RamKernelGrp0
    jmp .endif_2
    ; [BIT DEPTH] #2 If-End @ 2
.else_2:
    clc
    rol
    ; Update 2B
    CALC_REGS_AND_STORE 2, NibbleGemini2
    ; Update 3B
    CALC_REGS_AND_STORE 3, NibbleGemini3
    ; [BIT DEPTH] #2 *If-End @ 2
    ; [BIT DEPTH] #2 Else-End @ 2
.endif_2:
    ; [BIT DEPTH] #1 *If-End @ 1
    ; [BIT DEPTH] #2 Else-End @ 2
.endif_1:
    ; [BIT DEPTH] Final: 2 (out of 8 bits)
    rol
    rol
    rol
    rol
    rol
    rol
    ENDM




    MAC NIBBLE_gem_kernel_b_2_BUILD
    lda #0
    ; NIBBLE_VAR NibbleGemini1
    ; NIBBLE_VAR NibbleGemini1Reg
    ; NIBBLE_VAR NibbleGemini2
    ; NIBBLE_VAR NibbleGemini2Reg
    ; NIBBLE_VAR NibbleGemini3
    ; NIBBLE_VAR NibbleGemini3Reg
    ; NIBBLE_VAR NibbleMissile
    ; NIBBLE_VAR NibbleVdel1
    ; Gemini 1B
    ; Write out PHP flag comparison
    ldy BuildKernelRST
    cpy #G01
.if_1:
    bne .else_1
    sec
    rol
    jmp .endif_1
    ; [BIT DEPTH] #1 If-End @ 1
.else_1:
    clc
    rol
    ; [BIT DEPTH] #1 *If-End @ 1
    ; [BIT DEPTH] #1 Else-End @ 1
.endif_1:
    ; Missile
    ; ldy DO_MISS_B
    ; NIBBLE_IF eq
    ; NIBBLE_WRITE_IMM [KernelB_K - $100], #BC_STA
    ; NIBBLE_ELSE
    ;     NIBBLE_WRITE_IMM [KernelB_K - $100], NibbleMissile
    ; NIBBLE_END_IF
    ; Gemini 4B
    ldy [DO_GEMS_B + 4]
    jsr KernelA_UpdateRegs
    sty NibbleGemini4
    ; TODO if no PHP, rewrite previous section:
    ; NIBBLE_IF cs
    ;
    ;     NIBBLE_WRITE_IMM [KernelB_E_W + 0], #BC_PHP
    ;     NIBBLE_WRITE_IMM [KernelB_F_W + 0], #BC_STY, #EMERALD_SP
    ;     NIBBLE_WRITE_IMM [KernelB_G_W + 0], #BC_STA, #PF1
    ;     NIBBLE_WRITE_IMM [KernelB_H_W + 0], #BC_STY, #EMERALD_SP
    ; NIBBLE_END_IF
    ; Make adjustments for sprites.
    ror NibbleGrp0
    ror NibbleX
    ror NibbleY
    ;
    ; NIBBLE_WRITE_IMM [KernelB_VDEL1 - $100], NibbleVdel1
    ; GRP0
    ; [BIT DEPTH] Final: 1 (out of 8 bits)
    rol
    rol
    rol
    rol
    rol
    rol
    rol
    ENDM




