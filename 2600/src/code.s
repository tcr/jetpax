      include "jetpax.h"

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Start of Bank 0 (where all banks redirect to)

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
      lda #%00010011
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
      lda #$0f
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

      lda #0
      sta ROW_DEMO_INDEX

BeginFrame
      VERTICAL_SYNC

      TIMER_SETUP 37

      ; Scanline counter
      lda #ROW_COUNT
      sta LoopCount

      ; Frame counter
      inc FrameCount

; Now the work stuff
      jmp copy_frame

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

      MAC EMERALDS_TWO
.target  SET {1}
      ldx #%11
      .byte $CB, $0 ; axs
      ldy map_full,X
      sty [.target - storage + KERNEL_STORAGE_W]
      ror
      ror
      ENDM

      MAC EMERALDS_TWO_SKIP
      ror
      ror
      ENDM

      MAC EMERALDS_ONE
.target  SET {1}
.source SET {2}
      tax
      and #%1
      tay
      lda .source,Y
      sta [.target - storage + KERNEL_STORAGE_W]
      txa
      ror
      ENDM

      MAC EMERALDS_ONE_SKIP
      ror
      ENDM

      align 8
storage:
      ; Gem defaults kernel 1
storage_00:
      .byte SET_1_0
storage_04:
      .byte SET_0_0
storage_09:
      .byte SET_1_1
storage_13:
      .byte SET_1_1
storage_17:
      .byte SET_1_R
storage_18:
      .byte SET_0_0
storage_22:
      .byte SET_0_0

      ; Gem defaults kernel 2
storage_02:
      .byte SET_0_0
storage_06:
      .byte SET_0_0
storage_08:
      .byte SET_0_L
storage_11:
      .byte SET_1_1
storage_15:
      .byte SET_1_1
storage_20:
      .byte SET_0_0
storage_24:
      .byte SET_0_1
storage_end:

      align 8
      ; first bit of byte 2 & 3 are unused for simplicity
      .byte %0000, %000001, %0000100, %00000000
map_emeralds:
      .byte %1010, %0000000, %0000000, %00000000
      .byte %0101, %0000000, %0000000, %00000000
      .byte %0010, %1000000, %0000000, %00000000
      .byte %0001, %0100000, %0000000, %00000000
      .byte %0000, %1010000, %0000000, %00000000
      .byte %0000, %0101000, %0000000, %00000000
      .byte %0000, %0010100, %0000000, %00000000
      .byte %0000, %0001010, %0000000, %00000000
      .byte %0000, %0000101, %0000000, %00000000
      .byte %0000, %0000010, %1000000, %00000000
      .byte %0000, %0000001, %0100000, %00000000
      .byte %0000, %0000000, %1010000, %00000000
      .byte %0000, %0000000, %0101000, %00000000
      .byte %0000, %0000000, %0010100, %00000000
      .byte %0000, %0000000, %0001010, %00000000
      .byte %0000, %0000000, %0000101, %00000000
      .byte %0000, %0000000, %0000010, %10000000
      .byte %0000, %0000000, %0000001, %01000000
      .byte %0000, %0000000, %0000000, %10100000
      .byte %0000, %0000000, %0000000, %01010000
      .byte %0000, %0000000, %0000000, %00101000
      .byte %0000, %0000000, %0000000, %00010100
      .byte %0000, %0000000, %0000000, %00001010
      .byte %0000, %0000000, %0000000, %00000101
      .byte %1000, %0000000, %0000000, %00000010
      .byte %0100, %0000000, %0000000, %00000001
map_emeralds_end:

      align 8
map_full:
      .byte SET_0_0
      .byte SET_0_1
      .byte SET_1_0
      .byte SET_1_1
map_missle_l:
      .byte SET_0_L
      .byte SET_1_L
map_missle_r:
      .byte SET_0_R
      .byte SET_1_R


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

copy_frame:
      ; FRAMESWITCH
      lda #01
      and FrameCount
	beq CopyFrame1Kernel
      jmp CopyFrame2Kernel

CopyFrame1Kernel:
      ; Copy: KERNEL 1
      ldy #(kernel_1_end - kernel_1_start)-1
