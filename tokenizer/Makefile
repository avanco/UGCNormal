
all: clean
	flex ./webtok.lex
	gcc ./lex.yy.c -o webtok

.PHONY:
clean:
	rm -f webtok lex.yy.c
