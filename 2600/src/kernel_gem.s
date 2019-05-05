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
    ; ASSERT_RUNTIME "sp == $f9"
    ; ASSERT_RUNTIME "RamCurrentKernel != #1 || _scycles == #22"

    ; To disable VDELP0, we use the Y register %01100110, which has D0 always 0

    ; Register config
    lda #$01
    sta EMERALD_MI_ENABLE ; disable missile
    stx.w VDELP1 ; enable delayed sprite TODO: save the extra cycle here

    ; Write Gemini 0A into delayed sprite register
    sty EMERALD_SP

    ; Pop Player sprite from stack
    ; By writing into GRP0, we copy Gemini 0A into visible sprite register
    pla
    sta GRP0

    ; Write Gemini 1A into delayed sprite register
    sty EMERALD_SP

    ; 22c is critical start of precise GRP0 timing for Kernel A
    ASSERT_RUNTIME "RamCurrentKernel != #1 || _scycles == #22"
KernelA_A:
    sta EMERALD_SP_RESET ; RESPx must be strobed on cycle 25c.
KernelA_B:
    sleep 3
KernelA_C:
    lda RamPF1Value ; Load PF1 (TODO asymmetrical playfield)


; below has one `php` call (by default: RESET)
KernelA_D:
    sty VDELP1 ; Gemini 1A, clear VDELP1
KernelA_E:
    sta EMERALD_SP_RESET ; Reset "medium close" NUSIZ repetition
KernelA_F:
    stx EMERALD_MI_ENABLE ; Enable the missile (if we use %0xx00110 pattern)
KernelA_G:
    sty EMERALD_SP ; Gemini 2A
; above has php

KernelA_H:
    sty EMERALD_SP ; Gemini 3A, modified for RST2 along with HMM1

; RST4 vvv
KernelA_I:
    stx EMERALD_SP_RESET ; Reset "medium close" NUSIZ repetition
KernelA_J: ; unchanging
    sta PF1 ; Write asymmetrical playfield register
KernelA_K:
    sty EMERALD_SP ; Gemini 4A
KernelA_L:
    sleep 3 ; free
; RST4 ^^^

KernelA_M:
    sty EMERALD_SP ; Gemini 5A
KernelA_N:
    sleep 3
KernelA_O:
    sleep 3
KernelA_P:
    sleep 3

    ; 6c
    ASSERT_RUNTIME "RamCurrentKernel != #1 || _scycles == #70"
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
    ASSERT_RUNTIME "RamCurrentKernel != #2 || _scycles == #25"
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

; below has one php load (RESET?)
KernelB_H:
    sty EMERALD_SP ; Gemini 3B
KernelB_I:
    sta EMERALD_SP_RESET
KernelB_J:
    sty EMERALD_SP ; Gemini 4B
KernelB_K:
    sta EMERALD_MI_ENABLE
KernelB_L:
    sty EMERALD_SP ; Gemini 5B
; above has one PHP loa

KernelB_M:
    sleep 3
KernelB_N:
    sleep 3
KernelB_O:
    sleep 3

    ; 6c
    ASSERT_RUNTIME "RamCurrentKernel != #2 || _scycles == #70"
    rts

    rend
kernel_2_end:
    ASSERT_SIZE kernel_2_start, kernel_2_end, $40
