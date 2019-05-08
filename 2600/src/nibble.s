
    MAC NIBBLE_gem_kernel_BUILD
    lda #0
    ldx $f100
    cpx #$b
.if_1:
    rol
    bcc .else_1
    ; Kernel B
    cpx #$00
.if_2:
    rol
    bcc .else_2
    ; NIBBLE_WRITE [KernelB_H_W + 0], #BC_STA
    ; NIBBLE_WRITE [KernelB_H_W + 1], #EMERALD_SP
    ; NIBBLE_WRITE [KernelB_H_W + 2], #BC_PHP
    jmp .endif_2
.else_2:
    ; NIBBLE_WRITE [KernelB_H_W + 0], #BC_PHP
    ; NIBBLE_WRITE [KernelB_H_W + 1], #BC_STA
    ; NIBBLE_WRITE [KernelB_H_W + 2], #EMERALD_SP_RESET
.endif_2:
    REPEAT 6
    rol
    REPEND
    jmp .endif_1
.else_1:
    ; Kernel A
    cpx #$ff
.if_3:
    rol
    bcc .else_3
    ; NIBBLE_WRITE [KernelA_D_W + 0], #BC_STA, #RESP1
    jmp .endif_3
.else_3:
    ; NIBBLE_WRITE KernelA_H_W, #BC_STA, #REFP1
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
    jmp .endif_1
.else_1:
    ldx #RESP1
    stx [RamKernelPhpTarget + 0]
.if_3:
    asl
    bcc .else_3
    jmp .endif_3
.else_3:
    ldx #BC_STA
    stx [KernelA_D_W + 0]
    ldx #RESP1
    stx [KernelA_D_W + 1]
    ldx #BC_STX
    stx [KernelA_G_W + 0]
    ldx #BC_STX
    stx [KernelA_H_W + 0]
.endif_3:
.endif_1:
    ENDM

