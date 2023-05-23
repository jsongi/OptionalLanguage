%{

#include<stdio.h>
#include<string>
#include<vector>
#include<string.h>
#include<stdlib.h>
#include<sstream>

extern int yylex(void);
void yyerror(const char *msg);
extern int yylineno;

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

std::string create_temp() {
	static int num = 0;
	std::ostringstream ss;
	ss << num;
	std::string value = "_temp" + ss.str();
	num += 1;
	return value;
}

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

%define parse.error verbose
%start prog_start
%token ISV READ WRITE WHILE EXIT CONTINUE IF ELSE RETURN LBRACK RBRACK LBRACE RBRACE LPAREN RPAREN ASSIGN ADD SUBTRACT MULTIPLY DIVIDE MODULO LESSTHAN EQUAL GREATERTHAN NOTEQUAL LESSOREQUAL GREATEROREQUAL COMMA ENDLINE FUNC
%token <op_val> IDENT
%token <op_val> NUMBER
%type <op_val> function_ident
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
%type <node> array_access
%type <node> array_init
%type <node> term
%type <node> addop
%type <node> mulop
%type <node> factor
%type <node> relational_args

%%

prog_start : %empty { 
	//CodeNode *node = new CodeNode;
	//$$ = node;
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

function : function_ident FUNC LPAREN args RPAREN LBRACE statements RETURN return_args ENDLINE RBRACE {
	std::string func_name = $1;
	CodeNode *params = $4;
	CodeNode *body = $7;
	CodeNode *returns = $9;

	std::string code = std::string("func ") + func_name + std::string("\n") + params->code + body->code + returns->code + std::string("endfunc\n");
	CodeNode *node = new CodeNode;
	node->code = code;
	$$ = node;
		   } | 
		   function_ident FUNC LPAREN args RPAREN LBRACE statements RBRACE {
			std::string func_name = $1;
			CodeNode *params = $4;
			CodeNode *body = $7;

			std::string code = std::string("func ") + func_name + std::string("\n");
			code += params->code;
			code += body->code;
			code += std::string("endfunc\n");
			
			CodeNode *node = new CodeNode;
			node->code = code;
			$$ = node;
		   };

function_ident : IDENT {
	std::string func_name = $1;
	add_function_to_symbol_table(func_name);
	$$ = $1;
}

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
			std::string code = param->code + std::string("\n") + params->code + std::string("\n");
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
				$$ = $1;	
			} | 
			get {
				$$ = $1;
			} | 
			give {
				$$ = $1;
			} |
			ifotherwise {
				$$ = $1;
			} | 
			whilst {
				$$ = $1;	
			} | 
			ext {
				$$ = $1;
			} | 
			assignment ENDLINE {
				$$ = $1;
			} | 
			array_init ENDLINE {
				$$ = $1;	
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
				std::string value = $2;
				CodeNode* decls = $4;
				Type t = Integer;
				add_variable_to_symbol_table(value, t);
			
				std::string code = std::string(". ") + value + std::string("\n") + decls->code;
				CodeNode *node = new CodeNode;
				node->code = code;
				$$ = node;
			  }

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
					std::string value = $1;
					CodeNode* decls = $3;
					Type t = Integer;
					add_variable_to_symbol_table(value, t);
					
					std::string code = std::string(". ") + value + std::string("\n") + decls->code;
					CodeNode *node = new CodeNode;
					node->code = code;
					$$ = node;			
				   };

function_call : IDENT LPAREN args RPAREN {
	std::string func_name = $1;
	CodeNode* params = $3;
	add_function_to_symbol_table(func_name);
	
	std::string code = params->code + std::string("\n") + std::string("call ") + func_name + (", "); 
	CodeNode *node = new CodeNode;
	node->code = code;
	$$ = node;			
				};

