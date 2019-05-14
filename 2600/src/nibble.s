
    MAC NIBBLE_gem_kernel_a_1_BUILD
    lda #0
    ldx #SENTINEL
    stx BuildKernelX
    stx BuildKernelY
    stx BuildKernelRST
    ; Gemini 1A
    ldy [GEMS_A + 0]
    jsr KernelA_GenReset
.if_1:
    bne .else_1
    sec
    rol
    ; Special: Encoding RST0
    ; Rewrite lda RamKernelPF1 to be #immediate
    ldy #BC_LDA_IMM
    sty [KernelA_B - $100]
    ldy #%10100000
    sty [KernelA_B - $100 + 1]
    ; Store 1A in GRP0
    ldy [GEMS_A + 1]
    sty BuildKernelGrp0
    ; Gemini 1A is RESPx
    ldy #EMERALD_SP_RESET
    sty [KernelA_C - $100 + 1]
    ; Turn 3-cycle NOP into 4-cycle
    ldy #$14
    sty [KernelA_D - $100]
    jmp .endif_1
    ; [BIT DEPTH] #1 If-End @ 1
    rol

.else_1:
    clc
    rol
    ; Store 0A in GRP0
    ldy [GEMS_A + 0]
    sty BuildKernelGrp0
    ldy [GEMS_A + 1]
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
    sty RamKernelGemini1Reg
    ; Set opcode
    ldx SHARD_LUT_RF1
    cpx #1
    ldy #BC_STX
    .byte $D0, #4
    ldy [GEMS_A + 1]
    jsr KernelA_UpdateRegs
    sty RamKernelGemini1
    ; [BIT DEPTH] #2 *If-End @ 2
    ; [BIT DEPTH] #2 Else-End @ 2
.endif_2:
    ; [BIT DEPTH] #1 *If-End @ 1
    ; [BIT DEPTH] #1 Else-End @ 2
.endif_1:
    ; Gemini 2A
    ldy [GEMS_A + 2]
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
    ldy [GEMS_A + 2]
    jsr KernelA_UpdateRegs
    sty RamKernelGemini2
    ; Set opcode target
    ldy SHARD_LUT_RF1
    cpy #2
    .byte $D0, #3
    ldy #RESP1
    .byte $2C
    ldy #GRP1
    sty RamKernelGemini2Reg
    ; [BIT DEPTH] #3 *If-End @ 3
    ; [BIT DEPTH] #3 Else-End @ 3
.endif_3:
    ; Gemini 3A
    ldy [GEMS_A + 3]
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
    ldy [GEMS_A + 3]
    jsr KernelA_UpdateRegs
    sty RamKernelGemini3
    ; Set opcode target
    ldy SHARD_LUT_RF1
    cpy #3
    .byte $D0, #3
    ldy #RESP1
    .byte $2C
    ldy #GRP1
    sty RamKernelGemini3Reg
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
    ; VD1 default
    ldx [GEMS_A + 1]
    stx BuildKernelVdel1
    ; Gemini 4A
    ldx SHARD_LUT_VD1
    cpx #4
.if_1:
    beq .else_1
    sec
    rol
    ; Set PHP
    ; Update VDEL1
    ldx [GEMS_A + 4]
    stx BuildKernelVdel1
    jmp .endif_1
    ; [BIT DEPTH] #1 If-End @ 1

.else_1:
    clc
    rol
    ldy [GEMS_A + 4]
    jsr KernelA_UpdateRegs
    sty RamKernelGemini4
    ; Set PHP
    ; [BIT DEPTH] #1 *If-End @ 1
    ; [BIT DEPTH] #1 Else-End @ 1
