
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
    jmp .endif_2
.else_2:
.endif_2:
    jmp .endif_1
.else_1:
    ; Kernel A
    ; NIBBLE_WRITE RamKernelPhpTarget, #RESP1
    cpx #$00
.if_3:
    rol
    bcc .else_3
    ; NIBBLE_WRITE RamKernelPhpTarget, #EMERALD_SP_RESET
    jmp .endif_3
.else_3:
    ; NIBBLE_WRITE RamKernelPhpTarget, #RESP1
.endif_3:
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
    stx RamKernelPhpTarget
    ldx #BC_STA
    stx [KernelB_H_W + 0]
    ldx #EMERALD_SP
    stx [KernelB_H_W + 1]
    ldx #BC_PHP
    stx [KernelB_H_W + 2]
    jmp .endif_2
.else_2:
    ldx #EMERALD_SP
    stx RamKernelPhpTarget
    ldx #BC_PHP
    stx [KernelB_H_W + 0]
    ldx #BC_STA
    stx [KernelB_H_W + 1]
    ldx #EMERALD_SP_RESET
    stx [KernelB_H_W + 2]
.endif_2:
    jmp .endif_1
.else_1:
.if_3:
    asl
    bcc .else_3
    ldx #BC_STX
    stx [KernelA_D + 0]
    ldx #GRP1
    stx [KernelA_D + 0]
    jmp .endif_3
.else_3:
    ldx #BC_STY
    stx [KernelA_D + 0]
    ldx #GRP1
    stx [KernelA_D + 0]
.endif_3:
.endif_1:
    ENDM

