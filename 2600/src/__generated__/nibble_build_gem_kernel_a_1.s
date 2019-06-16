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
    rol RamNibbleBuildState
    jmp .endif_2
    ; [BIT DEPTH] #2 If-End @ 2
.else_2:
    clc
    rol RamNibbleBuildState
    ; Calculate the 1A value
    lda SHARD_LUT_RF1
    cmp #1
.if_3:
    bne .else_3
    sec
    rol RamNibbleBuildState
    jmp .endif_3
    ; [BIT DEPTH] #3 If-End @ 3
.else_3:
    clc
    rol RamNibbleBuildState
    lda [DO_GEMS_A + 1]
    jsr Kernel_UpdateRegs
    NIBBLE_RAM_STORE sta, NibbleGemini1
    ; [BIT DEPTH] #3 *If-End @ 3
    ; [BIT DEPTH] #3 Else-End @ 3
.endif_3:
    ; [BIT DEPTH] #2 *If-End @ 2
    ; [BIT DEPTH] #3 Else-End @ 3
.endif_2:
    ; [BIT DEPTH] #1 *If-End @ 1
    ; [BIT DEPTH] #3 Else-End @ 3
.endif_1:
    ; Stop reusing GRP0 by trashing our temp value
    lda #SENTINEL
    sta BuildNibbleGrp0
    ; NibbleX, NibbleY are upgraded if not set
    ; Gemini 2A
.K_2A
    lda [DO_GEMS_A + 2]
    jsr KernelA_GenReset
.if_4:
    bne .else_4
    sec
    rol RamNibbleBuildState
    rol RamNibbleBuildState
    jmp .endif_4
    ; [BIT DEPTH] #4 If-End @ 4
.else_4:
    clc
    rol RamNibbleBuildState
    ; Set opcode target
    lda SHARD_LUT_RF1
    cmp #2
.if_5:
    bne .else_5
    sec
    rol RamNibbleBuildState
    jmp .endif_5
    ; [BIT DEPTH] #5 If-End @ 5
.else_5:
    clc
    rol RamNibbleBuildState
    ; Set opcode and write to sprite
    lda [DO_GEMS_A + 2]
    jsr Kernel_UpdateRegs
    NIBBLE_RAM_STORE sta, NibbleGemini2
    ; [BIT DEPTH] #5 *If-End @ 5
    ; [BIT DEPTH] #5 Else-End @ 5
.endif_5:
    ; [BIT DEPTH] #4 *If-End @ 4
    ; [BIT DEPTH] #5 Else-End @ 5
.endif_4:
    ; Gemini 3A
.K_3A:
    lda [DO_GEMS_A + 3]
    jsr KernelA_GenReset
.if_6:
    bne .else_6
    sec
    rol RamNibbleBuildState
    rol RamNibbleBuildState
    jmp .endif_6
    ; [BIT DEPTH] #6 If-End @ 6
.else_6:
    clc
    rol RamNibbleBuildState
    ; Set opcode target
    lda SHARD_LUT_RF1
    cpy #3
.if_7:
    bne .else_7
    sec
    rol RamNibbleBuildState
    jmp .endif_7
    ; [BIT DEPTH] #7 If-End @ 7
.else_7:
    clc
    rol RamNibbleBuildState
    ; Set opcode and write to sprite
    lda [DO_GEMS_A + 3]
    jsr Kernel_UpdateRegs
    NIBBLE_RAM_STORE sta, NibbleGemini3
    ; [BIT DEPTH] #7 *If-End @ 7
    ; [BIT DEPTH] #7 Else-End @ 7
.endif_7:
    ; [BIT DEPTH] #6 *If-End @ 6
    ; [BIT DEPTH] #7 Else-End @ 7
.endif_6:
    ; [BIT DEPTH] Final: 7 (out of 8 bits)
    rol RamNibbleBuildState
