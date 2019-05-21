game_state_setup:
    ; Set up the level
    lda #%11111011
    sta [level_for_game + 0]
    lda #%11111111
    sta [level_for_game + 1]
    lda #%11111111
    sta [level_for_game + 2]
    lda #%11111111
    sta [level_for_game + 3]
    rts

   align 16
game_state_mask:
    .byte #%01111111
    .byte #%10111111
    .byte #%11011111
    .byte #%11101111
    .byte #%11110111
    .byte #%11111011
    .byte #%11111101
    .byte #%11111110

game_state_tick: subroutine
    jsr game_state_setup

    ; Get index [0, 25]
    clc
    lda XPos
    sbc #2
    lsr
    lsr
    sta Temp

    ; Load bit offset
    and #%111
    tay 
    lda game_state_mask,y
    sta Temp2

    ; Load sprite offset
    lda Temp
    lsr
    lsr
    lsr
    tay
    lda Temp2
    sta level_for_game,y
    rts


; game_state_tick:
;     lda FrameCount
;     and #%111
;     bne .skiprotate
;     lda level_for_game + 3
;     ror
; .rollall:
;     _ROR32 level_for_game, level_for_game

;     lda #%11101111
;     cmp [level_for_game + 3]
;     bne .skiprotate
;     jmp game_state_setup
; .skiprotate:
;     rts
