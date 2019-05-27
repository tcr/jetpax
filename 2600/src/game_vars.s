    seg.u Variables

    org $80

DebugKernelID           byte ; which kernel are we running this frame? (for debugging)

coolest_level           ds $3f

    align 16

; Nibble (16 bytes)
RamNibbleVar1           byte
RamNibbleVar2           byte
RamKernelGemini1        byte
RamKernelGemini1Reg     byte
RamKernelGemini2        byte
RamKernelGemini2Reg     byte
RamKernelGemini3        byte
RamKernelGemini3Reg     byte
RamKernelGemini4        byte
BuildKernelMissile      byte
BuildKernelVdel1        byte
BuildKernelGrp0         byte
BuildKernelX            byte
BuildKernelY            byte
RamKernelPhpTarget      byte
RamPSByte               byte

    align 16

; Misc Nibble support
RamKernelGrp0           byte
BuildKernelRST          byte

Temp                    byte
Temp2                   byte

; Counters
LoopCount               byte
FrameCount              byte

SpriteEnd               byte
XPos                    byte    ; X position of player sprite


Speed1                  byte
Speed2                  byte

YPos                    byte    ; Y position of player sprite
YPos2                   byte

ROW_DEMO_INDEX          byte

RamNibbleTemp           byte
RamZeroByte             byte
RamLowerSixByte         byte
RamFFByte               byte
RamStackBkp             byte
RamPF1Value             byte

RamRowJetpackIndex      byte ; sprite counter

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
