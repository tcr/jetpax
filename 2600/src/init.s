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

    ; just testing stuff
    
    NIBBLE_START_KERNEL gem_kernel, 40
        lda $80
        cmp #%01100110
        NIBBLE_IF cs
            cmp #%01100000
            NIBBLE_IF cs
                NIBBLE_WRITE .gem_ldx, #%11001100 ; write value to mem location
                NIBBLE_WRITE_OPCODE .gem_08, 2, lda #02 ; write *opcode* to mem location
                NIBBLE_WRITE_OPCODE .gem_09, 2, sleep 3
            NIBBLE_ELSE
                NIBBLE_WRITE_OPCODE .gem_08, 2, sta VDELP1
                NIBBLE_WRITE_OPCODE .gem_09, 2, sta RESP1
            NIBBLE_END_IF
        NIBBLE_ELSE
            NIBBLE_WRITE_OPCODE .gem_08, 2, sleep 3
            NIBBLE_WRITE_OPCODE .gem_09, 2, sleep 3
        NIBBLE_END_IF
    NIBBLE_END_KERNEL

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