get : READ IDENT ENDLINE {
	std::string value = $2;
	Type t = Integer;
	add_variable_to_symbol_table(value, t);
	
	std::string code = std::string(".< ") + value + std::string("\n");
	CodeNode *node = new CodeNode;
	node->code = code;
	$$ = node;
	  } | 
	  READ array_access ENDLINE {
		CodeNode *array = $2;
		
		std::string code = std::string(".[]< ") + array->code + std::string("\n");
		CodeNode *node = new CodeNode;
		node->code = code;
		$$ = node;
	  }; 

give : WRITE IDENT ENDLINE {
	std::string value = $2;
	Type t = Integer;
	add_variable_to_symbol_table(value, t);
	
	std::string code = std::string(".> ") + value + std::string("\n");
	CodeNode *node = new CodeNode;
	node->code = code;
	$$ = node;
	   } | 
	   WRITE array_access ENDLINE {
		CodeNode *array = $2;

		std::string code = std::string(".[]> ") + array->code + std::string("\n");
		CodeNode *node = new CodeNode;
		node->code = code;
		$$ = node;
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
	std::string value = $1;
	CodeNode *expr = $3;
	Type t = Integer;
	add_variable_to_symbol_table(value, t);
	
	std::string code = std::string("= ") + value + std::string(", ") + expr->code;		
	CodeNode *node = new CodeNode;
	node->code = code;
	$$ = node; 
			 } |
			 array_access ASSIGN expression {
				CodeNode *arr = $1;
				CodeNode *expr = $3;
				//Type t = Integer;
				//add_variable_to_symbol_table(value, t);	

				std::string code = std::string(""); //needs handling for index positions	
			 } | 
			 IDENT ASSIGN function_call {
				std::string value = $1;
				
				Type t = Integer;
				add_variable_to_symbol_table(value, t);

				CodeNode *node = new CodeNode;
				$$ = node;
			 } | 
			 array_access ASSIGN function_call {
				
			 }

expression : expression addop term {
	CodeNode *expr = $1;
	CodeNode *op = $2;
	CodeNode *trm = $3;
	
	std::string code = expr->code + op->code + trm->code + std::string("\n");
	CodeNode *node = new CodeNode;
	node->code = code;
	$$ = node;		 
			 } | 
			 term {
			 	$$ = $1;		
			 };

addop : ADD {
	std::string code = std::string("+ ");
	CodeNode *node = new CodeNode;
	node->code = code;
	$$ = node;	
		} | 
		SUBTRACT {
			std::string code = std::string("- ");
			CodeNode *node = new CodeNode;
			node->code = code;
			$$ = node;	
		};

term : term mulop factor {
	CodeNode *trm = $1;
	CodeNode *op = $2;
	CodeNode *fac = $3;

	std::string code = trm->code + op->code + fac->code + std::string("\n");
	CodeNode *node = new CodeNode;
	node->code = code;
	$$ = node;
	   } | 
	   factor {
		$$ = $1;
	   };

mulop : MULTIPLY {
	std::string code = std::string("* ");
	CodeNode *node = new CodeNode; 
	node->code = code;
	$$ = node;	
		} | 
		DIVIDE {
			std::string code = std::string("/ ");
			CodeNode *node = new CodeNode;
			node->code = code;
			$$ = node;	
		} |
		MODULO {
			std::string code = std::string("% ");
			CodeNode *node = new CodeNode;
			node->code = code;
			$$ = node;
		};

factor : LPAREN expression RPAREN {
	$$ = $2;
		 } | 
		 NUMBER {
			
		 } | 
		 IDENT LBRACK expression RBRACK {
			
		 } | 
		 IDENT {
			std::string value = $1;
			Type t = Integer;
			add_variable_to_symbol_table(value, t);
			
			std::string code = value;
			CodeNode *node = new CodeNode;
			node->code = code;
			$$ = node;
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

%%

int main(int argc, char** argv) {
	yyparse();
	return 0;
}

/* Called by yyparse on error. */
void
yyerror(char const *s)
{
	printf("** Line %d: %s\n", yylineno, s);
	exit(1);
}

