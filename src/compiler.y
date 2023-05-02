%{
#include <stdio.h>
extern FILE* yyin;
void yyerror(char const *msg);
%}


%token ISV IDENT READ WRITE WHILE EXIT CONTINUE IF ELSE RETURN LBRACK RBRACK LBRACE RBRACE LPAREN RPAREN ASSIGN ADD SUBTRACT MULTIPLY DIVIDE MODULO LESSTHAN EQUAL GREATERTHAN NOTEQUAL LESSOREQUAL GREATEROREQUAL COMMA ENDLINE FUNCTION NUMBERS
%start prog_start

%%

prog_start : %empty { printf("prog_start -> epsilon\n"); } | functions { printf("prog_start -> functions\n"); }

functions : function { printf("functions -> function\n"); } | function functions { printf("functions -> function functions\n"); }

function : IDENT COLON LPAREN arguments RPAREN LBRACK statements RETURN return_args RBRACK { printf("function -> IDENT LPAREN arguments RPAREN LBRACK statements RETURN RBRACK\n"); }

return_args : %empty { printf("return_args -> epsilon\n"); } | argument { printf("return_args -> argument\n"); }

arguments : argument { printf("arguments -> argument\n"); } | argument COMMA arguments { (printf("arguments -> argument COMMA arguments\n"); }

argument : IDENT { printf("argument -> IDENT\n"); }

statements : %empty { printf("statements -> epsilon\n"); } | statement { printf("statements -> statement\n"); } | statement statements { printf("statements -> statement statements"); }

statement : declaration { printf("statement -> declaration\n"); } | function_call { printf("statement -> function_call\n"); } | get { printf("statement -> get\n"); } | give { printf("statement -> give\n"); } | ifotherwise { printf("statement -> ifotherwise\n"); } | whilst { printf("statement -> whilst\n"); } | assignment { printf("statement -> assignment\n"); } | arithmetic { printf("statement -> arithmetic\n"); } | relational { printf("statement -> relational\n"); } | array { printf("statement -> array\n"); }

declaration : ISV IDENT { printf("declaration -> ISV IDENT\n"); } | ISV IDENT COMMA declaration_cont { printf("declaration -> ISV IDENT COMMA declaration_cont\n"); }

declaration_cont : IDENT ENDLINE { printf("declaration_cont -> IDENT ENDLINE\n"); } | IDENT COMMA declaration_cont { printf("declaration_cont -> IDENT COMMA declaration_cont\n"); }

function_call : IDENT LPAREN arguments RPAREN ENDLINE { printf("function_call -> IDENT LPAREN arguments RPAREN ENDLINE\n"); }

get : READ IDENT ENDLINE { printf("get -> READ IDENT ENDLINE\n"); }

give : WRITE IDENT ENDLINE { printf("give -> WRITE IDENT ENDLINE\n"); }

ifotherwise : IF LPAREN relational RPAREN LBRACK statements RBRACK { printf("ifotherwise -> IF LPAREN relational RPAREN LBRACK statements RBRACK\n"); } | IF LPAREN relational RPAREN LBRACK statements RBRACK OTHERWISE LBRACK statements RBRACK { printf("ifotherwise -> IF LPAREN\n"); } 

whilst : WHILE LPAREN relational LPAREN LBRACK statements RBRACK { printf("whilst -> WHILE LPAREN relational LPAREN LBRACK statements RBRACK\n"); }

assignment : IDENT ASSIGN NUMBER ENDLINE { printf("assignment -> IDENT ASSIGN NUMBER ENDLINE\n"); }

arithmetic :

relational : 

array : ISV LBRACE NUMBER RBRACE IDENT ENDLINE { printf("array -> ISV LBRACE NUMBER RBRACE IDENT ENDLINE\n"); } | { }

%%

void main(int argc, char** argv) {
	if(argc >= 2) {
		yyin = fopen(argv[1], "r");
		if(yyin == NULL)
			yyin = stdin;
	}else{
		yyin = stdin;
	}
	yyparse();
}

/* Called by yyparse on error. */
void
yyerror(char const *s)
{
	fprintf(stderr, "%s\n", s);
}

