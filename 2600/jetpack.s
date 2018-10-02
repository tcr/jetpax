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

; Adds glimmer for testing
LoopCount2   byte

THREE_COPIES    equ %00010011


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Sprites

; Frame 1 sprites
EMR1 equ %01100000
EMR2 equ %00000110
EMR3 equ %01100110

; Frame 2 sprites
T1 equ %11000000
T2 equ %00001100
T3 equ %11001100

; Shorthands

SET_0_0 equ $87 ; SAX (AXS)
SET_1_0 equ $85 ; STA
SET_0_1 equ $86 ; STX
SET_1_1 equ $84 ; STY

SET_0_L equ $86 ; STX
SET_1_L equ $84 ; STY

SET_0_R equ $85 ; STA
SET_1_R equ $84 ; STY

; Gem enabling/disabling globally

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

; Colors

COL_BG equ $42    
COL_EMERALD equ $CE
COL_EMERALD_2 equ $CE

; HMOVE values

HMM0_S equ 39
HMM0_1 equ $10
HMM0_2 equ $c0
HMM0_3 equ $00

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

      seg Code
      org $f000

Start
      CLEAN_START
      lda #0
      sta LoopCount2

      ;; Setup
      lda #THREE_COPIES
      sta NUSIZ0
      sta NUSIZ1	; both players have 3 copies

      lda #$00
      sta COLUBK
      lda #%00000001
      sta CTRLPF             ; reflect playfield

      ; Random P1 color
      lda #$12
      sta COLUP1
      lda #$10
      sta HMP1	; 1 pixel to the left

      lda #0
      sta VDELP0	; we need the VDEL registers
      sta VDELP1	; so we can do our 4-store trick

NextFrame
      VERTICAL_SYNC

      TIMER_SETUP 37
      lda #16
      sta LoopCount	; scanline counter
      inc LoopCount2    ; frame counter

      sta WSYNC
      SLEEP 20
      sta RESP0	; position 1st player
      sta RESP1	; ...and 2nd player
      sta WSYNC
      sta HMOVE	; apply HMOVE
      sta HMCLR
      TIMER_WAIT

      TIMER_SETUP 192

      ; Move missile to starting position
      sta WSYNC
      sleep HMM0_S
      sta RESM0

      ; Remove artifacts by moving these to end of line
      sta RESP0
      sta RESP1

      lda #HMM0_1
      sta HMM0
      sta WSYNC
      sta HMOVE

      ; Start top border
frame_top:
      lda #COL_BG
      sta COLUPF
      sta WSYNC
      sta WSYNC
      sta WSYNC
      sta WSYNC
      sta WSYNC
      sta WSYNC
      sta WSYNC
      sta WSYNC

PlayArea:
      ; PF is now the playing area
      lda #%00000000
      sta PF0
      lda #%00100000
      sta PF1
      lda #%00000000
      sta PF2

      ; Choose which kernel to use
      lda #01
      and LoopCount2
	bne NextFrame.2
      jmp frame_1_entry
NextFrame.2:
      jmp frame_2_entry



frame_1_entry:
      ; also pallet_line2 cont.
      ldx #HMM0_2
      stx HMM0
      
      sta WSYNC
      sta WSYNC

frame_1_start:


      MAC Frame1Line
      ;ldy LoopCount	; counts backwards
      sta WSYNC

;      lda #0
;      sta GRP0	; B0 -> [GRP0]
;      SLEEP 22
;      sta RESP0	; sync to next scanline
;      sta WSYNC

      sta HMOVE
      ldx #COL_EMERALD
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
      .byte GEM_08, ENAM0

      lda #0
      sta COLUP0
      sta HMM0
      ENDM

      Frame1Line
      Frame1Line
      
frame_1_remainder:
      sta WSYNC
      sta HMOVE
      sta WSYNC
      sta HMOVE
      sta WSYNC
      sta HMOVE
      sta WSYNC
      sta HMOVE
      sta WSYNC
      sta HMOVE
      sta WSYNC
      sta HMOVE

      ; next line, repeat until <0
      dec LoopCount
      bmi frame_1_remainder.skip
      jmp frame_1_start
frame_1_remainder.skip:
      jmp frame_bottom




frame_2_entry:
      ; also pallet_line2 cont.
      ldx #HMM0_3
      stx HMM0

      lda #$ff
      sta ENAM0

      sta WSYNC
      sta WSYNC

frame_2_start:
      MAC Frame2Line
      ;ldy LoopCount	; counts backwards
      sta WSYNC

;      lda #0
;      sta GRP0	; B0 -> [GRP0]
;      SLEEP 22
;      sta RESP0	; sync to next scanline
;      sta WSYNC

      ; Start new line
      sta HMOVE
	ldx #COL_EMERALD_2
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

      ;; TODO better than $ff?
      lda #$ff
      sta ENAM0
      ; sleep 4
      lda #0
      sta COLUP0
      sta HMM0
      ENDM

      Frame2Line
      Frame2Line
      
frame_2_remainder:
      sta WSYNC
      sta HMOVE
      sta WSYNC
      sta HMOVE
      sta WSYNC
      sta HMOVE
      sta WSYNC
      sta HMOVE
      sta WSYNC
      sta HMOVE
      sta WSYNC
      sta HMOVE

      ; next line, repeat until <0
      dec LoopCount
      bmi frame_2_remainder.skip
      jmp frame_2_start
frame_2_remainder.skip:
      jmp frame_bottom






      ; reset the background for bottom frame
frame_bottom:
      lda #%00000000
      sta PF0
      lda #%00111111
      sta PF1
      lda #%11111111
      sta PF2

      lda #0
      sta GRP0
      sta ENAM0

      sta WSYNC
      sta WSYNC
      sta WSYNC
      sta WSYNC
      sta WSYNC
      sta WSYNC
      sta WSYNC
      sta WSYNC

      lda #$00
      sta COLUBK
      sta COLUPF

frame_end:
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
