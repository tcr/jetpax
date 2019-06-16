    lda #0
    sta RamNibbleBuildState
    ; NIBBLE_VAR NibbleGemini1
    ; NIBBLE_VAR NibbleGemini4
    ; NIBBLE_VAR NibbleMissile
    ; NIBBLE_VAR NibbleVdel1
    lda #SENTINEL
    sta BuildKernelRST
    sta BuildNibbleX
    ; NIBBLE_RAM_STORE sta, NibbleX
    sta BuildNibbleY
    ; NIBBLE_RAM_STORE sta, NibbleY
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
