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
    ; end: 49 cycles
