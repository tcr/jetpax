;
; Gem Kernels
;
; Gems are displayed in alternating kernels. This chart shows
; which kernel is responsible for which gem, with missiles denoted.
;
;  1:   |SS  SS  MSS  |SS   SS  SS  |        kernel 1 (S = Sprite, M = missile)
;  2:   |  SS  SS   SS|  SSM  SS  SS|        kernel 2
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; GEM KERNEL A
;

kernel_1_start: subroutine
    rorg $f100

Kernel1: subroutine
    ASSERT_RUNTIME "sp == $f9"

    ; this sleep first make this distinct from Kernel B in debugger, lol
    sleep 6

    ; Load next Player sprite
    pla
    sta GRP0

    lda #%01100000
    ldx #%00000110
    ldy #%01100110
    .byte GEM_00, EMERALD_SP

    ; 22c is critical start of precise GRP0 timing for Kernel A
    ASSERT_RUNTIME "_scycles == #22"
KernelA_A:
    sta EMERALD_SP_RESET
KernelA_B:
    stx EMERALD_MI_ENABLE
KernelA_C:
    sleep 3
KernelA_D:
    .byte GEM_04, EMERALD_SP
KernelA_E:
    sta EMERALD_SP_RESET
KernelA_F:
    .byte GEM_09, EMERALD_SP
KernelA_G:
    sleep 3
KernelA_H:
    .byte GEM_13, EMERALD_SP
KernelA_I:
    sta EMERALD_SP_RESET
KernelA_J:
    .byte GEM_17, EMERALD_MI_ENABLE
KernelA_K:
    .byte GEM_18, EMERALD_SP
KernelA_L:
    sleep 3
KernelA_M:
    .byte GEM_22, EMERALD_SP
KernelA_N:
    sleep 3
KernelA_O:
    sleep 3
KernelA_P:
    sleep 3

    ; 6c
    ASSERT_RUNTIME "_scycles == #70"
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; GEM KERNEL B
;

kernel_2_start: subroutine
    rorg $f100

Kernel2: subroutine
    ASSERT_RUNTIME "sp == $f9"
    ; Assert: M1 is at position #61
    
    ; don't sleep first to make this distinct from Kernel A in debugger, lol

    ; Load next Player sprite
    pla
    sta GRP0
    
    sleep 4

    lda #02
    ldx #%00001100
    ldy #%11001100
    .byte GEM_08, EMERALD_MI_ENABLE
    lda #%11000000
    .byte GEM_02, EMERALD_SP

    ; 25c is critical start of precise GRP0 timing for Kernel B
    ASSERT_RUNTIME "_scycles == #25"
KernelB_A:
    sta EMERALD_SP_RESET
KernelB_B:
    sleep 3
KernelB_C:
    sleep 3
KernelB_D:
    .byte GEM_06, EMERALD_SP
KernelB_E:
    sta EMERALD_SP_RESET
KernelB_F:
    .byte GEM_11, EMERALD_SP
KernelB_G:
    ;stx EMERALD_MI_ENABLE
    sleep 3
KernelB_H:
    .byte GEM_15, EMERALD_SP
KernelB_I:
    sta EMERALD_SP_RESET
KernelB_J:
    .byte GEM_20, EMERALD_SP
KernelB_K:
    sleep 3
KernelB_L:
    .byte GEM_24, EMERALD_SP
KernelB_M:
    sleep 3
KernelB_N:
    sleep 3
KernelB_O:
    sleep 3

    ; 6c
    ASSERT_RUNTIME "_scycles == #70"
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
