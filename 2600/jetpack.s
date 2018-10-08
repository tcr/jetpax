; http://8bitworkshop.com/?platform=vcs&file=examples%2Fbigsprite
;
; TODO 03-19:
; - Investigate RAM PLUS (FA) method and test write kernel into it
; - Remove missile as way to render extra dots, switch to something else
; - Proof of concept missile as way to render Jetpack Man
; RAM+ is similar but the writing happens from adresses $1000 to $10FF (256 bytes) and the reading is from $1100 to $11FF (the next 256 bytes).
; 12K
;
; TODO 10-03:
; - Need to make each of the two-line kernels into a loop...
; - So that the rewriting code can call and overwrite the line easily
; - Then need POC of reading from a fixed buffer of code and copying into
;   the kernel those bytes, then a way to generate the bytes to stuff in the
;   kernel, then have per-line mutations!!

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
SpriteEnd byte
XPos    byte    ; X position of player sprite


Speed1  byte
Speed2  byte

YPos    byte    ; Y position of player sprite
YPos2   byte

GEM_02_TARGET byte

JMP_ADDR byte
JMP_ADDR_2 byte

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ROW_COUNT        equ 16

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

; ; all off
; GEM_00 equ SET_0_0
; GEM_02 equ SET_0_0
; GEM_04 equ SET_0_0
; GEM_06 equ SET_0_0
; GEM_08 equ SET_0_L
; GEM_09 equ SET_0_0
; GEM_11 equ SET_0_0
; GEM_13 equ SET_0_0
; GEM_15 equ SET_0_0
; GEM_17 equ SET_0_R
; GEM_18 equ SET_0_0
; GEM_20 equ SET_0_0
; GEM_22 equ SET_0_0
; GEM_24 equ SET_0_0

; all on
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

; ; odd on
; GEM_00 equ SET_1_0
; GEM_02 equ SET_1_0
; GEM_04 equ SET_1_0
; GEM_06 equ SET_1_0
; GEM_08 equ SET_1_L
; GEM_09 equ SET_0_1
; GEM_11 equ SET_0_1
; GEM_13 equ SET_0_1
; GEM_15 equ SET_0_1
; GEM_17 equ SET_0_R
; GEM_18 equ SET_1_0
; GEM_20 equ SET_1_0
; GEM_22 equ SET_1_0
; GEM_24 equ SET_1_0

; ; even on
; GEM_00 equ SET_0_1
; GEM_02 equ SET_0_1
; GEM_04 equ SET_0_1
; GEM_06 equ SET_0_1
; GEM_08 equ SET_0_L
; GEM_09 equ SET_1_0
; GEM_11 equ SET_1_0
; GEM_13 equ SET_1_0
; GEM_15 equ SET_1_0
; GEM_17 equ SET_1_R
; GEM_18 equ SET_0_1
; GEM_20 equ SET_0_1
; GEM_22 equ SET_0_1
; GEM_24 equ SET_0_1

; Colors

COL_BG equ $42    
COL_EMERALD equ $CC
COL_EMERALD_2 equ $CC

; HMOVE values

EMERALD_MI_HMOVE_S equ 39
EMERALD_MI_HMOVE_2 equ $d0
EMERALD_MI_HMOVE_3 equ $10

; Sprite details

SPRITE_HEIGHT    equ 9


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


; Offset from the sprite label to the point
; at which the sprite actually starts. This is the 0-padding
; FRAME_OFFSET equ 53

; Spriteend is HEIGHT_OFFSET - YPos
HEIGHT_OFFSET equ 200

; Compared with YPos
FLOOR_OFFSET equ 50

; YPos definite position 
YPosStart equ 100

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

      seg Code

      org $D000
      rorg $F000

BANK1 byte

      org $D200
      rorg $F200

Bank1Start:
      lda $FFFA
      nop
      nop
      nop

; Epilogue
      org $DFFC
      rorg $FFFC
      .word Bank1Start
      .word Bank1Start
      
      org $E000
      rorg $F000

BANK2 byte

      org $E200
      rorg $F200

Bank2Start:
      lda $FFFA
      nop
      nop
      nop

; Epilogue
      org $EFFC
      rorg $FFFC
      .word Bank2Start
      .word Bank2Start

      org $F000
      rorg $F000

BANK3 byte

      org $F200
      rorg $F200

Start
      lda $FFFA
      nop
      nop
      nop

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
      lda #$98
      sta JET_SP_COLOR
      lda #$00
      sta JET_SP

      ; Positions
      lda #YPosStart
      sta YPos
      lda #55
      sta XPos
      lda #0
      sta Speed1
      sta Speed2
      sta YPos2

