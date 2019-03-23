all:
	cd src; dasm main.s -f3 -v5 -I../include -o../bin/jetpack.bin -l../bin/jetpack.lst -s../bin/jetpack.sym
	python assertions.py

play:
	rm bin/jetpack.script
	stella  -bs FA bin/jetpack.bin -bs FA -center 0 -tv.phosphor always -tv.phosblend 40

debug: all
	stella -debug -plr.debugcolors 1 -bs FA bin/jetpack.bin -bs FA -center 0 -tv.phosphor always -tv.phosblend 40
