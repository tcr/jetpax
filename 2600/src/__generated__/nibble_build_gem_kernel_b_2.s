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
    ; [BIT DEPTH] Final: 1 (out of 8 bits)
    rol RamNibbleBuildState
    rol RamNibbleBuildState
    rol RamNibbleBuildState
    rol RamNibbleBuildState
    rol RamNibbleBuildState
    rol RamNibbleBuildState
    rol RamNibbleBuildState
