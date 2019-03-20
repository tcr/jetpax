    processor 6502

    ; Global headers
    include "vcs.h"
    include "macro.h"
    include "xmacro.h"
    include "vars.h"
    include "sprites.h"

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
    include "init.s"
    include "loader.s"
    include "frame.s"
    include "input.s"
    include "kernel.s"
    include "kernel_gem.s"
    include "data_sprites.s"
    include "data_levels.s"

    org $fffc
    .word Start
    .word Start
