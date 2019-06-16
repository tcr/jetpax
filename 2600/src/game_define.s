    seg.u CompileFlags

; ONLY_KERNEL_A = 1
; ONLY_KERNEL_B = 1

    seg.u Defines

ROW_COUNT               = 16
SIGNAL_LINE             = $02
FrameSkip               = %111 ; Tick (every 8 frames)

; RAM+ memory map



CBSRAM_KERNEL_WRITE     = $80
CBSRAM_KERNEL_READ      = $80
CBSRAM_KERNEL_READ_ID   = CBSRAM_KERNEL_READ
CBSRAM_KERNEL_ENTRY     = [CBSRAM_KERNEL_READ + 4]
CBSRAM_KERNEL_READ_END  = [CBSRAM_KERNEL_READ + $40]

CBSRAM_NIBBLE_WRITE     = $f080
CBSRAM_NIBBLE_READ      = $f180


DebugKernelID           = CBSRAM_KERNEL_READ ; which kernel are we running this frame? (for debugging)


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


; Game dimensions

; Spriteend is HEIGHT_OFFSET - YPos
SPRITE_HEIGHT           = 8
HEIGHT_OFFSET           = 200

; Compared with YPos
FLOOR_OFFSET = 72
CEILING_OFFSET = 192

; Starting player position
YPosStart = 72
XPosStart = 78

; Top left corner
; YPosStart equ 190
; XPosStart equ 28


; Nibble Variables

NibbleVar1              = 0
NibbleVar2              = 1
NibbleGemini1           = 2
NibbleGemini1Reg        = 3
NibbleGemini2           = 4
NibbleGemini2Reg        = 5
NibbleGemini3           = 6
NibbleGemini3Reg        = 7
NibbleGemini4           = 8
NibbleMissile           = 9   ; Missile opcode
NibbleVdel1             = 10  ; GRP0 w/ VDEL value
NibbleGrp0              = 11  ; GRP0 value
NibbleX                 = 12  ; X value
NibbleY                 = 13  ; Y value
NibblePhp               = 14  ; Processor value

NIBBLE_VAR_COUNT = 1 + NibblePhp
