    
    align 256

Frame0:
    ; 10 rows (8 + clear top and bottom)
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

    ; 8 buffer
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