BeginFrame
      VERTICAL_SYNC

      TIMER_SETUP 37

      ; Scanline counter
      lda #ROW_COUNT
      sta LoopCount

      ; Frame counter
      inc FrameCount

; Now the work stuff

      ; FRAMESWITCH
      lda #01
      and FrameCount
	bne CopyFrame2Kernel
CopyFrame1Kernel:

      ; Copy: FRAME 1
      ldy #(frame_1_end - frame_1_start)-1
.copy_loop:
      lda frame_1_start,Y
      sta $1000,Y
      dey
      bne .copy_loop
      lda frame_1_start
      sta $1000
      jmp CopyFrameNext

CopyFrame2Kernel:

      ; Copy: FRAME 2
      ldy #(frame_2_end - frame_2_start)-1
.copy_loop2:
      lda frame_2_start,Y
      sta $1000,Y
      dey
      bne .copy_loop2
      lda frame_2_start
      sta $1000
      jmp CopyFrameNext

CopyFrameNext:
      ; Positioning
      sta WSYNC
      SLEEP 40
      sta EMERALD_SP_RESET	; position 1st player
      sta WSYNC

      ; Misc
      lda #00
      sta EMERALD_MI_ENABLE

      ; Assign dervied SpriteEnd value
      lda #HEIGHT_OFFSET
      sbc YPos
      sta SpriteEnd

      ; Move missile to starting position and fine-tune position
      ; TODO replace with an HMOVE macro
      sta WSYNC
      sleep EMERALD_MI_HMOVE_S
      sta EMERALD_MI_RESET

      ; Player 1
      lda XPos
      ldx #0
      jsr SetHorizPos

      TIMER_WAIT
      TIMER_SETUP 192

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Frame border top

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
      ; FRAMESWITCH
      lda #01
      and FrameCount
	bne doframe2

      ; frame 1
      ldx #EMERALD_MI_HMOVE_2
      stx EMERALD_MI_HMOVE
      jmp doframe2after

      ; frame 2
doframe2:
      ldx #EMERALD_MI_HMOVE_3
      stx EMERALD_MI_HMOVE
doframe2after:




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; frame start




; MACRO for calculating next GRPx value

      MAC jet_spritedata_calc
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




      align 8

JUMP_TABLES:
      .byte $11, $00
      .byte <frame_start, >frame_start


frame_start:
      sta WSYNC
; [row:1]
      jet_spritedata_calc

      ; Select which jump table address to modify (update)
      ; FRAMESWITCH
      lda #01
      and FrameCount
	bne frame_jump_2
frame_jump_1:
      ; copy in the JUMP TABLES address
      lda >JUMP_TABLES
      sta $1000 + [frame_1_jump - frame_1_start]
      lda <JUMP_TABLES - 2
      sta $1001 + [frame_1_jump - frame_1_start]
      jmp frame_jump.next

frame_jump_2:
      ; copy in the JUMP TABLES address
      lda >JUMP_TABLES
      sta $1000 + [frame_2_jump - frame_2_start]
      lda <JUMP_TABLES - 2
      sta $1001 + [frame_2_jump - frame_2_start]

frame_jump.next:

      sta WSYNC
; [row:2]
      jet_spritedata_calc
      
      ; Prepare for the kernel.
      sleep 44
      dec SpriteEnd

      ; Jump to the copied kernel.
      ; TODO this has to be EXACT
; [row:3-4]
      jmp $1100

frame_row_start: subroutine
; [row:5]
      ; Cleanup from the kernel.
      lda #0
      sta EMERALD_MI_ENABLE
      sta EMERALD_SP


      sta WSYNC
; [row:6]
      jet_spritedata_calc

      ; FRAMESWITCH
      lda #01
      and FrameCount
	bne loadframe2
loadframe1:
      lda #SET_1_1
      sta GEM_02_TARGET

      lda #SET_1_1
      sta GEM_02_TARGET

      lda #SET_1_1
      sta GEM_02_TARGET

      lda #SET_1_L
      sta GEM_02_TARGET

      lda #SET_1_1
      sta GEM_02_TARGET

      lda #SET_1_1
      sta GEM_02_TARGET

      jmp loadframeafter

loadframe2:
      lda #SET_1_1
      sta GEM_02_TARGET

      lda #SET_1_1
      sta GEM_02_TARGET

      lda #SET_1_R
      sta GEM_02_TARGET

      lda #SET_1_1
      sta GEM_02_TARGET

      lda #SET_1_1
      sta GEM_02_TARGET

      lda #SET_1_1
      sta GEM_02_TARGET

      lda #SET_1_1
      sta GEM_02_TARGET

      jmp loadframeafter

loadframeafter:
      sta WSYNC
