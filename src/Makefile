all: compiler
compiler.tab.c compiler.tab.h:	compiler.y
	bison -t -v -d compiler.y
lex.yy.c: compiler.lex compiler.tab.h
	flex compiler.lex
compiler: lex.yy.c compiler.tab.c compiler.tab.h
	g++ -o compiler compiler.tab.c lex.yy.c -lfl
clean:
	rm compiler compiler.tab.c lex.yy.c compiler.tab.h compiler.output