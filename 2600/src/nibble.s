NIBBLE_gem_kernel_OPCODE_1:
    lda #%011000110
    ASSERT_SIZE_EXACT NIBBLE_gem_kernel_OPCODE_1, ., 2
NIBBLE_gem_kernel_OPCODE_2:
    lda #%000000000
    ASSERT_SIZE_EXACT NIBBLE_gem_kernel_OPCODE_2, ., 2

    MAC NIBBLE_gem_kernel
.if_1:
    asl
    bcc .else_1
    ldx [NIBBLE_gem_kernel_OPCODE_1 + 0]
    stx [[KernelA_TEST - $100] + 0]
    ldx [NIBBLE_gem_kernel_OPCODE_1 + 1]
    stx [[KernelA_TEST - $100] + 1]
    jmp .endif_1
.else_1:
    ldx [NIBBLE_gem_kernel_OPCODE_2 + 0]
    stx [[KernelA_TEST - $100] + 0]
    ldx [NIBBLE_gem_kernel_OPCODE_2 + 1]
    stx [[KernelA_TEST - $100] + 1]
.endif_1:
    ENDM

