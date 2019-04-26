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
    sleep 3

    ; Load next Player sprite
    pla
    sta GRP0

KernelA_TEST:
    lda #%01100000
    ldx #%00000110
    ldy #%01100110

    sta EMERALD_MI_ENABLE ;disable

    sta EMERALD_SP

    ; 22c is critical start of precise GRP0 timing for Kernel A
    ASSERT_RUNTIME "_scycles == #22"
KernelA_A:
    stx EMERALD_SP_RESET
KernelA_B:
    sleep 3
KernelA_C:
    sleep 3
KernelA_D:
    sty EMERALD_SP
KernelA_E:
    sleep 3
KernelA_F:
    stx EMERALD_MI_ENABLE
KernelA_G:
    stx EMERALD_SP_RESET
KernelA_H:
    sty EMERALD_SP
KernelA_I:
    stx EMERALD_SP_RESET
KernelA_J:
    sleep 3  ; PF1
KernelA_K:
    sty EMERALD_SP
KernelA_L:
    sleep 3
KernelA_M:
    sty EMERALD_SP
KernelA_N:
    sleep 3
KernelA_O:
    sleep 3
KernelA_P:
    sleep 3

    ; 6c
    ASSERT_RUNTIME "_scycles == #70"
    rts

    rend
kernel_1_end:
    ASSERT_SIZE kernel_1_start, kernel_1_end, $40

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


    ldx #%00001100
    ldy #%11001100

    lda #02
    sta EMERALD_MI_ENABLE ; Enable missile

    lda #%11000000
    sty EMERALD_SP

    ; 25c is critical start of precise GRP0 timing for Kernel B
    ASSERT_RUNTIME "_scycles == #25"
KernelB_A:
    sta EMERALD_SP_RESET
KernelB_B:
    sleep 3
KernelB_C:
    sleep 3
KernelB_D:
    sty EMERALD_SP
KernelB_E:
    sta EMERALD_SP_RESET
KernelB_F:
    sty EMERALD_SP
KernelB_G: ; PF1
    sleep 3
KernelB_H:
    sty EMERALD_SP
KernelB_I:
    sta EMERALD_SP_RESET
KernelB_J:
    sty EMERALD_SP
KernelB_K:
    sta EMERALD_MI_ENABLE
KernelB_L:
    sty EMERALD_SP
KernelB_M:
    sleep 3
KernelB_N:
    sleep 3
KernelB_O:
    sleep 3

    ; 6c
    ASSERT_RUNTIME "_scycles == #70"
    rts

    rend
kernel_2_end:
    ASSERT_SIZE kernel_2_start, kernel_2_end, $40
