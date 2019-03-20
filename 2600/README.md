# 2600 Jetpack

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