.copy_loop_1:
      lda kernel_1_start,Y
      sta $1000,Y
      dey
      bne .copy_loop_1
      lda kernel_1_start
      sta $1000

      ldx ROW_DEMO_INDEX
      lda map_emeralds+3,X
      EMERALDS_TWO_SKIP
      EMERALDS_TWO storage_22
      EMERALDS_TWO_SKIP
      EMERALDS_TWO storage_18

      ldx ROW_DEMO_INDEX
      lda map_emeralds+2,X
      EMERALDS_ONE storage_17, map_missle_r
      EMERALDS_TWO_SKIP
      EMERALDS_TWO storage_13
      EMERALDS_TWO_SKIP

      ldx ROW_DEMO_INDEX
      lda map_emeralds+1,X
      EMERALDS_TWO storage_09
      EMERALDS_ONE_SKIP
      EMERALDS_TWO_SKIP
      EMERALDS_TWO storage_04

      ldx ROW_DEMO_INDEX
      lda map_emeralds+0,X
      EMERALDS_TWO_SKIP
      EMERALDS_TWO storage_00

      jmp CopyFrameNext

CopyFrame2Kernel:
      ; Copy: KERNEL 2
      ldy #(kernel_2_end - kernel_2_start)-1
.copy_loop_2:
      lda kernel_2_start,Y
      sta $1000,Y
      dey
      bne .copy_loop_2
      lda kernel_2_start
      sta $1000

      ldx ROW_DEMO_INDEX
      lda map_emeralds+3,X
      EMERALDS_TWO storage_24
      EMERALDS_TWO_SKIP
      EMERALDS_TWO storage_20
      EMERALDS_TWO_SKIP

      ldx ROW_DEMO_INDEX
      lda map_emeralds+2,X
      EMERALDS_ONE_SKIP
      EMERALDS_TWO storage_15
      EMERALDS_TWO_SKIP
      EMERALDS_TWO storage_11

      ldx ROW_DEMO_INDEX
      lda map_emeralds+1,X
      EMERALDS_TWO_SKIP
      EMERALDS_ONE storage_08, map_missle_l
      EMERALDS_TWO storage_06
      EMERALDS_TWO_SKIP

      ldx ROW_DEMO_INDEX
      lda map_emeralds+0,X
      EMERALDS_TWO storage_02
      EMERALDS_TWO_SKIP

      jmp CopyFrameNext


CopyFrameNext:

      ; Frame skipping for increasing demo index
      lda FrameCount
      and #%111
      cmp #%111
      bne .next_next_thing

      clc
      lda ROW_DEMO_INDEX
      adc #4
      cmp #[map_emeralds_end - map_emeralds]
      bcc .next_thing_local
      lda #0
.next_thing_local
      sta ROW_DEMO_INDEX
.next_next_thing:
      sta WSYNC

      ; Positioning
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


      ; Choose which hmove value to use


      ; [TODO]
      ; Make these into separate horizontal positioning calls
      ; which will make it possible to do better missle tricks
      ; and free up both kernels to have another reigster



      ; FRAMESWITCH
      lda #01
      and FrameCount
	bne doframe2

      ; frame 1
      lda #EMERALD_MI_HMOVE_2
      sta EMERALD_MI_HMOVE
      jmp doframe2after

      ; frame 2
doframe2:
      lda #EMERALD_MI_HMOVE_3
      sta EMERALD_MI_HMOVE
doframe2after:




      TIMER_WAIT
      TIMER_SETUP 192
      sta WSYNC ; ??? Is this needed?

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Visible Kernel
;

; Frame border top

      ; First HMOVE
      sta HMOVE

      lda #0
      sta COLUPF
      sta PF1
      sta PF2
      lda #SIGNAL_LINE
      sta COLUBK

      REPEAT 6
      sta WSYNC
      REPEND

      lda #0
      sta COLUBK
      sta WSYNC

      ; Start top border
border_top:
      ; Make the playfield solid.
      lda #%00111111
      sta PF1
      lda #%11111111
      sta PF2

      lda #COL_BG
      ldy #0

      sta COLUPF
      sta WSYNC

      sty COLUPF
      sta WSYNC

      sta COLUPF
      sta WSYNC

      sta WSYNC
      
      sta WSYNC
      
      sty COLUPF
      sta WSYNC
      
      sta COLUPF
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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Frame Start



; MACRO for calculating next GRPx value

      MAC jet_spritedata_calc_nosta
      ; loader
      dcp SpriteEnd

      ; 4c
      ; This must never be 5 cycles This mean Frame0 + Y must not cross below apage boundary.
      ; 6c
      ldy #0
      .byte $b0, $01 ;2c / 3c (taken)
      .byte $2c ; 4c / 0c
      ldy SpriteEnd

      ENDM

      MAC jet_spritedata_calc
      ; loader
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


      ; Start the row with a WSYNC.
