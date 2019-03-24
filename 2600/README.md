# 2600 Jetpack

Run

```
make debug
```

## Gem Kernel

```

Gem Kernel Map by Color Clock

 - 3 Color Clocks = 1 CPU cycle
 - Kernel opcodes are 3 cycles = 9 color clocks
 - Playfield pixels = 4 color clocks wide

A: 01100110 use missiles?
B: 11001100 (PHP reflected?)   really should look at missile use to make this

STA = PF1
STX = 01
STY = 11

00 01 ?
04 10 A VDEL
09 01 B STX
13 10 C REFP0?
18 11 E STY

STA = PF1
STX = 01
STY = 11

02    ?
06    A VDEL
11 01 B STX
15 10 D PHP
20 11 E STY



magic:
VDELP1
RESP1
PHP


    v 22c    v 25c             v 31c                                                                                              v 64c    v 67c
    v -2P    v 7P             v 24P     v 34P    v 43P                               v 79P            $                  v 115P               v 136P
 A: A--------B--------C--------D--------E--------F--------G--------H--------I--------J--------K--------L--------M--------N--------O--------P--------
    RESP1    PF0      nop      GEM4(A)  RESP1    GEM9(B)  M1=on    GEM13(C) RESP1    PF1(D)   GEM18(E) LDA      GEM22    nop      PF2=0
             !--------****        s$$sssss       !s$$sssss****     mm ssssssss       !ssssssss****        ssssssss       |ssssssss        
                                   00  01          04  05          08  09  10          13  14              18  19          22  23         
 Gems:                        ====_AA__AA__BB__BB__AA__AA__BB__BB__AA__AA__AA__BB__BB__AA__AA__BB__BB__BB__AA__AA__BB__BB__AA__AA__BB__BB_====
                                           02  03          06  07              11  12          15  16  17          20  21          24  25 
                      !--------***         ssssssss       !ssssssss******      ssssssss       !ssssssssmm**        $$ssssss       |$$ssssss
             RESP1    PF0      nop      GEM6(A)  RESP1    GEM11(B) PF1(C)   GEM15(D) RESP1    GEM20(E) M1=off   LDA      GEM24    PF2=0
 B:          A--------B--------C--------D--------E--------F--------G--------H--------I--------J--------K--------L--------M--------N--------O--------
 PF  |0               1       ====                    2                               0               1                               2   ====|



   ====   playfield wall
   !      RESP0 
   |      let RESP0 chaining lapse
   -      no data due to resetting
   ****   mysterious post-resp0 4 cycle wait
   MM     missile
   ABCs   RESP0 sequences

```

## Etc.

Essential reading: https://alienbill.com/2600/101/docs/stella.html

Essential reading: https://github.com/munsie/dasm/blob/master/doc/dasm.txt 

This is based off the CBS RAM+ cartridge for 12K ROM space and an additional 256
bytes of RAM. This is Atari 2600 programming in easy mode.

> http://www.classic-games.com/atari2600/bankswitch.html
```
CBS  RAM Plus (RAM+)  This maps in 256 bytes of RAM in the first 512 bytes
of the cart; 1000-11FF.  The lower 256 addresses are the write port, while
the upper 256 addresses are the read port.  To store a byte and retrieve it:

LDA #$69  ; byte to store
STA $1000 ; store it
.
.         ; rest of program goes here
.
LDA $1100 ; read it back
.         ; acc=$69, which is what we stored here earlier.
```

> http://blog.kevtris.org/blogfiles/Atari%202600%20Mappers.txt
```
CBS Thought they'd throw a few tricks of their own at the 2600 with this.  It's got
12K of ROM and 256 bytes of RAM.

This works similar to F8, except there's only 3 4K ROM banks.  The banks are selected by
accessing 1FF8, 1FF9, and 1FFA.   There's also 256 bytes of RAM mapped into 1000-11FF.
The write port is at 1000-10FF, and the read port is 1100-11FF.
```

Misc:

```
; http://8bitworkshop.com/?platform=vcs&file=examples%2Fbigsprite
;
; TODO 03-19:
; - Investigate RAM PLUS (FA) method and test write kernel into it
; - Remove missile as way to render extra dots, switch to something else
; - Proof of concept missile as way to render Jetpack Man
; RAM+ is similar but the writing happens from adresses $1000 to $10FF (256 bytes) and the reading is from $1100 to $11FF (the next 256 bytes).
; 12K
;
; TODO 10-03:
; - Need to make each of the two-line kernels into a loop...
; - So that the rewriting code can call and overwrite the line easily
; - Then need POC of reading from a fixed buffer of code and copying into
;   the kernel those bytes, then a way to generate the bytes to stuff in the
;   kernel, then have per-line mutations!!
```

Text?

http://atariage.com/forums/topic/180632-32-character-text-display/page-3

Frame diagram:

http://www.randomterrain.com/atari-2600-memories-tutorial-andrew-davie-07.html
