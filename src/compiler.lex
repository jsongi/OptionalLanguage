%option noyywrap
%{
#include "compiler.tab.h"
#include <string.h>

int columnNum = 1;

extern char *identToken;
extern int numberToken;
%}
%option yylineno

DIGIT [0-9]
ALPHA [a-zA-Z]

%%

"#" { columnNum++; return ISV; }

get { columnNum += 3; return READ; }
give { columnNum += 4; return WRITE; }
whilst { columnNum += 5; return WHILE; }
exit { columnNum += 4; return EXIT; }
next { columnNum += 4; return CONTINUE; }
if { columnNum += 2; return IF; }
otherwise { columnNum += 8; return ELSE; }
return { columnNum += 6; return RETURN; }

"[" { columnNum++;  return LBRACK; }
"]" { columnNum++; return RBRACK; }

"{" { columnNum++; return LBRACE; }
"}" { columnNum++; return RBRACE; }

"(" { columnNum++; return LPAREN; }
")" { columnNum++; return RPAREN; }

"<-" { columnNum += 2; return ASSIGN; }

"+" { columnNum++; return ADD; }
"-" { columnNum++; return SUBTRACT; }
"*" { columnNum++; return MULTIPLY; }
"/" { columnNum++; return DIVIDE; }
"%" { columnNum++; return MODULO; }

"<" { columnNum++; return LESSTHAN; }
"=" { columnNum++; return EQUAL; }
">" { columnNum++; return GREATERTHAN; }
"=/=" { columnNum += 3; return NOTEQUAL; }
"<=" { columnNum += 2; return LESSOREQUAL; }
">=" { columnNum += 2; return GREATEROREQUAL; }

"," { columnNum++; return COMMA; }
";" { columnNum++; return ENDLINE; }
":" { columnNum++; return FUNC; }

{ALPHA}+({ALPHA}|{DIGIT}|_)* { columnNum += strlen(yytext); 
	char * token = new char[yyleng];
	strcpy(token, yytext);
	yylval.op_val = token;
	identToken = yytext;
	return IDENT; }
{DIGIT}+ { columnNum += strlen(yytext); 
	char * token = new char[yyleng];
	strcpy(token, yytext);
	yylval.op_val = token;
	numberToken = atoi(yytext);
	return NUMBER; }

{DIGIT}({DIGIT}|{ALPHA}|_)* { printf("Error at line %d, column %d: identifier \"%s\" cannot start with a digit\n", yylineno, columnNum, yytext); columnNum += strlen(yytext); }
_({DIGIT}|{ALPHA}|_)* { printf("Error at line %d, column %d: identifier \"%s\" cannot start with an underscore\n", yylineno, columnNum, yytext); columnNum += strlen(yytext); }

~.+~ { columnNum += strlen(yytext); }

" " { columnNum++; }
[\t] { columnNum++; }
[\n]|[\r\n] { columnNum = 1; }

. { printf("Error at line %d, column %d: unrecognized symbol \"%s\"\n", yylineno, columnNum, yytext); columnNum++; }

%%
