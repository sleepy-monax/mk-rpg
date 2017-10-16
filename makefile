rpg:
	gcc -o rpg src/main.c `sdl2-config --cflags --libs`

clean:
	rm rpg

run: clean rpg
	./rpg