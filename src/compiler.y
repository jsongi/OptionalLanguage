%{

#include<stdio.h>
#include<string>
#include<vector>
#include<string.h>
#include<stdlib.h>

extern int yylex(void);
void yyerror(const char *msg);
extern int currLine;

char *identToken;
int numberToken;
int  count_names = 0;

enum Type { Integer, Array };

struct Symbol {
  std::string name;
  Type type;
};

struct Function {
  std::string name;
  std::vector<Symbol> declarations;
};

std::vector <Function> symbol_table;

Function *get_function() {
  int last = symbol_table.size()-1;
  if (last < 0) {
    printf("***Error. Attempt to call get_function with an empty symbol table\n");
    printf("Create a 'Function' object using 'add_function_to_symbol_table' before\n");
    printf("calling 'find' or 'add_variable_to_symbol_table'");
    exit(1);
  }
  return &symbol_table[last];
}

bool find(std::string &value) {
  Function *f = get_function();
  for(int i=0; i < f->declarations.size(); i++) {
    Symbol *s = &f->declarations[i];
    if (s->name == value) {
      return true;
    }
  }
  return false;
}

void add_function_to_symbol_table(std::string &value) {
  Function f; 
  f.name = value; 
  symbol_table.push_back(f);
}

void add_variable_to_symbol_table(std::string &value, Type t) {
  Symbol s;
  s.name = value;
  s.type = t;
  Function *f = get_function();
  f->declarations.push_back(s);
}

void print_symbol_table(void) {
  printf("symbol table:\n");
  printf("--------------------\n");
  for(int i=0; i<symbol_table.size(); i++) {
    printf("function: %s\n", symbol_table[i].name.c_str());
    for(int j=0; j<symbol_table[i].declarations.size(); j++) {
      printf("  locals: %s\n", symbol_table[i].declarations[j].name.c_str());
    }
  }
  printf("--------------------\n");
}

struct CodeNode {
    std::string code; // generated code as a string.
    std::string name;
};

%}

%union {
    char *op_val;
    struct CodeNode *node;
}	

%token ISV READ WRITE WHILE EXIT CONTINUE IF ELSE RETURN LBRACK RBRACK LBRACE RBRACE LPAREN RPAREN ASSIGN ADD SUBTRACT MULTIPLY DIVIDE MODULO LESSTHAN EQUAL GREATERTHAN NOTEQUAL LESSOREQUAL GREATEROREQUAL COMMA ENDLINE FUNC
%start prog_start
%token <op_val> IDENT
%token <op_val> NUMBER
%type <node> functions
%type <node> function
%type <node> return_args
%type <node> args
%type <node> arguments
%type <node> argument
%type <node> statements
%type <node> statement
%type <node> declaration
%type <node> declaration_cont
%type <node> function_call
%type <node> get
%type <node> give
%type <node> ifotherwise
%type <node> whilst
%type <node> ext
%type <node> assignment
%type <node> expression

%%

prog_start : %empty { 
	CodeNode *node = new CodeNode;
	$$ = node;
			 } |
			 functions {
				CodeNode *node = $1;
				std::string code = node->code;
				printf("Generated code:\n");
				printf("%s\n", code.c_str());
			 };

functions : function {
	CodeNode *func = $1;
	std::string code = func->code;
	CodeNode *node = new CodeNode;
	node->code = code;
	$$ = node;
			} |
			function functions {
				CodeNode *func  = $1;
				CodeNode *funcs = $2;
				std::string code = func->code + funcs->code;
				CodeNode *node = new CodeNode;
				node->code = code;
				$$ = node;
			};

function : IDENT FUNC LPAREN args RPAREN LBRACE statements RETURN return_args ENDLINE RBRACE {
	CodeNode *func_name = $1;
	CodeNode *params = $4;
	CodeNode *body = $7;
	CodeNode *returns = $9;
	std::string code = std::string("func ") + func_name->code + std::string("\n") + params->code + body->code + returns->code + std::string("endfunc\n");
	CodeNode *node = new CodeNode;
	node->code = code;
	$$ = node;
		   } | 
		   IDENT FUNC LPAREN args RPAREN LBRACE statements RBRACE {
			CodeNode *func_name = $1;
			CodeNode *params = $4;
			CodeNode *body = $7;
			std::string code = std::string("func ") + func_name->code + std::string("\n") +	params->code + body->code + std::string("endfunc\n");
			CodeNode *node = new CodeNode;
			node->code = code;
			$$ = node;	
		   };

return_args : %empty {
	CodeNode* node = new CodeNode;
	$$ = node;		  		
	  	} |
	  	argument {
			$$ = $1;
	  	};

args : %empty {
	CodeNode* node = new CodeNode;
	$$ = node;	   
	   	} |
	   	arguments {
			$$ = $1; 
	   	};

arguments : argument {
	$$ = $1;
            	} |
	    	argument COMMA arguments {
			CodeNode *param = $1;
			CodeNode *params = $3;
			std::string code = param->code + params->code;
			CodeNode *node = new CodeNode;
			node->code = code;
			$$ = node;		
	    	};

argument : expression {
	$$ = $1;	   
		   };

statements : %empty {
	CodeNode* node = new CodeNode;
	$$ = node;		 
			 } |
			 statement statements {
				CodeNode *stmt = $1;
				CodeNode* stmts = $2;
				std::string code = stmt->code + stmts->code;
				CodeNode *node = new CodeNode;
				node->code = code;
				$$ = node;							
			 };

statement : declaration ENDLINE {
	$$ = $1;		
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
		std::string value = $2;
		Type t = Integer;
		add_variable_to_symbol_table(value, t);

		std::string code = std::string(". ") + value + std::string("\n");
		CodeNode *node = new CodeNode;
		node->code = code;
		$$ = node;
			  } | 
			  ISV IDENT COMMA declaration_cont {
		CodeNode *decl = $1;
		CodeNode *decls = $4;
		std::string code = decl->code + decls->code;
		CodeNode *node = new CodeNode;
		node->code = code;
		$$ = node;
			  } | 
			  declaration_err;

declaration_cont : IDENT {
	std::string value = $1;
	Type t = Integer;
	add_variable_to_symbol_table(value, t);
	
	std::string code = std::string(". ") + value + std::string("\n");
	CodeNode *node = new CodeNode;
	node->code = code;
	$$ = node;			   
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
	$$ = $1;			  
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

