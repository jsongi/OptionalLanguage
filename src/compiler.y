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

prog_start : %empty { 

			 } |
			 functions {

			 };

functions : function {
	
			} |
			function functions {
				
			};

function : IDENT FUNC LPAREN args RPAREN LBRACE statements RETURN return_args ENDLINE RBRACE {

		   } | 
		   IDENT FUNC LPAREN args RPAREN LBRACE statements RBRACE {
			
		   };

return_args : %empty {
			  		
			  } |
			  argument {
				
			  };

args : %empty {
	   
	   } |
	   arguments {
		
	   };

arguments : argument {

            } |
			argument COMMA arguments {
				
			};

argument : expression {
		   
		   };

statements : %empty {
			 
			 } |
			 statement statements {
				
			 };

statement : declaration ENDLINE {
			
			} | 
			function_call ENDLINE {
				
			} | 
			get {
				
			} | 
			ifotherwise {
				
			} | 
			whilst {
				
			} | 
			ext {
				
			} | 
			assignment ENDLINE {
				
			} | 
			array_init ENDLINE {
				
			};

declaration : ISV IDENT {
			  
			  } | 
			  ISV IDENT COMMA declaration_cont {
				
			  } | 
			  declaration_err;

declaration_cont : IDENT {
				   
				   } |
				   IDENT COMMA declaration_cont {
					
				   };

function_call : IDENT LPAREN args RPAREN {
				
				};

get : READ IDENT ENDLINE {
	  
	  } | 
	  READ array_access ENDLINE {
		
	  }; 

give : WRITE IDENT ENDLINE {
	   
	   } | 
	   WRITE array_access ENDLINE {
		
	   };

ifotherwise : IF LPAREN relational RPAREN LBRACE statements RBRACE {
			  
			  } | 
			  IF LPAREN relational RPAREN LBRACE statements RBRACE ELSE LBRACE statements RBRACE {
				
			  };

whilst : WHILE LPAREN relational RPAREN LBRACE statements RBRACE {
		 
		 };

ext : EXIT ENDLINE {
	  
	  };

assignment : IDENT ASSIGN expression {
			 
			 } |
			 array_access ASSIGN expression {
				
			 } | 
			 IDENT ASSIGN function_call {
				
			 } | 
			 array_access ASSIGN function_call {
				
			 } |
			 assignment_err;

expression : expression addop term {
			 
			 } | 
			 term {
				
			 };

addop : ADD {
		
		} | 
		SUBTRACT {
			
		};

term : term mulop factor {
	   
	   } | 
	   factor {
		
	   };

mulop : MULTIPLY {
		
		} | 
		DIVIDE {
			
		} |
		MODULO {
			
		};

factor : LPAREN expression RPAREN {
		 
		 } | 
		 NUMBER {
			
		 } | 
		 IDENT LBRACK expression RBRACK {
			
		 } | 
		 IDENT {
			
		 };

relational : relational_args relational_symbol relational_args {
			 
			 };

relational_args : expression {
				  
				  };

relational_symbol : LESSTHAN {
					
					} | 
					EQUAL {
						
					} | 
					GREATERTHAN {
						
					} | 
					NOTEQUAL {
						
					} | 
					LESSOREQUAL {
						
					} | 
					GREATEROREQUAL {
						
					};

array_init : ISV LBRACK NUMBER RBRACK IDENT {
			 
			 };

array_access : IDENT LBRACK expression RBRACK {
			  
			  };

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

