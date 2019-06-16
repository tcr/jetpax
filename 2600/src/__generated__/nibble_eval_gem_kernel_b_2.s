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
    ; end: 33 cycles
