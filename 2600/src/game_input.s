; Handles input checking. Called from overscan.

    ; Read joystick movement and apply to object 0
MoveJoystick: subroutine

    ; HACK to add in resetting ability for the gems
    lda INPT4                        ; read left port action button
    and #%10000000                   ; safe to avoid any reads from D6 - D0
    bmi .actionButtonNotPressed      ; branch if action button not pressed
    jsr game_state_setup    
.actionButtonNotPressed

    ; Move vertically
    ; (up and down are actually reversed since ypos starts at bottom)
;     ldx YPos
    lda #%00010000    ;Up?
    bit SWCHA
    bne SkipMoveUp

    clc
    lda Speed2
    adc #12
    sta Speed2
    lda Speed1
    adc #00
    sta Speed1

SkipMoveUp:
    ldx XPos

    ; Only check left/right on odd frames;
    ; TODO make this just a fractional speed
    ; rather than dropping frames
    lda #01
    and FrameCount
	bne SkipMoveRight


    ; Move horizontally
    lda #%01000000    ;Left?
    bit SWCHA
    bne SkipMoveLeft
    cpx #29
    bcc SkipMoveLeft
    dex

    ; Reflect
;     lda #$ff
;     sta REFP0
SkipMoveLeft
    lda #%10000000    ;Right?
    bit SWCHA
    bne SkipMoveRight
    cpx #128
    bcs SkipMoveRight
    inx

    ; Reflect
;     lda #$0
;     sta REFP0
SkipMoveRight
    stx XPos
    rts


SpeedCalculation:
    sec
    lda Speed2
    sbc #7
    sta Speed2
    lda Speed1
    sbc #0
    sta Speed1

    clc
    lda YPos2
    adc Speed2
    sta YPos2
    lda YPos
    adc Speed1
    sta YPos
    
    cmp #FLOOR_OFFSET
    bcs NewThing2

    ; Reset to floor
    lda #FLOOR_OFFSET
    sta YPos
    lda #0
    sta Speed1
    sta Speed2
NewThing2:
    
    cmp #CEILING_OFFSET
    bcc .next

    ; Reset to ceiling
    lda #CEILING_OFFSET
    sta YPos
    lda #0
    sta Speed1
    sta Speed2
.next:
    rts



; Subroutine
SetHorizPos:
    sta WSYNC    ; start a new line
    bit 0        ; waste 3 cycles
    sec        ; set carry flag
DivideLoop
    sbc #15        ; subtract 15
    bcs DivideLoop    ; branch until negative
    eor #7        ; calculate fine offset
    asl
    asl
    asl
    asl
    sta JET_SP_RESET,x    ; fix coarse position
    sta JET_SP_HMOVE,x    ; set fine offset
    rts        ; return to caller
