;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Visible Kernel
;

Kernel: subroutine
    sta WSYNC ; ??? Is this needed?

    ; First HMOVE
    sta HMOVE

    ; Frame border top
    lda #0
    sta COLUPF
    sta PF1
    sta PF2
    lda #SIGNAL_LINE
    sta COLUBK

    REPEAT 6
    sta WSYNC
    REPEND

    lda #0
    sta COLUBK
    sta WSYNC

    ; Start top border
border_top:
    ; Make the playfield solid.
    lda #%00111111
    sta PF1
    lda #%11111111
    sta PF2

    lda #COL_BG
    ldy #0

    sta COLUPF
    sta WSYNC

    sty COLUPF
    sta WSYNC

    sta COLUPF
    sta WSYNC

    sta WSYNC
    
    sta WSYNC
    
    sty COLUPF
    sta WSYNC
    
    sta COLUPF
    sta WSYNC
    
    sta WSYNC

PlayArea:
    ; PF is now the playing area
    lda #%00000000
    sta PF0
    lda #%00100000
    sta PF1
    lda #%00000000
    sta PF2


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Frame Start

    ; Start the row with a WSYNC.
row_start:
    ; ~15c 
    jet_spritedata_calc
    sta WSYNC

; [row:1]
    jet_spritedata_calc

    lda #0
    sta COLUPF

    ; Push jump table to the stack
    lda #>[row_after_kernel - 1]
    pha
    lda #<[row_after_kernel - 1]
    pha
    lda #%10000001
    pha
    lda #>[$1100 - 1]
    pha
    lda #<[$1100 - 1]
    pha
    lda #%10000001
    pha

    sta WSYNC

; [row:2]
    jet_spritedata_calc


    lda #COL_BG
    sta COLUPF
    

    lda #SPRITE_HEIGHT
    jet_spritedata_calc_nosta
    lda Frame0,Y
    sta $fa
    jet_spritedata_calc_nosta
    lda Frame0,Y
    sta $fd

    sleep 6

; [row:3-4]
    ; Jump to the copied kernel.
kernel_launch:
    jmp KERNEL_START

row_after_kernel:
; [row:5]
    ; Cleanup from the kernel.
    lda #0
    sta EMERALD_MI_ENABLE
    sta EMERALD_SP
    sta COLUPF

    jet_spritedata_calc

    sta WSYNC

; [row:6]
    jet_spritedata_calc
    lda #COL_BG
    sta COLUPF

    ; FRAMESWITCH
    lda #01
    and FrameCount
    bne loadframe2

loadframe1:
    ; ~30c

    ; Emerald byte setting 1A
    ldx #0
    lda KERNEL_STORAGE_R,X
    sta GEM_00_W
    inx
    lda KERNEL_STORAGE_R,X
    sta GEM_04_W
    inx
    lda KERNEL_STORAGE_R,X
    sta GEM_09_W
    inx

    sta WSYNC

; [row:7]
    jet_spritedata_calc

    ; Emerald byte setting 1B
    lda KERNEL_STORAGE_R,X
    sta GEM_13_W
    inx
    lda KERNEL_STORAGE_R,X
    sta GEM_17_W
    inx
    lda KERNEL_STORAGE_R,X
    sta GEM_18_W
    inx
    lda KERNEL_STORAGE_R,X
    sta GEM_22_W

    jmp row_7_end

loadframe2:
    ; ~30c

    ; Emerald byte setting 2A
    ldx #[storage_02 - storage]
    lda KERNEL_STORAGE_R,X
    sta GEM_02_W
    inx
    lda KERNEL_STORAGE_R,X
    sta GEM_06_W
    inx
    lda KERNEL_STORAGE_R,X
    sta GEM_08_W
    inx

    sta WSYNC

; [row:7]
    jet_spritedata_calc

    ; Emerald byte setting 2B
    lda KERNEL_STORAGE_R,X
    sta GEM_11_W
    inx
    lda KERNEL_STORAGE_R,X
    sta GEM_15_W
    inx
    lda KERNEL_STORAGE_R,X
    sta GEM_20_W
    inx
    lda KERNEL_STORAGE_R,X
    sta GEM_24_W

    jmp row_7_end

row_7_end:
    sta WSYNC

; [row:8]
    ; Repeat loop until LoopCount < 0
    dec LoopCount
    bmi frame_bottom
    jmp row_start

    ; reset the background for bottom of playfield
frame_bottom:
    ;sta WSYNC

    ; Form the bottom of the level frame.
    lda #%00111111
    sta PF1
    lda #%11111111
    sta PF2

    ; Clear all sprites.
    lda #0
    sta EMERALD_SP
    sta JET_SP
    sta EMERALD_MI_ENABLE

    lda #COL_BG
    ldy #0
    sta WSYNC

    sty COLUPF
    sta WSYNC

    sta COLUPF
    sta WSYNC

    sta WSYNC

    sta WSYNC

    sty COLUPF
    sta WSYNC

    sta COLUPF
    sta WSYNC
    sta WSYNC
    jmp FrameEnd
