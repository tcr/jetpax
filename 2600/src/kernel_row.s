; Frame Start

; Macros for calculating sprite values (GRPx).

; Load the player graphics for this scanline using SpriteEnd (3c + 17c)
    mac KERNEL_LOAD_PLAYER
    ; expects "lda #SPRITE_HEIGHT" before this ; 3c
    dcp SpriteEnd ; 5c
    ldy #0 ; 2c
    ; constant 6c:
    .byte $b0, $01 ; 2c / 3c (taken)  : bcs +01 (skipping 1-byte bit instr)
    .byte $2c ; 4c / 0c              : bit (skip next two bytes)
    ldy SpriteEnd
    ; 4c
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

; [scanline 1]
row_start:
    ; Enter after scanline starts on row "9" and wraps
    ASSERT_RUNTIME "_scycles == #10"

    jet_spritedata_calc
    sta WSYNC

; [scanline 2]
    jet_spritedata_calc

    ; Black out playfield
    ; TODO This should be done with playfield pixels, not color.
    lda #0
    sta COLUPF

    sleep 51
    ASSERT_RUNTIME "_scycles == #0"

; [scanline 3]
    jet_spritedata_calc

    ; Enable playfield
    lda #COL_BG
    sta COLUPF

    ; Set stack pointer and populate graphics.
    ldx #$f9
    txs
    lda #SPRITE_HEIGHT
    KERNEL_LOAD_PLAYER
    stx $fa
    KERNEL_LOAD_PLAYER
    stx $fd

    sleep 2
    ASSERT_RUNTIME "_scycles == #73"

; [scanline 4]
    ; Jump to the copied kernel.
kernel_launch:
    jmp KERNEL_START

    ; Try to avoid page crossing in jet_spritedata_calc
    ; TODO enforce this with ASSERT_RUNTIME instead?
    align 16

row_after_kernel:

; [scanline 6]
row_6:
    ASSERT_RUNTIME "_scycles == #0"

    ; Cleanup from the kernel.
    lda #0
    sta EMERALD_MI_ENABLE
    sta EMERALD_SP
    sta COLUPF

    jet_spritedata_calc

    sta WSYNC

; [scanline 7]
row_7:
    jet_spritedata_calc

    lda #COL_BG
    sta COLUPF

    ; FRAMESWITCH
    lda #01
    and FrameCount
    bne loadframe2

loadframe1:
    ASSERT_RUNTIME "_scycles == #32"

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

; [scanline 8]
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

    jmp row_8_end

loadframe2:
    ASSERT_RUNTIME "_scycles == #33"

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

; [scanline 8]
row_8:
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

    jmp row_8_end

row_8_end:
    sta WSYNC

; [scanline 8]
    ; Repeat loop until LoopCount < 0
    dec LoopCount
    bmi row_end
    jmp row_start
row_end:
    jmp border_bottom
