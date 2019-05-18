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

    ; Kernel Marker
    .byte $A

KernelA_early:
    ; Early code to set next GRP0 image. Immediate value is overwritten
    lda #$ff

KernelA: subroutine
    ASSERT_RUNTIME_KERNEL $A, "_scycles == #0"

    ; Write Gemini 0A into delayed sprite register
    ldy #%01100110 ; TODO temporary?
KernelA_VDEL1 = . - 1
    sty EMERALD_SP
    ; Write Player from accumulator. When writing to the other sprite, the
    ; TIA will copy Gemini 0A into visible sprite register
    sta JET_SP
    ; Write Gemini 1A into visible sprite register
    ldy #%01100110
KernelA_VDEL0 = . - 1
    sty EMERALD_SP
    ldy #%00000110
KernelA_STY = . - 1

    ; Need D0 for VDELP1 trigger with PHP
    sleep 2

    ; Register config
    lda #%00001000
    sta REFP1

    ; 22c is critical start of precise GRP0 timing for Kernel A
    ASSERT_RUNTIME_KERNEL $A, "_scycles == #22"
KernelA_A:
    sta EMERALD_SP_RESET ; RESPx must be strobed on cycle 25c.

; vvv RST0
KernelA_B:
    lda RamPF1Value
KernelA_C:
    sty VDELP1 ; disable delayed sprite
KernelA_D:
    ; sty VDELP1 ; Gemini 1A, clear VDELP1. all registers have d0 cleared
    sleep 3 ; Load PF1 (TODO asymmetrical playfield)
KernelA_E:
    sta EMERALD_SP_RESET ; Reset "medium close" NUSIZ repetition
KernelA_F:
    sta EMERALD_MI_ENABLE ; Enable the missile (if we use %0xx00110 pattern)
    ; sleep 3 ; FIXME This should be a "sleep 3" and the missile enabled should be moved
KernelA_G:
    sty EMERALD_SP ; Gemini 2A

KernelA_H:
    sty EMERALD_SP ; Gemini 3A, modified for RST2 along with HMM1

    ASSERT_RUNTIME_KERNEL $A, "c == #1"
; RST4 vvv
KernelA_I:
    php ; Reset "medium close" NUSIZ repetition
KernelA_J: ; unchanging
    sta PF1 ; Write asymmetrical playfield register
KernelA_K:
    sty EMERALD_SP ; Gemini 4A
; RST4 ^^^

KernelA_L:
    sta EMERALD_MI_ENABLE ; disable missile FIXME this should be in prelude
KernelA_M:
    sty VDELP1 ; Gemini 5A ; need a way to skip this vlaue

KernelA_N:
KernelA_O:
    sleep 2
    ; reset stack pointer
    pla

    ; End visible line
    ASSERT_RUNTIME_KERNEL $A, "_scycles == #67"

KernelA_branch:
    lda INTIM
    bne KernelA_early

    jmp row_after_kernel

    rend
kernel_1_end:
    ASSERT_SIZE kernel_1_start, kernel_1_end, $40

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; GEM KERNEL B
;

kernel_2_start: subroutine
    rorg $f100

    ; Kernel Marker
    .byte $B

KernelB_early:
    ; Early code to set next GRP0 image. Value is overwritten
    lda #$ff

KernelB: subroutine
    ASSERT_RUNTIME_KERNEL $B, "_scycles == #0"

    ; Write Gemini 0A into delayed sprite register
    sty EMERALD_SP
    ; Write Player from accumulator. When writing to the other sprite, the
    ; TIA will copy Gemini 0A into visible sprite register
    sta JET_SP
    ldy #%10101010
KernelB_VDEL0 = . - 1
    ; Write Gemini 1A into delayed sprite register
    sty EMERALD_SP
    sleep 2

    ldy #$ff
KernelB_STY = . - 1

    ; Register config
    lda #$ff

    sta EMERALD_MI_ENABLE ; enable missile
    ; Load PF1 value into accumulator
    lda RamPF1Value

    ; Clear bits in processor status register for drawing.
    ; clc
    ; bit RamLowerSixByte
    sec
KernelB_P11_C = . - 1
    ; sleep 2

    ; 25c is critical start of precise GRP0 timing for Kernel B
    ASSERT_RUNTIME_KERNEL $B, "_scycles == #25"
KernelB_A:
    sta EMERALD_SP_RESET
KernelB_B:
    bit RamZeroByte
KernelB_C:
    sleep 3
KernelB_D:
    stx EMERALD_SP ; Gemini 1B

; below has one php load (could just be RESET)
KernelB_E:
    php
KernelB_F:
    sty EMERALD_SP ; Gemini 2B
KernelB_G:
    sta PF1
KernelB_H:
    sty EMERALD_SP ; Gemini 3B; TODO write php instead fixed
; above has one PHP load

KernelB_I:
    sta EMERALD_SP_RESET
KernelB_J:
    sty EMERALD_SP ; Gemini 4B
KernelB_K:
    stx EMERALD_MI_ENABLE
KernelB_L:
    stx EMERALD_SP ; Gemini 5B

KernelB_M:
KernelB_N:
    sleep 2

    ; reset stack pointer
    pla

    ; End visible line
    ASSERT_RUNTIME_KERNEL $B, "_scycles == #67"

KernelB_branch:
    lda INTIM
    bne KernelB_early
    jmp row_after_kernel

    rend
kernel_2_end:
    ASSERT_SIZE kernel_2_start, kernel_2_end, $40
