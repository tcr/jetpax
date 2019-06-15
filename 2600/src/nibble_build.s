    MAC NIBBLE_gem_kernel_a_1_BUILD
    lda #0
    sta RamNibbleBuildState
    ; NIBBLE_VAR NibbleGemini4
    ; NIBBLE_VAR NibbleVdel1
    lda #SENTINEL
    sta BuildKernelRST
    sta BuildNibbleX
    NIBBLE_RAM_STORE sta, NibbleX
    sta BuildNibbleY
    NIBBLE_RAM_STORE sta, NibbleY
    ; FIXME don't hard code this?
    lda #BC_STX
    NIBBLE_RAM_STORE sta, NibbleMissile
    ; Gemini 1A
.K_1A:
    lda [DO_GEMS_A + 0]
    jsr KernelA_GenReset
.if_1:
    bne .else_1
    sec
    rol RamNibbleBuildState
    ; Store 1A in GRP0
    lda [DO_GEMS_A + 1]
    NIBBLE_RAM_STORE sta, NibbleGrp0
    sta BuildNibbleGrp0
    ; Special: Encoding RST0
    ; We make B two cycles, store
    ; Gemini 1A is RESPx
    ; Turn 3-cycle NOP into 4-cycle
    rol RamNibbleBuildState
    jmp .endif_1
    ; [BIT DEPTH] #1 If-End @ 1
.else_1:
    clc
    rol RamNibbleBuildState
    ; Store 0A in GRP0
    lda [DO_GEMS_A + 0]
    NIBBLE_RAM_STORE sta, NibbleGrp0
    sta BuildNibbleGrp0
    lda [DO_GEMS_A + 1]
    jsr KernelA_GenReset
.if_2:
    bne .else_2
    sec
    rol RamNibbleBuildState
    ; GEM1ASWITCH
    jmp .endif_2
    ; [BIT DEPTH] #2 If-End @ 2
.else_2:
    clc
    rol RamNibbleBuildState
    ; Calculate the 1A value
    lda SHARD_LUT_RF1
    cmp #1
    .byte $D0, #3
    lda #RESP1
    .byte $2C
    lda #GRP1
    NIBBLE_RAM_STORE sta, NibbleGemini1Reg
    ; Set opcode
    lda SHARD_LUT_RF1
    cmp #1
    lda #BC_STX
    .byte $F0, #5
    lda [DO_GEMS_A + 1]
    jsr Kernel_UpdateRegs
    NIBBLE_RAM_STORE sta, NibbleGemini1
    ; [BIT DEPTH] #2 *If-End @ 2
    ; [BIT DEPTH] #2 Else-End @ 2
.endif_2:
    ; [BIT DEPTH] #1 *If-End @ 1
    ; [BIT DEPTH] #2 Else-End @ 2
.endif_1:
    ; Stop reusing GRP0 by trashing our temp value
    lda #SENTINEL
    sta BuildNibbleGrp0
    ; NibbleX, NibbleY are upgraded if not set
    ; Gemini 2A
.K_2A
    lda [DO_GEMS_A + 2]
    jsr KernelA_GenReset
.if_3:
    bne .else_3
    sec
    rol RamNibbleBuildState
    jmp .endif_3
    ; [BIT DEPTH] #3 If-End @ 3
.else_3:
    clc
    rol RamNibbleBuildState
    ; Set opcode
    lda [DO_GEMS_A + 2]
    jsr Kernel_UpdateRegs
    NIBBLE_RAM_STORE sta, NibbleGemini2
    ; Set opcode target
    lda SHARD_LUT_RF1
    cmp #2
    .byte $D0, #3
    lda #RESP1
    .byte $2C
    lda #GRP1
    NIBBLE_RAM_STORE sta, NibbleGemini2Reg
    ; [BIT DEPTH] #3 *If-End @ 3
    ; [BIT DEPTH] #3 Else-End @ 3
.endif_3:
    ; Gemini 3A
.K_3A:
    lda [DO_GEMS_A + 3]
    jsr KernelA_GenReset
.if_4:
    bne .else_4
    sec
    rol RamNibbleBuildState
    jmp .endif_4
    ; [BIT DEPTH] #4 If-End @ 4
