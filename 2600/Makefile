all:
	cd src; dasm main.s -f3 -v5 -I../include -o../bin/jetpack.bin -l../bin/jetpack.lst -s../bin/jetpack.sym

play:
	stella  -bs FA bin/jetpack.bin -bs FA -center 0 -tv.phosphor always -tv.phosblend 50
