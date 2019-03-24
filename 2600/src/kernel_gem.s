;
; Gem Kernels
;
; Gems are displayed in alternating kernels. This chart shows
; which kernel is responsible for which gem, with missiles denoted.
;
;  1:   |SS  SS   SS  |SS  MSS  SS  |        kernel 1 (S = Sprite, M = missile)
;  2:   |  SS  SSM  SS|  SS   SS  SS|        kernel 2
;  =    |1122112221122|1122111221122|        kernel #
;  #    0^      8^       17^       26^       gem index
;
; The middle bar indicates where the pattern reverses.
;
; Because we can repeat a sprite multiple times, and reset the sprite
; occurance mid-line, we can render close to half of the 26 gems a line
; requires with a single sprite. By alternating sprites each frame with an...
; acceptable amount of flicker (15Hz) we can render almost all the gems on each
; line, except for two. These are instead rendered by the missile, which
; corresponds to the sprite and must have the same color and repeat pattern.

    ; for copying
    align 256

; KERNEL 1

; Emerald line macro (1, 2, ...)

kernel_1_start: subroutine
    rorg $f100

Kernel1: subroutine
    ; sleep first make this distinct from
    ; other kernel for debug scenarios
    ASSERT_RUNTIME "sp == $f9"
    sleep 6
    pla
    sta GRP0

    lda #EMR1
    ldx #EMR2
    ldy #EMR3
.gem_00:
    .byte GEM_00, EMERALD_SP ; moveable?

; Critical: 22c (start of precise timing)
    ; [A]
    sta EMERALD_SP_RESET ; trivial
    ; [B]
    sta EMERALD_MI_ENABLE ; trivial ; Is this timing-critical??
    ; [C]
    sleep 3

.gem_04:
    ; [D]
    .byte GEM_04, EMERALD_SP

    ; middle triplet; first kernel 1???
    ; [E]
    sta EMERALD_SP_RESET ; trivial
.gem_09:
    ; [F]
    .byte GEM_09, EMERALD_SP

    ; [G]
    sleep 3

.gem_13:
    ; [H]
    .byte GEM_13, EMERALD_SP

    ; [I]
    sta EMERALD_SP_RESET ; trivial
.gem_17:

    ; spare; missle writes
    ; [J]
    .byte GEM_17, EMERALD_MI_ENABLE ; could htis ever possibly be
    ; moved out of the kernel, and if so, huge wins
    ; (makes next sprite a freebie too, then just dealing with 3)
    ; unique sprite values!!
    ; or at least the write of the particular OPCODE out of hte krernel ?
    ; even extreme measures...! PHP with Z register!!! muahaha
    ; dunno how to deal with the opcode length change though?

    ; middle triplet; third kernel 1???
.gem_18:
    ; [K]
    .byte GEM_18, EMERALD_SP

    ; [L]
    sleep 3
.gem_22:
    ; [M]
    .byte GEM_22, EMERALD_SP

    ; [N]
    sleep 3
    ; [O]
    sleep 3
    ; [P]
    sleep 3

    ASSERT_RUNTIME "_scycles == #70"
    ; 6c
    rts

; Writable offsets
GEM_00_W equ [.gem_00 - $100]
GEM_04_W equ [.gem_04 - $100]
GEM_09_W equ [.gem_09 - $100]
GEM_13_W equ [.gem_13 - $100]
GEM_17_W equ [.gem_17 - $100]
GEM_18_W equ [.gem_18 - $100]
GEM_22_W equ [.gem_22 - $100]

    rend
kernel_1_end:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; KERNEL B

; Emerald line macro (3, 4, ...)

kernel_2_start: subroutine
    rorg $f100

Kernel2: subroutine
    ASSERT_RUNTIME "sp == $f9"
    ; don't sleep first to make this distinct from kernel 1
    pla
    sta GRP0
    sleep 4

    ; Enable missile (using excessive lda instructions)
    lda #02
    ldx #T2
    ldy #T3
.gem_08:
    .byte GEM_08, EMERALD_MI_ENABLE ; movable
    lda #T1 ; movable?
.gem_02:
    ; load the first sprite
    .byte GEM_02, EMERALD_SP ; movable

    ; TODO preload the second sprite and 
    ; have that write GEM_06

; Critical: 25c (start of precise timing)
    ASSERT_RUNTIME "_scycles == #25"

    ; [A]
    sta EMERALD_SP_RESET ; trivial
    ; [B]
    sleep 3
    ; [C]
    sleep 3

    ; end triplet; bonus VDEL write
.gem_06:
    ; [D]
    .byte GEM_06, EMERALD_SP

    ; middle triplet; write or change nusiz
    ; [E]
    sta EMERALD_SP_RESET ; trivial
.gem_11:
    ; [F]
    .byte GEM_11, EMERALD_SP

    ; disable missle
    ; [G]
    stx EMERALD_MI_ENABLE
    ; sleep 3
    ; ^ could this be moved, and then free the timing slot
    ; then can do the setting of PF1 value(!)

    ; end triplet; write or reset
.gem_15:
    ; [H]
    .byte GEM_15, EMERALD_SP
    ; 49c midway
    ; [I]
    sta EMERALD_SP_RESET ; spare

.gem_20:
    ; [J]
    .byte GEM_20, EMERALD_SP
    ; [K]
    sleep 3 ; spare

    ; end triplet; free
.gem_24:
    ; [L]
    .byte GEM_24, EMERALD_SP

    ; [M]
    sleep 3
    ; [N]
    sleep 3

    ; [O]
    sleep 3

    ASSERT_RUNTIME "_scycles == #70"
    ; 6c
    rts

; Writable offsets
GEM_02_W equ [.gem_02 - $100]
GEM_06_W equ [.gem_06 - $100]
GEM_08_W equ [.gem_08 - $100]
GEM_11_W equ [.gem_11 - $100]
GEM_15_W equ [.gem_15 - $100]
GEM_20_W equ [.gem_20 - $100]
GEM_24_W equ [.gem_24 - $100]

    rend
kernel_2_end:
