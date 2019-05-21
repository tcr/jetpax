; Perform a left rotation on the 32 bit number at
; location VLA and store the result at location
; RES. If VLA and RES are the same then the
; operation is applied directly to the memory,
; otherwise it is done in the accumulator.
;
; On exit: A = ??, X & Y are unchanged.

;http://www.obelisk.me.uk/6502/maclib.inc but reversed
	mac _ROR32
VLA EQU {1}
RES EQU {2}
		IF VLA != RES
		 LDA VLA+0
		 ROR A
		 STA RES+0
		 LDA VLA+1
		 ROR A
		 STA RES+1
		 LDA VLA+2
		 ROR A
		 STA RES+2
		 LDA VLA+3
		 ROR A
		 STA RES+3
		ELSE
		 ROR VLA+0
		 ROR VLA+1
		 ROR VLA+2
		 ROR VLA+3
		ENDIF
		ENDM
; Add two 32 bit numbers together and store the
; result in another memory location. RES may be
; the same as either VLA or VLB.
;
; On exit: A = ??, X & Y are unchanged.

game_state_adder:
   .byte #$0
   .byte #$0
   .byte #$0
   .byte #%10000

		mac _ADD32
.VLA EQU {1}
.VLB EQU {2} 
.RES EQU {3}
		 CLC
		 LDA .VLA+3
		 ADC .VLB+3
		 STA .RES+3
		 LDA .VLA+2
		 ADC .VLB+2
		 STA .RES+2
		 LDA .VLA+1
		 ADC .VLB+1
		 STA .RES+1
		 LDA .VLA+0
		 ADC .VLB+0
		 STA .RES+0
		ENDM

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

game_state_tick_2: subroutine
    _ADD32 level_for_game, game_state_adder, level_for_game
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
