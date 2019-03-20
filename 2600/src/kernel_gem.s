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
; 
; TODO there is a better writeup of how to get the last few sprites on the line
; with missles in some notebook somewhere?
;
;
; Gem Kernel Map by Color Clock
;
; - 3 Color Clocks = 1 CPU cycle
; - Kernel opcodes are 3 cycles = 9 color clocks
; - Playfield pixels = 4 color clocks wide
; - 
;
;    v 22c    v 25c             v 31c                                                                                              v 64c    v 67c
;    v -2P    v 7P             v 24P     v 34P    v 43P                               v 79P                               v 115P               v 136P
; A: AAAAAAAAABBBBBBBBBCCCCCCCCCDDDDDDDDDAAAAAAAAABBBBBBBBBCCCCCCCCCDDDDDDDDDAAAAAAAAABBBBBBBBBCCCCCCCCCDDDDDDDDDEEEEEEEEE.........,,,,,,,,,---------
;                                                 GEM9     PF1      GEM13    RESP1    M0=off   GEM18    LDA      GEM22
;             !--------****        _11__11_       !_11__11_****        _11__11_       !_11__11_****     MM _11__11_       |_11__11_        
; Gems:                        ====_XX__XX__XX__XX__XX__XX__XX__XX__XX__XX__XX__XX__XX__XX__XX__XX__XX__XX__XX__XX__XX__XX__XX__XX__XX__XX_====
; B:          AAAAAAAAABBBBBBBBBCCCCCCCCCDDDDDDDDDAAAAAAAAABBBBBBBBBCCCCCCCCCDDDDDDDDDAAAAAAAAABBBBBBBBBCCCCCCCCCDDDDDDDDD,,,,,,,,,.........,,,,,,,,,---------
;                                        GEM6     RESP1    GEM11    M1=on    GEM15    RESP1    GEM20    LDA      GEM24    ?
;                      !--------****        22__22__       !22__22__*MM*        22__22__       !22__22__****        22__22__       |22__22__
; PF |0                1       ====                    2                               0               1                               2   ====|
;
;   ====   playfield wall
;    !     RESP0 
;    |     Let RESP0 chaining lapse
;   ****   Mysterious post-resp0 4 cycle wait
;    MM    Missile
;    ABCs  Resp0 sequences
;

    ; for copying
    align 256

; KERNEL 1

; Emerald line macro (1, 2, ...)

kernel_1_start: subroutine
    ; sleep first make this distinct from
    ; other kernel for debug scenarios
    sleep 6
    pla
    sta GRP0

    lda #EMR1
    ldx #EMR2
    ldy #EMR3
.gem_00
    .byte GEM_00, EMERALD_SP ; moveable?

; Critical: 22c (start of precise timing)
    ; (A)
    sta EMERALD_SP_RESET ; trivial
    ; (B)
    sta EMERALD_MI_ENABLE ; trivial ; Is this timing-critical??
    ; (C)
    sleep 3
    ; (D) far

    ; TODO bonus VDEL sprite
.gem_04
    .byte GEM_04, EMERALD_SP

    ; middle triplet; first kernel 1???
    ; (A)
    sta EMERALD_SP_RESET ; trivial
.gem_09
    ; (B)
    .byte GEM_09, EMERALD_SP

    ; TODO PF1 load
    ; (C)
    sleep 3

    ; end triplet; second kernel 1???
.gem_13
    ; (D) for far ?
    .byte GEM_13, EMERALD_SP

    ; reset (A)
    sta EMERALD_SP_RESET ; trivial
.gem_17

    ; spare; missle writes
    ; 49c (B)
    .byte GEM_17, EMERALD_MI_ENABLE ; could htis ever possibly be
    ; moved out of the kernel, and if so, huge wins
    ; (makes next sprite a freebie too, then just dealing with 3)
    ; unique sprite values!!
    ; or at least the write of the particular OPCODE out of hte krernel ?
    ; even extreme measures...! PHP with Z register!!! muahaha
    ; dunno how to deal with the opcode length change though?

    ; middle triplet; third kernel 1??? (C)
.gem_18
    .byte GEM_18, EMERALD_SP

    ; end triplet; free (D)
    sleep 3
.gem_22
    ; (E) past far ????
    .byte GEM_22, EMERALD_SP
; Critical End: 64c (cycle follows start of right border)

    sleep 9
    rts
kernel_1_end:

; Writable offsets
GEM_00_W equ [$1000 + .gem_00 - kernel_1_start]
GEM_04_W equ [$1000 + .gem_04 - kernel_1_start]
GEM_09_W equ [$1000 + .gem_09 - kernel_1_start]
GEM_13_W equ [$1000 + .gem_13 - kernel_1_start]
GEM_17_W equ [$1000 + .gem_17 - kernel_1_start]
GEM_18_W equ [$1000 + .gem_18 - kernel_1_start]
GEM_22_W equ [$1000 + .gem_22 - kernel_1_start]


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; KERNEL 2

; Emerald line macro (3, 4, ...)

kernel_2_start: subroutine
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
    ; (A)
    sta EMERALD_SP_RESET ; trivial

    ; already set middle triplet
    ;ldx #%00010010
    ;stx.w NUSIZ1
    ; (B) (C)
    sleep 6

    ; end triplet; bonus VDEL write
.gem_06:
    ; (D)
    .byte GEM_06, EMERALD_SP

    ; middle triplet; write or change nusiz
    ; (A)
    sta EMERALD_SP_RESET ; trivial
.gem_11:
    ; (B)
    .byte GEM_11, EMERALD_SP

    ; disable missle
    ; (C)
    stx EMERALD_MI_ENABLE
    ; sleep 3
    ; ^ could this be moved, and then free the timing slot
    ; then can do the setting of PF1 value(!)

    ; end triplet; write or reset
.gem_15:
    ; (D)
    .byte GEM_15, EMERALD_SP
    ; 49c midway
    ; (A)
    sta EMERALD_SP_RESET ; spare
    ; PF2

    ; middle triplet; write or change nusiz
.gem_20:
    ; (B)
    .byte GEM_20, EMERALD_SP
    ; (C)
    sleep 3 ; spare

    ; end triplet; free
.gem_24:
    ; (D)
    .byte GEM_24, EMERALD_SP
; Critical End: 61c (just before gem 24 render)

    ; ldx #%0001001
    ; stx.w NUSIZ1
    sleep 9
    rts
kernel_2_end:

; Writable offsets
GEM_02_W equ [$1000 + .gem_02 - kernel_2_start]
GEM_06_W equ [$1000 + .gem_06 - kernel_2_start]
GEM_08_W equ [$1000 + .gem_08 - kernel_2_start]
GEM_11_W equ [$1000 + .gem_11 - kernel_2_start]
GEM_15_W equ [$1000 + .gem_15 - kernel_2_start]
GEM_20_W equ [$1000 + .gem_20 - kernel_2_start]
GEM_24_W equ [$1000 + .gem_24 - kernel_2_start]