row_start:
      ; ~15c 
      jet_spritedata_calc
      sta WSYNC

; [row:1]
      jet_spritedata_calc

      lda #0
      sta COLUPF

      ; Push jump table to the stack
      lda #>[row_after_kernel - 1]
      pha
      lda #<[row_after_kernel - 1]
      pha
      lda #%10000001
      pha
      lda #>[$1100 - 1]
      pha
      lda #<[$1100 - 1]
      pha
      lda #%10000001
      pha

      sta WSYNC

; [row:2]
      jet_spritedata_calc


      lda #COL_BG
      sta COLUPF
      

      lda #SPRITE_HEIGHT
      jet_spritedata_calc_nosta
      lda Frame0,Y
      sta $fa
      jet_spritedata_calc_nosta
      lda Frame0,Y
      sta $fd

      sleep 6

; [row:3-4]
      ; Jump to the copied kernel.
kernel_launch:
      jmp KERNEL_START

row_after_kernel:
; [row:5]
      ; Cleanup from the kernel.
      lda #0
      sta EMERALD_MI_ENABLE
      sta EMERALD_SP
      sta COLUPF

      jet_spritedata_calc

      sta WSYNC

; [row:6]
      jet_spritedata_calc
      lda #COL_BG
      sta COLUPF

      ; FRAMESWITCH
      lda #01
      and FrameCount
	bne loadframe2

loadframe1:
      ; ~30c

      ; Emerald byte setting 1A
      ldx #0
      lda KERNEL_STORAGE_R,X
      sta GEM_00_W
      inx
      lda KERNEL_STORAGE_R,X
      sta GEM_04_W
      inx
      lda KERNEL_STORAGE_R,X
      sta GEM_09_W
      inx

      sta WSYNC

; [row:7]
      jet_spritedata_calc

      ; Emerald byte setting 1B
      lda KERNEL_STORAGE_R,X
      sta GEM_13_W
      inx
      lda KERNEL_STORAGE_R,X
      sta GEM_17_W
      inx
      lda KERNEL_STORAGE_R,X
      sta GEM_18_W
      inx
      lda KERNEL_STORAGE_R,X
      sta GEM_22_W

      jmp row_7_end

loadframe2:
      ; ~30c

      ; Emerald byte setting 2A
      ldx #[storage_02 - storage]
      lda KERNEL_STORAGE_R,X
      sta GEM_02_W
      inx
      lda KERNEL_STORAGE_R,X
      sta GEM_06_W
      inx
      lda KERNEL_STORAGE_R,X
      sta GEM_08_W
      inx

      sta WSYNC

; [row:7]
      jet_spritedata_calc

      ; Emerald byte setting 2B
      lda KERNEL_STORAGE_R,X
      sta GEM_11_W
      inx
      lda KERNEL_STORAGE_R,X
      sta GEM_15_W
      inx
      lda KERNEL_STORAGE_R,X
      sta GEM_20_W
      inx
      lda KERNEL_STORAGE_R,X
      sta GEM_24_W

      jmp row_7_end

row_7_end:
      sta WSYNC

; [row:8]
      ; Repeat loop until LoopCount < 0
      dec LoopCount
      bmi frame_bottom
      jmp row_start

      ; reset the background for bottom of playfield
frame_bottom:
      ;sta WSYNC

      ; Form the bottom of the level frame.
      lda #%00111111
      sta PF1
      lda #%11111111
      sta PF2

      ; Clear all sprites.
      lda #0
      sta EMERALD_SP
      sta JET_SP
      sta EMERALD_MI_ENABLE

      lda #COL_BG
      ldy #0
      sta WSYNC

      sty COLUPF
      sta WSYNC

      sta COLUPF
      sta WSYNC

      sta WSYNC

      sta WSYNC

      sty COLUPF
      sta WSYNC

      sta COLUPF
      sta WSYNC
      sta WSYNC

      ; Blank all background colors.
frame_end:
      lda #0
      sta COLUPF
      sta PF2
      sta PF1
      sta EMERALD_SP
      sta WSYNC

      ; Guide lines (2x)
      lda #SIGNAL_LINE
      sta COLUBK
      REPEAT 6
      sta WSYNC
      REPEND
      lda #$00
      sta COLUBK
      sta WSYNC

      TIMER_WAIT
      TIMER_SETUP 30

      jsr MoveJoystick
      jsr SpeedCalculation

      TIMER_WAIT
      jmp BeginFrame


