------- FILE jetpack.s LEVEL 1 PASS 2
      1  10000 ????						; http://8bitworkshop.com/?platform=vcs&file=examples%2Fbigsprite
      2  10000 ????						;
      3  10000 ????						; TODO 03-19:
      4  10000 ????						; - Investigate RAM PLUS (FA) method and test write kernel into it
      5  10000 ????						; - Remove missile as way to render extra dots, switch to something else
      6  10000 ????						; - Proof of concept missile as way to render Jetpack Man
      7  10000 ????						; RAM+ is similar but the writing happens from adresses $1000 to $10FF (256 bytes) and the reading is from $1100 to $11FF (the next 256 bytes).
      8  10000 ????						; 12K
      9  10000 ????						;
     10  10000 ????						; TODO 10-03:
     11  10000 ????						; - Need to make each of the two-line kernels into a loop...
     12  10000 ????						; - So that the rewriting code can call and overwrite the line easily
     13  10000 ????						; - Then need POC of reading from a fixed buffer of code and copying into
     14  10000 ????						;   the kernel those bytes, then a way to generate the bytes to stuff in the
     15  10000 ????						;   kernel, then have per-line mutations!!
     16  10000 ????
     17  10000 ????				       processor	6502
------- FILE vcs.h LEVEL 2 PASS 2
      0  10000 ????				       include	"vcs.h"
      1  10000 ????						; VCS.H
      2  10000 ????						; Version 1.05, 13/November/2003
      3  10000 ????
      4  10000 ????		00 69	    VERSION_VCS =	105
      5  10000 ????
      6  10000 ????						; THIS IS A PRELIMINARY RELEASE OF *THE* "STANDARD" VCS.H
      7  10000 ????						; THIS FILE IS EXPLICITLY SUPPORTED AS A DASM-PREFERRED COMPANION FILE
      8  10000 ????						; PLEASE DO *NOT* REDISTRIBUTE THIS FILE!
      9  10000 ????						;
     10  10000 ????						; This file defines hardware registers and memory mapping for the
     11  10000 ????						; Atari 2600. It is distributed as a companion machine-specific support package
     12  10000 ????						; for the DASM compiler. Updates to this file, DASM, and associated tools are
     13  10000 ????						; available at at http://www.atari2600.org/dasm
     14  10000 ????						;
     15  10000 ????						; Many thanks to the original author(s) of this file, and to everyone who has
     16  10000 ????						; contributed to understanding the Atari 2600.  If you take issue with the
     17  10000 ????						; contents, or naming of registers, please write to me (atari2600@taswegian.com)
     18  10000 ????						; with your views.  Please contribute, if you think you can improve this
     19  10000 ????						; file!
     20  10000 ????						;
     21  10000 ????						; Latest Revisions...
     22  10000 ????						; 1.05  13/NOV/2003	  - Correction to 1.04 - now functions as requested by MR.
     23  10000 ????						;			  - Added VERSION_VCS equate (which will reflect 100x version #)
     24  10000 ????						;			    This will allow conditional code to verify VCS.H being
     25  10000 ????						;			    used for code assembly.
     26  10000 ????						; 1.04  12/NOV/2003	 Added TIA_BASE_WRITE_ADDRESS and TIA_BASE_READ_ADDRESS for
     27  10000 ????						;			 convenient disassembly/reassembly compatibility for hardware
     28  10000 ????						;			 mirrored reading/writing differences.	This is more a 
     29  10000 ????						;			 readability issue, and binary compatibility with disassembled
     30  10000 ????						;			 and reassembled sources.  Per Manuel Rotschkar's suggestion.
     31  10000 ????						; 1.03  12/MAY/2003	 Added SEG segment at end of file to fix old-code compatibility
     32  10000 ????						;			 which was broken by the use of segments in this file, as
     33  10000 ????						;			 reported by Manuel Polik on [stella] 11/MAY/2003
     34  10000 ????						; 1.02  22/MAR/2003	 Added TIMINT($285)
     35  10000 ????						; 1.01				Constant offset added to allow use for 3F-style bankswitching
     36  10000 ????						;						 - define TIA_BASE_ADDRESS as $40 for Tigervision carts, otherwise
     37  10000 ????						;						   it is safe to leave it undefined, and the base address will
     38  10000 ????						;						   be set to 0.  Thanks to Eckhard Stolberg for the suggestion.
     39  10000 ????						;			    Note, may use -DLABEL=EXPRESSION to define TIA_BASE_ADDRESS
     40  10000 ????						;			  - register definitions are now generated through assignment
     41  10000 ????						;			    in uninitialised segments.	This allows a changeable base
     42  10000 ????						;			    address architecture.
     43  10000 ????						; 1.0	22/MAR/2003		Initial release
     44  10000 ????
     45  10000 ????
     46  10000 ????						;-------------------------------------------------------------------------------
     47  10000 ????
     48  10000 ????						; TIA_BASE_ADDRESS
     49  10000 ????						; The TIA_BASE_ADDRESS defines the base address of access to TIA registers.
     50  10000 ????						; Normally 0, the base address should (externally, before including this file)
     51  10000 ????						; be set to $40 when creating 3F-bankswitched (and other?) cartridges.
     52  10000 ????						; The reason is that this bankswitching scheme treats any access to locations
     53  10000 ????						; < $40 as a bankswitch.
     54  10000 ????
     55  10000 ????			   -	       IFNCONST	TIA_BASE_ADDRESS
     56  10000 ????			   -TIA_BASE_ADDRESS =	0
     57  10000 ????				       ENDIF
     58  10000 ????
     59  10000 ????						; Note: The address may be defined on the command-line using the -D switch, eg:
     60  10000 ????						; dasm.exe code.asm -DTIA_BASE_ADDRESS=$40 -f3 -v5 -ocode.bin
     61  10000 ????						; *OR* by declaring the label before including this file, eg:
     62  10000 ????						; TIA_BASE_ADDRESS = $40
     63  10000 ????						;   include "vcs.h"
     64  10000 ????
     65  10000 ????						; Alternate read/write address capability - allows for some disassembly compatibility
     66  10000 ????						; usage ; to allow reassembly to binary perfect copies).  This is essentially catering
     67  10000 ????						; for the mirrored ROM hardware registers.
     68  10000 ????
     69  10000 ????						; Usage: As per above, define the TIA_BASE_READ_ADDRESS and/or TIA_BASE_WRITE_ADDRESS
     70  10000 ????						; using the -D command-line switch, as required.  If the addresses are not defined, 
     71  10000 ????						; they defaut to the TIA_BASE_ADDRESS.
     72  10000 ????
     73  10000 ????			   -	       IFNCONST	TIA_BASE_READ_ADDRESS
     74  10000 ????			   -TIA_BASE_READ_ADDRESS =	TIA_BASE_ADDRESS
     75  10000 ????				       ENDIF
     76  10000 ????
     77  10000 ????			   -	       IFNCONST	TIA_BASE_WRITE_ADDRESS
     78  10000 ????			   -TIA_BASE_WRITE_ADDRESS =	TIA_BASE_ADDRESS
     79  10000 ????				       ENDIF
     80  10000 ????
     81  10000 ????						;-------------------------------------------------------------------------------
     82  10000 ????
     83 U002d ????				      SEG.U	TIA_REGISTERS_WRITE
     84 U0000					      ORG	TIA_BASE_WRITE_ADDRESS
     85 U0000
     86 U0000							; DO NOT CHANGE THE RELATIVE ORDERING OF REGISTERS!
     87 U0000
     88 U0000		       00	   VSYNC      ds	1	; $00	 0000 00x0   Vertical Sync Set-Clear
     89 U0001		       00	   VBLANK     ds	1	; $01	 xx00 00x0   Vertical Blank Set-Clear
     90 U0002		       00	   WSYNC      ds	1	; $02	 ---- ----   Wait for Horizontal Blank
     91 U0003		       00	   RSYNC      ds	1	; $03	 ---- ----   Reset Horizontal Sync Counter
     92 U0004		       00	   NUSIZ0     ds	1	; $04	 00xx 0xxx   Number-Size player/missle 0
     93 U0005		       00	   NUSIZ1     ds	1	; $05	 00xx 0xxx   Number-Size player/missle 1
     94 U0006		       00	   COLUP0     ds	1	; $06	 xxxx xxx0   Color-Luminance Player 0
     95 U0007		       00	   COLUP1     ds	1	; $07	 xxxx xxx0   Color-Luminance Player 1
     96 U0008		       00	   COLUPF     ds	1	; $08	 xxxx xxx0   Color-Luminance Playfield
     97 U0009		       00	   COLUBK     ds	1	; $09	 xxxx xxx0   Color-Luminance Background
     98 U000a		       00	   CTRLPF     ds	1	; $0A	 00xx 0xxx   Control Playfield, Ball, Collisions
     99 U000b		       00	   REFP0      ds	1	; $0B	 0000 x000   Reflection Player 0
    100 U000c		       00	   REFP1      ds	1	; $0C	 0000 x000   Reflection Player 1
    101 U000d		       00	   PF0	      ds	1	; $0D	 xxxx 0000   Playfield Register Byte 0
    102 U000e		       00	   PF1	      ds	1	; $0E	 xxxx xxxx   Playfield Register Byte 1
    103 U000f		       00	   PF2	      ds	1	; $0F	 xxxx xxxx   Playfield Register Byte 2
    104 U0010		       00	   RESP0      ds	1	; $10	 ---- ----   Reset Player 0
    105 U0011		       00	   RESP1      ds	1	; $11	 ---- ----   Reset Player 1
    106 U0012		       00	   RESM0      ds	1	; $12	 ---- ----   Reset Missle 0
    107 U0013		       00	   RESM1      ds	1	; $13	 ---- ----   Reset Missle 1
    108 U0014		       00	   RESBL      ds	1	; $14	 ---- ----   Reset Ball
    109 U0015		       00	   AUDC0      ds	1	; $15	 0000 xxxx   Audio Control 0
    110 U0016		       00	   AUDC1      ds	1	; $16	 0000 xxxx   Audio Control 1
    111 U0017		       00	   AUDF0      ds	1	; $17	 000x xxxx   Audio Frequency 0
    112 U0018		       00	   AUDF1      ds	1	; $18	 000x xxxx   Audio Frequency 1
    113 U0019		       00	   AUDV0      ds	1	; $19	 0000 xxxx   Audio Volume 0
    114 U001a		       00	   AUDV1      ds	1	; $1A	 0000 xxxx   Audio Volume 1
    115 U001b		       00	   GRP0       ds	1	; $1B	 xxxx xxxx   Graphics Register Player 0
    116 U001c		       00	   GRP1       ds	1	; $1C	 xxxx xxxx   Graphics Register Player 1
    117 U001d		       00	   ENAM0      ds	1	; $1D	 0000 00x0   Graphics Enable Missle 0
    118 U001e		       00	   ENAM1      ds	1	; $1E	 0000 00x0   Graphics Enable Missle 1
    119 U001f		       00	   ENABL      ds	1	; $1F	 0000 00x0   Graphics Enable Ball
    120 U0020		       00	   HMP0       ds	1	; $20	 xxxx 0000   Horizontal Motion Player 0
    121 U0021		       00	   HMP1       ds	1	; $21	 xxxx 0000   Horizontal Motion Player 1
    122 U0022		       00	   HMM0       ds	1	; $22	 xxxx 0000   Horizontal Motion Missle 0
    123 U0023		       00	   HMM1       ds	1	; $23	 xxxx 0000   Horizontal Motion Missle 1
    124 U0024		       00	   HMBL       ds	1	; $24	 xxxx 0000   Horizontal Motion Ball
    125 U0025		       00	   VDELP0     ds	1	; $25	 0000 000x   Vertical Delay Player 0
    126 U0026		       00	   VDELP1     ds	1	; $26	 0000 000x   Vertical Delay Player 1
    127 U0027		       00	   VDELBL     ds	1	; $27	 0000 000x   Vertical Delay Ball
    128 U0028		       00	   RESMP0     ds	1	; $28	 0000 00x0   Reset Missle 0 to Player 0
    129 U0029		       00	   RESMP1     ds	1	; $29	 0000 00x0   Reset Missle 1 to Player 1
    130 U002a		       00	   HMOVE      ds	1	; $2A	 ---- ----   Apply Horizontal Motion
    131 U002b		       00	   HMCLR      ds	1	; $2B	 ---- ----   Clear Horizontal Move Registers
    132 U002c		       00	   CXCLR      ds	1	; $2C	 ---- ----   Clear Collision Latches
    133 U002d
    134 U002d							;-------------------------------------------------------------------------------
    135 U002d
    136 U000e ????				      SEG.U	TIA_REGISTERS_READ
    137 U0000					      ORG	TIA_BASE_READ_ADDRESS
    138 U0000
    139 U0000							;											bit 7	 bit 6
    140 U0000		       00	   CXM0P      ds	1	; $00	     xx00 0000	     Read Collision  M0-P1   M0-P0
    141 U0001		       00	   CXM1P      ds	1	; $01	     xx00 0000			     M1-P0   M1-P1
    142 U0002		       00	   CXP0FB     ds	1	; $02	     xx00 0000			     P0-PF   P0-BL
    143 U0003		       00	   CXP1FB     ds	1	; $03	     xx00 0000			     P1-PF   P1-BL
    144 U0004		       00	   CXM0FB     ds	1	; $04	     xx00 0000			     M0-PF   M0-BL
    145 U0005		       00	   CXM1FB     ds	1	; $05	     xx00 0000			     M1-PF   M1-BL
    146 U0006		       00	   CXBLPF     ds	1	; $06	     x000 0000			     BL-PF   -----
    147 U0007		       00	   CXPPMM     ds	1	; $07	     xx00 0000			     P0-P1   M0-M1
    148 U0008		       00	   INPT0      ds	1	; $08	     x000 0000	     Read Pot Port 0
    149 U0009		       00	   INPT1      ds	1	; $09	     x000 0000	     Read Pot Port 1
    150 U000a		       00	   INPT2      ds	1	; $0A	     x000 0000	     Read Pot Port 2
    151 U000b		       00	   INPT3      ds	1	; $0B	     x000 0000	     Read Pot Port 3
    152 U000c		       00	   INPT4      ds	1	; $0C		x000 0000	 Read Input (Trigger) 0
    153 U000d		       00	   INPT5      ds	1	; $0D		x000 0000	 Read Input (Trigger) 1
    154 U000e
    155 U000e							;-------------------------------------------------------------------------------
    156 U000e
    157 U0298 ????				      SEG.U	RIOT
    158 U0280					      ORG	$280
    159 U0280
    160 U0280							; RIOT MEMORY MAP
    161 U0280
    162 U0280		       00	   SWCHA      ds	1	; $280      Port A data register for joysticks:
    163 U0281							;			Bits 4-7 for player 1.  Bits 0-3 for player 2.
    164 U0281
    165 U0281		       00	   SWACNT     ds	1	; $281      Port A data direction register (DDR)
    166 U0282		       00	   SWCHB      ds	1	; $282		Port B data (console switches)
    167 U0283		       00	   SWBCNT     ds	1	; $283      Port B DDR
    168 U0284		       00	   INTIM      ds	1	; $284		Timer output
    169 U0285
    170 U0285		       00	   TIMINT     ds	1	; $285
    171 U0286
    172 U0286							; Unused/undefined registers ($285-$294)
    173 U0286
    174 U0286		       00		      ds	1	; $286
    175 U0287		       00		      ds	1	; $287
    176 U0288		       00		      ds	1	; $288
    177 U0289		       00		      ds	1	; $289
    178 U028a		       00		      ds	1	; $28A
    179 U028b		       00		      ds	1	; $28B
    180 U028c		       00		      ds	1	; $28C
    181 U028d		       00		      ds	1	; $28D
    182 U028e		       00		      ds	1	; $28E
    183 U028f		       00		      ds	1	; $28F
    184 U0290		       00		      ds	1	; $290
    185 U0291		       00		      ds	1	; $291
    186 U0292		       00		      ds	1	; $292
    187 U0293		       00		      ds	1	; $293
    188 U0294
    189 U0294		       00	   TIM1T      ds	1	; $294		set 1 clock interval
    190 U0295		       00	   TIM8T      ds	1	; $295      set 8 clock interval
    191 U0296		       00	   TIM64T     ds	1	; $296      set 64 clock interval
    192 U0297		       00	   T1024T     ds	1	; $297      set 1024 clock interval
    193 U0298
    194 U0298							;-------------------------------------------------------------------------------
    195 U0298							; The following required for back-compatibility with code which does not use
    196 U0298							; segments.
    197 U0298
    198  0000 ????				      SEG
    199  0000 ????
    200  0000 ????						; EOF
