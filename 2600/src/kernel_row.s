; Frame Start

; Macros for calculating sprite values (GRPx).

; mac jet_spritedata_calc
;
; loads the offset from Frame0 in Y, and the sprite value in A, and stores it in
; GRP0.
    mac jet_spritedata_calc
        dec RamRowJetpackIndex
        ldy RamRowJetpackIndex
        ldx Frame0,Y
        stx JET_SP
    endm

row_start:

; [scanline 1]
row_1:
    ; Enter after scanline starts on row "9" and wraps
    ASSERT_RUNTIME "_scycles == #10"

    ; Load sprite details
    lda [#SPRITE_HEIGHT + #7]
    cmp SpriteEnd ; 5c
    lda #0 ; 2c
    ; constant 6c: if carry set, load SpriteEnd into y
    .byte $b0, $01 ; 2c / 3c (taken)  : bcs +01 (skipping 1-byte bit instr)
    .byte $0c ; 4c / 0c              : bit (skip next two bytes)
    lda SpriteEnd
    adc #8
    sta RamRowJetpackIndex
    
    ; Load sprite
    dec RamRowJetpackIndex
    ldy RamRowJetpackIndex
    ldx Frame0,Y
    stx JET_SP

    ; TODO assert cycle is not in visible range!

    ; [[[Nibble VM.]]]
    sta WSYNC

    ; sleep 46

    ASSERT_RUNTIME "_scycles == #0"

; [scanline 2]
row_2:
    jet_spritedata_calc
    sleep 5

    ; Black out playfield
    ; TODO This should be done with playfield pixels, not color.
    lda #0
    sta COLUPF

    ; [[[Nibble VM.]]]
    sleep 27

    ; Load PF1 value
    lda #%00111111
    sta RamPF1Value

    lda #4
    sta TIM64T

    ; Enable playfield at end of scanline
    lda #COL_BG
    sta COLUPF

    ; Set stack pointer for PHP use from RamKernelPhpTarget.
    ldx RamKernelPhpTarget
    txs

    ; Set overflow flag
    bit RamFFByte

    ASSERT_RUNTIME "_scycles == #0"

; [scanline 3]
row_3:
    ; Current row and next two rows.
    ldy RamRowJetpackIndex
    dey
    ldx Frame0,Y
    stx JET_SP
    dey
    ldx Frame0,Y
    stx RamKernelGRP0
    dey
    ldx Frame0,Y
    stx [KernelA_GRP0 - $100]
    sty RamRowJetpackIndex

    ; Idle.
    sleep 22

    ; Setup for kernel
    sec ; clear carry bit
    ldx RamKernelX
    ldy RamKernelY

    ; Jump immediately into scanlines 4-5 aka "kernel_gem"
    lda BuildKernelVdel1
    sta EMERALD_SP
    lda RamKernelGRP0 ; Load sprite 2 into A
; [scanline 4]
; [scanline 5]
    ASSERT_RUNTIME "_scycles == #73"
    jmp CBSRAM_KERNEL_ENTRY

; [scanline 6]

    ; Try to avoid page crossing in jet_spritedata_calc
    ; TODO enforce this with ASSERT_RUNTIME instead?
    align 16

row_after_kernel:
row_6:
    ASSERT_RUNTIME "_scycles == #0"

    ; Cleanup from the kernel.
    lda #0
    sta EMERALD_MI_ENABLE
    sta EMERALD_SP
    sta COLUPF
    sta VDELP1

    lda #%00100000
    sta PF1

    jet_spritedata_calc

    ; Idle.
    sta WSYNC

; [scanline 7]
row_7:
    jet_spritedata_calc
    sleep 5
    ASSERT_RUNTIME "_scycles == #20"

    lda #COL_BG
    sta COLUPF

    ; FRAMESWITCH
    lda #01
    and FrameCount
    bne loadframe2

; Perform gem loading for Kernel A.

loadframe1:
    ASSERT_RUNTIME "_scycles == #32"

    ; Emerald byte setting 1A
    ; ldx #0
    ; lda KERNEL_STORAGE_R,X
    ; sta GEM_00_W
    ; inx
    ; lda KERNEL_STORAGE_R,X
    ; sta GEM_04_W
    ; inx
    ; lda KERNEL_STORAGE_R,X
    ; sta GEM_09_W
    ; inx

    sta WSYNC

; [scanline 8]
    jet_spritedata_calc
    sleep 5

    ; Emerald byte setting 1B
    ; lda KERNEL_STORAGE_R,X
    ; sta GEM_13_W
    ; inx
    ; lda KERNEL_STORAGE_R,X
    ; sta GEM_17_W
    ; inx
    ; lda KERNEL_STORAGE_R,X
    ; sta GEM_18_W
    ; inx
    ; lda KERNEL_STORAGE_R,X
    ; sta GEM_22_W

    jmp row_8_end

; Perform gem loading for Kernel B.

loadframe2:
    ASSERT_RUNTIME "_scycles == #33"

    ; Emerald byte setting 2A
    ; ldx #[storage_02 - storage]
    ; lda KERNEL_STORAGE_R,X
    ; sta GEM_02_W
    ; inx
    ; lda KERNEL_STORAGE_R,X
    ; sta GEM_06_W
    ; inx
    ; lda KERNEL_STORAGE_R,X
    ; sta GEM_08_W
    ; inx

    sta WSYNC

; [scanline 8]
row_8:
    jet_spritedata_calc
    sleep 5

    ; Emerald byte setting 2B
    ; lda KERNEL_STORAGE_R,X
    ; sta GEM_11_W
    ; inx
    ; lda KERNEL_STORAGE_R,X
    ; sta GEM_15_W
    ; inx
    ; lda KERNEL_STORAGE_R,X
    ; sta GEM_20_W
    ; inx
    ; lda KERNEL_STORAGE_R,X
    ; sta GEM_24_W

    jmp row_8_end

; Common row 8 return.

row_8_end:
    ; Decrease SpriteEnd
    sec
    lda SpriteEnd
    sbc #8
    sta SpriteEnd

    ; Idle.
    sta WSYNC

; [scanline 8]
    ; Repeat loop until LoopCount < 0
    dec LoopCount
    beq row_end
    jmp row_start
row_end:
    jmp border_bottom
