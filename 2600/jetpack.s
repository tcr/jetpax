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
      lda #16
      sta LoopCount	; scanline counter
      inc LoopCount2
      lda #$00
      sta COLUBK	; background color
      lda #$12
      sta COLUP1	; by having different colors
      lda #THREE_COPIES
      sta NUSIZ0
      sta NUSIZ1	; both players have 3 copies

      lda #%11110000
      sta PF0
      lda #%11100000
      sta PF1
      lda #%00000000
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

HMM0_S equ 39
HMM0_1 equ $10
HMM0_2 equ $c0
HMM0_3 equ $40

      ; Set where the missile goes
      sta WSYNC
      sleep HMM0_S
      sta RESM0

      lda #HMM0_1
      sta HMM0
      sta WSYNC
      sta HMOVE

      ; IDK
      lda #%10101010
      sta GRP0	; B0 -> [GRP0]
      lda #00
      sta GRP1	; B1 -> [GRP1], B0 -> GRP0
      lda #$ff
      ;sta NUSIZ0

; disable one, the other, or both or not disable
; sta loop ... did i write this out?

EMR1 equ %01100000
EMR2 equ %00000110
EMR3 equ %01100110

T1 equ %11000000
T2 equ %00001100
T3 equ %11001100

SET_0_0 equ $87 ; SAX (AXS)
SET_1_0 equ $85 ; STA
SET_0_1 equ $86 ; STX
SET_1_1 equ $84 ; STY

SET_0_L equ $86 ; STX
SET_1_L equ $84 ; STY

SET_0_R equ $85 ; STA
SET_1_R equ $84 ; STY

GEM_00 equ SET_1_1
GEM_02 equ SET_1_1
GEM_04 equ SET_1_1
GEM_06 equ SET_1_1
GEM_08 equ SET_1_L
GEM_09 equ SET_1_1
GEM_11 equ SET_1_1
GEM_13 equ SET_1_1
GEM_15 equ SET_1_1
GEM_17 equ SET_1_R
GEM_18 equ SET_1_1
GEM_20 equ SET_1_1
GEM_22 equ SET_1_1
GEM_24 equ SET_1_1

      SLEEP 30	; start near end of scanline
      lda #01
      and LoopCount2
	bne loop2


      ldy #EMR2
      sta WSYNC
loop2:
      sta WSYNC	; sync to next scanline

      ; pallet_line2 cont.
pellet_entry:
      ldx #HMM0_2
      stx HMM0

      ;ldy LoopCount	; counts backwards
      sta WSYNC

;      lda #0
;      sta GRP0	; B0 -> [GRP0]
;      SLEEP 22
;      sta RESP0	; sync to next scanline
;      sta WSYNC

      ; Start new line
pellet_line1:
      ; reset the things
      sta HMOVE
      ldx #$BA
      stx COLUP0

      lda #$00
      sta ENAM0

      lda #EMR1
      ldx #EMR2
      ldy #EMR3

      .byte GEM_00, GRP0
      sta RESP0

	sleep 6
      .byte GEM_04, GRP0

      sta RESP0
      .byte GEM_09, GRP0
      sleep 3
      .byte GEM_13, GRP0
      sta RESP0

      .byte GEM_17, ENAM0
      .byte GEM_18, GRP0
      sleep 3
      .byte GEM_22, GRP0

      ldx #HMM0_3
      stx HMM0

      .byte GEM_08, ENAM0

      sta WSYNC

pellet_line2:
      ; Start of line
      sta HMOVE
	ldx #$BA
      stx COLUP0

      lda #T1
      ldx #T2
      ldy #T3
      .byte GEM_02, GRP0

      sleep (20-12)
      sta RESP0
      sleep 6
      .byte GEM_06, GRP0
      sta RESP0
      .byte GEM_11, GRP0
      stx ENAM0 ; disable
      .byte GEM_15, GRP0
      sta RESP0
      .byte GEM_20, GRP0
      .byte GEM_24, GRP0

      sleep 4
      lda #0
      sta COLUP0

      sta WSYNC
      sta WSYNC
      sta WSYNC
      sta WSYNC
      sta WSYNC
      sta WSYNC

      dec LoopCount	; go to next line
      bpl pellet_entry	      ; repeat until < 0

end_frame:
      ; End
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
