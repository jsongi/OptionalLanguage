%{
#include <stdio.h>
extern FILE* yyin;
void yyerror(char const *msg);
int yylex();
extern int yylineno;
%}


%token ISV IDENT READ WRITE WHILE EXIT CONTINUE IF ELSE RETURN LBRACK RBRACK LBRACE RBRACE LPAREN RPAREN ASSIGN ADD SUBTRACT MULTIPLY DIVIDE MODULO LESSTHAN EQUAL GREATERTHAN NOTEQUAL LESSOREQUAL GREATEROREQUAL COMMA ENDLINE FUNC NUMBER
%start prog_start

%%

prog_start : %empty { printf("prog_start -> epsilon\n"); } |
			 functions { printf("prog_start -> functions\n"); };

functions : function { printf("functions -> function\n"); } |
			function functions { printf("functions -> function functions\n"); };

function : IDENT FUNC LPAREN args RPAREN LBRACE statements RETURN return_args ENDLINE RBRACE { printf("function -> IDENT LPAREN arguments RPAREN LBRACE statements RETURN RBRACE\n"); } | 
		   IDENT FUNC LPAREN args RPAREN LBRACE statements RBRACE { printf("function -> IDENT FUNC LPAREN args RPAREN LBRACE statements RBRACE\n"); };

return_args : %empty { printf("return_args -> epsilon\n"); } |
			  argument { printf("return_args -> argument\n"); };

args : %empty { printf("args -> epsilon\n"); } |
	   arguments { printf("args -> argument\n"); };

arguments : argument { printf("arguments -> argument\n"); } |
			argument COMMA arguments { printf("arguments -> argument COMMA arguments\n"); };

argument : expression { printf("argument -> expression\n"); };

statements : %empty { printf("statements -> epsilon\n"); } |
			 statement statements { printf("statements -> statement statements\n"); };

statement : declaration ENDLINE { printf("statement -> declaration\n"); } | 
			function_call ENDLINE { printf("statement -> function_call\n"); } | 
			get { printf("statement -> get\n"); } | give { printf("statement -> give\n"); } | 
			ifotherwise { printf("statement -> ifotherwise\n"); } | 
			whilst { printf("statement -> whilst\n"); } | 
			ext { printf("statement -> ext\n"); } | 
			assignment ENDLINE { printf("statement -> assignment ENDLINE\n"); } | 
			array_init ENDLINE { printf("statement -> array_init\n"); };

declaration : ISV IDENT { printf("declaration -> ISV IDENT\n"); } | 
			  ISV IDENT COMMA declaration_cont { printf("declaration -> ISV IDENT COMMA declaration_cont\n"); } | 
			  declaration_err;

declaration_cont : IDENT { printf("declaration_cont -> IDENT ENDLINE\n"); } |
				   IDENT COMMA declaration_cont { printf("declaration_cont -> IDENT COMMA declaration_cont\n"); };

function_call : IDENT LPAREN args RPAREN { printf("function_call -> IDENT LPAREN arguments RPAREN ENDLINE\n"); };

get : READ IDENT ENDLINE { printf("get -> READ IDENT ENDLINE\n"); } | READ array_access ENDLINE { printf("get -> READ array_access ENDLINE\n"); }; 

give : WRITE IDENT ENDLINE { printf("give -> WRITE IDENT ENDLINE\n"); } | WRITE array_access ENDLINE { printf("get -> WRITE array_access ENDLINE\n"); };

ifotherwise : IF LPAREN relational RPAREN LBRACE statements RBRACE { printf("ifotherwise -> IF LPAREN relational RPAREN LBRACE statements RBRACE\n"); } | 
			  IF LPAREN relational RPAREN LBRACE statements RBRACE ELSE LBRACE statements RBRACE { printf("ifotherwise -> IF LPAREN\n"); };

whilst : WHILE LPAREN relational RPAREN LBRACE statements RBRACE { printf("whilst -> WHILE LPAREN relational LPAREN LBRACE statements RBRACE\n"); };

ext : EXIT ENDLINE { printf("exit -> EXIT ENDLINE\n"); };

assignment : IDENT ASSIGN expression { printf("assignment -> IDENT ASSIGN expression\n"); } |
			 array_access ASSIGN expression { printf("assignment -> array_access ASSIGN expression\n"); } | 
			 IDENT ASSIGN function_call { printf("assignment -> IDENT ASSIGN function_call\n"); } | 
			 array_access ASSIGN function_call { printf("assignment -> array_access ASSIGN function_call\n"); } |
			 assignment_err;

expression : expression addop term { printf("expression -> expression addop term\n"); } | 
			 term { printf("expression -> term\n"); };

addop : ADD { printf("addop -> ADD\n"); } | 
		SUBTRACT { printf("addop -> SUBTRACT\n"); };

term : term mulop factor { printf("term -> term mulop factor\n"); } | 
	   factor { printf("term -> factor\n"); };

mulop : MULTIPLY { printf("mulop -> MULTIPLY\n"); } | 
		DIVIDE { printf("mulop -> DIVIDE\n"); } |
		MODULO { printf("mulop -> MODULO\n"); };

factor : LPAREN expression RPAREN { printf("factor -> LPAREN expression RPAREN\n"); } | 
		 NUMBER { printf("factor -> NUMBER\n"); } | 
		 IDENT LBRACK expression RBRACK { printf("factor -> IDENT LBRACK NUMBER RBRACK\n"); } | 
		 IDENT { printf("factor -> IDENT\n"); };

relational : relational_args relational_symbol relational_args { printf("relational -> relational_args relational_symbol relational_args\n"); };

relational_args : expression { printf("relational_args -> expression\n"); };

relational_symbol : LESSTHAN { printf("relational_symbol -> LESSTHAN\n"); } | 
					EQUAL { printf("relational_symbol -> EQUAL\n"); } | 
					GREATERTHAN { printf("relational_symbol -> GREATERTHAN\n"); } | 
					NOTEQUAL { printf("relational_symbol -> NOTEQUAL\n"); } | 
					LESSOREQUAL { printf("relation_symbol -> LESSOREQUAL\n"); } | 
					GREATEROREQUAL { printf("relational_symbol -> GREATEROREQUAL\n"); };

array_init : ISV LBRACK NUMBER RBRACK IDENT { printf("array_init -> ISV LBRACK NUMBER RBRACK IDENT\n"); };

array_access : IDENT LBRACK expression RBRACK { printf("array_access -> IDENT LBRACK NUMBER RBRACK\n"); };

assignment_err : IDENT LESSTHAN expression 			 { printf("Syntax error, invalid assignment at line %d: \"<-\" expected\n", yylineno); } |
			 	 IDENT LESSTHAN function_call 		 { printf("Syntax error, invalid assignment at line %d: \"<-\" expected\n", yylineno); } | 
			 	 array_access LESSTHAN expression 	 { printf("Syntax error, invalid array index assignment at line %d: \"<-\" expected\n", yylineno); } | 
			 	 array_access LESSTHAN function_call { printf("Syntax error, invalid array index assignment at line %d: \"<-\" expected\n", yylineno); };

declaration_err : IDENT 					   { printf("Syntax error at line %d, invalid declaration: need type for declaration\n", yylineno); } | 
			  	  IDENT COMMA declaration_cont { printf("Syntax error at line %d, invalid declaration: need type for declaration\n", yylineno); }
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
	fprintf(stderr, "%s on line %d\n", s, yylineno);
}

