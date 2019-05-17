    processor 6502

    ; Nibble null methods
    mac NIBBLE_START_KERNEL
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


; Perform a left rotation on the 32 bit number at
; location VLA and store the result at location
; RES. If VLA and RES are the same then the
; operation is applied directly to the memory,
; otherwise it is done in the accumulator.
;
; On exit: A = ??, X & Y are unchanged.

	mac _ROL32
VLA EQU {1}
RES EQU {2}
		IF VLA != RES
		 LDA VLA+0
		 ROL A
		 STA RES+0
		 LDA VLA+1
		 ROL A
		 STA RES+1
		 LDA VLA+2
		 ROL A
		 STA RES+2
		 LDA VLA+3
		 ROL A
		 STA RES+3
		ELSE
		 ROL VLA+0
		 ROL VLA+1
		 ROL VLA+2
		 ROL VLA+3
		ENDIF
		ENDM

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
