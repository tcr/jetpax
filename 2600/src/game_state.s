game_state_setup:
    ; Set up the level
    lda #%11111111
    sta [level_for_game + 0]
    lda #%11111111
    sta [level_for_game + 1]
    lda #%01111111
    sta [level_for_game + 2]
    lda #%11111111
    sta [level_for_game + 3]
    rts

game_state_tick:
    lda FrameCount
    and #%11111
    bne .skiprotate
    lda level_for_game + 3
    ror
.rollall:
    _ROR32 level_for_game, level_for_game

    lda #%11111011
    cmp [level_for_game + 2]
    bne .skiprotate
    jmp game_state_setup
.skiprotate:
    rts
