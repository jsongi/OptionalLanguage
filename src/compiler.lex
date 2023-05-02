%{
#include "y.tab.h"
#include <stdio.h>

int columnNum = 1;
%}
%option yylineno

DIGIT [0-9]
ALPHA [a-zA-Z]

%%

"#" { printf("ISV\n"); columnNum++; }

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
":" { columnNum++; return FUNCTION; }

{ALPHA}+({ALPHA}|{DIGIT}|_)* { columnNum += strlen(yytext); return IDENT; }
{DIGIT}+ { printf("NUMBER %s\n", yytext); columnNum += strlen(yytext); return NUMBER; }

{DIGIT}({DIGIT}|{ALPHA}|_)* { printf("Error at line %d, column %d: identifier \"%s\" cannot start with a digit\n", yylineno, columnNum, yytext); columnNum += strlen(yytext); }
_({DIGIT}|{ALPHA}|_)* { printf("Error at line %d, column %d: identifier \"%s\" cannot start with an underscore\n", yylineno, columnNum, yytext); columnNum += strlen(yytext); }

~.+~ { columnNum += strlen(yytext); }

" " { columnNum++; }
[\t] { columnNum++; }
[\n] { columnNum = 1; }

. { printf("Error at line %d, column %d: unrecognized symbol \"%s\"\n", yylineno, columnNum, yytext); columnNum++; }

%%