.else_4:
    clc
    rol RamNibbleBuildState
    ; Set opcode
    lda [DO_GEMS_A + 3]
    jsr Kernel_UpdateRegs
    NIBBLE_RAM_STORE sta, NibbleGemini3
    ; Set opcode target
    lda SHARD_LUT_RF1
    cpy #3
    .byte $D0, #3
    lda #RESP1
    .byte $2C
    lda #GRP1
    NIBBLE_RAM_STORE sta, NibbleGemini3Reg
    ; [BIT DEPTH] #4 *If-End @ 4
    ; [BIT DEPTH] #4 Else-End @ 4
.endif_4:
    ; [BIT DEPTH] Final: 4 (out of 8 bits)
    rol RamNibbleBuildState
    rol RamNibbleBuildState
    rol RamNibbleBuildState
    rol RamNibbleBuildState
    ENDM




    MAC NIBBLE_gem_kernel_a_2_BUILD
    lda #0
    sta RamNibbleBuildState
    ; NIBBLE_VAR NibbleGemini1
    ; NIBBLE_VAR NibbleGemini1Reg
    ; NIBBLE_VAR NibbleGemini2
    ; NIBBLE_VAR NibbleGemini2Reg
    ; NIBBLE_VAR NibbleGemini3
    ; NIBBLE_VAR NibbleGemini3Reg
    ; VD1 default
    lda [DO_GEMS_A + 1]
    NIBBLE_RAM_STORE sta, NibbleVdel1
    ; Gemini 4A
    lda SHARD_LUT_VD1
    cmp #4
.if_1:
    beq .else_1
    sec
    rol RamNibbleBuildState
    ; Set PHP
    lda #VDELP1
    NIBBLE_RAM_STORE sta, NibblePhp
    ; Update VDEL1
    lda [DO_GEMS_A + 4]
    NIBBLE_RAM_STORE sta, NibbleVdel1
    jmp .endif_1
    ; [BIT DEPTH] #1 If-End @ 1
.else_1:
    clc
    rol RamNibbleBuildState
    lda [DO_GEMS_A + 4]
    jsr Kernel_UpdateRegs
    NIBBLE_RAM_STORE sta, NibbleGemini4
    ; Set PHP
    lda #RESP1
    NIBBLE_RAM_STORE sta, NibblePhp
    ; [BIT DEPTH] #1 *If-End @ 1
    ; [BIT DEPTH] #1 Else-End @ 1
.endif_1:
    ; Gemini 5A
    ; TODO eventually...?
    ; Missile
    lda DO_MISS_A
    ; FIXME Why doesn't this branch compile?
    ; bne .+4
    ; ldx #BC_NOP
    ; stx NibbleMissile
    ; VD1
    ; GRP0
    lda #$ff
    NIBBLE_RAM_STORE sta, NibblePs
    ; [BIT DEPTH] Final: 1 (out of 8 bits)
    rol RamNibbleBuildState
    rol RamNibbleBuildState
    rol RamNibbleBuildState
    rol RamNibbleBuildState
    rol RamNibbleBuildState
    rol RamNibbleBuildState
    rol RamNibbleBuildState
    ENDM




    MAC NIBBLE_gem_kernel_b_1_BUILD
    lda #0
    sta RamNibbleBuildState
    ; NIBBLE_VAR NibbleGemini1
    ; NIBBLE_VAR NibbleGemini1Reg
    ; NIBBLE_VAR NibbleGemini2Reg
    ; NIBBLE_VAR NibbleGemini3Reg
    ; NIBBLE_VAR NibbleGemini4
    ; NIBBLE_VAR NibbleMissile
    ; NIBBLE_VAR NibbleVdel1
    lda #SENTINEL
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
    NIBBLE_RAM_STORE sta, NibbleGrp0
    sta BuildNibbleGrp0
    ; NIBBLE_WRITE_IMM KernelB_D_W, RamKernelGemini0
    ; Gemini 1B
    lda [DO_GEMS_B + 1]
    jsr Kernel_UpdateRegs
    NIBBLE_RAM_STORE sta, NibbleGemini1
    ; Gemini 2B
    lda [DO_GEMS_B + 2]
    jsr KernelB_GenPhp
.if_1:
    bne .else_1
    sec
    rol RamNibbleBuildState
    CALC_REGS_AND_STORE 3, NibbleGemini3
    ; Write to PHP in 2B
    lda #EMERALD_SP
    NIBBLE_RAM_STORE sta, NibblePhp
    ; Update Grp0
    lda BuildKernelRST
    sta BuildNibbleGrp0
    rol RamNibbleBuildState
    jmp .endif_1
    ; [BIT DEPTH] #1 If-End @ 1
