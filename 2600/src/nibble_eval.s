    MAC NIBBLE_gem_kernel_a_1
.if_1:
    asl
    bcc .else_1
    jmp .endif_1
.else_1:
.if_2:
    asl
    bcc .else_2
    ldx #BC_STX
    stx [KernelA_D_W + 0]
    ldx #RESP1
    stx [KernelA_D_W + 1]
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
    ENDM ; 44 cycles max




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
.endif_1:
.if_2:
    asl
    bcc .else_2
    ldx #BC_NOP
    stx [[KernelA_F - $100] + 0]
    jmp .endif_2
.else_2:
    ldx BuildKernelMissile
    stx [[KernelA_F - $100] + 0]
.endif_2:
    ldx BuildKernelVdel1
    stx [[KernelA_VDEL1 - $100] + 0]
    ldx BuildKernelGrp0
    stx [[KernelA_VDEL0 - $100] + 0]
    ldx #$ff
    stx [RamPSByte + 0]
    ENDM ; 58 cycles max




    MAC NIBBLE_gem_kernel_b_1
    ldx RamKernelGemini1
    stx [KernelB_D_W + 0]
.if_1:
    asl
    bcc .else_1
    ldx #EMERALD_SP
    stx [RamKernelPhpTarget + 0]
    ldx #BC_STY
    stx [[KernelB_E_W + 0] + 0]
    ldx #EMERALD_SP_RESET
    stx [[KernelB_E_W + 0] + 1]
    ldx #BC_PHP
    stx [[KernelB_F_W + 1] + 0]
    ldx #BC_STA
    stx [[KernelB_G_W + 0] + 0]
    ldx #PF1
    stx [[KernelB_G_W + 0] + 1]
    ldx RamKernelGemini3
    stx [[KernelB_H_W + 0] + 0]
    ldx #EMERALD_SP
    stx [[KernelB_H_W + 0] + 1]
    jmp .endif_1
.else_1:
    ldx RamKernelGemini2
    stx [KernelB_F_W + 0]
    ldx #EMERALD_SP
    stx [KernelB_F_W + 1]
.endif_1:
.if_2:
    asl
    bcc .else_2
    ldx #EMERALD_SP
    stx [RamKernelPhpTarget + 0]
    ldx #BC_STY
    stx [[KernelB_E_W + 0] + 0]
    ldx #EMERALD_SP_RESET
    stx [[KernelB_E_W + 0] + 1]
    ldx RamKernelGemini2
    stx [[KernelB_F_W + 1] + 0]
    ldx #EMERALD_SP
    stx [[KernelB_F_W + 1] + 1]
    ldx #BC_STA
    stx [[KernelB_G_W + 1] + 0]
    ldx #PF1
    stx [[KernelB_G_W + 1] + 1]
    ldx #BC_PHP
    stx [[KernelB_H_W + 1] + 0]
    jmp .endif_2
.else_2:
    ldx RamKernelGemini3
    stx [KernelB_H_W + 0]
    ldx #EMERALD_SP
    stx [KernelB_H_W + 1]
.endif_2:
    ENDM ; 106 cycles max




    MAC NIBBLE_gem_kernel_b_2
.if_1:
    asl
    bcc .else_1
    ldx #RamFFByte
    stx [[KernelB_C - $100 + 1] + 0]
    jmp .endif_1
.else_1:
    ldx #RamPF1Value
    stx [[KernelB_C - $100 + 1] + 0]
.endif_1:
    ldx RamKernelGemini4
    stx [KernelB_J_W + 0]
    ldx BuildKernelGrp0
    stx [[KernelB_VDEL0 - $100] + 0]
    ldx #$00
    stx [RamPSByte + 0]
    ENDM ; 26 cycles max




