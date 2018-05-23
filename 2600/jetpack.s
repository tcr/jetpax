; http://8bitworkshop.com/?platform=vcs&file=examples%2Fbigsprite
;
; TODO 03-19:
; - Investigate RAM PLUS (FA) method and test write kernel into it
; - Remove missile as way to render extra dots, switch to something else
; - Proof of concept missile as way to render Jetpack Man
; RAM+ is similar but the writing happens from adresses $1000 to $10FF (256 bytes) and the reading is from $1100 to $11FF (the next 256 bytes).
; 12K

      processor 6502
      include "vcs.h"
      include "macro.h"
      include "xmacro.h"

      seg.u Variables
      org $80

Temp        byte
LoopCount   byte
LoopCount2   byte

THREE_COPIES    equ %00010011

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

      seg Code
      org $f000

Start
      CLEAN_START
      lda #0
      sta LoopCount2

NextFrame
      VERTICAL_SYNC

      TIMER_SETUP 37
      lda #35
      sta LoopCount	; scanline counter
      inc LoopCount2
      lda #$00
      sta COLUBK	; background color
      lda #$B6
      sta COLUP0	; show how players alternate
      lda #$12
      sta COLUP1	; by having different colors
      lda #THREE_COPIES
      sta NUSIZ0
      sta NUSIZ1	; both players have 3 copies

      lda #%11110000
      sta PF0
      lda #%11100001
      sta PF1
      lda #%10000000
      sta PF2
      lda #$02
      sta COLUPF
      lda #%00000001
      sta CTRLPF             ; reflect playfield

      sta WSYNC
      SLEEP 20
      sta RESP0	; position 1st player
      sta RESP1	; ...and 2nd player
      lda #$10
      sta HMP1	; 1 pixel to the left
      sta WSYNC
      sta HMOVE	; apply HMOVE
      sta HMCLR
      lda #0
      sta VDELP0	; we need the VDEL registers
      sta VDELP1	; so we can do our 4-store trick
      TIMER_WAIT

      TIMER_SETUP 192


      sta WSYNC
      sleep 40
      sta RESM0

      lda #%10101010
      sta GRP0	; B0 -> [GRP0]
      lda #00
      sta GRP1	; B1 -> [GRP1], B0 -> GRP0
      lda #$ff
      ;sta NUSIZ0

; disable one, the other, or both or not disable
; sta loop ... did i write this out?

EMR1 equ %01100110
EMR2 equ %00000110
EMR3 equ %01100000

T1 equ %11001100
T2 equ %00001100
T3 equ %11000000

      SLEEP 30	; start near end of scanline
      lda #0
      and LoopCount2
	bne loop2


        ldy #EMR2
      sta WSYNC
loop2
      sta WSYNC	; sync to next scanline
BigLoop
      ldx #$40
      stx HMM0

      ldy LoopCount	; counts backwards
      sta WSYNC

;      lda #0
;      sta GRP0	; B0 -> [GRP0]
;      SLEEP 22
;      sta RESP0	; sync to next scanline
;      sta WSYNC

      ; Start new line


      ; reset the things
      ldx #$BA
      stx COLUP0
      sta HMOVE

      lda #$00
      sta ENAM0

      lda #EMR1
      ldy #EMR2
      ldx #EMR3

      sta GRP0
      sta RESP0

	sleep 6
      sta GRP0
       ;sleep 4
 	;.byte $9F, $15, $00

      sta RESP0
      sta GRP0
      ;sleep 4
      ;lda #EMR1
      sleep 3
      stx ENAM0
      sta RESP0
      sta GRP0
      sleep 6
      sta GRP0

      ldx #$C0
      stx HMM0


      sta WSYNC
      sta HMOVE
;      ldx #$BA
	ldx #$4A
      stx COLUP0

      lda #T1
      ldy #T2
      ldx #T3
      sta GRP0

      sleep (20-12)
      sta RESP0
      sleep 6
      sta GRP0
      sta RESP0
      sta GRP0
      sleep 6
      sta RESP0

      ;ldx #$0
      ;stx HMM0
      ;sta WSYNC
      ;sta HMOVE
      ;stx COLUP0
      ;sta WSYNC
      ;sta HMOVE
      ;sta WSYNC
      ;sta HMOVE

;      stx COLUBK

;        sleep 3
;      stx GRP0
;      sta RESP0	; sync to next scanline
;      sty GRP0

      dec LoopCount	; go to next line
      bpl BigLoop	; repeat until < 0
      lda #0
      sta GRP0

      TIMER_WAIT

      TIMER_SETUP 30
      TIMER_WAIT
      jmp NextFrame

; Epilogue
      org $fffc
      .word Start
      .word Start