; [row:7]
      jet_spritedata_calc

      sta WSYNC
; [row:8]
      jet_spritedata_calc
      sta WSYNC
; [row:9]
      jet_spritedata_calc

      ; next line, repeat until <0
      dec LoopCount
      bmi .skip
      jmp frame_start
.skip:

      ; reset the background for bottom of playfield
frame_bottom:
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

      jsr MoveJoystick
      jsr SpeedCalculation

      TIMER_WAIT
      jmp BeginFrame


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; kernels


      ; Important cycles for the kernels:
      ; left border: 29, right border: 64

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; FRAME 1

; Emerald line macro

      ; rorg $1100


frame_1_start:
      ; 8c
      ; little-endian means 0x0
      lda $1100 + [frame_1_jump - frame_1_start]
      adc #2
      sta $1000 + [frame_1_jump - frame_1_start]

      ; Start new line + HMOVE
      ;sta HMOVE
      ;sleep 8

      dec SpriteEnd

      lda #EMR1
      ldx #EMR2
      ldy #EMR3
      .byte GEM_00, EMERALD_SP

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
      sleep 7
frame_1_jump:
      jmp (JUMP_TABLES)
frame_1_end:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; FRAME 2

frame_2_start:
      ; 8c
      ; little-endian means 0x0
      lda $1100 + [frame_2_jump - frame_2_start]
      adc #2
      sta $1000 + [frame_2_jump - frame_2_start]

      ; Enable missile (using excessive lda instructions)
      lda #02
      .byte GEM_08, EMERALD_MI_ENABLE

      dec SpriteEnd
      sleep 5
      ; ldy SpriteEnd
      ; lda Frame0,Y
      ; sta JET_SP

      ; moved: lda #T1
      ldx #T2
      ldy #T3
      .byte GEM_02, EMERALD_SP

      ; cycle 25
      sta EMERALD_SP_RESET
      lda #T1 ; movable
      sleep 4
      .byte GEM_06, EMERALD_SP
      sta EMERALD_SP_RESET
      .byte GEM_11, EMERALD_SP
      ; stx EMERALD_MI_ENABLE ; stx disables it
      sleep 3
      .byte GEM_15, EMERALD_SP
      sta EMERALD_SP_RESET
      .byte GEM_20, EMERALD_SP
      .byte GEM_24, EMERALD_SP
      sta HMCLR ; movable
      sleep 3

      ; cycle 64 (start of right border)
      sleep 7
frame_2_jump:
      jmp (JUMP_TABLES)
frame_2_end:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; SUBROUTINE
    ; Read joystick movement and apply to object 0
MoveJoystick
    ; Move vertically
    ; (up and down are actually reversed since ypos starts at bottom)
;     ldx YPos
    lda #%00010000    ;Up?
    bit SWCHA
    bne SkipMoveUp

    clc
    lda Speed2
    adc #12
    sta Speed2
    lda Speed1
    adc #00
    sta Speed1

SkipMoveUp:
    ldx XPos

      ; Only check left/right on odd frames;
      ; TODO make this just a fractional speed
      ; rather than dropping frames
      lda #01
      and FrameCount
	bne SkipMoveRight


    ; Move horizontally
    lda #%01000000    ;Left?
    bit SWCHA
    bne SkipMoveLeft
    cpx #29
    bcc SkipMoveLeft
    dex

    ; Reflect
;     lda #$ff
;     sta REFP0
SkipMoveLeft
    lda #%10000000    ;Right?
    bit SWCHA
    bne SkipMoveRight
    cpx #128
    bcs SkipMoveRight
    inx

    ; Reflect
;     lda #$0
;     sta REFP0
SkipMoveRight
    stx XPos
    rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


SpeedCalculation
    sec
    lda Speed2
    sbc #7
    sta Speed2
    lda Speed1
    sbc #0
    sta Speed1

    clc
    lda YPos2
    adc Speed2
    sta YPos2
    lda YPos
    adc Speed1
    sta YPos
    
    cmp #FLOOR_OFFSET
    bcs NewThing2

    ; Reset everything?
    lda #FLOOR_OFFSET
    sta YPos
    lda #0
    sta Speed1
    sta Speed2
NewThing2:
    rts



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
; Comical amount of 0's for now to simplify sprite rendering

; Y can be from:
;     SPRITE_HEIGHT to (8*ROW_COUNT)
; SpriteEnd: 8..128
; Frame0 should start at +120 so the Y rollunder of -$120 is OK
      REPEAT 124
            .byte 0
      REPEND
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
      REPEAT 124
            .byte 0
      REPEND


; Epilogue
      org $fffc
      .word Start
      .word Start