------- FILE jetpack.s
------- FILE macro.h LEVEL 2 PASS 2
      0  0000 ????				      include	"macro.h"
      1  0000 ????						; MACRO.H
      2  0000 ????						; Version 1.06, 3/SEPTEMBER/2004
      3  0000 ????
      4  0000 ????	       00 6a	   VERSION_MACRO =	106
      5  0000 ????
      6  0000 ????						;
      7  0000 ????						; THIS FILE IS EXPLICITLY SUPPORTED AS A DASM-PREFERRED COMPANION FILE
      8  0000 ????						; PLEASE DO *NOT* REDISTRIBUTE MODIFIED VERSIONS OF THIS FILE!
      9  0000 ????						;
     10  0000 ????						; This file defines DASM macros useful for development for the Atari 2600.
     11  0000 ????						; It is distributed as a companion machine-specific support package
     12  0000 ????						; for the DASM compiler. Updates to this file, DASM, and associated tools are
     13  0000 ????						; available at at http://www.atari2600.org/dasm
     14  0000 ????						;
     15  0000 ????						; Many thanks to the people who have contributed.  If you take issue with the
     16  0000 ????						; contents, or would like to add something, please write to me
     17  0000 ????						; (atari2600@taswegian.com) with your contribution.
     18  0000 ????						;
     19  0000 ????						; Latest Revisions...
     20  0000 ????						;
     21  0000 ????						; 1.06  03/SEP/2004	 - nice revision of VERTICAL_BLANK (Edwin Blink)
     22  0000 ????						; 1.05  14/NOV/2003	 - Added VERSION_MACRO equate (which will reflect 100x version #)
     23  0000 ????						;			   This will allow conditional code to verify MACRO.H being
     24  0000 ????						;			   used for code assembly.
     25  0000 ????						; 1.04  13/NOV/2003	 - SET_POINTER macro added (16-bit address load)
     26  0000 ????						;
     27  0000 ????						; 1.03  23/JUN/2003	 - CLEAN_START macro added - clears TIA, RAM, registers
     28  0000 ????						;
     29  0000 ????						; 1.02  14/JUN/2003	 - VERTICAL_SYNC macro added
     30  0000 ????						;			   (standardised macro for vertical synch code)
     31  0000 ????						; 1.01  22/MAR/2003	 - SLEEP macro added. 
     32  0000 ????						;			 - NO_ILLEGAL_OPCODES switch implemented
     33  0000 ????						; 1.0	22/MAR/2003		Initial release
     34  0000 ????
     35  0000 ????						; Note: These macros use illegal opcodes.  To disable illegal opcode usage, 
     36  0000 ????						;   define the symbol NO_ILLEGAL_OPCODES (-DNO_ILLEGAL_OPCODES=1 on command-line).
     37  0000 ????						;   If you do not allow illegal opcode usage, you must include this file 
     38  0000 ????						;   *after* including VCS.H (as the non-illegal opcodes access hardware
     39  0000 ????						;   registers and require them to be defined first).
     40  0000 ????
     41  0000 ????						; Available macros...
     42  0000 ????						;   SLEEP n		 - sleep for n cycles
     43  0000 ????						;   VERTICAL_SYNC	 - correct 3 scanline vertical synch code
     44  0000 ????						;   CLEAN_START	 - set machine to known state on startup
     45  0000 ????						;   SET_POINTER	 - load a 16-bit absolute to a 16-bit variable
     46  0000 ????
     47  0000 ????						;-------------------------------------------------------------------------------
     48  0000 ????						; SLEEP duration
     49  0000 ????						; Original author: Thomas Jentzsch
     50  0000 ????						; Inserts code which takes the specified number of cycles to execute.	This is
     51  0000 ????						; useful for code where precise timing is required.
     52  0000 ????						; ILLEGAL-OPCODE VERSION DOES NOT AFFECT FLAGS OR REGISTERS.
     53  0000 ????						; LEGAL OPCODE VERSION MAY AFFECT FLAGS
     54  0000 ????						; Uses illegal opcode (DASM 2.20.01 onwards).
     55  0000 ????
     56  0000 ????				      MAC	sleep
     57  0000 ????			   .CYCLES    SET	{1}
     58  0000 ????
     59  0000 ????				      IF	.CYCLES < 2
     60  0000 ????				      ECHO	"MACRO ERROR: 'SLEEP': Duration must be > 1"
     61  0000 ????				      ERR
     62  0000 ????				      ENDIF
     63  0000 ????
     64  0000 ????				      IF	.CYCLES & 1
     65  0000 ????				      IFNCONST	NO_ILLEGAL_OPCODES
     66  0000 ????				      nop	0
     67  0000 ????				      ELSE
     68  0000 ????				      bit	VSYNC
     69  0000 ????				      ENDIF
     70  0000 ????			   .CYCLES    SET	.CYCLES - 3
     71  0000 ????				      ENDIF
     72  0000 ????
     73  0000 ????				      REPEAT	.CYCLES / 2
     74  0000 ????				      nop
     75  0000 ????				      REPEND
     76  0000 ????				      ENDM		;usage: SLEEP n (n>1)
     77  0000 ????
     78  0000 ????						;-------------------------------------------------------------------------------
     79  0000 ????						; VERTICAL_SYNC
     80  0000 ????						; revised version by Edwin Blink -- saves bytes!
     81  0000 ????						; Inserts the code required for a proper 3 scanline vertical sync sequence
     82  0000 ????						; Note: Alters the accumulator
     83  0000 ????
     84  0000 ????						; OUT: A = 0
     85  0000 ????
     86  0000 ????				      MAC	vertical_sync
     87  0000 ????				      lda	#%1110	; each '1' bits generate a VSYNC ON line (bits 1..3)
     88  0000 ????			   .VSLP1     sta	WSYNC	; 1st '0' bit resets Vsync, 2nd '0' bit exit loop
     89  0000 ????				      sta	VSYNC
     90  0000 ????				      lsr
     91  0000 ????				      bne	.VSLP1	; branch until VYSNC has been reset
     92  0000 ????				      ENDM
     93  0000 ????
     94  0000 ????						;-------------------------------------------------------------------------------
     95  0000 ????						; CLEAN_START
     96  0000 ????						; Original author: Andrew Davie
     97  0000 ????						; Standardised start-up code, clears stack, all TIA registers and RAM to 0
     98  0000 ????						; Sets stack pointer to $FF, and all registers to 0
     99  0000 ????						; Sets decimal mode off, sets interrupt flag (kind of un-necessary)
    100  0000 ????						; Use as very first section of code on boot (ie: at reset)
    101  0000 ????						; Code written to minimise total ROM usage - uses weird 6502 knowledge :)
    102  0000 ????
    103  0000 ????				      MAC	clean_start
    104  0000 ????				      sei
    105  0000 ????				      cld
    106  0000 ????
    107  0000 ????				      ldx	#0
    108  0000 ????				      txa
    109  0000 ????				      tay
    110  0000 ????			   .CLEAR_STACK dex
    111  0000 ????				      txs
    112  0000 ????				      pha
    113  0000 ????				      bne	.CLEAR_STACK	; SP=$FF, X = A = Y = 0
    114  0000 ????
    115  0000 ????				      ENDM
    116  0000 ????
    117  0000 ????						;-------------------------------------------------------
    118  0000 ????						; SET_POINTER
    119  0000 ????						; Original author: Manuel Rotschkar
    120  0000 ????						;
    121  0000 ????						; Sets a 2 byte RAM pointer to an absolute address.
    122  0000 ????						;
    123  0000 ????						; Usage: SET_POINTER pointer, address
    124  0000 ????						; Example: SET_POINTER SpritePTR, SpriteData
    125  0000 ????						;
    126  0000 ????						; Note: Alters the accumulator, NZ flags
    127  0000 ????						; IN 1: 2 byte RAM location reserved for pointer
    128  0000 ????						; IN 2: absolute address
    129  0000 ????
    130  0000 ????				      MAC	set_pointer
    131  0000 ????			   .POINTER   SET	{1}
    132  0000 ????			   .ADDRESS   SET	{2}
    133  0000 ????
    134  0000 ????				      LDA	#<.ADDRESS	; Get Lowbyte of Address
    135  0000 ????				      STA	.POINTER	; Store in pointer
    136  0000 ????				      LDA	#>.ADDRESS	; Get Hibyte of Address
    137  0000 ????				      STA	.POINTER+1	; Store in pointer+1
    138  0000 ????
    139  0000 ????				      ENDM
    140  0000 ????
    141  0000 ????						;-------------------------------------------------------
    142  0000 ????						; BOUNDARY byte#
    143  0000 ????						; Original author: Denis Debro (borrowed from Bob Smith / Thomas)
    144  0000 ????						;
    145  0000 ????						; Push data to a certain position inside a page and keep count of how
    146  0000 ????						; many free bytes the programmer will have.
    147  0000 ????						;
    148  0000 ????						; eg: BOUNDARY 5    ; position at byte #5 in page
    149  0000 ????
    150  0000 ????			   .FREE_BYTES SET	0
    151  0000 ????				      MAC	boundary
    152  0000 ????				      REPEAT	256
    153  0000 ????				      IF	<. % {1} = 0
    154  0000 ????				      MEXIT
    155  0000 ????				      ELSE
    156  0000 ????			   .FREE_BYTES SET	.FREE_BYTES + 1
    157  0000 ????				      .byte	$00
    158  0000 ????				      ENDIF
    159  0000 ????				      REPEND
    160  0000 ????				      ENDM
    161  0000 ????
    162  0000 ????
    163  0000 ????						; EOF
------- FILE jetpack.s
------- FILE xmacro.h LEVEL 2 PASS 2
      0  0000 ????				      include	"xmacro.h"
      1  0000 ????
      2  0000 ????						;-------------------------------------------------------
      3  0000 ????						; Usage: TIMER_SETUP lines
      4  0000 ????						; where lines is the number of scanlines to skip (> 2).
      5  0000 ????						; The timer will be set so that it expires before this number
      6  0000 ????						; of scanlines. A WSYNC will be done first.
      7  0000 ????
      8  0000 ????				      MAC	timer_setup
      9  0000 ????			   .lines     SET	{1}
     10  0000 ????				      lda	#(((.lines-1)*76-14)/64)
     11  0000 ????				      sta	WSYNC
     12  0000 ????				      sta	TIM64T
     13  0000 ????				      ENDM
     14  0000 ????
     15  0000 ????						;-------------------------------------------------------
     16  0000 ????						; Use with TIMER_SETUP to wait for timer to complete.
     17  0000 ????						; You may want to do a WSYNC afterwards, since the timer
     18  0000 ????						; is not accurate to the beginning/end of a scanline.
     19  0000 ????
     20  0000 ????				      MAC	timer_wait
     21  0000 ????			   .waittimer
     22  0000 ????				      lda	INTIM
     23  0000 ????				      bne	.waittimer
     24  0000 ????				      ENDM
     25  0000 ????
