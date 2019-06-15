    processor 6502

    ; Global headers
    include "vcs.h"
    include "macro.h"
    include "xmacro.h"
    include "main_macros.h"

    ; RAM and constants
    include "game_define.s"
    include "game_vars.s"

BANK_INITIAL_HOTSPOT = $fffa

    mac bank_init
    lda BANK_INITIAL_HOTSPOT
    nop
    nop
    nop
    endm

    mac bank_abort
    lda $fff9
    nop
    nop
    jmp ErrStart
    endm

    ;;;;;;;;;
    ; Bank 1
    ;;;;;;;;;

    seg CodeBank1
    org $D000
    rorg $F000
BANK1 byte

    org $d200
    rorg $d200
Bank1Brk:
    bank_abort
Bank1Start:
    bank_init

    org $dffc
    rorg $fffc
    .word Bank1Start
    .word Bank1Brk

    ;;;;;;;;;
    ; Bank 2
    ;;;;;;;;;

    seg CodeBank2
    org $E000
    rorg $F000
BANK2 byte

    org $e200
    rorg $f200
Bank2Brk:
    bank_abort
Bank2Start:
    bank_init
    jmp ErrStart

    include "error_frame.s"

    org $effc
    rorg $fffc
    .word Bank2Start
    .word Bank2Brk

    ;;;;;;;;;
    ; Bank 3
    ;;;;;;;;;

    seg CodeBank3
    org $F000
    rorg $F000
BANK3 byte

    org $f200
    rorg $f200
Bank3Brk:
    bank_abort
Bank3Start:
    bank_init
    jmp Start

    ; Bank 3 source code
    include "game_init.s"
    include "kernel_loader.s"
    include "kernel_gem.s"
    include "nibble_build.s"
    include "nibble_eval.s"
    ; TODO include "nibble_shard.s"
    include "game_frame.s"
    include "game_input.s"
    include "game_nibble.s"
    include "game_state.s"
    include "kernel_row.s"
    include "kernel_border.s"
    include "data_sprites.s"
    include "data_levels.s"

    org $fffc
    .word Bank3Start
    .word Bank3Brk
