; Copies the gem kernels to RAM

    ; Copy Kernel A to CBSRAM
LoadKernelA: subroutine
    ldy #(kernel_1_end - KernelA_start)-1
.loop:
    lda KernelA_start,Y
    sta CBSRAM_KERNEL_WRITE,Y
    dey
    bne .loop
    lda KernelA_start
    sta CBSRAM_KERNEL_WRITE
    rts

    ; Copy Kernel B to CBSRAM
LoadKernelB: subroutine
    ldy #(kernel_2_end - KernelB_start)-1
.loop:
    lda KernelB_start,Y
    sta CBSRAM_KERNEL_WRITE,Y
    dey
    bne .loop
    lda KernelB_start
    sta CBSRAM_KERNEL_WRITE
    rts
