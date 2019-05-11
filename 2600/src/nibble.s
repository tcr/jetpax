
    MAC NIBBLE_gem_kernel_BUILD
    lda #0
    ldx $f100
    cpx #$a
.if_1:
    bne .else_1
    sec
    rol
    ; Kernel A
    ; VD1
    ldy #SHARD_VD1
    sty [KernelA_VDEL1 - $100]
    ; GRP0
    ldy #SHARD_GRP0
    sty [KernelA_VDEL0 - $100]
    ; X
    ldy #SHARD_X
    sty RamKernelX
    ; Y
    ; PHP
    ; Gemini 1A
    ldx #SHARD_0A_RST
.if_2:
    beq .else_2
    sec
    rol
    ; Special: Encoding RST0
    ; Rewrite lda RamKernelPF1 to be #immediate
    ldy #BC_LDA_IMM
    sty [KernelA_B - $100]
    ldy #%10100000
    sty [KernelA_B - $100 + 1]
    ; Gemini 1A is RESPx
    ldy #EMERALD_SP_RESET
    sty [KernelA_C - $100 + 1]
    ; Turn 3-cycle NOP into 4-cycle
    ldy #$14
    sty [KernelA_D - $100]
    jmp .endif_2
    ; [BIT DEPTH] #2 If-End @ 2
    rol

.else_2:
    clc
    rol
    ldx #SHARD_1A_RST
.if_3:
    beq .else_3
    sec
    rol
    jmp .endif_3
    ; [BIT DEPTH] #3 If-End @ 3

.else_3:
    clc
    rol
    ldy #SHARD_1A
    sty RamKernelGemini1
    ; [BIT DEPTH] #3 *If-End @ 3
    ; [BIT DEPTH] #3 Else-End @ 3
.endif_3:
    ; [BIT DEPTH] #2 *If-End @ 2
    ; [BIT DEPTH] #2 Else-End @ 3
.endif_2:
    ; Gemini 2A
    ldy #SHARD_2A
    sty RamKernelGemini2
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
    ldy #SHARD_3A
    sty RamKernelGemini3
    ; [BIT DEPTH] #4 *If-End @ 4
    ; [BIT DEPTH] #4 Else-End @ 4
.endif_4:
    ; Gemini 4A
    ldx #SHARD_4A_VD1
.if_5:
    beq .else_5
    sec
    rol
    ; Set VDELPx
    jmp .endif_5
    ; [BIT DEPTH] #5 If-End @ 5

.else_5:
    clc
    rol
    ; [BIT DEPTH] #5 *If-End @ 5
    ; [BIT DEPTH] #5 Else-End @ 5
.endif_5:
    ; Gemini 5A
    ; TODO eventually...?
    jmp .endif_1
    ; [BIT DEPTH] #1 If-End @ 5

.else_1:
    clc
    rol
    ; Kernel B
    ; X
    ldy #%00000011
    sty RamKernelX
    ; Y
    ldy #%00110011
    sty RamKernelY
     
    cpx #$00
.if_6:
    bcc .else_6
    sec
    rol
    ; NIBBLE_WRITE [KernelB_H_W + 0], #BC_STA
    ; NIBBLE_WRITE [KernelB_H_W + 1], #EMERALD_SP
    ; NIBBLE_WRITE [KernelB_H_W + 2], #BC_PHP
    jmp .endif_6
    ; [BIT DEPTH] #6 If-End @ 2

.else_6:
    clc
    rol
    ; NIBBLE_WRITE [KernelB_H_W + 0], #BC_PHP
    ; NIBBLE_WRITE [KernelB_H_W + 1], #BC_STA
    ; NIBBLE_WRITE [KernelB_H_W + 2], #EMERALD_SP_RESET
    ; [BIT DEPTH] #6 *If-End @ 2
    ; [BIT DEPTH] #6 Else-End @ 2
.endif_6:
    ; [BIT DEPTH] #1 *If-End @ 5
    ; [BIT DEPTH] #1 Else-End @ 2
    rol
    rol
    rol
.endif_1:
    ; [BIT DEPTH] Final: 5 (out of 8 bits)
    rol
    rol
    rol
    ENDM

    MAC NIBBLE_gem_kernel
.if_1:
    asl
    bcc .else_1
    ldx #SHARD_Y
    stx [[KernelA_STY - $100] + 0]
    ldx #VDELP1
    stx [RamKernelPhpTarget + 0]
.if_2:
    asl
    bcc .else_2
    jmp .endif_2
.else_2:
.if_3:
    asl
    bcc .else_3
    ldx #RESP1
    stx [KernelA_D_W + 1 + 0]
    jmp .endif_3
.else_3:
    ldx RamKernelGemini1
    stx [KernelA_D_W + 0]
    ldx #GRP1
    stx [KernelA_D_W + 1]
.endif_3:
.endif_2:
    ldx RamKernelGemini2
    stx [KernelA_G_W + 0]
    ldx #GRP1
    stx [KernelA_G_W + 1]
.if_4:
    asl
    bcc .else_4
    ldx #RESP1
    stx [KernelA_H_W + 1 + 0]
    jmp .endif_4
.else_4:
    ldx RamKernelGemini3
    stx [KernelA_H_W + 0]
    ldx #GRP1
    stx [KernelA_H_W + 1]
.endif_4:
.if_5:
    asl
    bcc .else_5
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
    jmp .endif_5
.else_5:
    ldx #BC_PHP
    stx [[KernelA_I_W + 0] + 0]
    ldx #BC_STA
    stx [[KernelA_J_W + 0] + 0]
    ldx #PF1
    stx [[KernelA_J_W + 0] + 1]
    ldx #SHARD_4A
    stx [KernelA_K_W + 0]
    ldx #EMERALD_SP
    stx [KernelA_K_W + 1]
.endif_5:
    jmp .endif_1
.else_1:
.if_6:
    asl
    bcc .else_6
    ldx #EMERALD_SP_RESET
    stx [RamKernelPhpTarget + 0]
    jmp .endif_6
.else_6:
    ldx #EMERALD_SP
    stx [RamKernelPhpTarget + 0]
.endif_6:
.endif_1:
    ENDM