.endif_1:
    ; VD1
    ; ldy #SHARD_VD1
    ; sty [KernelA_VDEL1 - $100]
    ; GRP0
    ; ldy #SHARD_GRP0
    ; sty [KernelA_VDEL0 - $100]
    ; X
    ; ldy #SHARD_X
    ; sty RamKernelX
    ; Y
    ; Gemini 5A
    ; TODO eventually...?
    ; [BIT DEPTH] Final: 1 (out of 8 bits)
    rol
    rol
    rol
    rol
    rol
    rol
    rol
    ENDM

    MAC NIBBLE_gem_kernel_b_BUILD
    lda #0
    ; Php target default
    ldx #RESP1
    stx RamKernelPhpTarget
    ldx #SENTINEL
    stx BuildKernelX
    stx BuildKernelY
    stx BuildKernelRST
    ; Gemini 1B
    ldy [GEMS_B + 1]
    jsr KernelA_UpdateRegs
    sty RamKernelGemini3
    ; Gemini 2B
    ldy [GEMS_B + 2]
    jsr KernelB_GenPhp
.if_1:
    bne .else_1
    sec
    rol
    ; Write to PHP in 2B
    jmp .endif_1
    ; [BIT DEPTH] #1 If-End @ 1

.else_1:
    clc
    rol
    ; Calculate the gemini value
    ldy [GEMS_B + 2]
    jsr KernelB_UpdateRegs
    sty RamKernelGemini1
    ; [BIT DEPTH] #1 *If-End @ 1
    ; [BIT DEPTH] #1 Else-End @ 1
.endif_1:
    ; Gemini 3B
    ldy [GEMS_B + 3]
    jsr KernelB_GenPhp
.if_2:
    bne .else_2
    sec
    rol
    ; Write to PHP in 3B
    jmp .endif_2
    ; [BIT DEPTH] #2 If-End @ 2

.else_2:
    clc
    rol
    ; Calculate the gemini value
    ldy [GEMS_B + 1]
    jsr KernelB_UpdateRegs
    sty RamKernelGemini1
    ; [BIT DEPTH] #2 *If-End @ 2
    ; [BIT DEPTH] #2 Else-End @ 2
.endif_2:
    ; Gemini 4B
    ldy [GEMS_B + 4]
    jsr KernelA_UpdateRegs
    sty RamKernelGemini4
    ; TODO if no PHP, rewrite previous section:
    ; NIBBLE_IF cs
    ;
    ;     NIBBLE_WRITE [KernelB_E_W + 0], #BC_PHP
    ;     NIBBLE_WRITE [KernelB_F_W + 0], #BC_STY, #EMERALD_SP
    ;     NIBBLE_WRITE [KernelB_G_W + 0], #BC_STA, #PF1
    ;     NIBBLE_WRITE [KernelB_H_W + 0], #BC_STY, #EMERALD_SP
    ; NIBBLE_END_IF
    ; Make adjustments for sprites.
    ror BuildKernelGrp0
    ror BuildKernelX
    ror BuildKernelY
    ;
    ; NIBBLE_WRITE [KernelB_VDEL1 - $100], BuildKernelVdel1
    ; GRP0
    ; X
    ; Y
    ; [BIT DEPTH] Final: 2 (out of 8 bits)
    rol
    rol
    rol
    rol
    rol
    rol
    ENDM


    MAC NIBBLE_gem_kernel_a_1
.if_1:
    asl
    bcc .else_1
    jmp .endif_1
.else_1:
.if_2:
    asl
    bcc .else_2
    ldx #BC_STX
    stx [KernelA_D_W + 0]
    ldx #RESP1
    stx [KernelA_D_W + 1]
    jmp .endif_2
.else_2:
    ldx RamKernelGemini1
    stx [KernelA_D_W + 0]
    ldx RamKernelGemini1Reg
    stx [KernelA_D_W + 1]
.endif_2:
.endif_1:
.if_3:
    asl
    bcc .else_3
    ldx #NOP_REG
    stx [KernelA_E_W + 1 + 0]
    ldx #RESP1
    stx [KernelA_G_W + 1 + 0]
    jmp .endif_3
.else_3:
    ldx #RESP1
    stx [KernelA_E_W + 1 + 0]
    ldx RamKernelGemini2
    stx [KernelA_G_W + 0]
    ldx RamKernelGemini2Reg
    stx [KernelA_G_W + 1]
.endif_3:
.if_4:
    asl
    bcc .else_4
    ldx #RESP1
    stx [KernelA_H_W + 1 + 0]
    jmp .endif_4
