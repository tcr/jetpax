; Copies the gem kernel to RAM

CopyFrame: subroutine
    ; FRAMESWITCH
    lda #01
    and FrameCount
    beq CopyFrame1Kernel
    jmp CopyFrame2Kernel

    ; Copy: KERNEL 1
CopyFrame1Kernel: subroutine
    ldy #(kernel_1_end - kernel_1_start)-1
.loop:
    lda kernel_1_start,Y
    sta $1000,Y
    dey
    bne .loop
    lda kernel_1_start
    sta $1000
    rts

    ; Copy: KERNEL 2
CopyFrame2Kernel: subroutine
    ldy #(kernel_2_end - kernel_2_start)-1
.loop:
    lda kernel_2_start,Y
    sta $1000,Y
    dey
    bne .loop
    lda kernel_2_start
    sta $1000
    rts
