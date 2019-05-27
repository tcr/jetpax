    MAC NIBBLE_gem_kernel_a_1
    asl
    bcc .else_1
    ; parent: BuildState { index: 0, checkdepth: 0, cycles: 4 }
.if_1:
    rol
    sleep 17
    ; then: BuildState { index: 1, checkdepth: 1, cycles: 25 }

    jmp .endif_1
.else_1:
    asl
    bcc .else_2
    ; parent: BuildState { index: 1, checkdepth: 1, cycles: 9 }
.if_2:
    ldx #[ #BC_STX ]
    stx [[KernelA_D_W + 0] + 0]
    ldx #[ #RESP1 ]
    stx [[KernelA_D_W + 1] + 0]
    sleep 2
    ; then: BuildState { index: 2, checkdepth: 2, cycles: 25 }

    jmp .endif_2
.else_2:
    ldx.z RamKernelGemini1
    stx [[KernelA_D_W + 0] + 0]
    ldx.z RamKernelGemini1Reg
    stx [[KernelA_D_W + 1] + 0]
    sleep 3
    ; else: BuildState { index: 2, checkdepth: 2, cycles: 25 }
.endif_2:
    ; else: BuildState { index: 2, checkdepth: 2, cycles: 25 }
.endif_1:
    asl
    bcc .else_3
    ; parent: BuildState { index: 2, checkdepth: 2, cycles: 29 }
.if_3:
    ldx #[ #NOP_REG ]
    stx [[KernelA_E_W + 1] + 0]
    ldx #[ #RESP1 ]
    stx [[KernelA_G_W + 1] + 0]
    sleep 5
    ; then: BuildState { index: 3, checkdepth: 3, cycles: 48 }

    jmp .endif_3
.else_3:
    ldx #[ #RESP1 ]
    stx [[KernelA_E_W + 1] + 0]
    ldx.z RamKernelGemini2
    stx [[KernelA_G_W + 0] + 0]
    ldx.z RamKernelGemini2Reg
    stx [[KernelA_G_W + 1] + 0]
    ; else: BuildState { index: 3, checkdepth: 3, cycles: 48 }
.endif_3:
    asl
    bcc .else_4
    ; parent: BuildState { index: 3, checkdepth: 3, cycles: 52 }
.if_4:
    ldx #[ #RESP1 ]
    stx [[KernelA_H_W + 1] + 0]
    sleep 5
    ; then: BuildState { index: 4, checkdepth: 4, cycles: 65 }

    jmp .endif_4
.else_4:
    ldx.z RamKernelGemini3
    stx [[KernelA_H_W + 0] + 0]
    ldx.z RamKernelGemini3Reg
    stx [[KernelA_H_W + 1] + 0]
    ; else: BuildState { index: 4, checkdepth: 4, cycles: 65 }
.endif_4:
    ENDM ; 65 cycles max




    MAC NIBBLE_gem_kernel_a_2
    asl
    bcc .else_1
    ; parent: BuildState { index: 0, checkdepth: 0, cycles: 4 }
.if_1:
    ldx #[ #BC_STA ]
    stx [[KernelA_I_W + 0] + 0]
    ldx #[ #EMERALD_SP_RESET ]
    stx [[KernelA_I_W + 0] + 1]
    ldx #[ #BC_STA ]
    stx [[KernelA_J_W + 1] + 0]
    ldx #[ #PF1 ]
    stx [[KernelA_J_W + 1] + 1]
    ldx #[ #BC_PHP ]
    stx [[KernelA_K_W + 1] + 0]
    sleep 2
    ; then: BuildState { index: 1, checkdepth: 1, cycles: 38 }

    jmp .endif_1
.else_1:
    ldx #[ #BC_PHP ]
    stx [[KernelA_I_W + 0] + 0]
    ldx #[ #BC_STA ]
    stx [[KernelA_J_W + 0] + 0]
    ldx #[ #PF1 ]
    stx [[KernelA_J_W + 0] + 1]
    ldx.z RamKernelGemini4
    stx [[KernelA_K_W + 0] + 0]
    ldx #[ #EMERALD_SP ]
    stx [[KernelA_K_W + 1] + 0]
    sleep 3
    ; else: BuildState { index: 1, checkdepth: 1, cycles: 38 }
