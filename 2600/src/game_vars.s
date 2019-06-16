    seg.u Variables

    ; RAM not used by the gem kernel starts at $C0
    org $C0

; Zero-page access
RamZeroByte             byte    ; to load $00 from zero page
RamFFByte               byte    ; to load $ff from zero page

; Locally allocated
Temp                    byte
Temp2                   byte
Temp3                   byte

; Misc Nibble support
BuildKernelRST          byte
BuildNibbleX            byte
BuildNibbleY            byte
BuildNibbleGrp0         byte
RamNibbleBuildState     byte    ; Nibble build state

; Counters
LoopCount               byte
FrameCount              byte

; Sprite data
SpriteEnd               byte
XPos                    byte    ; X position of player sprite
YPos                    byte    ; Y position of player sprite
YPos2                   byte
Speed1                  byte
Speed2                  byte

; Row generated data
RamRowJetpackIndex      byte    ; sprite scanline offset
RamRowOffset            byte    ; row index (offset into nibble vars)
RamRowColor             byte    ; row color (for testing)
RamRowPs                byte    ; global PS value for this kernel
RamStackBkp             byte    ; cached stack value before kernel
RamPF1Value             byte    ; loaded PF1 value for kernel

; Temp storage for GeminiPopulate
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

    ; We intentionally only allow stack variables past $f0 for now
    org $f0
