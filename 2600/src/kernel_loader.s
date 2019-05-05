; Copies the gem kernels to RAM

    ; Copy Kernel A to CBSRAM
LoadKernelA: subroutine
    lda #01
    sta RamCurrentKernel
    ldy #(kernel_1_end - kernel_1_start)-1
.loop:
    lda kernel_1_start,Y
    sta $1000,Y
    dey
    bne .loop
    lda kernel_1_start
    sta $1000
    rts

    ; Copy Kernel B to CBSRAM
LoadKernelB: subroutine
    lda #02
    sta RamCurrentKernel
    ldy #(kernel_2_end - kernel_2_start)-1
.loop:
    lda kernel_2_start,Y
    sta $1000,Y
    dey
    bne .loop
    lda kernel_2_start
    sta $1000
    rts
