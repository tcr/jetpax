all:
	cd nibble; cargo run
	cd src; dasm main.s -f3 -v5 -I../include -o../bin/jetpack.bin -l../bin/jetpack.lst -s../bin/jetpack.sym
	python assertions.py

play:
	rm bin/jetpack.script
	# /Applications/Stella.app/Contents/MacOS/Stella
	stella \
		--args -bs FA bin/jetpack.bin -bs FA -center 0 -tv.phosphor always -tv.phosblend 40

debug: all
	if [[ $$STELLA_FG ]]; then ( sleep 0.4; osascript -e 'tell application "stella" to activate'; ) & fi
	# /Applications/Stella.app/Contents/MacOS/Stella
	stella \
		--args -debug -plr.debugcolors 0 -bs FA bin/jetpack.bin -bs FA -center 0 -tv.phosphor always -tv.phosblend 40 -sound 0
