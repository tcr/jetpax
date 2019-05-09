
    MAC NIBBLE_gem_kernel_BUILD
    lda #0
    ldx $f100
    cpx #$a
.if_1:
    bne .else_1
    sec
    rol
    ; Kernel A
    cpx #$ff
.if_2:
    bcc .else_2
    sec
    rol
    ; NIBBLE_WRITE [KernelA_D_W + 0], #BC_STA, #RESP1
    jmp .endif_2
.else_2:
    clc
    rol
    ; NIBBLE_WRITE KernelA_H_W, #BC_STA, #REFP1
.endif_2:
    REPEAT 6
    rol
    REPEND
    jmp .endif_1
.else_1:
    clc
    rol
    ; Kernel B
    cpx #$00
.if_3:
    bcc .else_3
    sec
    rol
    ; NIBBLE_WRITE [KernelB_H_W + 0], #BC_STA
    ; NIBBLE_WRITE [KernelB_H_W + 1], #EMERALD_SP
    ; NIBBLE_WRITE [KernelB_H_W + 2], #BC_PHP
    jmp .endif_3
.else_3:
    clc
    rol
    ; NIBBLE_WRITE [KernelB_H_W + 0], #BC_PHP
    ; NIBBLE_WRITE [KernelB_H_W + 1], #BC_STA
    ; NIBBLE_WRITE [KernelB_H_W + 2], #EMERALD_SP_RESET
.endif_3:
    REPEAT 6
    rol
    REPEND
.endif_1:
    ENDM

    MAC NIBBLE_gem_kernel
.if_1:
    asl
    bcc .else_1
    ldx #RESP1
    stx [RamKernelPhpTarget + 0]
    ldx #BC_STY
    stx [KernelA_D_W + 0]
    ldx #VDELP1
    stx [KernelA_D_W + 1]
.if_2:
    asl
    bcc .else_2
    jmp .endif_2
.else_2:
    ldx #BC_STX
    stx [KernelA_G_W + 0]
    ldx #GRP1
    stx [KernelA_G_W + 1]
    ldx #BC_STX
    stx [KernelA_H_W + 0]
    ldx #GRP1
    stx [KernelA_H_W + 1]
.endif_2:
    jmp .endif_1
.else_1:
.if_3:
    asl
    bcc .else_3
    ldx #EMERALD_SP_RESET
    stx [RamKernelPhpTarget + 0]
    jmp .endif_3
.else_3:
    ldx #EMERALD_SP
    stx [RamKernelPhpTarget + 0]
.endif_3:
.endif_1:
    ENDM

