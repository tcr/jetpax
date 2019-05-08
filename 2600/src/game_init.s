; Game Initialization after power on or reset

IFTRACKER SET 1

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    mac OK_IF
.COND SET {1}
    IF {1} == "cs"
        IFTRACKER SET [IFTRACKER + 1]
        echo "ok"
        ; bcc "OK_ELSE"+IFTRACKER
    ELSE
        err "why"
    ENDIF
    endm

    mac OK_ENDIF
"OK_ENDIF"+IFTRACKER SET .
    endm

    mac OK_ELSE
"OK_ELSE"+IFTRACKER SET .
    endm

    ; testing
    OK_IF "cs"
    OK_ELSE
    OK_ENDIF

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


    ; Start with vertical sync (to reset frame)
    jmp VerticalSync
