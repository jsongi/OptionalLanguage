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
int param_num = 0;

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

bool has_main() {
	bool TF = false;
	for(int i = 0; i < symbol_table.size(); i++) {
		Function *f = &symbol_table[i];
		if(f->name == "main")
			TF = true;
	}
	return TF;
}

bool findfunc(std::string &func) {
	bool found = false;
	for(int i = 0; i < symbol_table.size(); i++) {
		Function *f = &symbol_table[i];
		if(f->name == func)
			found = true;
	}
	return found;
}

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

Type get_var_type(std::string &value) {
	Function *f = get_function();
	for(int i = 0; i < f->declarations.size(); i++) {
		Symbol *s = &f->declarations[i];
		if(s->name == value)
			return s->type;
	}
	return Array;
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
%type <node> func_args
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
%type <node> array_init
%type <node> term
%type <node> addop
%type <node> mulop
%type <node> factor
%type <node> relational_args
%type <node> func_call_args
%type <node> call_arguments
%type <node> call_argument

%%

prog_start : %empty { 
	//CodeNode *node = new CodeNode;
	//$$ = node;
			 } |
			 functions {
				CodeNode *node = $1;
				std::string code = node->code;
		
				if(!has_main()) {
					std::string message = std::string("no main function found");
					yyerror(message.c_str());
				}
				// printf("Generated code:\n");
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

function : function_ident FUNC LPAREN func_args RPAREN LBRACE statements RETURN return_args ENDLINE RBRACE {
	std::string func_name = $1;
	CodeNode *params = $4;
	CodeNode *body = $7;
	CodeNode *returns = $9;

	std::string code = std::string("func ") + func_name + std::string("\n") + params->code + body->code + returns->code + std::string("endfunc\n");
	CodeNode *node = new CodeNode;
	node->code = code;
	$$ = node;
		   } | 
		   function_ident FUNC LPAREN func_args RPAREN LBRACE statements RBRACE {
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
			CodeNode* stm1 = $1;
			CodeNode* node = new CodeNode;
			
			//if(!find(stm1->name)) {
			//	std::string message = std::string("unidentified variable '") + stm1->name + std::string("'");
			//	yyerror(message.c_str());
			//}

			node->code = "ret " + stm1->code;
			$$ = node;
	  	};

func_args : %empty {
	CodeNode* node = new CodeNode;
	$$ = node;	   
	   	} |
	   	arguments {
			CodeNode* stm1 = $1;
			CodeNode* node = new CodeNode;
			node->code = ". " + stm1->code;
			$$ = node;
	   	};

func_call_args : %empty {
	CodeNode *node = new CodeNode;
	$$ = node;
		} |
		call_arguments {
			CodeNode *stm1 = $1;
			CodeNode *node = new CodeNode;
			node->code = std::string("params ") + stm1->code;
			$$ = node;
		};

call_arguments : call_argument {
				$$ = $1;
		} |
		call_argument COMMA call_arguments {
			CodeNode *param = $1;
			CodeNode *params = $3;
			std::string code = param->code + std::string("params ") + params->code;
			CodeNode *node = new CodeNode;
			node->code = code;
			$$ = node;
		};

call_argument : expression {
	CodeNode *param = $1;
	std::string code = param->name + std::string("\n");
	CodeNode *node = new CodeNode;
	node->code = code;
	$$ = node;
		};

arguments : argument {
				$$ = $1;
            	} |
	    	argument COMMA arguments {
				//this is a horrible disgusting mess
				CodeNode *param = $1;
				CodeNode *params = $3;
				std::string code = param->code + ". " + params->code;
				std::ostringstream ss;
				ss << param_num;
				code += "= " + param->name + ", $" + ss.str() + "\n";
				param_num += 1;
				ss.str("");
				ss.clear();
				ss << param_num;
				code += "= " + params->name + ", $" + ss.str() + "\n";
				CodeNode *node = new CodeNode;
				node->code = code;
				param_num = 0;
				$$ = node;
	    	};

argument : expression {
	CodeNode *param = $1;
	std::string code = param->code;
	CodeNode *node = new CodeNode;
	
	Type t = Integer;

	node->code = code;
	node->name = code;
	node->code += "\n";
	$$ = node;	   
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
		if(find(value)) {
			std::string message = std::string("cannot redefine variable '") + value + std::string("'");
			yyerror(message.c_str());
		}
	
		if(value == "whilst" || value == "otherwise" || value == "get" || value == "give" || value == "exit" || value == "next"
			|| value == "return") {
			std::string message = std::string("cannot use variable name '") + value + std::string("'");
			yyerror(message.c_str());
		}	
		
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

				if(find(value)) {
					std::string message = std::string("cannot redefine variable '") + value + std::string("'");
					yyerror(message.c_str());
				}
				
				if(value == "whilst" || value == "otherwise" || value == "get" || value == "give" || value == "exit" || value == "next"
                 		       || value == "return") {
                        		std::string message = std::string("cannot use variable name '") + value + std::string("'");
                       			yyerror(message.c_str());
                		}
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

function_call : IDENT LPAREN func_call_args RPAREN {
	std::string func_name = $1;
	CodeNode* params = $3;
	if(!findfunc(func_name)) {
		std::string message = std::string("unidentified function '") + func_name + std::string("'");
		yyerror(message.c_str());
	}
	std::string code = params->name + std::string("call ") + func_name + (", "); 
	CodeNode *node = new CodeNode;
	node->code = code;
	$$ = node;			
				};

get : READ IDENT ENDLINE {
			std::string value = $2;
			
			if(!find(value)) {
				std::string message = std::string("variable undeclared '") + value + std::string("'");
				yyerror(message.c_str());
			}
			
			std::string code = std::string(".< ") + value + std::string("\n");
			CodeNode *node = new CodeNode;
			node->code = code;
			$$ = node;
	  } | 
	  READ IDENT LBRACK expression RBRACK ENDLINE {
			std::string dst = $2;
			
			if(!find(dst)) {
				std::string message = std::string("variable undeclared '") + dst + std::string("'");
				yyerror(message.c_str());
			}
			
			std::string code = $4->code + ".[]< " + dst + ", " + $4->name + "\n";
			CodeNode *node = new CodeNode;
			node->code = code;
			$$ = node;
	  }; 

give : WRITE expression ENDLINE {
			CodeNode* node = new CodeNode;
			if (isdigit($2->name[0])) {
				std::string temp = create_temp();
				node->code = $2->code + ". " + temp + "\n";
				node->code += "= " + temp + ", " + $2->name + "\n";
				node->code += $2->code + ".> " + temp + "\n";
			}
			else {
				node->code = $2->code + ".> " + $2->name + "\n";
			}
			$$ = node;
	   };

ifotherwise : IF LPAREN relational RPAREN LBRACE statements RBRACE {
			  
			  } | 
			  IF LPAREN relational RPAREN LBRACE statements RBRACE ELSE LBRACE statements RBRACE {
				
			  };

whilst : WHILE LPAREN relational RPAREN LBRACE statements RBRACE {
		 
		 };

ext : EXIT ENDLINE {
	  		CodeNode* node = new CodeNode;
			node->code = "ret 0\n";
			$$ = node;
	  };

assignment : IDENT ASSIGN expression {
				std::string value = $1;
				
				if(!find(value)) {
					std::string message = std::string("variable undeclared '") + value + std::string("'");
					yyerror(message.c_str());
				}
				
				if(get_var_type(value) == Array) {
					std::string message = std::string("missing index for array");
					yyerror(message.c_str());
				}
							

				CodeNode *node = new CodeNode;
				node->code = $3->code + "= " + value + ", " + $3->name + "\n";
				$$ = node; 
			 } |
			 IDENT LBRACK expression RBRACK ASSIGN expression  {
				CodeNode *node = new CodeNode;
				std::string dst = $1;
				
				if(get_var_type(dst) == Integer) {
					std::string message = std::string("invalid access of array as integer variable");
					yyerror(message.c_str());
				}

				node->code = $6->code + "[]= " + dst + ", " + $3->name + ", " + $6->name + "\n";
				$$ = node;
			 };

expression : expression addop term {
				CodeNode* node = new CodeNode;
				std::string temp = create_temp();
				node->name = temp;
				node->code = $1->code + $3->code + ". " + temp + "\n";
				node->code += $2->code + temp + ", " + $1->name + ", " + $3->name + "\n";
					$$ = node;
			 } | 
			 term {
			 	$$ = $1;		
			 };
addop : ADD {
			CodeNode* node = new CodeNode;
			node->code = "+ ";
			$$ = node;
		} | 
		SUBTRACT {
			CodeNode* node = new CodeNode;
			node->code = "- ";
			$$ = node;
		};

term : term mulop factor {
			CodeNode* node = new CodeNode;
			std::string temp = create_temp();
			node->name = temp;
			node->code = $1->code + $3->code + ". " + temp + "\n";
			node->code += $2->code + temp + ", " + $1->name + ", " + $3->name + "\n";
			$$ = node;
	   } | 
	   factor {
			$$ = $1;
	   };

mulop : MULTIPLY {
			CodeNode* node = new CodeNode;
			node->code = "* ";
			$$ = node;
		} | 
		DIVIDE {
			CodeNode* node = new CodeNode;
			node->code = "/ ";
			$$ = node;
		} |
		MODULO {
			CodeNode* node = new CodeNode;
			node->code = "% ";
			$$ = node;
		};

factor : LPAREN expression RPAREN {
			$$ = $2;
		 } | 
		 NUMBER {
			CodeNode *node = new CodeNode;
			std::string digit = $1;
			node->name = digit;
			node->code = "";
			$$ = node;
		 } | 
		 IDENT LBRACK expression RBRACK {
			std::string value = $1;
			CodeNode* node = new CodeNode;
			std::string temp = create_temp();
			node->name = temp;

			if(get_var_type(value) == Integer) {
				std::string message = std::string("invalid access of array for integer variable");
				yyerror(message.c_str());
			}

			node->code = $3->code + ". " + temp + "\n";
			node->code += "=[] " + temp + ", " + value + ", " + $3->name + "\n";
			$$ = node;
		 } |
		 IDENT {
			std::string value = $1;
			
			if(get_var_type(value) == Array) {
				std::string message = std::string("attempt to access array as regular integer variable");
				yyerror(message.c_str());
			}

			CodeNode *node = new CodeNode;
			node->code = "";
			node->name = value;
			$$ = node;
		 } |
		 function_call {
			CodeNode* node = new CodeNode;
			std::string temp = create_temp();
			node->name = ". " + temp + "\n" + $1->code + temp + "\n";
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
			 	std::string value = $5;
				CodeNode *num = new CodeNode;
				std::string digit = $3;
				num->code = digit;
				Type t = Array;
				add_variable_to_symbol_table(value, t);
				
				CodeNode *node = new CodeNode;
				std::string code = ".[] " + value + ", " + num->code + "\n";
				node->code = code;
				$$ = node;
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

