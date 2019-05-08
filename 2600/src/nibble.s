
    MAC NIBBLE_gem_kernel_BUILD
    ldx $f100
    cpx #$b
.if_1:
    bcc .else_1
    cpx #$ff
.if_2:
    bcc .else_2
    jmp .endif_2
.else_2:
.endif_2:
    jmp .endif_1
.else_1:
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
    ldx #$85
    stx [KernelB_H - $100 + 0]
    ldx #EMERALD_SP
    stx [KernelB_H - $100 + 1]
    ldx #$08
    stx [KernelB_H - $100 + 2]
    jmp .endif_2
.else_2:
    ldx #EMERALD_SP
    stx RamKernelPhpTarget
    ldx #$08
    stx [KernelB_H - $100 + 0]
    ldx #$85
    stx [KernelB_H - $100 + 1]
    ldx #EMERALD_SP_RESET
    stx [KernelB_H - $100 + 2]
.endif_2:
    jmp .endif_1
.else_1:
    ldx #RESP1
    stx RamKernelPhpTarget
.endif_1:
    ENDM

