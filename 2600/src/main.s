    processor 6502

    include "jetpax.h"
    include "vars.h"

    include "banks.s"
    include "code.s"
    include "kernel_gem.s"
    include "input.s"

    align 256
    include "sprites.s"

    org $fffc
    .word Start
    .word Start
