    seg.u Variables

    org $80

DebugKernelID           byte ; which kernel are we running this frame? (for debugging)

coolest_level           ds $3f

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

RamNibbleBuildState     byte    ; Nibble build state

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