.else_1:
    clc
    rol RamNibbleBuildState
    ; Gemini 3B
    lda [DO_GEMS_B + 3]
    jsr KernelB_GenPhp
.if_2:
    bne .else_2
    sec
    rol RamNibbleBuildState
    ; Write to PHP in 3B
    CALC_REGS_AND_STORE 2, NibbleGemini2
    lda #EMERALD_SP
    NIBBLE_RAM_STORE sta, NibblePhp
     
    ; Update Grp0
    ; NIBBLE_RAM_LOAD lda, BuildKernelRST
    lda [DO_GEMS_B + 3]
    sta BuildNibbleGrp0
    jmp .endif_2
    ; [BIT DEPTH] #2 If-End @ 2
.else_2:
    clc
    rol RamNibbleBuildState
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
    rol RamNibbleBuildState
    rol RamNibbleBuildState
    rol RamNibbleBuildState
    rol RamNibbleBuildState
    rol RamNibbleBuildState
    rol RamNibbleBuildState
    ENDM




    MAC NIBBLE_gem_kernel_b_2_BUILD
    lda #0
    sta RamNibbleBuildState
    ; NIBBLE_VAR NibbleGemini1Reg
    ; NIBBLE_VAR NibbleGemini2
    ; NIBBLE_VAR NibbleGemini2Reg
    ; NIBBLE_VAR NibbleGemini3
    ; NIBBLE_VAR NibbleGemini3Reg
    ; NIBBLE_VAR NibbleMissile
    ; NIBBLE_VAR NibbleVdel1
    ; Gemini 1B
    ; Write out PHP flag comparison
    lda BuildKernelRST
    cmp #G01
.if_1:
    bne .else_1
    sec
    rol RamNibbleBuildState
    lda BuildKernelRST
    sta BuildNibbleGrp0
    jmp .endif_1
    ; [BIT DEPTH] #1 If-End @ 1
.else_1:
    clc
    rol RamNibbleBuildState
    ; [BIT DEPTH] #1 *If-End @ 1
    ; [BIT DEPTH] #1 Else-End @ 1
.endif_1:
    ; Missile
    ; ldy DO_MISS_B
    ; NIBBLE_IF eq
    ; NIBBLE_WRITE_IMM [KernelB_K_W + 0], #BC_STA
    ; NIBBLE_ELSE
    ;     NIBBLE_WRITE_IMM [KernelB_K_W + 0], NibbleMissile
    ; NIBBLE_END_IF
    ; Gemini 4B
    CALC_REGS_AND_STORE 4, NibbleGemini4
    ; TODO if no PHP, rewrite previous section:
    ; NIBBLE_IF cs
    ;
    ;     NIBBLE_WRITE_IMM [KernelB_E_W + 0], #BC_PHP
    ;     NIBBLE_WRITE_IMM [KernelB_F_W + 0], #BC_STY, #EMERALD_SP
    ;     NIBBLE_WRITE_IMM [KernelB_G_W + 0], #BC_STA, #PF1
    ;     NIBBLE_WRITE_IMM [KernelB_H_W + 0], #BC_STY, #EMERALD_SP
    ; NIBBLE_END_IF
    ; Make adjustments for sprites.
    clc
    NIBBLE_RAM_LOAD lda, NibbleGrp0
    ror
    NIBBLE_RAM_STORE sta, NibbleGrp0
    lda BuildNibbleX
    ror
    NIBBLE_RAM_STORE sta, NibbleX
    lda BuildNibbleY
    ror
    NIBBLE_RAM_STORE sta, NibbleY
    ;
    ; NIBBLE_WRITE_IMM [KernelB_VDEL1_W + 0], NibbleVdel1
    ; GRP0
    lda #$00
    NIBBLE_RAM_STORE sta, NibblePs
    ; [BIT DEPTH] Final: 1 (out of 8 bits)
    rol RamNibbleBuildState
    rol RamNibbleBuildState
    rol RamNibbleBuildState
    rol RamNibbleBuildState
    rol RamNibbleBuildState
    rol RamNibbleBuildState
    rol RamNibbleBuildState
    ENDM




