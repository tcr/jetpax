    seg.u Defines

ROW_COUNT               = 16
SIGNAL_LINE             = $02
FrameSkip               = %111 ; Tick (every 8 frames)

; RAM+ memory map

CBSRAM_KERNEL_WRITE     = $f000
CBSRAM_KERNEL_READ      = $f100
CBSRAM_KERNEL_ENTRY     = [CBSRAM_KERNEL_READ + 4]

RAMP_STORAGE_W          = $f040 ; is this just max(frame_1_end, frame_2_end) ?
RAMP_STORAGE_R          = $f140


; NUSIZ values

THREE_COPIES            = %00010011


; Colors

COL_BG                  = $42    
COL_EMERALD             = $CC
COL_EMERALD_2           = $CC


; HMOVE values for missiles

KERNEL_A_MISSILE_SLEEP  = 28
KERNEL_A_MISSILE_HMOVE  = $00

KERNEL_B_MISSILE_SLEEP  = 51
KERNEL_B_MISSILE_HMOVE  = $10

; Missile values when 2A=RST
; KERNEL_B_MISSILE_SLEEP equ 46
; KERNEL_B_MISSILE_HMOVE equ $20


; Sprite details

EMERALD_SP_COLOR        = COLUP1
EMERALD_SP              = GRP1
EMERALD_MI_ENABLE       = ENAM1
EMERALD_SP_RESET        = RESP1
EMERALD_MI_RESET        = RESM1
EMERALD_SP_HMOVE        = HMP1
EMERALD_MI_HMOVE        = HMM1
EMERALD_COPIES          = NUSIZ1

JET_SP                  = GRP0
JET_SP_RESET            = RESP0
JET_SP_HMOVE            = HMP0
JET_SP_COLOR            = COLUP0


; Game dimensionsn

; Spriteend is HEIGHT_OFFSET - YPos
SPRITE_HEIGHT           = 9
HEIGHT_OFFSET           = 200

; Compared with YPos
FLOOR_OFFSET = 70
CEILING_OFFSET = 190

; Starting player position
YPosStart = 70
XPosStart = 88

; Top left corner
; YPosStart equ 190
; XPosStart equ 28
