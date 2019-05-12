
    MAC NIBBLE_gem_kernel_a_1_BUILD
    lda #0
    ldx #SENTINEL
    stx BuildKernelX
    stx BuildKernelY
    stx BuildKernelZ
    ; Gemini 1A
    ldx #SHARD_0A_RST
.if_1:
    beq .else_1
    sec
    rol
    ; Special: Encoding RST0
    ; Rewrite lda RamKernelPF1 to be #immediate
    ldy #BC_LDA_IMM
    sty [KernelA_B - $100]
    ldy #%10100000
    sty [KernelA_B - $100 + 1]
    ; Store 1A in GRP0
    ldy #GEM1
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
    ldy #GEM0
    sty BuildKernelGrp0
    ldx #SHARD_1A_RST
.if_2:
    beq .else_2
    sec
    rol
    jmp .endif_2
    ; [BIT DEPTH] #2 If-End @ 2

.else_2:
    clc
    rol
    ; Calculate the 1A value
    if SHARD_LUT_RF1
    ldy #REFP1
    else
    ; Set opcode
    ldy #GEM1
    jsr KernelA_UpdateRegs
    sty RamKernelGemini1
    ; Set opcode target
    ldy #GRP1
    endif
    sty RamKernelGemini1Reg
    ; [BIT DEPTH] #2 *If-End @ 2
    ; [BIT DEPTH] #2 Else-End @ 2
.endif_2:
    ; [BIT DEPTH] #1 *If-End @ 1
    ; [BIT DEPTH] #1 Else-End @ 2
.endif_1:
    ; Gemini 2A
    ldx #SHARD_2A_RST
.if_3:
    beq .else_3
    sec
    rol
    jmp .endif_3
    ; [BIT DEPTH] #3 If-End @ 3

.else_3:
    clc
    rol
    ; Set opcode
    ldy #GEM2
    jsr KernelA_UpdateRegs
    sty RamKernelGemini2
    ; Set opcode target
    if SHARD_LUT_RF1 == 2
    ldy #REFP1
    else
    ldy #GRP1
    endif
    sty RamKernelGemini2Reg
    ; [BIT DEPTH] #3 *If-End @ 3
    ; [BIT DEPTH] #3 Else-End @ 3
.endif_3:
    ; Gemini 3A
    ldx #SHARD_3A_RST
.if_4:
    beq .else_4
    sec
    rol
    jmp .endif_4
    ; [BIT DEPTH] #4 If-End @ 4

.else_4:
    clc
    rol
    ; FIXME Calculate the 3A value
    ; Set opcode
    ldy #GEM3
    jsr KernelA_UpdateRegs
    sty RamKernelGemini3
    ; Set opcode target
    if SHARD_LUT_RF1 == 3
    ldy #REFP1
    else
    ldy #GRP1
    endif
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
    ; Gemini 4A
    ldx #[SHARD_LUT_VD1 == 4]
.if_1:
    beq .else_1
    sec
    rol
    ; Set PHP
    jmp .endif_1
    ; [BIT DEPTH] #1 If-End @ 1

.else_1:
    clc
    rol
    ; FIXME Calculate the 4A value
    ldy #GEM4
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
    ; X
    ldy #%00000011
    sty RamKernelX
    ; Y
    ldy #%00110011
    sty [KernelB_STY - $100]
     
    cpx #$00
.if_1:
    bcc .else_1
    sec
    rol
    ; NIBBLE_WRITE [KernelB_H_W + 0], #BC_STA
    ; NIBBLE_WRITE [KernelB_H_W + 1], #EMERALD_SP
    ; NIBBLE_WRITE [KernelB_H_W + 2], #BC_PHP
    jmp .endif_1
    ; [BIT DEPTH] #1 If-End @ 1

.else_1:
    clc
    rol
    ; NIBBLE_WRITE [KernelB_H_W + 0], #BC_PHP
    ; NIBBLE_WRITE [KernelB_H_W + 1], #BC_STA
    ; NIBBLE_WRITE [KernelB_H_W + 2], #EMERALD_SP_RESET
    ; [BIT DEPTH] #1 *If-End @ 1
    ; [BIT DEPTH] #1 Else-End @ 1
.endif_1:
    ; [BIT DEPTH] Final: 1 (out of 8 bits)
    rol
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
    ldx #RESP1
    stx [KernelA_D_W + 1 + 0]
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
    ldx #[SHARD_LUT_VD1 == 4 ? GEM4 - GEM1] + GEM1
    stx [[KernelA_VDEL1 - $100] + 0]
    ldx BuildKernelGrp0
    stx [[KernelA_VDEL0 - $100] + 0]
    ldx BuildKernelX
    stx [RamKernelX + 0]
    ldx BuildKernelY
    stx [[KernelA_STY - $100] + 0]
    ENDM

    MAC NIBBLE_gem_kernel_b
.if_1:
    asl
    bcc .else_1
    ldx #EMERALD_SP_RESET
    stx [RamKernelPhpTarget + 0]
    jmp .endif_1
.else_1:
    ldx #EMERALD_SP
    stx [RamKernelPhpTarget + 0]
.endif_1:
    ENDM


