```
echo 'turing(state(q0, Cpu), [g00,g11,g01,g11,g10,g00], Prog).' | swipl turing.pl
```

```
echo 'use_module(library(plunit)). load_test_files(turing). run_tests.' | swipl turing.pl
```

---

> solve for these 8
! \[\w+,bc_RST,bc_RF1         8V [g01,g00,g10,g11,g01 ... (truly unique, no VD0)...

> solve for the break at the beginning of this...
! \[\w+,\w+,bc_VD0           24V [g00,g00 ...

> solve for reflect
\[\w+,\w+,bc_RF1                    24 (16?)
    [_,g01,g10,g11,_,_
    [_,g10,g01,g11,_,_

    [g00,g01,g10,g11,g01
    [g00,g10,g01,g11,g10
    [g11,g01,g10,g11,g01
    [g11,g10,g01,g11,g10
    [g11,g10,g01,g11,g10
    [g11,g01,g10,g11,g01
    [g00,g10,g01,g11,g10
    [g00,g01,g10,g11,g01
\[\w+,\w+,\w+,bc_RF1                24
    [_,_,g01,g10,g11,_
    [_,_,g10,g01,g11,_

    [g00,g11,g01,g10,g11
    [g00,g11,g10,g01,g11
    [g11,g00,g01,g10,g11
    [g11,g00,g10,g01,g11
    [g01,g11,g10,g01,g11
    [g10,g11,g01,g10,g11
\[\w+,\w+,\w+,\w+,bc_RF1            24
    [_,_,g11,g01,g10,_
    [_,_,g11,g10,g01,_

    [g00,g01,g11,g10,g01
    [g00,g10,g11,g01,g10
    [g01,g00,g11,g10,g01
    [g01,g10,g11,g01,g10
    [g10,g00,g11,g01,g10
    [g10,g01,g11,g10,g01

> solve for reset (easy)
\[\w+,bc_RST,bc_VD1                 48
\[bc_VD1,bc_VD0,bc_RST             288 ; this is tricky one for the RESET class
\[bc_VD1,bc_VD0,\w+,bc_RST         384

>  solve for vdelay
\[\w+,bc_VD1                        96
\[\w+,\w+,bc_VD1                    96

; the 8 (special cases)
; the 24 (blank at beginning)
RF1 = <crit> ? : null.
RST = <crit> ? 1, 2, or 3 : null.
VD1 = (RF1 == 2 && RST == 1) ? null
    : RST == 1 ? 2 :
    : <crit> ? 2, 1
    : 0.






----


(replace with leading BRK)

\[\w+,\w+,\w+,bc_VD0
\[bc_STX,bc_STY,bc_VD1,bc_VD0   8  [g01,g11,g10,g11,g01 ... [g10,g11,g01,g11,g10 ...
\[bc_STX,bc_RST,bc_VD1,bc_VD0  16  [g01,g00,g01,g11,g10 ... [g10,g00,g10,g11,g01 ...
                                   [g11,g00,g01,g11,g10 ... [g11,g00,g10,g11,g01 ...
\[bc_NOP,bc_STX,bc_VD1,bc_VD0   8  [g00,g11,g10,g11,g01 ... [g00,g11,g01,g11,g10 ...
\[bc_STX,bc_STX,bc_VD1,bc_VD0   8  [g11,g11,g01,g11,g10 ... [g11,g11,g10,g11,g01 ...
    (but could be VD0=2 instead?)
(hardcode list?)

bc_RF1
\[\w+,bc_RST,bc_RF1         8      [g01,g00,g10,g11,g01,g00
(harcode list?)

bc_RF1
\[\w+,\w+,bc_RF1           24
\[\w+,\w+,\w+,bc_RF1       24
\[\w+,\w+,\w+,\w+,bc_RF1   24
TODO

bc_BLK
\[\w+,\w+,\w+,\w+,bc_RST  384
(first two blank, last two blank)

bc_RST
\[\w+,bc_RST               24
\[\w+,\w+,bc_RST          192
\[\w+,\w+,\w+,bc_RST      384
(black on 2, 3, or 4 but not BLK)

---

\[\w+,bc_VD1
4096

bc_P10
736

bc_P11
736