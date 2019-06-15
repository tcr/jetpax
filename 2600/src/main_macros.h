    ; Nibble null methods
    mac NIBBLE_START_KERNEL
        seg.U ignoreme ; comment out rest of code
    endm
    mac NIBBLE_VAR
    endm
    mac NIBBLE_VAR_STY
    endm
    mac NIBBLE_IF
    endm
    mac NIBBLE_WRITE_IMM
    endm
    mac NIBBLE_WRITE_VAR
    endm
    mac NIBBLE_WRITE_OPCODE
    endm
    mac NIBBLE_ELSE
    endm
    mac NIBBLE_END_IF
    endm
    mac NIBBLE_END_KERNEL
        seg CodeBank3
    endm

    ; Dynamic, runtime (Stella) assertions for "make debug"
    mac NIBBLE_RAM_STORE
        {1} [CBSRAM_NIBBLE_WRITE + {2}],y
    endm

    mac NIBBLE_RAM_LOAD
        {1} [CBSRAM_NIBBLE_READ + {2}],y
    ; {1} .KEY
    endm

    mac NIBBLE_RAM_ROR
        NIBBLE_RAM_LOAD {1}, {3}
        ror
        NIBBLE_RAM_STORE {2}, {3}
    endm

    mac CALC_REGS_AND_STORE_A
.OFFSET SET {1}
    lda [DO_GEMS_A + .OFFSET]
    jsr Kernel_UpdateRegs
    NIBBLE_RAM_STORE sta, {2}
    endm


    mac CALC_REGS_AND_STORE
.OFFSET SET {1}
    lda [DO_GEMS_B + .OFFSET]
    jsr Kernel_UpdateRegs
    NIBBLE_RAM_STORE sta, {2}
    endm


    ; Dynamic, runtime (Stella) assertions for "make debug"
    mac ASSERT_RUNTIME
.COND SET {1}
    echo "ASSERT:", "breakif { pc==", ., " && !( ", .COND, " ) }"
    endm


    ; Dynamic, runtime (Stella) assertions for "make debug"
    mac ASSERT_RUNTIME_KERNEL
.KERNEL SET {1}
.COND SET {2}
    echo "ASSERT:", "breakif { pc==", ., " && ( *$f100 == ", .KERNEL, "  ) && ! ( ", .COND, " ) }"
    endm

    ; Static assertions for size
    mac ASSERT_SIZE
.STARTA SET {1}
.ENDA SET {2}
.LEN SET {3}
    if [[.ENDA - .STARTA] >= .LEN]
        echo "Error: Exceeded size limit", [.ENDA - .STARTA], "vs", .LEN
        err
    endif
    endm
    mac ASSERT_SIZE_EXACT
.STARTA SET {1}
.ENDA SET {2}
.LEN SET {3}
    if [[.ENDA - .STARTA] != .LEN]
        echo ""
        echo "Error: Violated size limit", [.ENDA - .STARTA], "vs", .LEN
        err
    endif
    endm
