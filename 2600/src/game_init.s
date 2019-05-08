; Game Initialization after power on or reset

IFTRACKER SET 1

IFTRACKER SET 2

Start:
    CLEAN_START

    ; Disable interrupt flag in processor status (it's useless anyway)
    cli

InitSetup:
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
    lda #XPosStart
    sta XPos
    lda #0
    sta Speed1
    sta Speed2
    sta YPos2

    lda #0
    sta ROW_DEMO_INDEX

    ; Store 0 into RamZeroByte
    lda #0
    sta RamZeroByte
    lda #%00111111
    sta RamLowerSixByte

    ; Start with vertical sync (to reset frame)
    jmp VerticalSync