.else_4:
    ldx RamKernelGemini3
    stx [KernelA_H_W + 0]
    ldx RamKernelGemini3Reg
    stx [KernelA_H_W + 1]
.endif_4:
    ENDM

    MAC NIBBLE_gem_kernel_a_2
.if_1:
    asl
    bcc .else_1
    ldx #BC_STA
    stx [[KernelA_I_W + 0] + 0]
    ldx #EMERALD_SP_RESET
    stx [[KernelA_I_W + 0] + 1]
    ldx #BC_STA
    stx [[KernelA_J_W + 1] + 0]
    ldx #PF1
    stx [[KernelA_J_W + 1] + 1]
    ldx #BC_PHP
    stx [[KernelA_K_W + 1] + 0]
    ldx #VDELP1
    stx [RamKernelPhpTarget + 0]
    jmp .endif_1
.else_1:
    ldx #BC_PHP
    stx [[KernelA_I_W + 0] + 0]
    ldx #BC_STA
    stx [[KernelA_J_W + 0] + 0]
    ldx #PF1
    stx [[KernelA_J_W + 0] + 1]
    ldx RamKernelGemini4
    stx [KernelA_K_W + 0]
    ldx #EMERALD_SP
    stx [KernelA_K_W + 1]
    ldx #RESP1
    stx [RamKernelPhpTarget + 0]
.endif_1:
    ldx BuildKernelVdel1
    stx [[KernelA_VDEL1 - $100] + 0]
    ldx BuildKernelGrp0
    stx [[KernelA_VDEL0 - $100] + 0]
    ldx BuildKernelX
    stx [RamKernelX + 0]
    ldx BuildKernelY
    stx [[KernelA_STY - $100] + 0]
    ENDM

    MAC NIBBLE_gem_kernel_b
    ldx RamKernelGemini3
    stx [KernelB_D_W + 0]
.if_1:
    asl
    bcc .else_1
    ldx #EMERALD_SP
    stx [RamKernelPhpTarget + 0]
    ldx #BC_STY
    stx [[KernelB_E_W + 0] + 0]
    ldx #EMERALD_SP_RESET
    stx [[KernelB_E_W + 0] + 1]
    ldx #BC_PHP
    stx [[KernelB_F_W + 1] + 0]
    ldx #BC_STA
    stx [[KernelB_G_W + 0] + 0]
    ldx #PF1
    stx [[KernelB_G_W + 0] + 1]
    ldx #BC_STY
    stx [[KernelB_H_W + 0] + 0]
    ldx #EMERALD_SP
    stx [[KernelB_H_W + 0] + 1]
    jmp .endif_1
.else_1:
    ldx RamKernelGemini1
    stx [KernelB_F_W + 0]
    ldx #EMERALD_SP
    stx [KernelB_F_W + 1]
.endif_1:
.if_2:
    asl
    bcc .else_2
    ldx #EMERALD_SP
    stx [RamKernelPhpTarget + 0]
    ldx #BC_STY
    stx [[KernelB_E_W + 0] + 0]
    ldx #EMERALD_SP_RESET
    stx [[KernelB_E_W + 0] + 1]
    ldx #BC_STY
    stx [[KernelB_F_W + 1] + 0]
    ldx #EMERALD_SP
    stx [[KernelB_F_W + 1] + 1]
    ldx #BC_STA
    stx [[KernelB_G_W + 1] + 0]
    ldx #PF1
    stx [[KernelB_G_W + 1] + 1]
    ldx #BC_PHP
    stx [[KernelB_H_W + 1] + 0]
    jmp .endif_2
.else_2:
    ldx RamKernelGemini1
    stx [KernelA_H_W + 0]
    ldx #EMERALD_SP
    stx [KernelA_H_W + 1]
.endif_2:
    ldx RamKernelGemini4
    stx [KernelB_J_W + 0]
    ldx BuildKernelGrp0
    stx [[KernelB_VDEL0 - $100] + 0]
    ldx BuildKernelX
    stx [RamKernelX + 0]
    ldx BuildKernelY
    stx [RamKernelY + 0]
    ENDM


