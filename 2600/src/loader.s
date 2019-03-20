; Copies the gem kernel to RAM

    mac EMERALDS_TWO
.target SET {1}
    ldx #%11
    .byte $CB, $0 ; axs
    ldy map_full,X
    sty [.target - storage + KERNEL_STORAGE_W]
    ror
    ror
    endm

    mac EMERALDS_TWO_SKIP
    ror
    ror
    endm

    mac EMERALDS_ONE
.target SET {1}
.source SET {2}
    tax
    and #%1
    tay
    lda .source,Y
    sta [.target - storage + KERNEL_STORAGE_W]
    txa
    ror
    endm

    mac EMERALDS_ONE_SKIP
    ror
    endm


; Map 

    align 8
map_full:
    .byte SET_0_0 ; 00
    .byte SET_0_1 ; 01
    .byte SET_1_0 ; 10
    .byte SET_1_1 ; 11
map_missle_l:
    .byte SET_0_L ; 0
    .byte SET_1_L ; 1
map_missle_r:
    .byte SET_0_R ; 0
    .byte SET_1_R ; 1


; Frame Copying

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

    ldx ROW_DEMO_INDEX
    lda map_emeralds+3,X
    EMERALDS_TWO_SKIP
    EMERALDS_TWO storage_22
    EMERALDS_TWO_SKIP
    EMERALDS_TWO storage_18

    ldx ROW_DEMO_INDEX
    lda map_emeralds+2,X
    EMERALDS_ONE storage_17, map_missle_r
    EMERALDS_TWO_SKIP
    EMERALDS_TWO storage_13
    EMERALDS_TWO_SKIP

    ldx ROW_DEMO_INDEX
    lda map_emeralds+1,X
    EMERALDS_TWO storage_09
    EMERALDS_ONE_SKIP
    EMERALDS_TWO_SKIP
    EMERALDS_TWO storage_04

    ldx ROW_DEMO_INDEX
    lda map_emeralds+0,X
    EMERALDS_TWO_SKIP
    EMERALDS_TWO storage_00

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

    ldx ROW_DEMO_INDEX
    lda map_emeralds+3,X
    EMERALDS_TWO storage_24
    EMERALDS_TWO_SKIP
    EMERALDS_TWO storage_20
    EMERALDS_TWO_SKIP

    ldx ROW_DEMO_INDEX
    lda map_emeralds+2,X
    EMERALDS_ONE_SKIP
    EMERALDS_TWO storage_15
    EMERALDS_TWO_SKIP
    EMERALDS_TWO storage_11

    ldx ROW_DEMO_INDEX
    lda map_emeralds+1,X
    EMERALDS_TWO_SKIP
    EMERALDS_ONE storage_08, map_missle_l
    EMERALDS_TWO storage_06
    EMERALDS_TWO_SKIP

    ldx ROW_DEMO_INDEX
    lda map_emeralds+0,X
    EMERALDS_TWO storage_02
    EMERALDS_TWO_SKIP

    rts
