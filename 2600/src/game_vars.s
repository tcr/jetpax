    seg.u Variables

    org $80

DebugKernelID           byte ; which kernel are we running this frame? (for debugging)

coolest_level           ds $3f

    align 16

NIBBLE_VAR_START = .

; Nibble (16 bytes)
NibbleVar1              byte
NibbleVar2              byte
NibbleGemini1           byte
NibbleGemini1Reg        byte
NibbleGemini2           byte
NibbleGemini2Reg        byte
NibbleGemini3           byte
NibbleGemini3Reg        byte
NibbleGemini4           byte
NibbleMissile           byte
NibbleVdel1             byte
NibbleGrp0              byte
NibbleX                 byte
NibbleY                 byte
NibblePhp               byte
NibblePs                byte

NIBBLE_VAR_END = .

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
