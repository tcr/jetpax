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

    ; Decrease SpriteEnd
    sec
    lda SpriteEnd
    sbc #8
    sta SpriteEnd

    ; Idle.
    sta WSYNC
    ; sleep 33

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
    sleep 21

    ; Load PF1 value
    lda #%00111101
    sta RamPF1Value

    lda #4
    sta TIM64T

    ; Set stack pointer for PHP use from NibblePhp.
    ; FIXME need to fix these and other Nibble references
    NIBBLE_RAM_LOAD ldx, NibblePhp
    dex
    txs

    ; Enable playfield at end of scanline
    lda #COL_BG
    sta COLUPF

    ; Set overflow flag
    NIBBLE_RAM_LOAD bit, NibblePs

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
    stx RamKernelGrp0
    dey
    ldx Frame0,Y
    stx [KernelA_GRP0 - $100]
    sty RamRowJetpackIndex

    ; [[[Nibble VM.]]]
    ; Idle.
    sleep 22

    ; Setup for kernel
    sec ; clear carry bit
    NIBBLE_RAM_LOAD ldx, NibbleX
    NIBBLE_RAM_LOAD ldy, NibbleY

    ; Jump immediately into scanlines 4-5 aka "kernel_gem"
    lda NibbleVdel1
    sta EMERALD_SP
    lda RamKernelGrp0 ; Load sprite 2 into A
; [scanline 4]
; [scanline 5]
    ASSERT_RUNTIME "_scycles == #73"
    jmp CBSRAM_KERNEL_ENTRY

; [scanline 6]

row_after_kernel:
row_6:
    ASSERT_RUNTIME "_scycles == #0"

    ; Cleanup from the kernel.
    lda #0
    sta EMERALD_MI_ENABLE
    sta EMERALD_SP
    sta COLUPF

    lda #%00100000
    sta PF1

    jet_spritedata_calc

    ; Load nibble index.
    ldy #0

    ; Idle.
    sta WSYNC

; [scanline 7]
row_7:
    ASSERT_RUNTIME "_scycles == #0"

    ; FIXME this should be enabled!
    ; jet_spritedata_calc

    lda #COL_BG
    sta COLUPF

    ; Idle.
    ; sleep 71

    ; Run Kernel.
    NIBBLE_RAM_LOAD lda, NibbleVar2
    NIBBLE_gem_kernel_a_2
    ; sleep 5

; [scanline 8]
row_8:
    ASSERT_RUNTIME "_scycles == #0"

    ; FIXME this should be enabled!
    ; jet_spritedata_calc

    ; [NIBBLE VM]
    NIBBLE_RAM_LOAD lda, NibbleVar1
    NIBBLE_gem_kernel_a_1
    ; sleep 3

    ; Idle.
    ; sleep 51
    ; sta WSYNC

; [scanline 8-1]
    ASSERT_RUNTIME "_scycles == #0"
    ; Repeat loop until LoopCount < 0
    dec LoopCount
    beq row_end
    jmp row_start
row_end:
    jmp border_bottom
