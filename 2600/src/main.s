    processor 6502

    ; Nibble null methods
    mac NIBBLE_START_KERNEL
        NIBBLE_gem_kernel_BUILD ; todo make generic?
        seg.U ignoreme ; comment out rest of code
    endm
    mac NIBBLE_IF
    endm
    mac NIBBLE_WRITE
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

    ; Global headers
    include "vcs.h"
    include "macro.h"
    include "xmacro.h"

    ; RAM and constants
    include "game_vars.s"

    ; Bank 1
    seg CodeBank1
    org $D000
    rorg $F000
BANK1 byte
    org $d200
    rorg $d200
Bank1Start:
    lda $fffa
    nop
    nop
    nop

    org $dffc
    rorg $fffc
    .word Bank1Start
    .word Bank1Start

    ; Bank 2
    seg CodeBank2
    org $E000
    rorg $F000
BANK2 byte
    org $e200
    rorg $f200
Bank2Start:
    lda $fffa
    nop
    nop
    nop

    org $effc
    rorg $fffc
    .word Bank2Start
    .word Bank2Start

    ; Bank 3
    seg CodeBank3
    org $F000
    rorg $F000
BANK3 byte
    org $f200
    rorg $f200
Bank3Start:
    lda $fffa
    nop
    nop
    nop
    jmp Start

    ; Bank 3 source code
    include "game_init.s"
    include "kernel_loader.s"
    include "nibble.s"
    include "game_frame.s"
    include "game_input.s"
    include "kernel_border.s"
    include "kernel_row.s"
    include "kernel_gem.s"
    include "data_sprites.s"
    include "data_levels.s"

    org $fffc
    .word Start
    .word Start
