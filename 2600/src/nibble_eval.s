    MAC NIBBLE_gem_kernel_a_1
    asl
    bcc .else_1
    ; parent: BuildState { index: 0, checkdepth: 0, cycles: 4 }
.if_1:
    ldx #[ #BC_LDA_IMM ]
    stx [[KernelA_B - $100] + 0]
    ldx #[ #%10100000 ]
    stx [[KernelA_B - $100 + 1] + 0]
    ldx #[ #EMERALD_SP_RESET ]
    stx [[KernelA_C - $100 + 1] + 0]
    ldx #[ #$14 ]
    stx [[KernelA_D - $100] + 0]
    rol
    ; then: BuildState { index: 1, checkdepth: 1, cycles: 32 }

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
    sleep 3
    ; then: BuildState { index: 2, checkdepth: 2, cycles: 26 }

    jmp .endif_2
.else_2:
    NIBBLE_RAM_LOAD ldx, NibbleGemini1
    stx [[KernelA_D_W + 0] + 0]
    NIBBLE_RAM_LOAD ldx, NibbleGemini1Reg
    stx [[KernelA_D_W + 1] + 0]
    ; else: BuildState { index: 2, checkdepth: 2, cycles: 26 }
.endif_2:
    sleep 6
    ; else: BuildState { index: 2, checkdepth: 2, cycles: 32 }
.endif_1:
    asl
    bcc .else_3
    ; parent: BuildState { index: 2, checkdepth: 2, cycles: 36 }
.if_3:
    ldx #[ #NOP_REG ]
    stx [[KernelA_E_W + 1] + 0]
    ldx #[ #RESP1 ]
    stx [[KernelA_G_W + 1] + 0]
    sleep 9
    ; then: BuildState { index: 3, checkdepth: 3, cycles: 59 }

    jmp .endif_3
.else_3:
    ldx #[ #RESP1 ]
    stx [[KernelA_E_W + 1] + 0]
    NIBBLE_RAM_LOAD ldx, NibbleGemini2
    stx [[KernelA_G_W + 0] + 0]
    NIBBLE_RAM_LOAD ldx, NibbleGemini2Reg
    stx [[KernelA_G_W + 1] + 0]
    ; else: BuildState { index: 3, checkdepth: 3, cycles: 59 }
.endif_3:
    asl
    bcc .else_4
    ; parent: BuildState { index: 3, checkdepth: 3, cycles: 63 }
.if_4:
    ldx #[ #RESP1 ]
    stx [[KernelA_H_W + 1] + 0]
    sleep 9
    ; then: BuildState { index: 4, checkdepth: 4, cycles: 80 }

    jmp .endif_4
.else_4:
    NIBBLE_RAM_LOAD ldx, NibbleGemini3
    stx [[KernelA_H_W + 0] + 0]
    NIBBLE_RAM_LOAD ldx, NibbleGemini3Reg
    stx [[KernelA_H_W + 1] + 0]
    ; else: BuildState { index: 4, checkdepth: 4, cycles: 80 }
.endif_4:
    ENDM ; 80 cycles max




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
    sleep 3
    ; then: BuildState { index: 1, checkdepth: 1, cycles: 39 }

    jmp .endif_1
.else_1:
    ldx #[ #BC_PHP ]
    stx [[KernelA_I_W + 0] + 0]
    ldx #[ #BC_STA ]
    stx [[KernelA_J_W + 0] + 0]
    ldx #[ #PF1 ]
    stx [[KernelA_J_W + 0] + 1]
    NIBBLE_RAM_LOAD ldx, NibbleGemini4
    stx [[KernelA_K_W + 0] + 0]
    ldx #[ #EMERALD_SP ]
    stx [[KernelA_K_W + 1] + 0]
    sleep 2
    ; else: BuildState { index: 1, checkdepth: 1, cycles: 39 }
.endif_1:
    NIBBLE_RAM_LOAD ldx, NibbleMissile
    stx [[KernelA_F - $100] + 0]
    NIBBLE_RAM_LOAD ldx, NibbleVdel1
    stx [[KernelA_VDEL1 - $100] + 0]
    NIBBLE_RAM_LOAD ldx, NibbleGrp0
    stx [[KernelA_VDEL0 - $100] + 0]
    ENDM ; 63 cycles max




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
    NIBBLE_RAM_LOAD ldx, NibbleGemini3
    stx [[KernelB_H_W + 0] + 0]
    ldx #[ #EMERALD_SP ]
    stx [[KernelB_H_W + 1] + 0]
    rol
    sleep 3
    ; then: BuildState { index: 1, checkdepth: 1, cycles: 55 }

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
    NIBBLE_RAM_LOAD ldx, NibbleGemini2
    stx [[KernelB_F_W + 1] + 0]
    ldx #[ #EMERALD_SP ]
    stx [[KernelB_F_W + 2] + 0]
    ldx #[ #BC_STA ]
    stx [[KernelB_G_W + 1] + 0]
    ldx #[ #PF1 ]
    stx [[KernelB_G_W + 2] + 0]
    ldx #[ #BC_PHP ]
    stx [[KernelB_H_W + 1] + 0]
    ; then: BuildState { index: 2, checkdepth: 2, cycles: 55 }

    jmp .endif_2
.else_2:
    NIBBLE_RAM_LOAD ldx, NibbleGemini2
    stx [[KernelB_F_W + 0] + 0]
    ldx #[ #EMERALD_SP ]
    stx [[KernelB_F_W + 1] + 0]
    NIBBLE_RAM_LOAD ldx, NibbleGemini3
    stx [[KernelB_H_W + 0] + 0]
    ldx #[ #EMERALD_SP ]
    stx [[KernelB_H_W + 1] + 0]
    sleep 17
    ; else: BuildState { index: 2, checkdepth: 2, cycles: 55 }
.endif_2:
    ; else: BuildState { index: 2, checkdepth: 2, cycles: 55 }
.endif_1:
    ENDM ; 55 cycles max




    MAC NIBBLE_gem_kernel_b_2
    NIBBLE_RAM_LOAD ldx, NibbleGemini1
    stx [KernelB_D_W + 0]
    asl
    bcc .else_1
    ; parent: BuildState { index: 0, checkdepth: 0, cycles: 12 }
.if_1:
    ldx #[ #RamFFByte ]
    stx [[KernelB_C - $100 + 1] + 0]
    sleep 2
    ; then: BuildState { index: 1, checkdepth: 1, cycles: 22 }

    jmp .endif_1
.else_1:
    ldx #[ #RamPF1Value ]
    stx [[KernelB_C - $100 + 1] + 0]
    sleep 3
    ; else: BuildState { index: 1, checkdepth: 1, cycles: 22 }
.endif_1:
    NIBBLE_RAM_LOAD ldx, NibbleGemini4
    stx [KernelB_J_W + 0]
    NIBBLE_RAM_LOAD ldx, NibbleGrp0
    stx [[KernelB_VDEL0 - $100] + 0]
    ENDM ; 38 cycles max




