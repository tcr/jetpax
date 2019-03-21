; Frame Start

; Macros for calculating sprite values (GRPx).

; mac jet_spritedata_calc_nosta
    mac jet_spritedata_calc_nosta
    ; assumes lda #SPRITE_HEIGHT
    ; loader
    dcp SpriteEnd

    ; 4c
    ; This must never be 5 cycles This mean Frame0 + Y must not cross below apage boundary.
    ; 6c
    ldy #0
    .byte $b0, $01 ;2c / 3c (taken)
    .byte $2c ; 4c / 0c
    ldy SpriteEnd
    ldx Frame0,Y
    endm

; mac jet_spritedata_calc
;
; loads the offset from Frame0 in Y, and the sprite value in A, and stores it in
; GRP0.
    mac jet_spritedata_calc
    ; loader
    lda #SPRITE_HEIGHT
    dcp SpriteEnd
    ldy SpriteEnd

    ; 4c
    ; This must never be 5 cycles This means Frame0 must be aligned and loading
    ; from Frame0 + Y must never cross a page boundary.
    lda Frame0,Y
    ; 6c
    .byte $b0, $01 ;2c / 3c (taken)
    .byte $2c ; 4c / 0c
    sta JET_SP ; 0c / 3c
    endm

    ; Start the row with a WSYNC.
row_start:
    ; ~15c 
    jet_spritedata_calc
    sta WSYNC

; [row:1]
    jet_spritedata_calc

    ; ASSERT_RUNTIME "_scan != #63 || a != #0"

    lda #0
    sta COLUPF

    ; Push jump table to the stack
    ASSERT_RUNTIME "sp == $ff"
    ; final rts to return point of kernel
    lda #>[row_after_kernel - 1]
    pha ; $ff
    lda #<[row_after_kernel - 1]
    pha ; $fe
    lda #%10101010
    pha ; $fd
    lda #>[$1100 - 1]
    pha ; $fc
    lda #<[$1100 - 1]
    pha ; $fb
    lda #%10101010
    pha ; $fa
    ASSERT_RUNTIME "sp == $f9"

    sta WSYNC

; [row:2]
    jet_spritedata_calc


    lda #COL_BG
    sta COLUPF

    lda #SPRITE_HEIGHT
    jet_spritedata_calc_nosta
    stx $fa
    jet_spritedata_calc_nosta
    stx $fd

    sleep 6

; [row:3-4]
    ; Jump to the copied kernel.
kernel_launch:
    jmp KERNEL_START

row_after_kernel:

row_5:
; [row:5]
    ; Cleanup from the kernel.
    lda #0
    sta EMERALD_MI_ENABLE
    sta EMERALD_SP
    sta COLUPF

    jet_spritedata_calc
    ; ASSERT_RUNTIME "_scan != #59 || y == 3"

    sta WSYNC

row_6:
; [row:6]
    jet_spritedata_calc

    lda #COL_BG
    sta COLUPF

    ; FRAMESWITCH
    lda #01
    and FrameCount
    bne loadframe2

loadframe1:
    ; ~30c

    ; Emerald byte setting 1A
    ldx #0
    lda KERNEL_STORAGE_R,X
    sta GEM_00_W
    inx
    lda KERNEL_STORAGE_R,X
    sta GEM_04_W
    inx
    lda KERNEL_STORAGE_R,X
    sta GEM_09_W
    inx

    sta WSYNC

; [row:7]
    jet_spritedata_calc

    ; Emerald byte setting 1B
    lda KERNEL_STORAGE_R,X
    sta GEM_13_W
    inx
    lda KERNEL_STORAGE_R,X
    sta GEM_17_W
    inx
    lda KERNEL_STORAGE_R,X
    sta GEM_18_W
    inx
    lda KERNEL_STORAGE_R,X
    sta GEM_22_W

    jmp row_7_end

loadframe2:
    ; ~30c

    ; Emerald byte setting 2A
    ldx #[storage_02 - storage]
    lda KERNEL_STORAGE_R,X
    sta GEM_02_W
    inx
    lda KERNEL_STORAGE_R,X
    sta GEM_06_W
    inx
    lda KERNEL_STORAGE_R,X
    sta GEM_08_W
    inx

    sta WSYNC

row_7:
; [row:7]
    jet_spritedata_calc

    ; Emerald byte setting 2B
    lda KERNEL_STORAGE_R,X
    sta GEM_11_W
    inx
    lda KERNEL_STORAGE_R,X
    sta GEM_15_W
    inx
    lda KERNEL_STORAGE_R,X
    sta GEM_20_W
    inx
    lda KERNEL_STORAGE_R,X
    sta GEM_24_W

    jmp row_7_end

row_7_end:
    sta WSYNC

; [row:8]
    ; Repeat loop until LoopCount < 0
    dec LoopCount
    bmi row_end
    jmp row_start
row_end:
    jmp border_bottom
