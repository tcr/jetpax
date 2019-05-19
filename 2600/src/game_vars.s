    seg.u Variables

    org $80

DebugKernelID byte ; only for debugging

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

ROW_DEMO_INDEX byte

RamNibbleTemp       byte
RamNibbleVar1       byte
RamNibbleVar2       byte
RamZeroByte         byte
RamLowerSixByte     byte
RamStackBkp         byte

; Kernel support
RamPF1Value         byte
RamKernelGRP0       byte ; temp
RamKernelPhpTarget  byte
RamKernelX          byte
RamKernelY          byte
RamKernelGemini1    byte
RamKernelGemini1Reg byte
RamKernelGemini2    byte
RamKernelGemini2Reg byte
RamKernelGemini3    byte
RamKernelGemini3Reg byte
RamKernelGemini4    byte
RamKernelGemini4Reg byte
RamKernelGemini5    byte

BuildKernelX byte
BuildKernelY byte
BuildKernelRST byte
BuildKernelGrp0 byte
BuildKernelVdel1 byte
BuildKernelMissile byte

level_for_game byte
    byte
    byte
    byte

DO_MISS_A byte
DO_MISS_B byte
DO_GEMS_A byte
    byte
    byte
    byte
    byte
    byte
DO_GEMS_B byte
    byte
    byte
    byte
    byte
    byte

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ROW_COUNT = 16

SIGNAL_LINE = $02

; RAM+ memory map
CBSRAM_KERNEL_WRITE     = $f000
CBSRAM_KERNEL_READ      = $f100
CBSRAM_KERNEL_ENTRY     = [CBSRAM_KERNEL_READ + 3]

RAMP_STORAGE_W = $f040 ; is this just max(frame_1_end, frame_2_end) ?
RAMP_STORAGE_R = $f140

; NUSIZ values

THREE_COPIES = %00010011

; Colors

COL_BG equ $42    
COL_EMERALD equ $CC
COL_EMERALD_2 equ $CC

; HMOVE values for missiles

KERNEL_A_MISSILE_SLEEP equ 28
KERNEL_A_MISSILE_HMOVE equ $00

KERNEL_B_MISSILE_SLEEP equ 51
KERNEL_B_MISSILE_HMOVE equ $10

; Missile values when 2A=RST
; KERNEL_B_MISSILE_SLEEP equ 46
; KERNEL_B_MISSILE_HMOVE equ $20

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

; Spriteend is HEIGHT_OFFSET - YPos
HEIGHT_OFFSET equ 200

; Compared with YPos
FLOOR_OFFSET equ 62
CEILING_OFFSET equ 190

; Starting player position
YPosStart equ 62
XPosStart equ 88

; Top left corner
; YPosStart equ 190
; XPosStart equ 28

; Tick (every 8 frames)
FrameSkip equ %111
