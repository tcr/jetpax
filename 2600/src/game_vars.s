    seg.u Variables

    org $C0

; Misc Nibble support
BuildKernelRST          byte
BuildNibbleX            byte
BuildNibbleY            byte
BuildNibbleGrp0         byte

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
RamRowOffset            byte
RamRowColor             byte
RamRowPs                byte

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

    ; Protect the stack
    org $f0
