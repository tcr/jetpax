; Game Initialization after power on or reset

    mac NIBBLE_START_KERNEL
    endm
    mac NIBBLE_IF
        ror
    endm
    mac NIBBLE_WRITE
    endm
    mac NIBBLE_WRITE_OPCODE
    endm
    mac NIBBLE_ELSE
    endm
    mac NIBBLE_END_IF
    endm
    mac NIBBLE_END_KERNEL
    endm

Start:
    CLEAN_START

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

    ; Start with vertical sync (to reset frame)
    jmp VerticalSync
