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
    ; [BIT DEPTH] Final: 1 (out of 8 bits)
    rol RamNibbleBuildState
    rol RamNibbleBuildState
    rol RamNibbleBuildState
    rol RamNibbleBuildState
    rol RamNibbleBuildState
    rol RamNibbleBuildState
    rol RamNibbleBuildState
