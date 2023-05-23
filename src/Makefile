all: practice
compiler.tab.c compiler.tab.h:	compiler.y
	bison -t -v -d compiler.y
lex.yy.c: compiler.lex compiler.tab.h
	flex compiler.lex
practice: lex.yy.c compiler.tab.c compiler.tab.h
	g++ -o practice compiler.tab.c lex.yy.c -lfl
clean:
	rm practice compiler.tab.c lex.yy.c compiler.tab.h compiler.output
