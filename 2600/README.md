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


Using VDEL is a robust way to do sprite changing, though Kernel B has the
benefit of a much simpler "algorithm" involving PHP. But might be worth using
this for now and leaving the status flag concept if ever to save RAM or space.

List of 26 bits --> which sections of RAM to rewrite and which decompress step
to go to next. Compiler can optimize for available space. Might be easier to
just write good code though.

on: 01 | off: 10
00 01 ? VDEL on
04 10 A VDEL off
09 01 B STX
13 10 C REFP0?
18 11 E STY

on: 01 | off: 11 | Y: -- | X: 10
00 01 ? VDEL on
04 11 A VDEL off
09 01 B VDEL on
13 11 C VDEL off
18 10 E stx GRP0
22*-- M 

This one looks weirder than the rest:
on: 01 | off: 10 | Y: 11 | X: 10
00 10 ? -
04 11 A sty GRP0
09 01 B VDEL on
13 11 C VDEL off
18 10 E stx GRP0
22*-- M 


This one looks weirder than the rest:
on: 01 | off: 10 | Y: 11 | X: 10
00 10 ? VDEL on
04 11 A VDEL off
09 01 B stx 
13 11 C sty
18 10 E VDEL on
22*01 M VDEL off + stx

on: 01 | off: 10 | Y: 11 | X: 01
00 01 ? VDEL on
04 10 A VDEL off
09 11 B sty GRP0
13 01 C stx GRP0
18 10 E REFP0 / PHP
22*-- M 

on: 10 | off: 01 | Y: 11 | X: 01
00 10 ? VDEL on
04 01 A VDEL off
09 11 B sty GRP0
13 01 C stx GRP0
18 10 E REFP0 / PHP
22*-- M 

on: 11 | off: 01 | Y: 11 | X: 01
00 01 ? VDEL on
04 11 A VDEL off
09 10 B stx GRP0
13 11 C sty GRP0
18 01 E VDEL on / PHP
22*10 M REFP1 / stx GRP0
(or)
on: 11 | off: 01 | Y: 11 | X: 01
00 01 ? stx GRP0
04 11 A sty GRP0
09 10 B VDEL on
13 11 C VDEL off
18 01 E stx GRP0
22*10 M REFP1 / PHP

on: 11 | off: 01 | Y: 11 | X: 01
00 01 ? -
04 11 A sty GRP0
09 10 B VDEL on
13 11 C VDEL off
18 01 E stx GRP0
22*-- M 

A
on: 01 | off: 11 | Y: -- | X: 01
00 11 ? -
04 01 A VDEL on
09 10 B REFP0 (A)
13 11 C VDEL off
18 01 E stx GRP0
22*-- M 
B
on: 11 | off: 01 | Y: 11 | X: 01
00 11 ? VDEL on
04 01 A VDEL off
09 10 B PHP (B)
13 11 C sty GRP0
18 01 E stx GRP0
22*-- M 

on: 11 | off: 01 | Y: 11 | X: 10
00 01 ? -
04 11 A VDEL on
09 01 B VDEL off
13 10 C stx GRP0
18 11 E sty GRP0
22*-- M 





; IDEAS: For Kernel A, keep VDEL=on traffic to the single items. When making a
; 0x XX x0 trip or vice versa we just hard code the value with a register.
; 
on: 11 | off: 01 | Y: 11 | X: 10
00 01 ? VDEL on
04 11 A VDEL off
09 01 B VDEL on
13 10 C REFP0
18 11 E VDEL off
22*01 M stx GRP0


A:
   10 VDEL on
   11 VDEL off
   01 stx
   10 REFP1
   11 sty
   01 VDEL on
B:
   10 -
   11 sty
   01 stx
   10 PHP
   11 sty
   01 stx

A:
   10 VDEL on
   11 VDEL off
   01 stx
   10 REFP1
   11 sty
   10 stx
B: (no reverse)
   10 -
   11 sty
   01 stx
   10 PHP
   11 VDEL on !
   10 VDEL off

   11 -
   01 stx
   10 PHP
   11 sty !
   01 stx !
   10 VDEL off

   01 VDEL on
   10 VDEL off
   11 sty
   01 stx
   10 PHP
   11 sty

~~~ 12 bytes for 12 gems :O 40 bytes taken by kernel, so 120 left.
~~~ that's 10 rows. not great. need better encoding algo

What the makeup of the last two 10 distinct values, might be the key for B.

A: keep VDEL=on traffic to the single items, using RESP0, or regs to bridge 01 11 10 gaps
   01 VDEL on
   10 VDEL off
   11 VDEL off
   01 stx
   10 REFP1
   11 sty
B: use VDEL early and just focus on populating the next four registers!
   01 VDEL on
   10 VDEL off
   11 sty
   01 stx
   10 PHP
   11 sty




on: 11 | off: 01 | Y: 11 | X: 10
00 10 ? VDEL on
04 11 A VDEL off
09 01 B stx GRP0
13 10 C PHP / RESP0
18 11 E sty GRP0
22*01 M VDEL ON

VDEL should end as OFF

how many registers: how many of stx, sty, are used + any VDEL state not used
linear reversing and pushing... or PHP lol



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
    RESP1    PF0      LDA      GEM4(A)  RESP1    M1=on    GEM9(B)  GEM13(C) RESP1    PF1(D)   GEM18(E) LDA      GEM22    nop      PF2=0
                                   00  01          04  05          08  09  10          13  14              18  19          22  23         
             !--------????        s$$sssss       !s$$sssss????     mm ssssssss       !ssssssss????        ssssssss       |ssssssss        
 Gems:                        ====_AA__AA__BB__BB__AA__AA__BB__BB__AA__AA__AA__BB__BB__AA__AA__BB__BB__BB__AA__AA__BB__BB__AA__AA__BB__BB_====
                      !--------????        ssssssss       !ssssssss????       ssssssss       !ssssssssmm??        $$ssssss       |$$ssssss
                                           02  03          06  07              11  12          15  16  17          20  21          24  25 
             RESP1    PF0      LDA      GEM6(A)  RESP1    GEM11(B) PF1(C)   GEM15(D) RESP1    GEM20(E) M1=off   LDA      GEM24    PF2=0
 B:          A--------B--------C--------D--------E--------F--------G--------H--------I--------J--------K--------L--------M--------N--------O--------
 PF  |0               1       ====                    2                               0               1                               2   ====|



   ====   playfield wall
   !      RESP0 
   |      let RESP0 chaining lapse
   -      no data due to resetting
   ?      mysterious post-resp0 4 cycle wait
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
