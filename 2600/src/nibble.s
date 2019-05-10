
    MAC NIBBLE_gem_kernel_BUILD
    lda #0
    ldx $f100
    cpx #$a
.if_1:
    bne .else_1
    sec
    rol
    ; Kernel A
    ; gems:     [g00,g01,g10,g11,g00,g01]
    ; cpu:      cpu(g01,g00,false,g10,g11,false)
    ; solved:   [bc_RST,bc_NOP,bc_STX,bc_STY,bc_VD1]
     
    ; gems:     [g01,g10,g11,g00,g01,g10]
    ; cpu:      cpu(g01,g01,false,g10,g11,false)
    ; solved:   [bc_NOP,bc_STX,bc_STY,bc_RST,bc_VD1]
    ; TODO implement this, also implement RST2
    ; gems:     [g10,g11,g00,g01,g10,g11]
    ; cpu:      cpu(g10,g10,false,g11,g01,false)
    ; solved:   [bc_NOP,bc_STX,bc_RST,bc_STY,bc_VD1]
    ; todo rst2
    ; VDELPx
    ldy #%01100000
    sty [KernelA_VDEL1 - $100]
    ; GRP0
    ldy #%01100000
    sty [KernelA_VDEL0 - $100]
    ; X
    ldy #%00000110
    sty RamKernelX
    ; Y
    ; PHP
    ; Gemini 1A
.if_2:
    bvs .else_2
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
.else_2:
    clc
    rol
.if_3:
    bvc .else_3
    sec
    rol
    jmp .endif_3
.else_3:
    clc
    rol
    ldy #BC_STX
    sty RamKernelGemini1
.endif_3:
.endif_2:
    ; Gemini 2A
    ldy #BC_STY
    sty RamKernelGemini2
    ; Gemini 3A
.if_4:
    bvc .else_4
    sec
    rol
    jmp .endif_4
.else_4:
    clc
    rol
    ldy #BC_STX
    sty RamKernelGemini3
.endif_4:
    ; Gemini 4A
    ; Set VDELPx
.if_5:
    bvc .else_5
    sec
    rol
    jmp .endif_5
.else_5:
    clc
    rol
.endif_5:
    ; Gemini 5A
    ; TODO eventually...?
    ; End of NIBBLE_IF normalizing
    REPEAT 3
    rol
    REPEND
    jmp .endif_1
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
.else_6:
    clc
    rol
    ; NIBBLE_WRITE [KernelB_H_W + 0], #BC_PHP
    ; NIBBLE_WRITE [KernelB_H_W + 1], #BC_STA
    ; NIBBLE_WRITE [KernelB_H_W + 2], #EMERALD_SP_RESET
.endif_6:
    REPEAT 6
    rol
    REPEND
.endif_1:
    ENDM

    MAC NIBBLE_gem_kernel
.if_1:
    asl
    bcc .else_1
    ldx #%01100110
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
    ldx #BC_STY
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

