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
    rol
    sleep 6
    ; then: BuildState { index: 1, checkdepth: 1, cycles: 37 }

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
    rol
    sleep 3
    ; then: BuildState { index: 2, checkdepth: 2, cycles: 37 }

    jmp .endif_2
.else_2:
    asl
    bcc .else_3
    ; parent: BuildState { index: 2, checkdepth: 2, cycles: 24 }
.if_3:
    ldx #[ #BC_STX ]
    stx [[KernelA_D_W + 0] + 0]
    ldx #[ #REFP1 ]
    stx [[KernelA_D_W + 1] + 0]
    ; then: BuildState { index: 3, checkdepth: 3, cycles: 37 }

    jmp .endif_3
.else_3:
    NIBBLE_RAM_LOAD ldx, NibbleGemini1
    stx [[KernelA_D_W + 0] + 0]
    ldx #[ #GRP1 ]
    stx [[KernelA_D_W + 1] + 0]
    ; else: BuildState { index: 3, checkdepth: 3, cycles: 37 }
.endif_3:
    ; else: BuildState { index: 3, checkdepth: 3, cycles: 37 }
.endif_2:
    ; else: BuildState { index: 3, checkdepth: 3, cycles: 37 }
.endif_1:
    asl
    bcc .else_4
    ; parent: BuildState { index: 3, checkdepth: 3, cycles: 41 }
.if_4:
    ldx #[ #NOP_REG ]
    stx [[KernelA_E_W + 1] + 0]
    ldx #[ #RESP1 ]
    stx [[KernelA_G_W + 1] + 0]
    rol
    sleep 8
    ; then: BuildState { index: 4, checkdepth: 4, cycles: 64 }

    jmp .endif_4
.else_4:
    ldx #[ #RESP1 ]
    stx [[KernelA_E_W + 1] + 0]
    asl
    bcc .else_5
    ; parent: BuildState { index: 4, checkdepth: 4, cycles: 51 }
.if_5:
    ldx #[ #RESP1 ]
    stx [[KernelA_G_W + 1] + 0]
    sleep 5
    ; then: BuildState { index: 5, checkdepth: 5, cycles: 64 }

    jmp .endif_5
.else_5:
    NIBBLE_RAM_LOAD ldx, NibbleGemini2
    stx [[KernelA_G_W + 0] + 0]
    ldx #[ #GRP1 ]
    stx [[KernelA_G_W + 1] + 0]
    ; else: BuildState { index: 5, checkdepth: 5, cycles: 64 }
.endif_5:
    ; else: BuildState { index: 5, checkdepth: 5, cycles: 64 }
.endif_4:
    asl
    bcc .else_6
    ; parent: BuildState { index: 5, checkdepth: 5, cycles: 68 }
.if_6:
    ldx #[ #RESP1 ]
    stx [[KernelA_H_W + 1] + 0]
    rol
    sleep 8
    ; then: BuildState { index: 6, checkdepth: 6, cycles: 86 }

    jmp .endif_6
.else_6:
    asl
    bcc .else_7
    ; parent: BuildState { index: 6, checkdepth: 6, cycles: 73 }
.if_7:
    ldx #[ #RESP1 ]
    stx [[KernelA_H_W + 1] + 0]
    sleep 5
    ; then: BuildState { index: 7, checkdepth: 7, cycles: 86 }

    jmp .endif_7
.else_7:
    NIBBLE_RAM_LOAD ldx, NibbleGemini3
    stx [[KernelA_H_W + 0] + 0]
    ldx #[ #GRP1 ]
    stx [[KernelA_H_W + 1] + 0]
    ; else: BuildState { index: 7, checkdepth: 7, cycles: 86 }
.endif_7:
    ; else: BuildState { index: 7, checkdepth: 7, cycles: 86 }
.endif_6:
    ; end: 86 cycles
