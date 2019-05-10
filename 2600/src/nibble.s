
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
    ; Special: Encoding RST0
    ;
    ; ldy #BC_LDA_IMM
    ; sty [KernelA_B - $100]
    ; ldy #%10100000
    ; sty [KernelA_B - $100 + 1]
    ;
    ; ldy #EMERALD_SP_RESET
    ; sty [KernelA_C - $100 + 1]
    ;
    ; ldy #$14
    ; sty [KernelA_D - $100]
    ; VDEL enabled
    ldy #%01100000
    sty [KernelA_VDEL1 - $100]
    ; Initial GRP0
    ldy #%01100000
    sty [KernelA_VDEL0 - $100]
    ; Initial X
    ldy #%00000110
    sty RamKernelX
    ; Initial Y
    ldy #%01100110
    sty [KernelA_STY - $100]
    ; PHP will always be VDELP1
    ; End of NIBBLE_IF normalizing
    REPEAT 7
    rol
    REPEND
    jmp .endif_1
.else_1:
    clc
    rol
    ; Kernel B
    ; Kernel: Set X register.
    ldy #%00000011
    sty RamKernelX
    ldy #%00110011
    sty RamKernelY
     
    cpx #$00
.if_2:
    bcc .else_2
    sec
    rol
    ; NIBBLE_WRITE [KernelB_H_W + 0], #BC_STA
    ; NIBBLE_WRITE [KernelB_H_W + 1], #EMERALD_SP
    ; NIBBLE_WRITE [KernelB_H_W + 2], #BC_PHP
    jmp .endif_2
.else_2:
    clc
    rol
    ; NIBBLE_WRITE [KernelB_H_W + 0], #BC_PHP
    ; NIBBLE_WRITE [KernelB_H_W + 1], #BC_STA
    ; NIBBLE_WRITE [KernelB_H_W + 2], #EMERALD_SP_RESET
.endif_2:
    REPEAT 6
    rol
    REPEND
.endif_1:
    ENDM

    MAC NIBBLE_gem_kernel
.if_1:
    asl
    bcc .else_1
    ldx #VDELP1
    stx [RamKernelPhpTarget + 0]
    ldx #BC_STX
    stx [KernelA_D_W + 0]
    ldx #GRP1
    stx [KernelA_D_W + 1]
    ldx #BC_STY
    stx [KernelA_G_W + 0]
    ldx #GRP1
    stx [KernelA_G_W + 1]
    ldx #RESP1
    stx [KernelA_H_W + 1 + 0]
    ldx #BC_STA
    stx [KernelA_I_W + 0]
    ldx #EMERALD_SP_RESET
    stx [KernelA_I_W + 1]
    ldx #BC_STA
    stx [[KernelA_J_W + 1] + 0]
    ldx #PF1
    stx [[KernelA_J_W + 1] + 1]
    ldx #BC_PHP
    stx [[KernelA_K_W + 1] + 0]
    jmp .endif_1
.else_1:
.if_2:
    asl
    bcc .else_2
    ldx #EMERALD_SP_RESET
    stx [RamKernelPhpTarget + 0]
    jmp .endif_2
.else_2:
    ldx #EMERALD_SP
    stx [RamKernelPhpTarget + 0]
.endif_2:
.endif_1:
    ENDM

