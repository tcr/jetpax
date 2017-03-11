; http://8bitworkshop.com/?platform=vcs&file=examples%2Fbigsprite

      processor 6502
      include "vcs.h"
      include "macro.h"
      include "xmacro.h"

      seg.u Variables
      org $80

Temp        byte
LoopCount   byte

THREE_COPIES    equ %011

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

      seg Code
      org $f000

Start
      CLEAN_START

NextFrame
      VERTICAL_SYNC

      TIMER_SETUP 37
      lda #64
      sta LoopCount	; scanline counter
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
      lda #%11101010
      sta PF1
      lda #%01010101
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
      lda #%10101010
      sta GRP0	; B0 -> [GRP0]
      lda #00
      sta GRP1	; B1 -> [GRP1], B0 -> GRP0
      lda #$ff
      ;sta NUSIZ0

; disable one, the other, or both or not disable
; sta loop ... did i write this out?

EMR1 equ %00110011
EMR2 equ %001100110
EMR3 equ %00110011
EMR4 equ %00110011
EMR5 equ %00110011

      SLEEP 30	; start near end of scanline
      sta WSYNC	; sync to next scanline
BigLoop
      ldy LoopCount	; counts backwards
      sta WSYNC

      lda #0
      sta GRP0	; B0 -> [GRP0]
      SLEEP 22
      sta RESP0	; sync to next scanline
      sta WSYNC

      lda #EMR1
      sta GRP0	; B0 -> [GRP0]

      ldx #EMR5
      ldy #EMR2
      lda #EMR3

      sleep 22

      stx GRP0

;	SLEEP 18

      sta GRP0
      sta RESP0	; sync to next scanline
      lda #EMR4
      sta GRP0
;        sleep 3
      stx GRP0
      sta RESP0	; sync to next scanline
      sty GRP0

      dec LoopCount	; go to next line
      bpl BigLoop	; repeat until < 0
      lda #0
      sta GRP0

      TIMER_WAIT

      TIMER_SETUP 30
      TIMER_WAIT
      jmp NextFrame

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Bitmap data, six columns

    align $100	; ensure we start on a page boundary
Bitmap0
    hex 00
    hex 00000000000000000000000000000000
    hex 00000000000000000000000000000001
    hex 01010205040402040404040404040404
    hex 040404060203000107df7f1f0f000000
Bitmap1
    hex 00
    hex 0000073f1f0303000000000000010704
    hex 0808101010101412120a0a1e75c38000
    hex 0000076260e0e0e0c0c0e0e0c0c00000
    hex 00000000408170feffffffffc7030000
Bitmap2
    hex 00
    hex 007ffffcf0e0c0404040404020bb7608
    hex 000402020809094f494949fa07010000
    hex 00000000006070f0f0f0c0e0e0e0e0e0
    hex 400000000010a06010e0e0f1ffff7f00
Bitmap3
    hex 00
    hex 3effff07010000000000302159878184
    hex 848efeffffff9f0f0e9c7c0402c12010
    hex 08040207050000000002020104070f0f
    hex 0f070703030707070f1f7efcf8f0c000
Bitmap4
    hex 00
    hex 00f0f0fffff0404040404080641e02c3
    hex 4242c3e2e2f4fcfc787838787cfa3131
    hex 6102021cf840c04042a022c14080c4c3
    hex c0c0c0c0808090900010180c04243800
Bitmap5
    hex 00
    hex 000000fcfefc1c0c040402020202040c
    hex f800e01804040402020101010111e192
    hex dc700000000000000000000080808000
    hex 00000000000000000000000000000000

; Epilogue
      org $fffc
      .word Start
      .word Start
