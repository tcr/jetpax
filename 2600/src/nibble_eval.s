    MAC NIBBLE_gem_kernel_a_1
    asl
    bcc .else_1
    ; parent: BuildState { index: 0, checkdepth: 0, cycles: 4 }
.if_1:
    ldx #[ #BC_LDA_IMM ]
    stx [[KernelA_B_W + 0] + 0]
    ldx #[ #%10100000 ]
    stx [[KernelA_B_W + 1] + 0]
    ldx #[ #EMERALD_SP_RESET ]
    stx [[KernelA_C_W + 1] + 0]
    ldx #[ #$14 ]
    stx [[KernelA_D_W + 0] + 0]
    rol
    sleep 5
    ; then: BuildState { index: 1, checkdepth: 1, cycles: 34 }

    jmp .endif_1
.else_1:
    ldx #[ #BC_LDA ]
    stx [[KernelA_B_W + 0] + 0]
    ldx #[ #VDELP1 ]
    stx [[KernelA_C_W + 1] + 0]
    asl
    bcc .else_2
    ; parent: BuildState { index: 1, checkdepth: 1, cycles: 19 }
.if_2:
    ldx #[ #BC_STX ]
    stx [[KernelA_D_W + 0] + 0]
    ldx #[ #RESP1 ]
    stx [[KernelA_D_W + 1] + 0]
    sleep 2
    ; then: BuildState { index: 2, checkdepth: 2, cycles: 34 }

    jmp .endif_2
.else_2:
    NIBBLE_RAM_LOAD ldx, NibbleGemini1
    stx [[KernelA_D_W + 0] + 0]
    NIBBLE_RAM_LOAD ldx, NibbleGemini1Reg
    stx [[KernelA_D_W + 1] + 0]
    ; else: BuildState { index: 2, checkdepth: 2, cycles: 34 }
.endif_2:
    ; else: BuildState { index: 2, checkdepth: 2, cycles: 34 }
.endif_1:
    asl
    bcc .else_3
    ; parent: BuildState { index: 2, checkdepth: 2, cycles: 38 }
.if_3:
    ldx #[ #NOP_REG ]
    stx [[KernelA_E_W + 1] + 0]
    ldx #[ #RESP1 ]
    stx [[KernelA_G_W + 1] + 0]
    sleep 7
    ; then: BuildState { index: 3, checkdepth: 3, cycles: 58 }

    jmp .endif_3
.else_3:
    ldx #[ #RESP1 ]
    stx [[KernelA_E_W + 1] + 0]
    NIBBLE_RAM_LOAD ldx, NibbleGemini2
    stx [[KernelA_G_W + 0] + 0]
    NIBBLE_RAM_LOAD ldx, NibbleGemini2Reg
    stx [[KernelA_G_W + 1] + 0]
    ; else: BuildState { index: 3, checkdepth: 3, cycles: 58 }
.endif_3:
    asl
    bcc .else_4
    ; parent: BuildState { index: 3, checkdepth: 3, cycles: 62 }
.if_4:
    ldx #[ #RESP1 ]
    stx [[KernelA_H_W + 1] + 0]
    sleep 7
    ; then: BuildState { index: 4, checkdepth: 4, cycles: 77 }

    jmp .endif_4
.else_4:
    NIBBLE_RAM_LOAD ldx, NibbleGemini3
    stx [[KernelA_H_W + 0] + 0]
    NIBBLE_RAM_LOAD ldx, NibbleGemini3Reg
    stx [[KernelA_H_W + 1] + 0]
    ; else: BuildState { index: 4, checkdepth: 4, cycles: 77 }
.endif_4:
    ENDM ; 77 cycles max




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
    ; then: BuildState { index: 1, checkdepth: 1, cycles: 32 }

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
    ; else: BuildState { index: 1, checkdepth: 1, cycles: 32 }
.endif_1:
    NIBBLE_RAM_LOAD ldx, NibbleMissile
    stx [[KernelA_F_W + 0] + 0]
    NIBBLE_RAM_LOAD ldx, NibbleVdel1
    stx [[KernelA_VDEL1_W + 0] + 0]
    NIBBLE_RAM_LOAD ldx, NibbleGrp0
    stx [[KernelA_VDEL0_W + 0] + 0]
    ENDM ; 53 cycles max




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
    ; then: BuildState { index: 1, checkdepth: 1, cycles: 49 }

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
    ; then: BuildState { index: 2, checkdepth: 2, cycles: 49 }

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
    sleep 15
    ; else: BuildState { index: 2, checkdepth: 2, cycles: 49 }
.endif_2:
    ; else: BuildState { index: 2, checkdepth: 2, cycles: 49 }
.endif_1:
    ENDM ; 49 cycles max




    MAC NIBBLE_gem_kernel_b_2
    NIBBLE_RAM_LOAD ldx, NibbleGemini1
    stx [KernelB_D_W + 0]
    asl
    bcc .else_1
    ; parent: BuildState { index: 0, checkdepth: 0, cycles: 11 }
.if_1:
    ldx #[ #RamFFByte ]
    stx [[KernelB_C_W + 1] + 0]
    ; then: BuildState { index: 1, checkdepth: 1, cycles: 19 }

    jmp .endif_1
.else_1:
    ldx #[ #RamPF1Value ]
    stx [[KernelB_C_W + 1] + 0]
    sleep 2
    ; else: BuildState { index: 1, checkdepth: 1, cycles: 19 }
.endif_1:
    NIBBLE_RAM_LOAD ldx, NibbleGemini4
    stx [KernelB_J_W + 0]
    NIBBLE_RAM_LOAD ldx, NibbleGrp0
    stx [[KernelB_VDEL0_W + 0] + 0]
    ENDM ; 33 cycles max




