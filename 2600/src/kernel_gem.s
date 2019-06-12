;
; Gem Kernels
;
; Gems are displayed in alternating kernels. This chart shows
; which kernel is responsible for which gem, with missiles denoted.
;
;  1:   |SS  SS  M|SS  SS   |SS  SS  |        kernel 1 (S = Sprite, M = missile)
;  2:   |  SS  SS |  SS  SSM|  SS  SS|        kernel 2
;  =    |112211222|112211221|11221122|        kernel #
;  #    0^      8^       17^       26^       gem index
;
; The middle bars indicate when RESP1 is performed.
;
; Because we can repeat a sprite multiple times, and reset the sprite
; occurance mid-line, we can render close to half of the 26 gems a line
; requires with a single sprite. By alternating sprites each frame with an
; "acceptable" amount of flicker (15Hz) we can render 24 out of 26 gems.
; There is a TIA feature where RESP0 will offset the next sprite by 4 color
; clocks, leaving two gaps in the row.
;
; Instead, we render the gems in these two gaps with the player's missile, which
; shares the same color and repeat pattern as the player. The 3x repeat pattern
; is mostly unused, by disabling the missile for the first two of its three
; repetitions.

    ; for copying
    align 256

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; GEM KERNEL A
;

KernelA_start: subroutine
    rorg $f100

    ; Kernel Marker
    .byte $A

KernelA_early:
    ASSERT_RUNTIME_KERNEL $A, "v == #1"
    clv

    ; Early code to set next Player GRP0. Immediate value is overwritten
    lda #$ff
KernelA_GRP0 = . - 1

KernelA: subroutine
    ASSERT_RUNTIME_KERNEL $A, "_scycles == #0"

    ; Write Player from accumulator. When writing to the other sprite, the
    ; TIA will copy Gemini 0A into visible sprite register
    sta JET_SP
    ; Write Gemini 1A into visible sprite register
    lda #%01100110
KernelA_VDEL0 = . - 1
    sta EMERALD_SP

    ; Register config
    lda #%00001000
    sta REFP1

    lda #%00100000
    sta PF1

    ; Reset stack pointer
    pla

    ; 22c is critical start of precise GRP0 timing for Kernel A
    ASSERT_RUNTIME_KERNEL $A, "_scycles == #22"
KernelA_A:
    sta EMERALD_SP_RESET ; RESPx must be strobed on cycle 25c.

; RST0 vvv
KernelA_B:
    lda RamPF1Value
KernelA_C:
    sty VDELP1 ; disable delayed sprite
KernelA_D:
    ; sty EMERALD_SP ; Gemini 1A
    sleep 3
; RST0 ^^^

KernelA_E:
    sta EMERALD_SP_RESET ; Reset "medium close" NUSIZ repetition
KernelA_F:
    stx EMERALD_MI_ENABLE ; Enable the missile (if register uses the %0xx00110 pattern)
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
    lda RamZeroByte ; FIXME this doesn't belong here
KernelA_M:
    sty VDELP1 ; Gemini 5A ; need a way to skip this vlaue
KernelA_N:
    sta EMERALD_MI_ENABLE ; disable missile FIXME better place for this?
KernelA_O:
    lda #%01100110
KernelA_VDEL1 = . - 1

    ; End visible line
    ASSERT_RUNTIME_KERNEL $A, "_scycles == #66"
KernelA_branch:
    sta EMERALD_SP ; set VDEL1

    ; Branch or return. 
    bvs KernelA_early
    sleep 2
    jmp row_after_kernel

    rend
kernel_1_end:
    ASSERT_SIZE KernelA_start, kernel_1_end, $40

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; GEM KERNEL B
;

KernelB_start: subroutine
    rorg $f100

    ; Kernel Marker
    .byte $B

    clv

KernelB_early:
    ; Early code to set next GRP0 image. Value is overwritten
    lda #$ff
KernelB_GRP0 = . - 1