------- FILE jetpack.s
     21  0000 ????
     22 U008c ????				      seg.u	Variables
     23 U0080					      org	$80
     24 U0080
     25 U0080		       00	   Temp       byte.b
     26 U0081
     27 U0081							; Counters
     28 U0081		       00	   RowCount   byte.b
     29 U0082		       00	   LoopCount  byte.b
     30 U0083		       00	   FrameCount byte.b
     31 U0084
     32 U0084		       00	   YP1	      byte.b
     33 U0085		       00	   SpriteEnd  byte.b
     34 U0086		       00	   XPos       byte.b		; X position of player sprite
     35 U0087
     36 U0087
     37 U0087		       00	   Speed1     byte.b
     38 U0088		       00	   Speed2     byte.b
     39 U0089
     40 U0089		       00	   YPos       byte.b		; Y position of player sprite
     41 U008a		       00	   YPos2      byte.b
     42 U008b
     43 U008b		       00	   GEM_02_TARGET byte.b
     44 U008c
     45 U008c							;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     46 U008c
     47 U008c		       00 10	   ROW_COUNT  equ	16
     48 U008c
     49 U008c							; Sprites
     50 U008c
     51 U008c							; Nusiz
     52 U008c		       00 13	   THREE_COPIES equ	%00010011
     53 U008c
     54 U008c							; Frame 1 sprites
     55 U008c		       00 60	   EMR1       equ	%01100000
     56 U008c		       00 06	   EMR2       equ	%00000110
     57 U008c		       00 66	   EMR3       equ	%01100110
     58 U008c
     59 U008c							; Frame 2 sprites
     60 U008c		       00 c0	   T1	      equ	%11000000
     61 U008c		       00 0c	   T2	      equ	%00001100
     62 U008c		       00 cc	   T3	      equ	%11001100
     63 U008c
     64 U008c							; Shorthands
     65 U008c
     66 U008c		       00 87	   SET_0_0    equ	$87	; SAX (AXS)
     67 U008c		       00 85	   SET_1_0    equ	$85	; STA
     68 U008c		       00 86	   SET_0_1    equ	$86	; STX
     69 U008c		       00 84	   SET_1_1    equ	$84	; STY
     70 U008c
     71 U008c		       00 86	   SET_0_L    equ	$86	; STX
     72 U008c		       00 85	   SET_1_L    equ	$85	; STY
     73 U008c
     74 U008c		       00 85	   SET_0_R    equ	$85	; STA
     75 U008c		       00 84	   SET_1_R    equ	$84	; STY
     76 U008c
     77 U008c							; Gem enabling/disabling globally
     78 U008c
     79 U008c							; ; all off
     80 U008c							; GEM_00 equ SET_0_0
     81 U008c							; GEM_02 equ SET_0_0
     82 U008c							; GEM_04 equ SET_0_0
     83 U008c							; GEM_06 equ SET_0_0
     84 U008c							; GEM_08 equ SET_0_L
     85 U008c							; GEM_09 equ SET_0_0
     86 U008c							; GEM_11 equ SET_0_0
     87 U008c							; GEM_13 equ SET_0_0
     88 U008c							; GEM_15 equ SET_0_0
     89 U008c							; GEM_17 equ SET_0_R
     90 U008c							; GEM_18 equ SET_0_0
     91 U008c							; GEM_20 equ SET_0_0
     92 U008c							; GEM_22 equ SET_0_0
     93 U008c							; GEM_24 equ SET_0_0
     94 U008c
     95 U008c							; all on
     96 U008c		       00 84	   GEM_00     equ	SET_1_1
     97 U008c		       00 84	   GEM_02     equ	SET_1_1
     98 U008c		       00 84	   GEM_04     equ	SET_1_1
     99 U008c		       00 84	   GEM_06     equ	SET_1_1
    100 U008c		       00 85	   GEM_08     equ	SET_1_L
    101 U008c		       00 84	   GEM_09     equ	SET_1_1
    102 U008c		       00 84	   GEM_11     equ	SET_1_1
    103 U008c		       00 84	   GEM_13     equ	SET_1_1
    104 U008c		       00 84	   GEM_15     equ	SET_1_1
    105 U008c		       00 84	   GEM_17     equ	SET_1_R
    106 U008c		       00 84	   GEM_18     equ	SET_1_1
    107 U008c		       00 84	   GEM_20     equ	SET_1_1
    108 U008c		       00 84	   GEM_22     equ	SET_1_1
    109 U008c		       00 84	   GEM_24     equ	SET_1_1
    110 U008c
    111 U008c							; ; odd on
    112 U008c							; GEM_00 equ SET_1_0
    113 U008c							; GEM_02 equ SET_1_0
    114 U008c							; GEM_04 equ SET_1_0
    115 U008c							; GEM_06 equ SET_1_0
    116 U008c							; GEM_08 equ SET_1_L
    117 U008c							; GEM_09 equ SET_0_1
    118 U008c							; GEM_11 equ SET_0_1
    119 U008c							; GEM_13 equ SET_0_1
    120 U008c							; GEM_15 equ SET_0_1
    121 U008c							; GEM_17 equ SET_0_R
    122 U008c							; GEM_18 equ SET_1_0
    123 U008c							; GEM_20 equ SET_1_0
    124 U008c							; GEM_22 equ SET_1_0
    125 U008c							; GEM_24 equ SET_1_0
    126 U008c
    127 U008c							; ; even on
    128 U008c							; GEM_00 equ SET_0_1
    129 U008c							; GEM_02 equ SET_0_1
    130 U008c							; GEM_04 equ SET_0_1
    131 U008c							; GEM_06 equ SET_0_1
    132 U008c							; GEM_08 equ SET_0_L
    133 U008c							; GEM_09 equ SET_1_0
    134 U008c							; GEM_11 equ SET_1_0
    135 U008c							; GEM_13 equ SET_1_0
    136 U008c							; GEM_15 equ SET_1_0
    137 U008c							; GEM_17 equ SET_1_R
    138 U008c							; GEM_18 equ SET_0_1
    139 U008c							; GEM_20 equ SET_0_1
    140 U008c							; GEM_22 equ SET_0_1
    141 U008c							; GEM_24 equ SET_0_1
    142 U008c
    143 U008c							; Colors
    144 U008c
    145 U008c		       00 42	   COL_BG     equ	$42
    146 U008c		       00 cc	   COL_EMERALD equ	$CC
    147 U008c		       00 cc	   COL_EMERALD_2 equ	$CC
    148 U008c
    149 U008c							; HMOVE values
    150 U008c
    151 U008c		       00 27	   EMERALD_MI_HMOVE_S equ	39
    152 U008c		       00 d0	   EMERALD_MI_HMOVE_2 equ	$d0
    153 U008c		       00 10	   EMERALD_MI_HMOVE_3 equ	$10
    154 U008c
    155 U008c							; Sprite details
    156 U008c
    157 U008c		       00 09	   SPRITE_HEIGHT equ	9
    158 U008c
    159 U008c
    160 U008c		       00 07	   EMERALD_SP_COLOR equ	COLUP1
    161 U008c		       00 1c	   EMERALD_SP equ	GRP1
    162 U008c		       00 1e	   EMERALD_MI_ENABLE equ	ENAM1
    163 U008c		       00 11	   EMERALD_SP_RESET equ	RESP1
    164 U008c		       00 13	   EMERALD_MI_RESET equ	RESM1
    165 U008c		       00 21	   EMERALD_SP_HMOVE equ	HMP1
    166 U008c		       00 23	   EMERALD_MI_HMOVE equ	HMM1
    167 U008c		       00 05	   EMERALD_COPIES equ	NUSIZ1
    168 U008c
    169 U008c		       00 1b	   JET_SP     equ	GRP0
    170 U008c		       00 10	   JET_SP_RESET equ	RESP0
    171 U008c		       00 20	   JET_SP_HMOVE equ	HMP0
    172 U008c		       00 06	   JET_SP_COLOR equ	COLUP0
    173 U008c
    174 U008c
    175 U008c							; Offset from the sprite label to the point
    176 U008c							; at which the sprite actually starts. This is the 0-padding
    177 U008c							; FRAME_OFFSET equ 53
    178 U008c
    179 U008c							; Spriteend is HEIGHT_OFFSET - YPos
    180 U008c		       00 c8	   HEIGHT_OFFSET equ	200
    181 U008c
    182 U008c							; Compared with YPos
    183 U008c		       00 32	   FLOOR_OFFSET equ	50
    184 U008c
    185 U008c							; YPos definite position
    186 U008c		       00 64	   YPosStart  equ	100
    187 U008c
    188 U008c							;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    189 U008c
    190  10000 ????				       seg	Code
    191  10000 ????
    192  d000					      org	$D000
    193  d000					      rorg	$F000
    194  d000
    195  d000		       00	   BANK1      byte.b
    196  d001
    197  d200					      org	$D200
    198  d200					      rorg	$F200
    199  d200
    200  d200				   Bank1Start
    201  d200		       ad fa ff 	      lda	$FFFA
    202  d203		       ea		      nop
    203  d204		       ea		      nop
    204  d205		       ea		      nop
    205  d206
    206  d206							; Epilogue
    207  dffc					      org	$DFFC
    208  dffc					      rorg	$FFFC
    209  dffc		       00 f2		      .word.w	Bank1Start
    210  dffe		       00 f2		      .word.w	Bank1Start
    211  e000
    212  e000					      org	$E000
    213  e000					      rorg	$F000
    214  e000
    215  e000		       00	   BANK2      byte.b
    216  e001
    217  e200					      org	$E200
    218  e200					      rorg	$F200
    219  e200
    220  e200				   Bank2Start
    221  e200		       ad fa ff 	      lda	$FFFA
    222  e203		       ea		      nop
    223  e204		       ea		      nop
    224  e205		       ea		      nop
    225  e206
    226  e206							; Epilogue
    227  effc					      org	$EFFC
    228  effc					      rorg	$FFFC
    229  effc		       00 f2		      .word.w	Bank2Start
    230  effe		       00 f2		      .word.w	Bank2Start
    231  f000
    232  f000					      org	$F000
    233  f000					      rorg	$F000
    234  f000
    235  f000		       00	   BANK3      byte.b
    236  f001
    237  f200					      org	$F200
    238  f200					      rorg	$F200
    239  f200
    240  f200				   Start
    241  f200		       ad fa ff 	      lda	$FFFA
    242  f203		       ea		      nop
    243  f204		       ea		      nop
    244  f205		       ea		      nop
    245  f206
      0  f206					      CLEAN_START
      1  f206		       78		      sei
      2  f207		       d8		      cld
      3  f208
      4  f208		       a2 00		      ldx	#0
      5  f20a		       8a		      txa
      6  f20b		       a8		      tay
      7  f20c		       ca	   .CLEAR_STACK dex
      8  f20d		       9a		      txs
      9  f20e		       48		      pha
     10  f20f		       d0 fb		      bne	.CLEAR_STACK
     11  f211
    247  f211		       a9 00		      lda	#0
    248  f213		       85 83		      sta	FrameCount
    249  f215
    250  f215							; P0 has three copies
    251  f215		       a9 13		      lda	#THREE_COPIES
    252  f217		       85 05		      sta	EMERALD_COPIES
    253  f219
    254  f219		       a9 00		      lda	#$00
    255  f21b		       85 09		      sta	COLUBK
    256  f21d		       a9 01		      lda	#%00000001
    257  f21f		       85 0a		      sta	CTRLPF	; reflect playfield
    258  f221
    259  f221							; Disable VDEL
    260  f221		       a9 00		      lda	#0
    261  f223		       85 25		      sta	VDELP0
    262  f225		       85 26		      sta	VDELP1
    263  f227
    264  f227
    265  f227							; Player 0
    266  f227		       a2 cc		      ldx	#COL_EMERALD
    267  f229		       86 07		      stx	EMERALD_SP_COLOR
    268  f22b
    269  f22b							; Player 1
    270  f22b		       a9 98		      lda	#$98
    271  f22d		       85 06		      sta	JET_SP_COLOR
    272  f22f		       a9 00		      lda	#$00
    273  f231		       85 1b		      sta	JET_SP
    274  f233
    275  f233							; Positions
    276  f233		       a9 64		      lda	#YPosStart
    277  f235		       85 89		      sta	YPos
    278  f237		       a9 37		      lda	#55
    279  f239		       85 86		      sta	XPos
    280  f23b		       a9 00		      lda	#0
    281  f23d		       85 87		      sta	Speed1
    282  f23f		       85 88		      sta	Speed2
    283  f241		       85 8a		      sta	YPos2
    284  f243
    285  f243				   BeginFrame
      0  f243					      VERTICAL_SYNC
      1  f243		       a9 0e		      lda	#%1110
      2  f245		       85 02	   .VSLP1     sta	WSYNC
      3  f247		       85 00		      sta	VSYNC
      4  f249		       4a		      lsr
      5  f24a		       d0 f9		      bne	.VSLP1
    287  f24c
      0  f24c					      TIMER_SETUP	37
      1  f24c				   .lines     SET	37
      2  f24c		       a9 2a		      lda	#(((.lines-1)*76-14)/64)
      3  f24e		       85 02		      sta	WSYNC
      4  f250		       8d 96 02 	      sta	TIM64T
    289  f253
    290  f253							; Scanline counter
    291  f253		       a9 10		      lda	#ROW_COUNT
    292  f255		       85 82		      sta	LoopCount
    293  f257
    294  f257							; Frame counter
    295  f257		       e6 83		      inc	FrameCount
    296  f259
    297  f259							; Now the work stuff
    298  f259
    299  f259		       a9 01		      lda	#01
    300  f25b		       25 83		      and	FrameCount
    301  f25d		       d0 14		      bne	CopyFrame2Kernel
    302  f25f				   CopyFrame1Kernel
    303  f25f
    304  f25f							; Copy: FRAME 1
    305  f25f		       a0 1f		      ldy	#(frame_1_end - frame_1_start)-1
    306  f261				   .copy_loop
    307  f261		       b9 13 f4 	      lda	frame_1_start,Y
    308  f264		       99 00 10 	      sta	$1000,Y
    309  f267		       88		      dey
    310  f268		       d0 f7		      bne	.copy_loop
    311  f26a		       ad 13 f4 	      lda	frame_1_start
    312  f26d		       8d 00 10 	      sta	$1000
    313  f270		       4c 87 f2 	      jmp	CopyFrameNext
    314  f273
    315  f273				   CopyFrame2Kernel
    316  f273
    317  f273							; Copy: FRAME 2
    318  f273		       a0 66		      ldy	#(frame_2_end - frame_2_start)-1
    319  f275				   .copy_loop2
    320  f275		       b9 33 11 	      lda	frame_2_start,Y
    321  f278		       99 00 10 	      sta	$1000,Y
    322  f27b		       88		      dey
    323  f27c		       d0 f7		      bne	.copy_loop2
    324  f27e		       ad 33 11 	      lda	frame_2_start
    325  f281		       8d 00 10 	      sta	$1000
    326  f284		       4c 87 f2 	      jmp	CopyFrameNext
    327  f287
    328  f287				   CopyFrameNext
    329  f287							; Positioning
    330  f287		       85 02		      sta	WSYNC
      0  f289					      SLEEP	40
      1  f289				   .CYCLES    SET	40
      2  f289
      3  f289				  -	      IF	.CYCLES < 2
      4  f289				  -	      ECHO	"MACRO ERROR: 'SLEEP': Duration must be > 1"
      5  f289				  -	      ERR
      6  f289					      ENDIF
      7  f289
      8  f289				  -	      IF	.CYCLES & 1
      9  f289				  -	      IFNCONST	NO_ILLEGAL_OPCODES
     10  f289				  -	      nop	0
     11  f289				  -	      ELSE
     12  f289				  -	      bit	VSYNC
     13  f289				  -	      ENDIF
     14  f289				  -.CYCLES    SET	.CYCLES - 3
     15  f289					      ENDIF
     16  f289
     17  f289					      REPEAT	.CYCLES / 2
     18  f289		       ea		      nop
     17  f289					      REPEND
     18  f28a		       ea		      nop
     17  f28a					      REPEND
     18  f28b		       ea		      nop
     17  f28b					      REPEND
     18  f28c		       ea		      nop
     17  f28c					      REPEND
     18  f28d		       ea		      nop
     17  f28d					      REPEND
     18  f28e		       ea		      nop
     17  f28e					      REPEND
     18  f28f		       ea		      nop
     17  f28f					      REPEND
     18  f290		       ea		      nop
     17  f290					      REPEND
     18  f291		       ea		      nop
     17  f291					      REPEND
     18  f292		       ea		      nop
     17  f292					      REPEND
     18  f293		       ea		      nop
     17  f293					      REPEND
     18  f294		       ea		      nop
     17  f294					      REPEND
     18  f295		       ea		      nop
     17  f295					      REPEND
     18  f296		       ea		      nop
     17  f296					      REPEND
     18  f297		       ea		      nop
     17  f297					      REPEND
     18  f298		       ea		      nop
     17  f298					      REPEND
     18  f299		       ea		      nop
     17  f299					      REPEND
     18  f29a		       ea		      nop
     17  f29a					      REPEND
     18  f29b		       ea		      nop
     17  f29b					      REPEND
     18  f29c		       ea		      nop
     19  f29d					      REPEND
    332  f29d		       85 11		      sta	EMERALD_SP_RESET	; position 1st player
    333  f29f		       85 02		      sta	WSYNC
    334  f2a1
    335  f2a1							; Misc
    336  f2a1		       a9 00		      lda	#00
    337  f2a3		       85 1e		      sta	EMERALD_MI_ENABLE
    338  f2a5
    339  f2a5							; Assign dervied SpriteEnd value
    340  f2a5		       a9 c8		      lda	#HEIGHT_OFFSET
    341  f2a7		       e5 89		      sbc	YPos
    342  f2a9		       85 85		      sta	SpriteEnd
    343  f2ab
    344  f2ab							; Move missile to starting position and fine-tune position
    345  f2ab							; TODO replace with an HMOVE macro
    346  f2ab		       85 02		      sta	WSYNC
      0  f2ad					      sleep	EMERALD_MI_HMOVE_S
      1  f2ad				   .CYCLES    SET	EMERALD_MI_HMOVE_S
      2  f2ad
      3  f2ad				  -	      IF	.CYCLES < 2
      4  f2ad				  -	      ECHO	"MACRO ERROR: 'SLEEP': Duration must be > 1"
      5  f2ad				  -	      ERR
      6  f2ad					      ENDIF
      7  f2ad
      8  f2ad					      IF	.CYCLES & 1
      9  f2ad					      IFNCONST	NO_ILLEGAL_OPCODES
     10  f2ad		       04 00		      nop	0
     11  f2af				  -	      ELSE
     12  f2af				  -	      bit	VSYNC
     13  f2af					      ENDIF
     14  f2af				   .CYCLES    SET	.CYCLES - 3
     15  f2af					      ENDIF
     16  f2af
     17  f2af					      REPEAT	.CYCLES / 2
     18  f2af		       ea		      nop
     17  f2af					      REPEND
     18  f2b0		       ea		      nop
     17  f2b0					      REPEND
     18  f2b1		       ea		      nop
     17  f2b1					      REPEND
     18  f2b2		       ea		      nop
     17  f2b2					      REPEND
     18  f2b3		       ea		      nop
     17  f2b3					      REPEND
     18  f2b4		       ea		      nop
     17  f2b4					      REPEND
     18  f2b5		       ea		      nop
     17  f2b5					      REPEND
     18  f2b6		       ea		      nop
     17  f2b6					      REPEND
     18  f2b7		       ea		      nop
     17  f2b7					      REPEND
     18  f2b8		       ea		      nop
     17  f2b8					      REPEND
     18  f2b9		       ea		      nop
     17  f2b9					      REPEND
     18  f2ba		       ea		      nop
     17  f2ba					      REPEND
     18  f2bb		       ea		      nop
     17  f2bb					      REPEND
     18  f2bc		       ea		      nop
     17  f2bc					      REPEND
     18  f2bd		       ea		      nop
     17  f2bd					      REPEND
     18  f2be		       ea		      nop
     17  f2be					      REPEND
     18  f2bf		       ea		      nop
     17  f2bf					      REPEND
     18  f2c0		       ea		      nop
     19  f2c1					      REPEND
    348  f2c1		       85 13		      sta	EMERALD_MI_RESET
    349  f2c3
    350  f2c3							; Player 1
    351  f2c3		       a5 86		      lda	XPos
    352  f2c5		       a2 00		      ldx	#0
    353  f2c7		       20 fa 11 	      jsr	SetHorizPos
    354  f2ca
      0  f2ca					      TIMER_WAIT
      1  f2ca				   .waittimer
      2  f2ca		       ad 84 02 	      lda	INTIM
      3  f2cd		       d0 fb		      bne	.waittimer
      0  f2cf					      TIMER_SETUP	192
      1  f2cf				   .lines     SET	192
      2  f2cf		       a9 e2		      lda	#(((.lines-1)*76-14)/64)
      3  f2d1		       85 02		      sta	WSYNC
      4  f2d3		       8d 96 02 	      sta	TIM64T
    357  f2d6
    358  f2d6							;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    359  f2d6
    360  f2d6							; Frame border top
    361  f2d6
    362  f2d6							; Start top border
    363  f2d6				   frame_top
    364  f2d6		       a9 42		      lda	#COL_BG
    365  f2d8		       85 08		      sta	COLUPF
    366  f2da		       85 02		      sta	WSYNC
    367  f2dc		       85 02		      sta	WSYNC
    368  f2de		       85 02		      sta	WSYNC
    369  f2e0		       85 02		      sta	WSYNC
    370  f2e2		       85 02		      sta	WSYNC
    371  f2e4		       85 02		      sta	WSYNC
    372  f2e6		       85 02		      sta	WSYNC
    373  f2e8		       85 02		      sta	WSYNC
    374  f2ea
    375  f2ea				   PlayArea
    376  f2ea							; PF is now the playing area
    377  f2ea		       a9 00		      lda	#%00000000
    378  f2ec		       85 0d		      sta	PF0
    379  f2ee		       a9 20		      lda	#%00100000
    380  f2f0		       85 0e		      sta	PF1
    381  f2f2		       a9 00		      lda	#%00000000
    382  f2f4		       85 0f		      sta	PF2
    383  f2f6
    384  f2f6							; Choose which kernel to use
    385  f2f6		       a9 01		      lda	#01
    386  f2f8		       25 83		      and	FrameCount
    387  f2fa		       d0 07		      bne	doframe2
    388  f2fc
    389  f2fc							; frame 1
    390  f2fc		       a2 d0		      ldx	#EMERALD_MI_HMOVE_2
    391  f2fe		       86 23		      stx	EMERALD_MI_HMOVE
    392  f300		       4c 07 f3 	      jmp	doframe2after
    393  f303
    394  f303							; frame 2
    395  f303				   doframe2
    396  f303		       a2 10		      ldx	#EMERALD_MI_HMOVE_3
    397  f305		       86 23		      stx	EMERALD_MI_HMOVE
    398  f307				   doframe2after
    399  f307
    400  f307
    401  f307
    402  f307
    403  f307							;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    404  f307
    405  f307							; frame start
    406  f307
    407  f307
    408  f307
    409  f307
    410  f307							; MACRO for calculating next GRPx value
    411  f307
    412  f307					      MAC	jet_spritedata_calc
    413  f307					      lda	#SPRITE_HEIGHT
    414  f307					      dcp	SpriteEnd
    415  f307					      ldy	SpriteEnd
    416  f307
    417  f307							; 4c
    418  f307							; This must never be 5 cycles This mean Frame0 + Y must not cross below apage boundary.
    419  f307					      lda	Frame0,Y
    420  f307							; 6c
    421  f307					      .byte	$b0, $01	;2c / 3c (taken)
    422  f307					      .byte	$2c	; 4c / 0c
    423  f307					      sta	JET_SP	; 0c / 3c
    424  f307
    425  f307					      ENDM
    426  f307
    427  f307
    428  f307
    429  f307
    430  f307
    431  f307
    432  f307				   frame_start
    433  f307		       85 02		      sta	WSYNC
      0  f309					      jet_spritedata_calc
      1  f309		       a9 09		      lda	#SPRITE_HEIGHT
      2  f30b		       c7 85		      dcp	SpriteEnd
      3  f30d		       a4 85		      ldy	SpriteEnd
      4  f30f
      5  f30f
      6  f30f
      7  f30f		       b9 7c 13 	      lda	Frame0,Y
      8  f312
      9  f312		       b0 01		      .byte.b	$b0, $01
     10  f314		       2c		      .byte.b	$2c
     11  f315		       85 1b		      sta	JET_SP
     12  f317
    435  f317		       85 02		      sta	WSYNC
      0  f319					      jet_spritedata_calc
      1  f319		       a9 09		      lda	#SPRITE_HEIGHT
      2  f31b		       c7 85		      dcp	SpriteEnd
      3  f31d		       a4 85		      ldy	SpriteEnd
      4  f31f
      5  f31f
      6  f31f
      7  f31f		       b9 7c 13 	      lda	Frame0,Y
      8  f322
      9  f322		       b0 01		      .byte.b	$b0, $01
     10  f324		       2c		      .byte.b	$2c
     11  f325		       85 1b		      sta	JET_SP
     12  f327
      0  f327					      sleep	44
      1  f327				   .CYCLES    SET	44
      2  f327
      3  f327				  -	      IF	.CYCLES < 2
      4  f327				  -	      ECHO	"MACRO ERROR: 'SLEEP': Duration must be > 1"
      5  f327				  -	      ERR
      6  f327					      ENDIF
      7  f327
      8  f327				  -	      IF	.CYCLES & 1
      9  f327				  -	      IFNCONST	NO_ILLEGAL_OPCODES
     10  f327				  -	      nop	0
     11  f327				  -	      ELSE
     12  f327				  -	      bit	VSYNC
     13  f327				  -	      ENDIF
     14  f327				  -.CYCLES    SET	.CYCLES - 3
     15  f327					      ENDIF
     16  f327
     17  f327					      REPEAT	.CYCLES / 2
     18  f327		       ea		      nop
     17  f327					      REPEND
     18  f328		       ea		      nop
     17  f328					      REPEND
     18  f329		       ea		      nop
     17  f329					      REPEND
     18  f32a		       ea		      nop
     17  f32a					      REPEND
     18  f32b		       ea		      nop
     17  f32b					      REPEND
     18  f32c		       ea		      nop
     17  f32c					      REPEND
     18  f32d		       ea		      nop
     17  f32d					      REPEND
     18  f32e		       ea		      nop
     17  f32e					      REPEND
     18  f32f		       ea		      nop
     17  f32f					      REPEND
     18  f330		       ea		      nop
     17  f330					      REPEND
     18  f331		       ea		      nop
     17  f331					      REPEND
     18  f332		       ea		      nop
     17  f332					      REPEND
     18  f333		       ea		      nop
     17  f333					      REPEND
     18  f334		       ea		      nop
     17  f334					      REPEND
     18  f335		       ea		      nop
     17  f335					      REPEND
     18  f336		       ea		      nop
     17  f336					      REPEND
     18  f337		       ea		      nop
     17  f337					      REPEND
     18  f338		       ea		      nop
     17  f338					      REPEND
     18  f339		       ea		      nop
     17  f339					      REPEND
     18  f33a		       ea		      nop
     17  f33a					      REPEND
     18  f33b		       ea		      nop
     17  f33b					      REPEND
     18  f33c		       ea		      nop
     19  f33d					      REPEND
    438  f33d		       c6 85		      dec	SpriteEnd
    439  f33f
    440  f33f							; Jump to copied kernel
    441  f33f		       4c 00 11 	      jmp	$1100
    442  f342
    443  f342				   frame_row_start subroutine
    444  f342		       a9 00		      lda	#0
    445  f344		       85 1e		      sta	EMERALD_MI_ENABLE
    446  f346		       85 1c		      sta	EMERALD_SP
    447  f348
    448  f348							; four blank lines
    449  f348		       85 02		      sta	WSYNC
      0  f34a					      jet_spritedata_calc
      1  f34a		       a9 09		      lda	#SPRITE_HEIGHT
      2  f34c		       c7 85		      dcp	SpriteEnd
      3  f34e		       a4 85		      ldy	SpriteEnd
      4  f350
      5  f350
      6  f350
      7  f350		       b9 7c 13 	      lda	Frame0,Y
      8  f353
      9  f353		       b0 01		      .byte.b	$b0, $01
     10  f355		       2c		      .byte.b	$2c
     11  f356		       85 1b		      sta	JET_SP
     12  f358
    451  f358
    452  f358		       a9 01		      lda	#01
    453  f35a		       25 83		      and	FrameCount
    454  f35c		       d0 1b		      bne	loadframe2
    455  f35e				   loadframe1
    456  f35e		       a9 84		      lda	#SET_1_1
    457  f360		       85 8b		      sta	GEM_02_TARGET
    458  f362
    459  f362		       a9 84		      lda	#SET_1_1
    460  f364		       85 8b		      sta	GEM_02_TARGET
    461  f366
    462  f366		       a9 84		      lda	#SET_1_1
    463  f368		       85 8b		      sta	GEM_02_TARGET
    464  f36a
    465  f36a		       a9 85		      lda	#SET_1_L
    466  f36c		       85 8b		      sta	GEM_02_TARGET
    467  f36e
    468  f36e		       a9 84		      lda	#SET_1_1
    469  f370		       85 8b		      sta	GEM_02_TARGET
    470  f372
    471  f372		       a9 84		      lda	#SET_1_1
    472  f374		       85 8b		      sta	GEM_02_TARGET
    473  f376
    474  f376		       4c 98 f3 	      jmp	loadframeafter
    475  f379
    476  f379				   loadframe2
    477  f379		       a9 84		      lda	#SET_1_1
    478  f37b		       85 8b		      sta	GEM_02_TARGET
    479  f37d
    480  f37d		       a9 84		      lda	#SET_1_1
    481  f37f		       85 8b		      sta	GEM_02_TARGET
    482  f381
    483  f381		       a9 84		      lda	#SET_1_R
    484  f383		       85 8b		      sta	GEM_02_TARGET
    485  f385
    486  f385		       a9 84		      lda	#SET_1_1
    487  f387		       85 8b		      sta	GEM_02_TARGET
    488  f389
    489  f389		       a9 84		      lda	#SET_1_1
    490  f38b		       85 8b		      sta	GEM_02_TARGET
    491  f38d
    492  f38d		       a9 84		      lda	#SET_1_1
    493  f38f		       85 8b		      sta	GEM_02_TARGET
    494  f391
    495  f391		       a9 84		      lda	#SET_1_1
    496  f393		       85 8b		      sta	GEM_02_TARGET
    497  f395
    498  f395		       4c 98 f3 	      jmp	loadframeafter
    499  f398
    500  f398				   loadframeafter
    501  f398		       85 02		      sta	WSYNC
      0  f39a					      jet_spritedata_calc
      1  f39a		       a9 09		      lda	#SPRITE_HEIGHT
      2  f39c		       c7 85		      dcp	SpriteEnd
      3  f39e		       a4 85		      ldy	SpriteEnd
      4  f3a0
      5  f3a0
      6  f3a0
      7  f3a0		       b9 7c 13 	      lda	Frame0,Y
      8  f3a3
      9  f3a3		       b0 01		      .byte.b	$b0, $01
     10  f3a5		       2c		      .byte.b	$2c
     11  f3a6		       85 1b		      sta	JET_SP
     12  f3a8
    503  f3a8
    504  f3a8		       85 02		      sta	WSYNC
      0  f3aa					      jet_spritedata_calc
      1  f3aa		       a9 09		      lda	#SPRITE_HEIGHT
      2  f3ac		       c7 85		      dcp	SpriteEnd
      3  f3ae		       a4 85		      ldy	SpriteEnd
      4  f3b0
      5  f3b0
      6  f3b0
      7  f3b0		       b9 7c 13 	      lda	Frame0,Y
      8  f3b3
      9  f3b3		       b0 01		      .byte.b	$b0, $01
     10  f3b5		       2c		      .byte.b	$2c
     11  f3b6		       85 1b		      sta	JET_SP
     12  f3b8
    506  f3b8		       85 02		      sta	WSYNC
      0  f3ba					      jet_spritedata_calc
      1  f3ba		       a9 09		      lda	#SPRITE_HEIGHT
      2  f3bc		       c7 85		      dcp	SpriteEnd
      3  f3be		       a4 85		      ldy	SpriteEnd
      4  f3c0
      5  f3c0
      6  f3c0
      7  f3c0		       b9 7c 13 	      lda	Frame0,Y
      8  f3c3
      9  f3c3		       b0 01		      .byte.b	$b0, $01
     10  f3c5		       2c		      .byte.b	$2c
     11  f3c6		       85 1b		      sta	JET_SP
     12  f3c8
    508  f3c8
    509  f3c8							; next line, repeat until <0
    510  f3c8		       c6 82		      dec	LoopCount
    511  f3ca		       30 03		      bmi	.skip
    512  f3cc		       4c 07 f3 	      jmp	frame_start
    513  f3cf				   .skip
    514  f3cf
    515  f3cf							; reset the background for bottom of playfield
    516  f3cf				   frame_bottom
    517  f3cf		       a9 3f		      lda	#%00111111
    518  f3d1		       85 0e		      sta	PF1
    519  f3d3		       a9 ff		      lda	#%11111111
    520  f3d5		       85 0f		      sta	PF2
    521  f3d7
    522  f3d7		       a9 00		      lda	#0
    523  f3d9		       85 1c		      sta	EMERALD_SP
    524  f3db		       85 1b		      sta	JET_SP
    525  f3dd		       85 1e		      sta	EMERALD_MI_ENABLE
    526  f3df
    527  f3df		       85 02		      sta	WSYNC
    528  f3e1		       85 02		      sta	WSYNC
    529  f3e3		       85 02		      sta	WSYNC
    530  f3e5		       85 02		      sta	WSYNC
    531  f3e7		       85 02		      sta	WSYNC
    532  f3e9		       85 02		      sta	WSYNC
    533  f3eb		       85 02		      sta	WSYNC
    534  f3ed		       85 02		      sta	WSYNC
    535  f3ef
    536  f3ef		       a9 00		      lda	#$00
    537  f3f1		       85 09		      sta	COLUBK
    538  f3f3		       85 08		      sta	COLUPF
    539  f3f5
    540  f3f5				   frame_end
    541  f3f5							; End
    542  f3f5		       a9 00		      lda	#0
    543  f3f7		       85 1c		      sta	EMERALD_SP
    544  f3f9
      0  f3f9					      TIMER_WAIT
      1  f3f9				   .waittimer
      2  f3f9		       ad 84 02 	      lda	INTIM
      3  f3fc		       d0 fb		      bne	.waittimer
      0  f3fe					      TIMER_SETUP	30
      1  f3fe				   .lines     SET	30
      2  f3fe		       a9 22		      lda	#(((.lines-1)*76-14)/64)
      3  f400		       85 02		      sta	WSYNC
      4  f402		       8d 96 02 	      sta	TIM64T
    547  f405
    548  f405		       20 9a 11 	      jsr	MoveJoystick
    549  f408		       20 d1 11 	      jsr	SpeedCalculation
    550  f40b
      0  f40b					      TIMER_WAIT
      1  f40b				   .waittimer
      2  f40b		       ad 84 02 	      lda	INTIM
      3  f40e		       d0 fb		      bne	.waittimer
    552  f410		       4c 43 f2 	      jmp	BeginFrame
    553  f413
    554  f413
    555  f413							;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    556  f413
    557  f413							; kernels
    558  f413
    559  f413
    560  f413							; Important cycles for the kernels:
    561  f413							; left border: 29, right border: 64
    562  f413
    563  f413							;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    564  f413
    565  f413							; FRAME 1
    566  f413
    567  f413							; Emerald line macro
    568  f413					      MAC	frame1line
    569  f413
    570  f413				   wow	      rorg	$1100
    571  f413
    572  f413							; lda #<frame_row_start
    573  f413							; sta .jmpaddr
    574  f413							; lda #>frame_row_start
    575  f413							; sta .jmpaddr+1
    576  f413
    577  f413							; Start new line + HMOVE
    578  f413					      sta	HMOVE
    579  f413
    580  f413					      dec	SpriteEnd
    581  f413					      sleep	5
    582  f413
    583  f413					      lda	#EMR1
    584  f413					      ldx	#EMR2
    585  f413					      ldy	#EMR3
    586  f413					      .byte	GEM_00, EMERALD_SP
    587  f413
    588  f413							; 22
    589  f413					      sta	EMERALD_SP_RESET
    590  f413					      sleep	6
    591  f413					      .byte	GEM_04, EMERALD_SP
    592  f413					      sta	EMERALD_SP_RESET
    593  f413					      .byte	GEM_09, EMERALD_SP
    594  f413					      sleep	3
    595  f413					      .byte	GEM_13, EMERALD_SP
    596  f413					      sta	EMERALD_SP_RESET
    597  f413					      .byte	GEM_17, EMERALD_MI_ENABLE
    598  f413					      .byte	GEM_18, EMERALD_SP
    599  f413					      sta	HMCLR	; movable
    600  f413					      .byte	GEM_22, EMERALD_SP
    601  f413					      .byte	GEM_08, EMERALD_MI_ENABLE
    602  f413
    603  f413							; cycle 64 (start of right border)
    604  f413					      sleep	12
    605  f413				   endwow
    606  f413					      ENDM
    607  f413
    608  f413				   frame_1_start
    609  f413		       85 02		      sta	WSYNC
      0  f415					      Frame1Line
      1  f415
      2  f415				   wow	      rorg	$1100
      3  f415
      4  f415
      5  f415
      6  f415
      7  f415
      8  f415
      9  f415
     10  f415		       85 2a		      sta	HMOVE
     11  f417
     12  f417		       c6 85		      dec	SpriteEnd
      0  f419					      sleep	5
      1  f419				   .CYCLES    SET	5
      2  f419
      3  f419				  -	      IF	.CYCLES < 2
      4  f419				  -	      ECHO	"MACRO ERROR: 'SLEEP': Duration must be > 1"
      5  f419				  -	      ERR
      6  f419					      ENDIF
      7  f419
      8  f419					      IF	.CYCLES & 1
      9  f419					      IFNCONST	NO_ILLEGAL_OPCODES
     10  f419		       04 00		      nop	0
     11  f41b				  -	      ELSE
     12  f41b				  -	      bit	VSYNC
     13  f41b					      ENDIF
     14  f41b				   .CYCLES    SET	.CYCLES - 3
     15  f41b					      ENDIF
     16  f41b
     17  f41b					      REPEAT	.CYCLES / 2
     18  f41b		       ea		      nop
     19  f41c					      REPEND
     14  f41c
     15  f41c		       a9 60		      lda	#EMR1
     16  f41e		       a2 06		      ldx	#EMR2
     17  f420		       a0 66		      ldy	#EMR3
     18  f422		       84 1c		      .byte.b	GEM_00, EMERALD_SP
     19  f424
     20  f424
     21  f424		       85 11		      sta	EMERALD_SP_RESET
      0  f426					      sleep	6
      1  f426				   .CYCLES    SET	6
      2  f426
      3  f426				  -	      IF	.CYCLES < 2
      4  f426				  -	      ECHO	"MACRO ERROR: 'SLEEP': Duration must be > 1"
      5  f426				  -	      ERR
      6  f426					      ENDIF
      7  f426
      8  f426				  -	      IF	.CYCLES & 1
      9  f426				  -	      IFNCONST	NO_ILLEGAL_OPCODES
     10  f426				  -	      nop	0
     11  f426				  -	      ELSE
     12  f426				  -	      bit	VSYNC
     13  f426				  -	      ENDIF
     14  f426				  -.CYCLES    SET	.CYCLES - 3
     15  f426					      ENDIF
     16  f426
     17  f426					      REPEAT	.CYCLES / 2
     18  f426		       ea		      nop
     17  f426					      REPEND
     18  f427		       ea		      nop
     17  f427					      REPEND
     18  f428		       ea		      nop
     19  f429					      REPEND
     23  f429		       84 1c		      .byte.b	GEM_04, EMERALD_SP
     24  f42b		       85 11		      sta	EMERALD_SP_RESET
     25  f42d		       84 1c		      .byte.b	GEM_09, EMERALD_SP
      0  f42f					      sleep	3
      1  f42f				   .CYCLES    SET	3
      2  f42f
      3  f42f				  -	      IF	.CYCLES < 2
      4  f42f				  -	      ECHO	"MACRO ERROR: 'SLEEP': Duration must be > 1"
      5  f42f				  -	      ERR
      6  f42f					      ENDIF
      7  f42f
      8  f42f					      IF	.CYCLES & 1
      9  f42f					      IFNCONST	NO_ILLEGAL_OPCODES
     10  f42f		       04 00		      nop	0
     11  f431				  -	      ELSE
     12  f431				  -	      bit	VSYNC
     13  f431					      ENDIF
     14  f431				   .CYCLES    SET	.CYCLES - 3
     15  f431					      ENDIF
     16  f431
     17  f431				  -	      REPEAT	.CYCLES / 2
     18  f431				  -	      nop
     19  f431					      REPEND
     27  f431		       84 1c		      .byte.b	GEM_13, EMERALD_SP
     28  f433		       85 11		      sta	EMERALD_SP_RESET
     29  f435		       84 1e		      .byte.b	GEM_17, EMERALD_MI_ENABLE
     30  f437		       84 1c		      .byte.b	GEM_18, EMERALD_SP
     31  f439		       85 2b		      sta	HMCLR
     32  f43b		       84 1c		      .byte.b	GEM_22, EMERALD_SP
     33  f43d		       85 1e		      .byte.b	GEM_08, EMERALD_MI_ENABLE
     34  f43f
     35  f43f
      0  f43f					      sleep	12
      1  f43f				   .CYCLES    SET	12
      2  f43f
      3  f43f				  -	      IF	.CYCLES < 2
      4  f43f				  -	      ECHO	"MACRO ERROR: 'SLEEP': Duration must be > 1"
      5  f43f				  -	      ERR
      6  f43f					      ENDIF
      7  f43f
      8  f43f				  -	      IF	.CYCLES & 1
      9  f43f				  -	      IFNCONST	NO_ILLEGAL_OPCODES
     10  f43f				  -	      nop	0
     11  f43f				  -	      ELSE
     12  f43f				  -	      bit	VSYNC
     13  f43f				  -	      ENDIF
     14  f43f				  -.CYCLES    SET	.CYCLES - 3
     15  f43f					      ENDIF
     16  f43f
     17  f43f					      REPEAT	.CYCLES / 2
     18  f43f		       ea		      nop
     17  f43f					      REPEND
     18  f440		       ea		      nop
     17  f440					      REPEND
     18  f441		       ea		      nop
     17  f441					      REPEND
     18  f442		       ea		      nop
     17  f442					      REPEND
     18  f443		       ea		      nop
     17  f443					      REPEND
     18  f444		       ea		      nop
     19  f445					      REPEND
     37  f445				   endwow
      0  f445					      Frame1Line
      1  f445
      2  f445				   wow	      rorg	$1100
      3  f445
      4  f445
      5  f445
      6  f445
      7  f445
      8  f445
      9  f445
     10  f445		       85 2a		      sta	HMOVE
     11  f447
     12  f447		       c6 85		      dec	SpriteEnd
      0  f449					      sleep	5
      1  f449				   .CYCLES    SET	5
      2  f449
      3  f449				  -	      IF	.CYCLES < 2
      4  f449				  -	      ECHO	"MACRO ERROR: 'SLEEP': Duration must be > 1"
      5  f449				  -	      ERR
      6  f449					      ENDIF
      7  f449
      8  f449					      IF	.CYCLES & 1
      9  f449					      IFNCONST	NO_ILLEGAL_OPCODES
     10  f449		       04 00		      nop	0
     11  f44b				  -	      ELSE
     12  f44b				  -	      bit	VSYNC
     13  f44b					      ENDIF
     14  f44b				   .CYCLES    SET	.CYCLES - 3
     15  f44b					      ENDIF
     16  f44b
     17  f44b					      REPEAT	.CYCLES / 2
     18  f44b		       ea		      nop
     19  f44c					      REPEND
     14  f44c
     15  f44c		       a9 60		      lda	#EMR1
     16  f44e		       a2 06		      ldx	#EMR2
     17  f450		       a0 66		      ldy	#EMR3
     18  f452		       84 1c		      .byte.b	GEM_00, EMERALD_SP
     19  f454
     20  f454
     21  f454		       85 11		      sta	EMERALD_SP_RESET
      0  f456					      sleep	6
      1  f456				   .CYCLES    SET	6
      2  f456
      3  f456				  -	      IF	.CYCLES < 2
      4  f456				  -	      ECHO	"MACRO ERROR: 'SLEEP': Duration must be > 1"
      5  f456				  -	      ERR
      6  f456					      ENDIF
      7  f456
      8  f456				  -	      IF	.CYCLES & 1
      9  f456				  -	      IFNCONST	NO_ILLEGAL_OPCODES
     10  f456				  -	      nop	0
     11  f456				  -	      ELSE
     12  f456				  -	      bit	VSYNC
     13  f456				  -	      ENDIF
     14  f456				  -.CYCLES    SET	.CYCLES - 3
     15  f456					      ENDIF
     16  f456
     17  f456					      REPEAT	.CYCLES / 2
     18  f456		       ea		      nop
     17  f456					      REPEND
     18  f457		       ea		      nop
     17  f457					      REPEND
     18  f458		       ea		      nop
     19  f459					      REPEND
     23  f459		       84 1c		      .byte.b	GEM_04, EMERALD_SP
     24  f45b		       85 11		      sta	EMERALD_SP_RESET
     25  f45d		       84 1c		      .byte.b	GEM_09, EMERALD_SP
      0  f45f					      sleep	3
      1  f45f				   .CYCLES    SET	3
      2  f45f
      3  f45f				  -	      IF	.CYCLES < 2
      4  f45f				  -	      ECHO	"MACRO ERROR: 'SLEEP': Duration must be > 1"
      5  f45f				  -	      ERR
      6  f45f					      ENDIF
      7  f45f
      8  f45f					      IF	.CYCLES & 1
      9  f45f					      IFNCONST	NO_ILLEGAL_OPCODES
     10  f45f		       04 00		      nop	0
     11  f461				  -	      ELSE
     12  f461				  -	      bit	VSYNC
     13  f461					      ENDIF
     14  f461				   .CYCLES    SET	.CYCLES - 3
     15  f461					      ENDIF
     16  f461
     17  f461				  -	      REPEAT	.CYCLES / 2
     18  f461				  -	      nop
     19  f461					      REPEND
     27  f461		       84 1c		      .byte.b	GEM_13, EMERALD_SP
     28  f463		       85 11		      sta	EMERALD_SP_RESET
     29  f465		       84 1e		      .byte.b	GEM_17, EMERALD_MI_ENABLE
     30  f467		       84 1c		      .byte.b	GEM_18, EMERALD_SP
     31  f469		       85 2b		      sta	HMCLR
     32  f46b		       84 1c		      .byte.b	GEM_22, EMERALD_SP
     33  f46d		       85 1e		      .byte.b	GEM_08, EMERALD_MI_ENABLE
     34  f46f
     35  f46f
      0  f46f					      sleep	12
      1  f46f				   .CYCLES    SET	12
      2  f46f
      3  f46f				  -	      IF	.CYCLES < 2
      4  f46f				  -	      ECHO	"MACRO ERROR: 'SLEEP': Duration must be > 1"
      5  f46f				  -	      ERR
      6  f46f					      ENDIF
      7  f46f
      8  f46f				  -	      IF	.CYCLES & 1
      9  f46f				  -	      IFNCONST	NO_ILLEGAL_OPCODES
     10  f46f				  -	      nop	0
     11  f46f				  -	      ELSE
     12  f46f				  -	      bit	VSYNC
     13  f46f				  -	      ENDIF
     14  f46f				  -.CYCLES    SET	.CYCLES - 3
     15  f46f					      ENDIF
     16  f46f
     17  f46f					      REPEAT	.CYCLES / 2
     18  f46f		       ea		      nop
     17  f46f					      REPEND
     18  f470		       ea		      nop
     17  f470					      REPEND
     18  f471		       ea		      nop
     17  f471					      REPEND
     18  f472		       ea		      nop
     17  f472					      REPEND
     18  f473		       ea		      nop
     17  f473					      REPEND
     18  f474		       ea		      nop
     19  f475					      REPEND
     37  f475				   endwow
    612  f475		       4c 42 f3 	      jmp	frame_row_start
    613  f478				   frame_1_end
    614  f478
    615  f478							;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    616  f478
    617  f478							; FRAME 2
    618  f478
    619  f478							; Emerald line macro
    620  f478					      MAC	frame2line
    621  f478
    622  f478							; Start new line + HMOVE
    623  f478					      sta	HMOVE
    624  f478
    625  f478							; Enable missile (using excessive lda instructions)
    626  f478					      lda	#02
    627  f478					      .byte	GEM_08, EMERALD_MI_ENABLE
    628  f478
    629  f478					      dec	SpriteEnd
    630  f478					      sleep	5
    631  f478							; ldy SpriteEnd
    632  f478							; lda Frame0,Y
    633  f478							; sta JET_SP
    634  f478
    635  f478							; moved: lda #T1
    636  f478					      ldx	#T2
    637  f478					      ldy	#T3
    638  f478					      .byte	GEM_02, EMERALD_SP
    639  f478
    640  f478							; cycle 25
    641  f478					      sta	EMERALD_SP_RESET
    642  f478					      lda	#T1	; movable
    643  f478					      sleep	4
    644  f478					      .byte	GEM_06, EMERALD_SP
    645  f478					      sta	EMERALD_SP_RESET
    646  f478					      .byte	GEM_11, EMERALD_SP
    647  f478							; stx EMERALD_MI_ENABLE ; stx disables it
    648  f478					      sleep	3
    649  f478					      .byte	GEM_15, EMERALD_SP
    650  f478					      sta	EMERALD_SP_RESET
    651  f478					      .byte	GEM_20, EMERALD_SP
    652  f478					      .byte	GEM_24, EMERALD_SP
    653  f478					      sta	HMCLR	; movable
    654  f478					      sleep	3
    655  f478
    656  f478							; cycle 64 (start of right border)
    657  f478					      sleep	12
    658  f478					      ENDM
    659  f478
    660  f478				   frame_2_start
    661  f478		       85 02		      sta	WSYNC
      0  f47a					      Frame2Line
      1  f47a
      2  f47a
      3  f47a		       85 2a		      sta	HMOVE
      4  f47c
      5  f47c
      6  f47c		       a9 02		      lda	#02
      7  f47e		       85 1e		      .byte.b	GEM_08, EMERALD_MI_ENABLE
      8  f480
      9  f480		       c6 85		      dec	SpriteEnd
      0  f482					      sleep	5
      1  f482				   .CYCLES    SET	5
      2  f482
      3  f482				  -	      IF	.CYCLES < 2
      4  f482				  -	      ECHO	"MACRO ERROR: 'SLEEP': Duration must be > 1"
      5  f482				  -	      ERR
      6  f482					      ENDIF
      7  f482
      8  f482					      IF	.CYCLES & 1
      9  f482					      IFNCONST	NO_ILLEGAL_OPCODES
     10  f482		       04 00		      nop	0
     11  f484				  -	      ELSE
     12  f484				  -	      bit	VSYNC
     13  f484					      ENDIF
     14  f484				   .CYCLES    SET	.CYCLES - 3
     15  f484					      ENDIF
     16  f484
     17  f484					      REPEAT	.CYCLES / 2
     18  f484		       ea		      nop
     19  f485					      REPEND
     11  f485
     12  f485
     13  f485
     14  f485
     15  f485
     16  f485		       a2 0c		      ldx	#T2
     17  f487		       a0 cc		      ldy	#T3
     18  f489		       84 1c		      .byte.b	GEM_02, EMERALD_SP
     19  f48b
     20  f48b
     21  f48b		       85 11		      sta	EMERALD_SP_RESET
     22  f48d		       a9 c0		      lda	#T1
      0  f48f					      sleep	4
      1  f48f				   .CYCLES    SET	4
      2  f48f
      3  f48f				  -	      IF	.CYCLES < 2
      4  f48f				  -	      ECHO	"MACRO ERROR: 'SLEEP': Duration must be > 1"
      5  f48f				  -	      ERR
      6  f48f					      ENDIF
      7  f48f
      8  f48f				  -	      IF	.CYCLES & 1
      9  f48f				  -	      IFNCONST	NO_ILLEGAL_OPCODES
     10  f48f				  -	      nop	0
     11  f48f				  -	      ELSE
     12  f48f				  -	      bit	VSYNC
     13  f48f				  -	      ENDIF
     14  f48f				  -.CYCLES    SET	.CYCLES - 3
     15  f48f					      ENDIF
     16  f48f
     17  f48f					      REPEAT	.CYCLES / 2
     18  f48f		       ea		      nop
     17  f48f					      REPEND
     18  f490		       ea		      nop
     19  f491					      REPEND
     24  f491		       84 1c		      .byte.b	GEM_06, EMERALD_SP
     25  f493		       85 11		      sta	EMERALD_SP_RESET
     26  f495		       84 1c		      .byte.b	GEM_11, EMERALD_SP
     27  f497
      0  f497					      sleep	3
      1  f497				   .CYCLES    SET	3
      2  f497
      3  f497				  -	      IF	.CYCLES < 2
      4  f497				  -	      ECHO	"MACRO ERROR: 'SLEEP': Duration must be > 1"
      5  f497				  -	      ERR
      6  f497					      ENDIF
      7  f497
      8  f497					      IF	.CYCLES & 1
      9  f497					      IFNCONST	NO_ILLEGAL_OPCODES
     10  f497		       04 00		      nop	0
     11  f499				  -	      ELSE
     12  f499				  -	      bit	VSYNC
     13  f499					      ENDIF
     14  f499				   .CYCLES    SET	.CYCLES - 3
     15  f499					      ENDIF
     16  f499
     17  f499				  -	      REPEAT	.CYCLES / 2
     18  f499				  -	      nop
     19  f499					      REPEND
     29  f499		       84 1c		      .byte.b	GEM_15, EMERALD_SP
     30  f49b		       85 11		      sta	EMERALD_SP_RESET
     31  f49d		       84 1c		      .byte.b	GEM_20, EMERALD_SP
     32  f49f		       84 1c		      .byte.b	GEM_24, EMERALD_SP
     33  f4a1		       85 2b		      sta	HMCLR
      0  f4a3					      sleep	3
      1  f4a3				   .CYCLES    SET	3
      2  f4a3
      3  f4a3				  -	      IF	.CYCLES < 2
      4  f4a3				  -	      ECHO	"MACRO ERROR: 'SLEEP': Duration must be > 1"
      5  f4a3				  -	      ERR
      6  f4a3					      ENDIF
      7  f4a3
      8  f4a3					      IF	.CYCLES & 1
      9  f4a3					      IFNCONST	NO_ILLEGAL_OPCODES
     10  f4a3		       04 00		      nop	0
     11  f4a5				  -	      ELSE
     12  f4a5				  -	      bit	VSYNC
     13  f4a5					      ENDIF
     14  f4a5				   .CYCLES    SET	.CYCLES - 3
     15  f4a5					      ENDIF
     16  f4a5
     17  f4a5				  -	      REPEAT	.CYCLES / 2
     18  f4a5				  -	      nop
     19  f4a5					      REPEND
     35  f4a5
     36  f4a5
      0  f4a5					      sleep	12
      1  f4a5				   .CYCLES    SET	12
      2  f4a5
      3  f4a5				  -	      IF	.CYCLES < 2
      4  f4a5				  -	      ECHO	"MACRO ERROR: 'SLEEP': Duration must be > 1"
      5  f4a5				  -	      ERR
      6  f4a5					      ENDIF
      7  f4a5
      8  f4a5				  -	      IF	.CYCLES & 1
      9  f4a5				  -	      IFNCONST	NO_ILLEGAL_OPCODES
     10  f4a5				  -	      nop	0
     11  f4a5				  -	      ELSE
     12  f4a5				  -	      bit	VSYNC
     13  f4a5				  -	      ENDIF
     14  f4a5				  -.CYCLES    SET	.CYCLES - 3
     15  f4a5					      ENDIF
     16  f4a5
     17  f4a5					      REPEAT	.CYCLES / 2
     18  f4a5		       ea		      nop
     17  f4a5					      REPEND
     18  f4a6		       ea		      nop
     17  f4a6					      REPEND
     18  f4a7		       ea		      nop
     17  f4a7					      REPEND
     18  f4a8		       ea		      nop
     17  f4a8					      REPEND
     18  f4a9		       ea		      nop
     17  f4a9					      REPEND
     18  f4aa		       ea		      nop
     19  f4ab					      REPEND
      0  f4ab					      Frame2Line
      1  f4ab
      2  f4ab
      3  f4ab		       85 2a		      sta	HMOVE
      4  f4ad
      5  f4ad
      6  f4ad		       a9 02		      lda	#02
      7  f4af		       85 1e		      .byte.b	GEM_08, EMERALD_MI_ENABLE
      8  f4b1
      9  f4b1		       c6 85		      dec	SpriteEnd
      0  f4b3					      sleep	5
      1  f4b3				   .CYCLES    SET	5
      2  f4b3
      3  f4b3				  -	      IF	.CYCLES < 2
      4  f4b3				  -	      ECHO	"MACRO ERROR: 'SLEEP': Duration must be > 1"
      5  f4b3				  -	      ERR
      6  f4b3					      ENDIF
      7  f4b3
      8  f4b3					      IF	.CYCLES & 1
      9  f4b3					      IFNCONST	NO_ILLEGAL_OPCODES
     10  f4b3		       04 00		      nop	0
     11  f4b5				  -	      ELSE
     12  f4b5				  -	      bit	VSYNC
     13  f4b5					      ENDIF
     14  f4b5				   .CYCLES    SET	.CYCLES - 3
     15  f4b5					      ENDIF
     16  f4b5
     17  f4b5					      REPEAT	.CYCLES / 2
     18  f4b5		       ea		      nop
     19  f4b6					      REPEND
     11  f4b6
     12  f4b6
     13  f4b6
     14  f4b6
     15  f4b6
     16  f4b6		       a2 0c		      ldx	#T2
     17  f4b8		       a0 cc		      ldy	#T3
     18  f4ba		       84 1c		      .byte.b	GEM_02, EMERALD_SP
     19  f4bc
     20  f4bc
     21  f4bc		       85 11		      sta	EMERALD_SP_RESET
     22  f4be		       a9 c0		      lda	#T1
      0  f4c0					      sleep	4
      1  f4c0				   .CYCLES    SET	4
      2  f4c0
      3  f4c0				  -	      IF	.CYCLES < 2
      4  f4c0				  -	      ECHO	"MACRO ERROR: 'SLEEP': Duration must be > 1"
      5  f4c0				  -	      ERR
      6  f4c0					      ENDIF
      7  f4c0
      8  f4c0				  -	      IF	.CYCLES & 1
      9  f4c0				  -	      IFNCONST	NO_ILLEGAL_OPCODES
     10  f4c0				  -	      nop	0
     11  f4c0				  -	      ELSE
     12  f4c0				  -	      bit	VSYNC
     13  f4c0				  -	      ENDIF
     14  f4c0				  -.CYCLES    SET	.CYCLES - 3
     15  f4c0					      ENDIF
     16  f4c0
     17  f4c0					      REPEAT	.CYCLES / 2
     18  f4c0		       ea		      nop
     17  f4c0					      REPEND
     18  f4c1		       ea		      nop
     19  f4c2					      REPEND
     24  f4c2		       84 1c		      .byte.b	GEM_06, EMERALD_SP
     25  f4c4		       85 11		      sta	EMERALD_SP_RESET
     26  f4c6		       84 1c		      .byte.b	GEM_11, EMERALD_SP
     27  f4c8
      0  f4c8					      sleep	3
      1  f4c8				   .CYCLES    SET	3
      2  f4c8
      3  f4c8				  -	      IF	.CYCLES < 2
      4  f4c8				  -	      ECHO	"MACRO ERROR: 'SLEEP': Duration must be > 1"
      5  f4c8				  -	      ERR
      6  f4c8					      ENDIF
      7  f4c8
      8  f4c8					      IF	.CYCLES & 1
      9  f4c8					      IFNCONST	NO_ILLEGAL_OPCODES
     10  f4c8		       04 00		      nop	0
     11  f4ca				  -	      ELSE
     12  f4ca				  -	      bit	VSYNC
     13  f4ca					      ENDIF
     14  f4ca				   .CYCLES    SET	.CYCLES - 3
     15  f4ca					      ENDIF
     16  f4ca
     17  f4ca				  -	      REPEAT	.CYCLES / 2
     18  f4ca				  -	      nop
     19  f4ca					      REPEND
     29  f4ca		       84 1c		      .byte.b	GEM_15, EMERALD_SP
     30  f4cc		       85 11		      sta	EMERALD_SP_RESET
     31  f4ce		       84 1c		      .byte.b	GEM_20, EMERALD_SP
     32  f4d0		       84 1c		      .byte.b	GEM_24, EMERALD_SP
     33  f4d2		       85 2b		      sta	HMCLR
      0  f4d4					      sleep	3
      1  f4d4				   .CYCLES    SET	3
      2  f4d4
      3  f4d4				  -	      IF	.CYCLES < 2
      4  f4d4				  -	      ECHO	"MACRO ERROR: 'SLEEP': Duration must be > 1"
      5  f4d4				  -	      ERR
      6  f4d4					      ENDIF
      7  f4d4
      8  f4d4					      IF	.CYCLES & 1
      9  f4d4					      IFNCONST	NO_ILLEGAL_OPCODES
     10  f4d4		       04 00		      nop	0
     11  f4d6				  -	      ELSE
     12  f4d6				  -	      bit	VSYNC
     13  f4d6					      ENDIF
     14  f4d6				   .CYCLES    SET	.CYCLES - 3
     15  f4d6					      ENDIF
     16  f4d6
     17  f4d6				  -	      REPEAT	.CYCLES / 2
     18  f4d6				  -	      nop
     19  f4d6					      REPEND
     35  f4d6
     36  f4d6
      0  f4d6					      sleep	12
      1  f4d6				   .CYCLES    SET	12
      2  f4d6
      3  f4d6				  -	      IF	.CYCLES < 2
      4  f4d6				  -	      ECHO	"MACRO ERROR: 'SLEEP': Duration must be > 1"
      5  f4d6				  -	      ERR
      6  f4d6					      ENDIF
      7  f4d6
      8  f4d6				  -	      IF	.CYCLES & 1
      9  f4d6				  -	      IFNCONST	NO_ILLEGAL_OPCODES
     10  f4d6				  -	      nop	0
     11  f4d6				  -	      ELSE
     12  f4d6				  -	      bit	VSYNC
     13  f4d6				  -	      ENDIF
     14  f4d6				  -.CYCLES    SET	.CYCLES - 3
     15  f4d6					      ENDIF
     16  f4d6
     17  f4d6					      REPEAT	.CYCLES / 2
     18  f4d6		       ea		      nop
     17  f4d6					      REPEND
     18  f4d7		       ea		      nop
     17  f4d7					      REPEND
     18  f4d8		       ea		      nop
     17  f4d8					      REPEND
     18  f4d9		       ea		      nop
     17  f4d9					      REPEND
     18  f4da		       ea		      nop
     17  f4da					      REPEND
     18  f4db		       ea		      nop
     19  f4dc					      REPEND
    664  f4dc		       4c 42 f3 	      jmp	frame_row_start
    665  f4df				   frame_2_end
    666  f4df
    667  f4df							;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    668  f4df
    669  f4df							; SUBROUTINE
    670  f4df							; Read joystick movement and apply to object 0
    671  f4df				   MoveJoystick
    672  f4df							; Move vertically
    673  f4df							; (up and down are actually reversed since ypos starts at bottom)
    674  f4df							;     ldx YPos
    675  f4df		       a9 10		      lda	#%00010000	;Up?
    676  f4e1		       2c 80 02 	      bit	SWCHA
    677  f4e4		       d0 0d		      bne	SkipMoveUp
    678  f4e6
    679  f4e6		       18		      clc
    680  f4e7		       a5 88		      lda	Speed2
    681  f4e9		       69 0c		      adc	#12
    682  f4eb		       85 88		      sta	Speed2
    683  f4ed		       a5 87		      lda	Speed1
    684  f4ef		       69 00		      adc	#00
    685  f4f1		       85 87		      sta	Speed1
    686  f4f3
    687  f4f3				   SkipMoveUp
    688  f4f3		       a6 86		      ldx	XPos
    689  f4f5
    690  f4f5							; Only check left/right on odd frames;
    691  f4f5							; TODO make this just a fractional speed
    692  f4f5							; rather than dropping frames
    693  f4f5		       a9 01		      lda	#01
    694  f4f7		       25 83		      and	FrameCount
    695  f4f9		       d0 18		      bne	SkipMoveRight
    696  f4fb
    697  f4fb
    698  f4fb							; Move horizontally
    699  f4fb		       a9 40		      lda	#%01000000	;Left?
    700  f4fd		       2c 80 02 	      bit	SWCHA
    701  f500		       d0 05		      bne	SkipMoveLeft
    702  f502		       e0 1d		      cpx	#29
    703  f504		       90 01		      bcc	SkipMoveLeft
    704  f506		       ca		      dex
    705  f507
    706  f507							; Reflect
    707  f507							;     lda #$ff
    708  f507							;     sta REFP0
    709  f507				   SkipMoveLeft
    710  f507		       a9 80		      lda	#%10000000	;Right?
    711  f509		       2c 80 02 	      bit	SWCHA
    712  f50c		       d0 05		      bne	SkipMoveRight
    713  f50e		       e0 80		      cpx	#128
    714  f510		       b0 01		      bcs	SkipMoveRight
    715  f512		       e8		      inx
    716  f513
    717  f513							; Reflect
    718  f513							;     lda #$0
    719  f513							;     sta REFP0
    720  f513				   SkipMoveRight
    721  f513		       86 86		      stx	XPos
    722  f515		       60		      rts
    723  f516
    724  f516
    725  f516							;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    726  f516
    727  f516
    728  f516				   SpeedCalculation
    729  f516		       38		      sec
    730  f517		       a5 88		      lda	Speed2
    731  f519		       e9 07		      sbc	#7
    732  f51b		       85 88		      sta	Speed2
    733  f51d		       a5 87		      lda	Speed1
    734  f51f		       e9 00		      sbc	#0
    735  f521		       85 87		      sta	Speed1
    736  f523
    737  f523		       18		      clc
    738  f524		       a5 8a		      lda	YPos2
    739  f526		       65 88		      adc	Speed2
    740  f528		       85 8a		      sta	YPos2
    741  f52a		       a5 89		      lda	YPos
    742  f52c		       65 87		      adc	Speed1
    743  f52e		       85 89		      sta	YPos
    744  f530
    745  f530		       c9 32		      cmp	#FLOOR_OFFSET
    746  f532		       b0 0a		      bcs	NewThing2
    747  f534
    748  f534							; Reset everything?
    749  f534		       a9 32		      lda	#FLOOR_OFFSET
    750  f536		       85 89		      sta	YPos
    751  f538		       a9 00		      lda	#0
    752  f53a		       85 87		      sta	Speed1
    753  f53c		       85 88		      sta	Speed2
    754  f53e				   NewThing2
    755  f53e		       60		      rts
    756  f53f
    757  f53f
    758  f53f
    759  f53f							; Subroutine
    760  f53f				   SetHorizPos
    761  f53f		       85 02		      sta	WSYNC	; start a new line
    762  f541		       24 00		      bit	0	; waste 3 cycles
    763  f543		       38		      sec		; set carry flag
    764  f544				   DivideLoop
    765  f544		       e9 0f		      sbc	#15	; subtract 15
    766  f546		       b0 fc		      bcs	DivideLoop	; branch until negative
    767  f548		       49 07		      eor	#7	; calculate fine offset
    768  f54a		       0a		      asl
    769  f54b		       0a		      asl
    770  f54c		       0a		      asl
    771  f54d		       0a		      asl
    772  f54e		       95 10		      sta	JET_SP_RESET,x	; fix coarse position
    773  f550		       95 20		      sta	JET_SP_HMOVE,x	; set fine offset
    774  f552		       60		      rts		; return to caller
    775  f553
    776  f553
    777  f553
    778  f645		       00 00 00 00*	      align	256
    779  f645
    780  f645							; Bitmap data for character "standing" position
    781  f645							; Comical amount of 0's for now to simplify sprite rendering
    782  f645
    783  f645							; Y can be from:
    784  f645							;     SPRITE_HEIGHT to (8*ROW_COUNT)
    785  f645							; SpriteEnd: 8..128
    786  f645							; Frame0 should start at +120 so the Y rollunder of -$120 is OK
    787  f645					      REPEAT	124
    788  f645		       00		      .byte.b	0
    787  f645					      REPEND
    788  f646		       00		      .byte.b	0
    787  f646					      REPEND
    788  f647		       00		      .byte.b	0
    787  f647					      REPEND
    788  f648		       00		      .byte.b	0
    787  f648					      REPEND
    788  f649		       00		      .byte.b	0
    787  f649					      REPEND
    788  f64a		       00		      .byte.b	0
    787  f64a					      REPEND
    788  f64b		       00		      .byte.b	0
    787  f64b					      REPEND
    788  f64c		       00		      .byte.b	0
    787  f64c					      REPEND
    788  f64d		       00		      .byte.b	0
    787  f64d					      REPEND
    788  f64e		       00		      .byte.b	0
    787  f64e					      REPEND
    788  f64f		       00		      .byte.b	0
    787  f64f					      REPEND
    788  f650		       00		      .byte.b	0
    787  f650					      REPEND
    788  f651		       00		      .byte.b	0
    787  f651					      REPEND
    788  f652		       00		      .byte.b	0
    787  f652					      REPEND
    788  f653		       00		      .byte.b	0
    787  f653					      REPEND
    788  f654		       00		      .byte.b	0
    787  f654					      REPEND
    788  f655		       00		      .byte.b	0
    787  f655					      REPEND
    788  f656		       00		      .byte.b	0
    787  f656					      REPEND
    788  f657		       00		      .byte.b	0
    787  f657					      REPEND
    788  f658		       00		      .byte.b	0
    787  f658					      REPEND
    788  f659		       00		      .byte.b	0
    787  f659					      REPEND
    788  f65a		       00		      .byte.b	0
    787  f65a					      REPEND
    788  f65b		       00		      .byte.b	0
    787  f65b					      REPEND
    788  f65c		       00		      .byte.b	0
    787  f65c					      REPEND
    788  f65d		       00		      .byte.b	0
    787  f65d					      REPEND
    788  f65e		       00		      .byte.b	0
    787  f65e					      REPEND
    788  f65f		       00		      .byte.b	0
    787  f65f					      REPEND
    788  f660		       00		      .byte.b	0
    787  f660					      REPEND
    788  f661		       00		      .byte.b	0
    787  f661					      REPEND
    788  f662		       00		      .byte.b	0
    787  f662					      REPEND
    788  f663		       00		      .byte.b	0
    787  f663					      REPEND
    788  f664		       00		      .byte.b	0
    787  f664					      REPEND
    788  f665		       00		      .byte.b	0
    787  f665					      REPEND
    788  f666		       00		      .byte.b	0
    787  f666					      REPEND
    788  f667		       00		      .byte.b	0
    787  f667					      REPEND
    788  f668		       00		      .byte.b	0
    787  f668					      REPEND
    788  f669		       00		      .byte.b	0
    787  f669					      REPEND
    788  f66a		       00		      .byte.b	0
    787  f66a					      REPEND
    788  f66b		       00		      .byte.b	0
    787  f66b					      REPEND
    788  f66c		       00		      .byte.b	0
    787  f66c					      REPEND
    788  f66d		       00		      .byte.b	0
    787  f66d					      REPEND
    788  f66e		       00		      .byte.b	0
    787  f66e					      REPEND
    788  f66f		       00		      .byte.b	0
    787  f66f					      REPEND
    788  f670		       00		      .byte.b	0
    787  f670					      REPEND
    788  f671		       00		      .byte.b	0
    787  f671					      REPEND
    788  f672		       00		      .byte.b	0
    787  f672					      REPEND
    788  f673		       00		      .byte.b	0
    787  f673					      REPEND
    788  f674		       00		      .byte.b	0
    787  f674					      REPEND
    788  f675		       00		      .byte.b	0
    787  f675					      REPEND
    788  f676		       00		      .byte.b	0
    787  f676					      REPEND
    788  f677		       00		      .byte.b	0
    787  f677					      REPEND
    788  f678		       00		      .byte.b	0
    787  f678					      REPEND
    788  f679		       00		      .byte.b	0
    787  f679					      REPEND
    788  f67a		       00		      .byte.b	0
    787  f67a					      REPEND
    788  f67b		       00		      .byte.b	0
    787  f67b					      REPEND
    788  f67c		       00		      .byte.b	0
    787  f67c					      REPEND
    788  f67d		       00		      .byte.b	0
    787  f67d					      REPEND
    788  f67e		       00		      .byte.b	0
    787  f67e					      REPEND
    788  f67f		       00		      .byte.b	0
    787  f67f					      REPEND
    788  f680		       00		      .byte.b	0
    787  f680					      REPEND
    788  f681		       00		      .byte.b	0
    787  f681					      REPEND
    788  f682		       00		      .byte.b	0
    787  f682					      REPEND
    788  f683		       00		      .byte.b	0
    787  f683					      REPEND
    788  f684		       00		      .byte.b	0
    787  f684					      REPEND
    788  f685		       00		      .byte.b	0
    787  f685					      REPEND
    788  f686		       00		      .byte.b	0
    787  f686					      REPEND
    788  f687		       00		      .byte.b	0
    787  f687					      REPEND
    788  f688		       00		      .byte.b	0
    787  f688					      REPEND
    788  f689		       00		      .byte.b	0
    787  f689					      REPEND
    788  f68a		       00		      .byte.b	0
    787  f68a					      REPEND
    788  f68b		       00		      .byte.b	0
    787  f68b					      REPEND
    788  f68c		       00		      .byte.b	0
    787  f68c					      REPEND
    788  f68d		       00		      .byte.b	0
    787  f68d					      REPEND
    788  f68e		       00		      .byte.b	0
    787  f68e					      REPEND
    788  f68f		       00		      .byte.b	0
    787  f68f					      REPEND
    788  f690		       00		      .byte.b	0
    787  f690					      REPEND
    788  f691		       00		      .byte.b	0
    787  f691					      REPEND
    788  f692		       00		      .byte.b	0
    787  f692					      REPEND
    788  f693		       00		      .byte.b	0
    787  f693					      REPEND
    788  f694		       00		      .byte.b	0
    787  f694					      REPEND
    788  f695		       00		      .byte.b	0
    787  f695					      REPEND
    788  f696		       00		      .byte.b	0
    787  f696					      REPEND
    788  f697		       00		      .byte.b	0
    787  f697					      REPEND
    788  f698		       00		      .byte.b	0
    787  f698					      REPEND
    788  f699		       00		      .byte.b	0
    787  f699					      REPEND
    788  f69a		       00		      .byte.b	0
    787  f69a					      REPEND
    788  f69b		       00		      .byte.b	0
    787  f69b					      REPEND
    788  f69c		       00		      .byte.b	0
    787  f69c					      REPEND
    788  f69d		       00		      .byte.b	0
    787  f69d					      REPEND
    788  f69e		       00		      .byte.b	0
    787  f69e					      REPEND
    788  f69f		       00		      .byte.b	0
    787  f69f					      REPEND
    788  f6a0		       00		      .byte.b	0
    787  f6a0					      REPEND
    788  f6a1		       00		      .byte.b	0
    787  f6a1					      REPEND
    788  f6a2		       00		      .byte.b	0
    787  f6a2					      REPEND
    788  f6a3		       00		      .byte.b	0
    787  f6a3					      REPEND
    788  f6a4		       00		      .byte.b	0
    787  f6a4					      REPEND
    788  f6a5		       00		      .byte.b	0
    787  f6a5					      REPEND
    788  f6a6		       00		      .byte.b	0
    787  f6a6					      REPEND
    788  f6a7		       00		      .byte.b	0
    787  f6a7					      REPEND
    788  f6a8		       00		      .byte.b	0
    787  f6a8					      REPEND
    788  f6a9		       00		      .byte.b	0
    787  f6a9					      REPEND
    788  f6aa		       00		      .byte.b	0
    787  f6aa					      REPEND
    788  f6ab		       00		      .byte.b	0
    787  f6ab					      REPEND
    788  f6ac		       00		      .byte.b	0
    787  f6ac					      REPEND
    788  f6ad		       00		      .byte.b	0
    787  f6ad					      REPEND
    788  f6ae		       00		      .byte.b	0
    787  f6ae					      REPEND
    788  f6af		       00		      .byte.b	0
    787  f6af					      REPEND
    788  f6b0		       00		      .byte.b	0
    787  f6b0					      REPEND
    788  f6b1		       00		      .byte.b	0
    787  f6b1					      REPEND
    788  f6b2		       00		      .byte.b	0
    787  f6b2					      REPEND
    788  f6b3		       00		      .byte.b	0
    787  f6b3					      REPEND
    788  f6b4		       00		      .byte.b	0
    787  f6b4					      REPEND
    788  f6b5		       00		      .byte.b	0
    787  f6b5					      REPEND
    788  f6b6		       00		      .byte.b	0
    787  f6b6					      REPEND
    788  f6b7		       00		      .byte.b	0
    787  f6b7					      REPEND
    788  f6b8		       00		      .byte.b	0
    787  f6b8					      REPEND
    788  f6b9		       00		      .byte.b	0
    787  f6b9					      REPEND
    788  f6ba		       00		      .byte.b	0
    787  f6ba					      REPEND
    788  f6bb		       00		      .byte.b	0
    787  f6bb					      REPEND
    788  f6bc		       00		      .byte.b	0
    787  f6bc					      REPEND
    788  f6bd		       00		      .byte.b	0
    787  f6bd					      REPEND
    788  f6be		       00		      .byte.b	0
    787  f6be					      REPEND
    788  f6bf		       00		      .byte.b	0
    787  f6bf					      REPEND
    788  f6c0		       00		      .byte.b	0
    789  f6c1					      REPEND
    790  f6c1				   Frame0
    791  f6c1		       00		      .byte.b	#%00000000
    792  f6c2		       60		      .byte.b	#%01100000
    793  f6c3		       60		      .byte.b	#%01100000
    794  f6c4		       60		      .byte.b	#%01100000
    795  f6c5		       c0		      .byte.b	#%11000000
    796  f6c6		       c0		      .byte.b	#%11000000
    797  f6c7		       f0		      .byte.b	#%11110000
    798  f6c8		       c0		      .byte.b	#%11000000
    799  f6c9		       c0		      .byte.b	#%11000000
    800  f6ca		       00		      .byte.b	#%00000000
    801  f6cb					      REPEAT	124
    802  f6cb		       00		      .byte.b	0
    801  f6cb					      REPEND
    802  f6cc		       00		      .byte.b	0
    801  f6cc					      REPEND
    802  f6cd		       00		      .byte.b	0
    801  f6cd					      REPEND
    802  f6ce		       00		      .byte.b	0
    801  f6ce					      REPEND
    802  f6cf		       00		      .byte.b	0
    801  f6cf					      REPEND
    802  f6d0		       00		      .byte.b	0
    801  f6d0					      REPEND
    802  f6d1		       00		      .byte.b	0
    801  f6d1					      REPEND
    802  f6d2		       00		      .byte.b	0
    801  f6d2					      REPEND
    802  f6d3		       00		      .byte.b	0
    801  f6d3					      REPEND
    802  f6d4		       00		      .byte.b	0
    801  f6d4					      REPEND
    802  f6d5		       00		      .byte.b	0
    801  f6d5					      REPEND
    802  f6d6		       00		      .byte.b	0
    801  f6d6					      REPEND
    802  f6d7		       00		      .byte.b	0
    801  f6d7					      REPEND
    802  f6d8		       00		      .byte.b	0
    801  f6d8					      REPEND
    802  f6d9		       00		      .byte.b	0
    801  f6d9					      REPEND
    802  f6da		       00		      .byte.b	0
    801  f6da					      REPEND
    802  f6db		       00		      .byte.b	0
    801  f6db					      REPEND
    802  f6dc		       00		      .byte.b	0
    801  f6dc					      REPEND
    802  f6dd		       00		      .byte.b	0
    801  f6dd					      REPEND
    802  f6de		       00		      .byte.b	0
    801  f6de					      REPEND
    802  f6df		       00		      .byte.b	0
    801  f6df					      REPEND
    802  f6e0		       00		      .byte.b	0
    801  f6e0					      REPEND
    802  f6e1		       00		      .byte.b	0
    801  f6e1					      REPEND
    802  f6e2		       00		      .byte.b	0
    801  f6e2					      REPEND
    802  f6e3		       00		      .byte.b	0
    801  f6e3					      REPEND
    802  f6e4		       00		      .byte.b	0
    801  f6e4					      REPEND
    802  f6e5		       00		      .byte.b	0
    801  f6e5					      REPEND
    802  f6e6		       00		      .byte.b	0
    801  f6e6					      REPEND
    802  f6e7		       00		      .byte.b	0
    801  f6e7					      REPEND
    802  f6e8		       00		      .byte.b	0
    801  f6e8					      REPEND
    802  f6e9		       00		      .byte.b	0
    801  f6e9					      REPEND
    802  f6ea		       00		      .byte.b	0
    801  f6ea					      REPEND
    802  f6eb		       00		      .byte.b	0
    801  f6eb					      REPEND
    802  f6ec		       00		      .byte.b	0
    801  f6ec					      REPEND
    802  f6ed		       00		      .byte.b	0
    801  f6ed					      REPEND
    802  f6ee		       00		      .byte.b	0
    801  f6ee					      REPEND
    802  f6ef		       00		      .byte.b	0
    801  f6ef					      REPEND
    802  f6f0		       00		      .byte.b	0
    801  f6f0					      REPEND
    802  f6f1		       00		      .byte.b	0
    801  f6f1					      REPEND
    802  f6f2		       00		      .byte.b	0
    801  f6f2					      REPEND
    802  f6f3		       00		      .byte.b	0
    801  f6f3					      REPEND
    802  f6f4		       00		      .byte.b	0
    801  f6f4					      REPEND
    802  f6f5		       00		      .byte.b	0
    801  f6f5					      REPEND
    802  f6f6		       00		      .byte.b	0
    801  f6f6					      REPEND
    802  f6f7		       00		      .byte.b	0
    801  f6f7					      REPEND
    802  f6f8		       00		      .byte.b	0
    801  f6f8					      REPEND
    802  f6f9		       00		      .byte.b	0
    801  f6f9					      REPEND
    802  f6fa		       00		      .byte.b	0
    801  f6fa					      REPEND
    802  f6fb		       00		      .byte.b	0
    801  f6fb					      REPEND
    802  f6fc		       00		      .byte.b	0
    801  f6fc					      REPEND
    802  f6fd		       00		      .byte.b	0
    801  f6fd					      REPEND
    802  f6fe		       00		      .byte.b	0
    801  f6fe					      REPEND
    802  f6ff		       00		      .byte.b	0
    801  f6ff					      REPEND
    802  f700		       00		      .byte.b	0
    801  f700					      REPEND
    802  f701		       00		      .byte.b	0
    801  f701					      REPEND
    802  f702		       00		      .byte.b	0
    801  f702					      REPEND
    802  f703		       00		      .byte.b	0
    801  f703					      REPEND
    802  f704		       00		      .byte.b	0
    801  f704					      REPEND
    802  f705		       00		      .byte.b	0
    801  f705					      REPEND
    802  f706		       00		      .byte.b	0
    801  f706					      REPEND
    802  f707		       00		      .byte.b	0
    801  f707					      REPEND
    802  f708		       00		      .byte.b	0
    801  f708					      REPEND
    802  f709		       00		      .byte.b	0
    801  f709					      REPEND
    802  f70a		       00		      .byte.b	0
    801  f70a					      REPEND
    802  f70b		       00		      .byte.b	0
    801  f70b					      REPEND
    802  f70c		       00		      .byte.b	0
    801  f70c					      REPEND
    802  f70d		       00		      .byte.b	0
    801  f70d					      REPEND
    802  f70e		       00		      .byte.b	0
    801  f70e					      REPEND
    802  f70f		       00		      .byte.b	0
    801  f70f					      REPEND
    802  f710		       00		      .byte.b	0
    801  f710					      REPEND
    802  f711		       00		      .byte.b	0
    801  f711					      REPEND
    802  f712		       00		      .byte.b	0
    801  f712					      REPEND
    802  f713		       00		      .byte.b	0
    801  f713					      REPEND
    802  f714		       00		      .byte.b	0
    801  f714					      REPEND
    802  f715		       00		      .byte.b	0
    801  f715					      REPEND
    802  f716		       00		      .byte.b	0
    801  f716					      REPEND
    802  f717		       00		      .byte.b	0
    801  f717					      REPEND
    802  f718		       00		      .byte.b	0
    801  f718					      REPEND
    802  f719		       00		      .byte.b	0
    801  f719					      REPEND
    802  f71a		       00		      .byte.b	0
    801  f71a					      REPEND
    802  f71b		       00		      .byte.b	0
    801  f71b					      REPEND
    802  f71c		       00		      .byte.b	0
    801  f71c					      REPEND
    802  f71d		       00		      .byte.b	0
    801  f71d					      REPEND
    802  f71e		       00		      .byte.b	0
    801  f71e					      REPEND
    802  f71f		       00		      .byte.b	0
    801  f71f					      REPEND
    802  f720		       00		      .byte.b	0
    801  f720					      REPEND
    802  f721		       00		      .byte.b	0
    801  f721					      REPEND
    802  f722		       00		      .byte.b	0
    801  f722					      REPEND
    802  f723		       00		      .byte.b	0
    801  f723					      REPEND
    802  f724		       00		      .byte.b	0
    801  f724					      REPEND
    802  f725		       00		      .byte.b	0
    801  f725					      REPEND
    802  f726		       00		      .byte.b	0
    801  f726					      REPEND
    802  f727		       00		      .byte.b	0
    801  f727					      REPEND
    802  f728		       00		      .byte.b	0
    801  f728					      REPEND
    802  f729		       00		      .byte.b	0
    801  f729					      REPEND
    802  f72a		       00		      .byte.b	0
    801  f72a					      REPEND
    802  f72b		       00		      .byte.b	0
    801  f72b					      REPEND
    802  f72c		       00		      .byte.b	0
    801  f72c					      REPEND
    802  f72d		       00		      .byte.b	0
    801  f72d					      REPEND
    802  f72e		       00		      .byte.b	0
    801  f72e					      REPEND
    802  f72f		       00		      .byte.b	0
    801  f72f					      REPEND
    802  f730		       00		      .byte.b	0
    801  f730					      REPEND
    802  f731		       00		      .byte.b	0
    801  f731					      REPEND
    802  f732		       00		      .byte.b	0
    801  f732					      REPEND
    802  f733		       00		      .byte.b	0
    801  f733					      REPEND
    802  f734		       00		      .byte.b	0
    801  f734					      REPEND
    802  f735		       00		      .byte.b	0
    801  f735					      REPEND
    802  f736		       00		      .byte.b	0
    801  f736					      REPEND
    802  f737		       00		      .byte.b	0
    801  f737					      REPEND
    802  f738		       00		      .byte.b	0
    801  f738					      REPEND
    802  f739		       00		      .byte.b	0
    801  f739					      REPEND
    802  f73a		       00		      .byte.b	0
    801  f73a					      REPEND
    802  f73b		       00		      .byte.b	0
    801  f73b					      REPEND
    802  f73c		       00		      .byte.b	0
    801  f73c					      REPEND
    802  f73d		       00		      .byte.b	0
    801  f73d					      REPEND
    802  f73e		       00		      .byte.b	0
    801  f73e					      REPEND
    802  f73f		       00		      .byte.b	0
    801  f73f					      REPEND
    802  f740		       00		      .byte.b	0
    801  f740					      REPEND
    802  f741		       00		      .byte.b	0
    801  f741					      REPEND
    802  f742		       00		      .byte.b	0
    801  f742					      REPEND
    802  f743		       00		      .byte.b	0
    801  f743					      REPEND
    802  f744		       00		      .byte.b	0
    801  f744					      REPEND
    802  f745		       00		      .byte.b	0
    801  f745					      REPEND
    802  f746		       00		      .byte.b	0
    803  f747					      REPEND
    804  f747
    805  f747
    806  f747							; Epilogue
    807  fffc					      org	$fffc
    808  fffc		       00 f2		      .word.w	Start
    809  fffe		       00 f2		      .word.w	Start
