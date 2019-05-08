NIBBLE_gem_kernel_OPCODE_1:
    php
    ASSERT_SIZE_EXACT NIBBLE_gem_kernel_OPCODE_1, ., 1
NIBBLE_gem_kernel_OPCODE_2:
    sta EMERALD_SP_RESET
    ASSERT_SIZE_EXACT NIBBLE_gem_kernel_OPCODE_2, ., 2
NIBBLE_gem_kernel_OPCODE_3:
    php
    ASSERT_SIZE_EXACT NIBBLE_gem_kernel_OPCODE_3, ., 1
NIBBLE_gem_kernel_OPCODE_4:
    sta EMERALD_SP_RESET
    ASSERT_SIZE_EXACT NIBBLE_gem_kernel_OPCODE_4, ., 2

    MAC NIBBLE_gem_kernel
.if_1:
    asl
    bcc .endif_1
.if_2:
    asl
    bcc .else_2
    ldx [NIBBLE_gem_kernel_OPCODE_1 + 0]
    stx [[KernelB_D - $100 + 0] + 0]
    ldx [NIBBLE_gem_kernel_OPCODE_2 + 0]
    stx [[KernelB_D - $100 + 1] + 0]
    ldx [NIBBLE_gem_kernel_OPCODE_2 + 1]
    stx [[KernelB_D - $100 + 1] + 1]
    jmp .endif_2
.else_2:
    ldx [NIBBLE_gem_kernel_OPCODE_3 + 0]
    stx [[KernelB_H - $100 + 0] + 0]
    ldx [NIBBLE_gem_kernel_OPCODE_4 + 0]
    stx [[KernelB_H - $100 + 1] + 0]
    ldx [NIBBLE_gem_kernel_OPCODE_4 + 1]
    stx [[KernelB_H - $100 + 1] + 1]
.endif_2:
.endif_1:
    ENDM