.endif_1:
    ldx.z BuildKernelMissile
    stx [[KernelA_F - $100] + 0]
    ldx.z BuildKernelVdel1
    stx [[KernelA_VDEL1 - $100] + 0]
    ldx.z BuildKernelGrp0
    stx [[KernelA_VDEL0 - $100] + 0]
    ldx #[ #$ff ]
    stx [RamPSByte + 0]
    ENDM ; 62 cycles max




    MAC NIBBLE_gem_kernel_b_1
    asl
    bcc .else_1
    ; parent: BuildState { index: 0, checkdepth: 0, cycles: 4 }
.if_1:
    ldx #[ #BC_STY ]
    stx [[KernelB_E_W + 0] + 0]
    ldx #[ #EMERALD_SP_RESET ]
    stx [[KernelB_E_W + 1] + 0]
    ldx #[ #BC_PHP ]
    stx [[KernelB_F_W + 1] + 0]
    ldx #[ #BC_STA ]
    stx [[KernelB_G_W + 0] + 0]
    ldx #[ #PF1 ]
    stx [[KernelB_G_W + 1] + 0]
    ldx.z RamKernelGemini3
    stx [[KernelB_H_W + 0] + 0]
    ldx #[ #EMERALD_SP ]
    stx [[KernelB_H_W + 1] + 0]
    rol
    sleep 3
    ; then: BuildState { index: 1, checkdepth: 1, cycles: 53 }

    jmp .endif_1
.else_1:
    asl
    bcc .else_2
    ; parent: BuildState { index: 1, checkdepth: 1, cycles: 9 }
.if_2:
    ldx #[ #BC_STY ]
    stx [[KernelB_E_W + 0] + 0]
    ldx #[ #EMERALD_SP_RESET ]
    stx [[KernelB_E_W + 1] + 0]
    ldx.z RamKernelGemini2
    stx [[KernelB_F_W + 1] + 0]
    ldx #[ #EMERALD_SP ]
    stx [[KernelB_F_W + 2] + 0]
    ldx #[ #BC_STA ]
    stx [[KernelB_G_W + 1] + 0]
    ldx #[ #PF1 ]
    stx [[KernelB_G_W + 2] + 0]
    ldx #[ #BC_PHP ]
    stx [[KernelB_H_W + 1] + 0]
    ; then: BuildState { index: 2, checkdepth: 2, cycles: 53 }

    jmp .endif_2
.else_2:
    ldx.z RamKernelGemini2
    stx [[KernelB_F_W + 0] + 0]
    ldx #[ #EMERALD_SP ]
    stx [[KernelB_F_W + 1] + 0]
    ldx.z RamKernelGemini3
    stx [[KernelB_H_W + 0] + 0]
    ldx #[ #EMERALD_SP ]
    stx [[KernelB_H_W + 1] + 0]
    sleep 19
    ; else: BuildState { index: 2, checkdepth: 2, cycles: 53 }
.endif_2:
    ; else: BuildState { index: 2, checkdepth: 2, cycles: 53 }
.endif_1:
    ENDM ; 53 cycles max




    MAC NIBBLE_gem_kernel_b_2
    ldx #[ RamKernelGemini1 ]
    stx [KernelB_D_W + 0]
    asl
    bcc .else_1
    ; parent: BuildState { index: 0, checkdepth: 0, cycles: 10 }
.if_1:
    ldx #[ #RamFFByte ]
    stx [[KernelB_C - $100 + 1] + 0]
    sleep 2
    ; then: BuildState { index: 1, checkdepth: 1, cycles: 20 }

    jmp .endif_1
.else_1:
    ldx #[ #RamPF1Value ]
    stx [[KernelB_C - $100 + 1] + 0]
    sleep 3
    ; else: BuildState { index: 1, checkdepth: 1, cycles: 20 }
.endif_1:
    ldx.z RamKernelGemini4
    stx [KernelB_J_W + 0]
    ldx.z BuildKernelGrp0
    stx [[KernelB_VDEL0 - $100] + 0]
    ldx #[ #$00 ]
    stx [RamPSByte + 0]
    ENDM ; 38 cycles max