KernelB: subroutine
    ASSERT_RUNTIME_KERNEL $B, "_scycles == #0"

    ; Write Player from accumulator. When writing to the other sprite, the
    ; TIA will copy Gemini 0A into visible sprite register
    sta JET_SP
    lda #%10101010
KernelB_VDEL0 = . - 1
    ; Write Gemini 1A into delayed sprite register
    sta EMERALD_SP

    ; Reset stack
    pla

    ; 6c
    lda #%00100000
    sta PF1

    ; Register config
    lda #$ff
    sta EMERALD_MI_ENABLE ; enable missile

    ; Set processor register bit for PHP sprite rendering.
    sleep 3

    ; 25c is critical start of precise GRP0 timing for Kernel B
    ASSERT_RUNTIME_KERNEL $B, "_scycles == #25"
KernelB_A:
    sta EMERALD_SP_RESET
KernelB_B:
    lda RamPF1Value
KernelB_C:
    cmp RamPF1Value
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
    sta EMERALD_MI_ENABLE ; FIXME this can't rely on sta
KernelB_L:
    stx EMERALD_SP ; Gemini 5B

KernelB_M:
    sleep 3
KernelB_N:
    sleep 3

    ; End visible line
    ASSERT_RUNTIME_KERNEL $B, "_scycles == #67"

KernelB_branch:
    lda INTIM
    bne KernelB_early
    jmp row_after_kernel

    rend
kernel_2_end:
    ASSERT_SIZE KernelB_start, kernel_2_end, $40


; Write definitions

KERNEL_WRITE_OFFSSET = -$100

KernelA_B_W         EQM [KernelA_B + KERNEL_WRITE_OFFSSET]
KernelA_C_W         EQM [KernelA_C + KERNEL_WRITE_OFFSSET]
KernelA_D_W         EQM [KernelA_D + KERNEL_WRITE_OFFSSET]
KernelA_E_W         EQM [KernelA_E + KERNEL_WRITE_OFFSSET]
KernelA_F_W         EQM [KernelA_F + KERNEL_WRITE_OFFSSET]
KernelA_G_W         EQM [KernelA_G + KERNEL_WRITE_OFFSSET]
KernelA_H_W         EQM [KernelA_H + KERNEL_WRITE_OFFSSET]
KernelA_I_W         EQM [KernelA_I + KERNEL_WRITE_OFFSSET]
KernelA_J_W         EQM [KernelA_J + KERNEL_WRITE_OFFSSET]
KernelA_K_W         EQM [KernelA_K + KERNEL_WRITE_OFFSSET]
KernelA_VDEL0_W     EQM [KernelA_VDEL0 + KERNEL_WRITE_OFFSSET]
KernelA_VDEL1_W     EQM [KernelA_VDEL1 + KERNEL_WRITE_OFFSSET]
KernelA_GRP0_W      EQM [KernelA_GRP0 + KERNEL_WRITE_OFFSSET]

KernelB_C_W         EQM [KernelB_C + KERNEL_WRITE_OFFSSET]
KernelB_D_W         EQM [KernelB_D + KERNEL_WRITE_OFFSSET]
KernelB_E_W         EQM [KernelB_E + KERNEL_WRITE_OFFSSET]
KernelB_F_W         EQM [KernelB_F + KERNEL_WRITE_OFFSSET]
KernelB_G_W         EQM [KernelB_G + KERNEL_WRITE_OFFSSET]
KernelB_H_W         EQM [KernelB_H + KERNEL_WRITE_OFFSSET]
KernelB_I_W         EQM [KernelB_I + KERNEL_WRITE_OFFSSET]
KernelB_J_W         EQM [KernelB_J + KERNEL_WRITE_OFFSSET]
KernelB_K_W         EQM [KernelB_K + KERNEL_WRITE_OFFSSET]
KernelB_VDEL0_W     EQM [KernelB_VDEL0 + KERNEL_WRITE_OFFSSET]
