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

; Counters
RowCount   byte
LoopCount   byte
FrameCount   byte

YP1 byte
SpriteEndOriginal byte
SpriteEnd byte
XPos    byte    ; X position of player sprite

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Sprites

; Nusiz
THREE_COPIES    equ %00010011

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
SET_1_L equ $85 ; STY

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
GEM_17 equ SET_0_R
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

; Sprite details

SpriteHeight    equ 9

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

      seg Code
      org $f000

Start
      CLEAN_START
      lda #0
      sta FrameCount

      ; P0 has three copies
      lda #THREE_COPIES
      sta NUSIZ0

      lda #$00
      sta COLUBK
      lda #%00000001
      sta CTRLPF             ; reflect playfield

      lda #0
      sta VDELP0	; we need the VDEL registers
      sta VDELP1	; so we can do our 4-store trick

      ; Player 0
      ldx #COL_EMERALD
      stx COLUP0

      ; Player 1
      lda #$86
      sta COLUP1
      lda #$00
      sta GRP1
      lda #55 
      sta SpriteEndOriginal
      lda #55
      sta XPos

BeginFrame
      VERTICAL_SYNC

      TIMER_SETUP 37

      ; Scanline counter
      lda #16
      sta LoopCount

      ; Frame counter
      inc FrameCount

      ; Positioning
      sta WSYNC
      SLEEP 40
      sta RESP0	; position 1st player
      sta WSYNC

      ; Misc
      lda #00
      sta ENAM0
      lda SpriteEndOriginal
      sta SpriteEnd

      ; Move missile to starting position and fine-tune position
      ; TODO replace with a macro
      sta WSYNC
      sleep HMM0_S
      sta RESM0
      lda #HMM0_1
      sta HMM0
      sta WSYNC
      sta HMOVE

      ; Player 1
      lda XPos
      ldx #0
      jsr SetHorizPos
      stx GRP1

      TIMER_WAIT
      TIMER_SETUP 192

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
      and FrameCount
	bne BeginFrame.2
      jmp frame_1_entry
BeginFrame.2:
      jmp frame_2_entry



      MAC p1_calc
      lda #SpriteHeight
      dcp SpriteEnd
      ldy SpriteEnd
      lda Frame0,Y
      sta GRP1
      ENDM



frame_1_entry:
      ; also pallet_line2 cont.
      ldx #HMM0_2
      stx HMM0

frame_1_start:
      sta WSYNC
      p1_calc
      sta WSYNC

; Line macro; run twice
      MAC Frame1Line

      ; Start new line + HMOVE
      sta HMOVE

      ; sleep 10
      ldy SpriteEnd
      lda Frame0,Y
      sta GRP1

      lda #EMR1
      ldx #EMR2
      ldy #EMR3
      .byte GEM_00, GRP0

      ; left border: 29, right border: 64

      ; 22
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
      sta HMCLR ; movable
      .byte GEM_22, GRP0
      .byte GEM_08, ENAM0

      ; cycle 64 (start of right border)
      sleep (12-7)

      lda #SpriteHeight
      dcp SpriteEnd
      ENDM

; Line macro invocation
      sta WSYNC
      Frame1Line
      Frame1Line
      
frame_1_remainder:
      lda #0
      sta ENAM0
      sta GRP0

      ; four blank lines
      sta WSYNC
      p1_calc
      sta WSYNC
      p1_calc
      sta WSYNC
      p1_calc
      sta WSYNC
      p1_calc

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

frame_2_start:
      ; Start
      lda #02

      sta WSYNC
      p1_calc
      sta WSYNC

; Line macro; run twice
      MAC Frame2Line

      ; Start new line + HMOVE
      sta HMOVE

      ; Enable missile
      ; NOTE: rolls over from STA at end of cycle
      .byte GEM_08, ENAM0

      ; sleep 10
      ldy SpriteEnd
      lda Frame0,Y
      sta GRP1

      lda #T1
      ldx #T2
      ldy #T3
      .byte GEM_02, GRP0

      ; cycle 25
      sta RESP0
      sleep 6
      .byte GEM_06, GRP0
      sta RESP0
      .byte GEM_11, GRP0
      stx ENAM0 ; (disable)
      .byte GEM_15, GRP0
      sta RESP0
      .byte GEM_20, GRP0
      .byte GEM_24, GRP0
      ; cycle 58
      sta HMCLR ; movable
      sleep 3

      ; cycle 64 (start of right border)
      sleep (10-7)

      lda #SpriteHeight
      dcp SpriteEnd

      ; Rollover
      lda #02
      ENDM

; Line macro invocation
      sta WSYNC
      Frame2Line
      Frame2Line
      
frame_2_remainder:
      lda #0
      sta ENAM0
      sta GRP0

      ; four blank lines
      sta WSYNC
      p1_calc
      sta WSYNC
      p1_calc
      sta WSYNC
      p1_calc
      sta WSYNC
      p1_calc

      ; next line, repeat until <0
      dec LoopCount
      bmi frame_2_remainder.skip
      jmp frame_2_start
frame_2_remainder.skip:
      jmp frame_bottom






      ; reset the background for bottom frame
frame_bottom:
      sta WSYNC
      lda #%00000000
      sta PF0
      lda #%00111111
      sta PF1
      lda #%11111111
      sta PF2

      lda #0
      sta GRP0
      sta GRP1
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


    ; Read joystick movement and apply to object 0
MoveJoystick
    ; Move vertically
    ; (up and down are actually reversed since ypos starts at bottom)
    lda #%00010000    ;Up?
    bit SWCHA
    bne SkipMoveUp
    ldx SpriteEndOriginal
    cpx #9
    bcc SkipMoveUp
    dec SpriteEndOriginal
SkipMoveUp
    ; Move vertically
    ; (up and down are actually reversed since ypos starts at bottom)
    lda #%00100000    ;Up?
    bit SWCHA
    bne SkipMoveDown
    ldx SpriteEndOriginal
    cpx #120
    bcs SkipMoveDown
    inc SpriteEndOriginal
SkipMoveDown

    ; Move horizontally
    ldx XPos
    lda #%01000000    ;Left?
    bit SWCHA
    bne SkipMoveLeft
    cpx #29
    bcc SkipMoveLeft
    dex
SkipMoveLeft
    lda #%10000000    ;Right?
    bit SWCHA
    bne SkipMoveRight
    cpx #128
    bcs SkipMoveRight
    inx
SkipMoveRight
    stx XPos

      TIMER_WAIT
      jmp BeginFrame




; Subroutine
SetHorizPos
    sta WSYNC    ; start a new line
    bit 0        ; waste 3 cycles
    sec        ; set carry flag
DivideLoop
    sbc #15        ; subtract 15
    bcs DivideLoop    ; branch until negative
    eor #7        ; calculate fine offset
    asl
    asl
    asl
    asl
    sta RESP1,x    ; fix coarse position
    sta HMP1,x    ; set fine offset
    rts        ; return to caller



      align 256

; Bitmap data for character "standing" position
Frame0
    .byte #%00000000
    .byte #%01100000
    .byte #%01100000
    .byte #%01100000
    .byte #%11000000
    .byte #%11000000
    .byte #%11110000
    .byte #%11000000
    .byte #%11000000
    .byte #%00000000



; Epilogue
      org $fffc
      .word Start
      .word Start