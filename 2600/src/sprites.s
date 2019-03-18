; Bitmap data for character "standing" position
; Comical amount of 0's for now to simplify sprite rendering

; Y can be from:
;     SPRITE_HEIGHT to (8*ROW_COUNT)
; SpriteEnd: 8..128
; Frame0 should start at +120 so the Y rollunder of -$120 is OK]
Frame0
    .byte #%00000000
    .byte #%01100000
    .byte #%01100000
    .byte #%01100000
    .byte #%11000000
    .byte #%11000000
    .byte #%11110000
    .byte #%11000000
    .byte #%11000000
    .byte #%00000000
