all:
	dasm jetpack.s -f3 -v5 -obin/jetpack.bin -lbin/jetpack.lst -sbin/jetpack.sym

play:
	stella  -bs FA bin/jetpack.bin -bs FA -center 0 -tv.phosphor always -tv.phosblend 50
