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
    ; end: 53 cycles
