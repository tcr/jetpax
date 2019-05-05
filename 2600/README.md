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

    v 22c    v 25c             v 31c                                                                                              v 64c    v 67c
    v -2P    v 7P             v 24P     v 34P    v 43P                               v 79P            $                  v 115P               v 136P
 A: A--------B--------C--------D--------E--------F--------G--------H--------I--------J--------K--------L--------M--------N--------O--------P--------
    RESP1    PF0      LDA PF1  GEM1A    RESP1    M1=on    GEM2A    GEM3A    RESP1    PF1      GEM4A    LDA      GEM5A    nop      PF2=0
                                   00  01            04  05        08  09  10          13  14              18  19          22  23         
             !--------????        s$$0Asss       !s$$1Asss????     mm sss2Asss       !sss3Asss????        sss4Asss       |sss5Asss        
 Gems:                        ====_AA__AA__BB__BB__AA__AA__BB__BB__AA__AA__AA__BB__BB__AA__AA__BB__BB__BB__AA__AA__BB__BB__AA__AA__BB__BB_====
                      !--------????        sss0Bsss       !sss1Bsss????        sss2Bsss       !sss3Bsssmm??        $$s4Bsss       |$$s5Bsss
                                           02  03          06  07              11  12          15  16  17          20  21          24  25 
             RESP1    PF0      LDA      GEM1B    RESP1    GEM2B    PF1      GEM3B    RESP1    GEM4B    M1=off   LDA      GEM5B    PF2=0
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

## NUSIZ Tricks

NUSIZ is a way to set the width and repetition of Player and Missile graphics
across the screen. This feature is intended to let you draw multiple enemies
or dangers while only requiring one player object.

["When you strobe RESPx, the player's "coarse" position will be 5 color clocks
after the
strobe."](http://atariage.com/forums/topic/239890-respx-nusizx-and-player-positioning/)
This means when resetting the sprite's position, we will leave a 5 color clock
gap after the opcode finishes. The mismatch between eight color clocks being a
sprite and nine being an opcode actually works out—we can time a RESP0 call to
reset a sprite exactly four color clocks after the previous one ended.

## Gem Kernel

A great reference for NUSIZ tricks is the [Circus 2600
game](http://atariage.com/forums/topic/207391-circus-atariage-2600/) which
inspired me to pursue a kernel based on NUSIZ interleaving. Their setup is
different, as their sprites are not interleaved with e.g. playfield commands and
thus can maintain a fixed cadance of RESP0 calls, dropping them to create a
hole.

Jetpax for the 2600 is more complex, because horizontal width is fixed to what
we can meaningfully render with the playfield. The playfield is a 40 bits wide
(actually 20 bits repeated) sprite that spans the width of the screen. Each bit
is 4 color clocks wide, and you can think of it as 40 pixels stretched 4 times
wide across the screen. This is what games use for background graphics, since
environment elements tend to be chunky. Jetpax is no different, as we'll need it
to render ledges, ladders, and the game border.

Jetpack levels are 26 columns wide. 26 doesn't fit more than once into 40, so we
artifically have to restrict ourselves to the 26*4= 104 color clocks in the
middle of the 160 color clocks in a scanline. This is fine by rendering a
floating box in the middle of a black screen, but the loss of horizontal
resolution is costly.

We'll need to render one gem every four color clocks,
meaning two for eight color clocks. If we want to use NUSIZ tricks for this,
we'll need to render two sprites per gem. Each sprite on a line may need a
different graphic.

Blanking out gem1/3:
   replace with a sta RESP1 and you're good.


Blanking out gem4:

* Boggles the mind
* KernelA_E is nop
* G is turned into a RESET
* replace with:
  * KERNEL_B_MISSILE_SLEEP equ 46
  * KERNEL_B_MISSILE_HMOVE equ $20

Blanking out gem6:

* Cursed
* KernelA_I shortens to two cycles, to load int A the value for Gems 22-23
* K is replaced by the reset in I
* L is replaced with "sleep 4" (how?)
* M will always store STA

That's how blanking works.

## Etc.

Essential reading: https://alienbill.com/2600/101/docs/stella.html

Essential reading: https://github.com/munsie/dasm/blob/master/doc/dasm.txt 

This is based off the CBS RAM Plus (RAM+) cartridge.

* These cartridges have for 12K of ROM space, across three banks, with about
  10.7kb addressible (the first two pages of each bank are reserved for RAM
  access).
* RAM+ cartridges support an additional 256 bytes of RAM. (This is Atari 2600
  programming on easy mode.) You can write to 

> http://www.classic-games.com/atari2600/bankswitch.html
```
CBS RAM Plus (RAM+)  This maps in 256 bytes of RAM in the first 512 bytes
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
