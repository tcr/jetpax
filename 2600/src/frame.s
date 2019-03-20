; Frame loop, including calling out to other kernels.

; Overscan
FrameStart: subroutine
    VERTICAL_SYNC

    TIMER_SETUP 37

    ; Scanline counter
    lda #ROW_COUNT
    sta LoopCount

    ; Frame counter
    inc FrameCount

    ; Copy frames
    jsr CopyFrame

    ; Skip every 8 frames for increasing demo index
    lda FrameCount
    and #%111
    cmp #%111
    bne .next_next_thing

    clc
    lda ROW_DEMO_INDEX
    adc #4
    cmp #[map_emeralds_end - map_emeralds]
    bcc .next_thing_local
    lda #0
.next_thing_local
    sta ROW_DEMO_INDEX
.next_next_thing:
    sta WSYNC

    ; Positioning
    SLEEP 40
    sta EMERALD_SP_RESET	; position 1st player
    sta WSYNC

    ; Misc
    lda #00
    sta EMERALD_MI_ENABLE

    ; Assign dervied SpriteEnd value
    lda #HEIGHT_OFFSET
    sbc YPos
    sta SpriteEnd

    ; Move missile to starting position and fine-tune position
    ; TODO replace with an HMOVE macro
    sta WSYNC
    sleep EMERALD_MI_HMOVE_S
    sta EMERALD_MI_RESET

    ; Player 1
    lda XPos
    ldx #0
    jsr SetHorizPos


    ; Choose which hmove value to use


    ; [TODO]
    ; Make these into separate horizontal positioning calls
    ; which will make it possible to do better missle tricks
    ; and free up both kernels to have another reigster



    ; FRAMESWITCH
    lda #01
    and FrameCount
    bne doframe2

    ; frame 1
    lda #EMERALD_MI_HMOVE_2
    sta EMERALD_MI_HMOVE
    jmp doframe2after

    ; frame 2
doframe2:
    lda #EMERALD_MI_HMOVE_3
    sta EMERALD_MI_HMOVE
doframe2after:


    ; Start rendering the kernel.
    TIMER_WAIT
    TIMER_SETUP 192
    jmp Kernel

FrameEnd: subroutine
    ; Blank all background colors.
    lda #0
    sta COLUPF
    sta PF2
    sta PF1
    sta EMERALD_SP
    sta WSYNC

    ; Guide lines (2x)
    lda #SIGNAL_LINE
    sta COLUBK
    REPEAT 6
    sta WSYNC
    REPEND
    lda #$00
    sta COLUBK
    sta WSYNC


    ; VSYNC
    TIMER_WAIT
    TIMER_SETUP 30

    jsr MoveJoystick
    jsr SpeedCalculation

    TIMER_WAIT
    jmp FrameStart
