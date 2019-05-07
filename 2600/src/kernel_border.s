; Visible Kernel

KernelBorder: subroutine
    sta WSYNC ; ??? Is this needed?

    ; First HMOVE
    sta HMOVE

    ; Border top
    lda #0
    sta COLUPF
    sta PF1
    sta PF2
    lda #SIGNAL_LINE
    sta COLUBK

    REPEAT 6
    sta WSYNC
    REPEND

    lda #0
    sta COLUBK
    sta WSYNC

    ; Start top border
border_top:
    ; Make the playfield solid.
    lda #%00111111
    sta PF1
    lda #%11111111
    sta PF2

    lda #COL_BG
    ldy #0

    ; X_XXXX_XX
    ; Commented lines removed to save on space.
    sta COLUPF
    sta WSYNC
    sty COLUPF
    sta WSYNC
    sta COLUPF
    sta WSYNC
    ; sta COLUPF
    sta WSYNC
    ; sta COLUPF
    sta WSYNC
    sty COLUPF
    sta WSYNC
    sta COLUPF

    sta WSYNC
    ; sta COLUPF

PlayArea:
    ; PF is now the playing area
    ASSERT_RUNTIME "_scycles == #0"
    sleep 61
    lda #%00000000
    sta PF0
    lda #%00100000
    sta PF1
    lda #%00000000
    sta PF2
    ASSERT_RUNTIME "_scycles == #0"
    sleep 7
    jmp row_start
    ; enter row on cycle 10.

    ; reset the background for bottom of playfield
border_bottom:
    ;sta WSYNC

    ; Form the bottom of the level frame.
    lda #%00111111
    sta PF1
    lda #%11111111
    sta PF2

    ; Clear all sprites.
    lda #0
    sta EMERALD_SP
    sta JET_SP
    sta EMERALD_MI_ENABLE

    lda #COL_BG
    ldy #0
    sta WSYNC

    sty COLUPF
    sta WSYNC

    sta COLUPF
    sta WSYNC

    sta WSYNC

    sta WSYNC

    sty COLUPF
    sta WSYNC

    sta COLUPF
    sta WSYNC
    sta WSYNC
    jmp FrameEnd
