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
