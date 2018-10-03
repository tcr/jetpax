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
GEM_06 equ SET_0_0
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

EMERALD_MI_HMOVE_S equ 39
EMERALD_MI_HMOVE_2 equ $b0
EMERALD_MI_HMOVE_3 equ $10

; Sprite details

SpriteHeight    equ 9
FRAME_OFFSET equ 100

EMERALD_SP_COLOR        equ COLUP1
EMERALD_SP              equ GRP1
EMERALD_MI_ENABLE       equ ENAM1
EMERALD_SP_RESET        equ RESP1
EMERALD_MI_RESET        equ RESM1
EMERALD_SP_HMOVE        equ HMP1
EMERALD_MI_HMOVE        equ HMM1
EMERALD_COPIES          equ NUSIZ1

JET_SP                  equ GRP0
JET_SP_RESET            equ RESP0
JET_SP_HMOVE            equ HMP0
JET_SP_COLOR            equ COLUP0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

      seg Code
      org $f000

Lol byte

      org $f100

Start
      CLEAN_START
      lda #0
      sta FrameCount

      ; P0 has three copies
      lda #THREE_COPIES
      sta EMERALD_COPIES

      lda #$00
      sta COLUBK
      lda #%00000001
      sta CTRLPF             ; reflect playfield

      ; Disable VDEL
      lda #0
      sta VDELP0
      sta VDELP1

      ; Player 0
      ldx #COL_EMERALD
      stx EMERALD_SP_COLOR

      ; Player 1
      lda #$86
      sta JET_SP_COLOR
      lda #$00
      sta JET_SP
      lda #(55  + FRAME_OFFSET)
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
      sta EMERALD_SP_RESET	; position 1st player
      sta WSYNC

      ; Misc
      lda #00
      sta EMERALD_MI_ENABLE
      lda SpriteEndOriginal
      sta SpriteEnd

      ; Move missile to starting position and fine-tune position
      ; TODO replace with a macro
      sta WSYNC
      sleep EMERALD_MI_HMOVE_S
      sta EMERALD_MI_RESET

      ; Player 1
      lda XPos
      ldx #0
      jsr SetHorizPos

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



      MAC jet_spritedata_calc
      lda #(SpriteHeight + FRAME_OFFSET)
      dcp SpriteEnd
      ldy SpriteEnd
      lda Frame0,Y
      sta JET_SP
      ENDM

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



frame_1_entry:
      ; also pallet_line2 cont.
      ldx #EMERALD_MI_HMOVE_2
      stx EMERALD_MI_HMOVE

frame_1_start:
      sta WSYNC
      jet_spritedata_calc
      sta WSYNC
      jet_spritedata_calc

; Line macro; run twice
      MAC Frame1Line

      ; Start new line + HMOVE
      sta HMOVE

      ; sleep 10
      ldy SpriteEnd
      lda Frame0,Y
      sta JET_SP

      lda #EMR1
      ldx #EMR2
      ldy #EMR3
      .byte GEM_00, EMERALD_SP

      ; left border: 29, right border: 64

      ; 22
      sta EMERALD_SP_RESET
      sleep 6
      .byte GEM_04, EMERALD_SP
      sta EMERALD_SP_RESET
      .byte GEM_09, EMERALD_SP
      sleep 3
      .byte GEM_13, EMERALD_SP
      sta EMERALD_SP_RESET
      .byte GEM_17, EMERALD_MI_ENABLE
      .byte GEM_18, EMERALD_SP
      sta HMCLR ; movable
      .byte GEM_22, EMERALD_SP
      .byte GEM_08, EMERALD_MI_ENABLE

      ; cycle 64 (start of right border)
      sleep (12-7)

      lda #SpriteHeight
      dec SpriteEnd
      ENDM

; Line macro invocation
      sta WSYNC
      Frame1Line
      Frame1Line
      
frame_1_remainder:
      lda #0
      sta EMERALD_MI_ENABLE
      sta EMERALD_SP

      ; four blank lines
      sta WSYNC
      jet_spritedata_calc
      sta WSYNC
      jet_spritedata_calc
      sta WSYNC
      jet_spritedata_calc
      sta WSYNC
      jet_spritedata_calc

      ; next line, repeat until <0
      dec LoopCount
      bmi frame_1_remainder.skip
      jmp frame_1_start
frame_1_remainder.skip:
      jmp frame_bottom




frame_2_entry:
      ; also pallet_line2 cont.
      ldx #EMERALD_MI_HMOVE_3
      stx EMERALD_MI_HMOVE

frame_2_start:
      ; Start
      lda #02

      sta WSYNC
      jet_spritedata_calc
      sta WSYNC
      jet_spritedata_calc

; Line macro; run twice
      MAC Frame2Line

      ; Start new line + HMOVE
      sta HMOVE

      ; Enable missile
      ; NOTE: rolls over from STA at end of cycle
      .byte GEM_08, EMERALD_MI_ENABLE

      ; sleep 10
      ldy SpriteEnd
      lda Frame0,Y
      sta JET_SP

      lda #T1
      ldx #T2
      ldy #T3
      .byte GEM_02, EMERALD_SP

      ; cycle 25
      sta EMERALD_SP_RESET
      sleep 6
      .byte GEM_06, EMERALD_SP
      sta EMERALD_SP_RESET
      .byte GEM_11, EMERALD_SP
      stx EMERALD_MI_ENABLE ; (disable)
      .byte GEM_15, EMERALD_SP
      sta EMERALD_SP_RESET
      .byte GEM_20, EMERALD_SP
      .byte GEM_24, EMERALD_SP
      ; cycle 58
      sta HMCLR ; movable
      sleep 3

      ; cycle 64 (start of right border)
      sleep (10-7)

      lda #SpriteHeight
      dec SpriteEnd

      ; Rollover
      lda #02
      ENDM

; Line macro invocation
      sta WSYNC
      Frame2Line
      Frame2Line
      
frame_2_remainder:
      lda #0
      sta EMERALD_MI_ENABLE
      sta EMERALD_SP

      ; four blank lines
      sta WSYNC
      jet_spritedata_calc
      sta WSYNC
      jet_spritedata_calc
      sta WSYNC
      jet_spritedata_calc
      sta WSYNC
      jet_spritedata_calc

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
      sta EMERALD_SP
      sta JET_SP
      sta EMERALD_MI_ENABLE

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
      sta EMERALD_SP

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
    cpx #(9 + FRAME_OFFSET)
    bcc SkipMoveUp
    dec SpriteEndOriginal
SkipMoveUp
    ; Move vertically
    ; (up and down are actually reversed since ypos starts at bottom)
    lda #%00100000    ;Up?
    bit SWCHA
    bne SkipMoveDown
    ldx SpriteEndOriginal
    cpx #(120 + FRAME_OFFSET)
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
    sta JET_SP_RESET,x    ; fix coarse position
    sta JET_SP_HMOVE,x    ; set fine offset
    rts        ; return to caller



      align 256

; Bitmap data for character "standing" position

Frame0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
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
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0
    .byte #0



; Epilogue
      org $fffc
      .word Start
      .word Start