; Macros for calculating sprite values (GRPx).

    MAC jet_spritedata_calc_nosta
    ; loader
    dcp SpriteEnd

    ; 4c
    ; This must never be 5 cycles This mean Frame0 + Y must not cross below apage boundary.
    ; 6c
    ldy #0
    .byte $b0, $01 ;2c / 3c (taken)
    .byte $2c ; 4c / 0c
    ldy SpriteEnd

    ENDM

    MAC jet_spritedata_calc
    ; loader
    lda #SPRITE_HEIGHT
    dcp SpriteEnd
    ldy SpriteEnd

    ; 4c
    ; This must never be 5 cycles This mean Frame0 + Y must not cross below apage boundary.
    lda Frame0,Y
    ; 6c
    .byte $b0, $01 ;2c / 3c (taken)
    .byte $2c ; 4c / 0c
    sta JET_SP ; 0c / 3c

    ENDM
