%{
#include <stdio.h>

int columnNum = 1;
%}
%option yylineno

DIGIT [0-9]
ALPHA [a-zA-Z]

%%

"#" { printf("ISV\n"); columnNum++; }

get { printf("READ\n"); columnNum += 3; }
give { printf("WRITE\n"); columnNum += 4; }
whilst { printf("WHILE\n"); columnNum += 5; }
exit { printf("EXIT\n"); columnNum += 4; }
next { printf("CONTINUE\n"); columnNum += 4; }
if { printf("IF\n"); columnNum += 2; }
otherwise { printf("ELSE\n"); columnNum += 8; }
return { printf("RETURN\n"); columnNum += 6; }

"[" { printf("LBRACK\n"); columnNum++; }
"]" { printf("RBRACK\n"); columnNum++; }

"{" { printf("LBRACE\n"); columnNum++; }
"}" { printf("RBRACE\n"); columnNum++; }

"(" { printf("LPAREN\n"); columnNum++; }
")" { printf("RPAREN\n"); columnNum++; }

"<-" { printf("ASSIGN\n"); columnNum += 2; }

"+" { printf("ADD\n"); columnNum++; }
"-" { printf("SUBTRACT\n"); columnNum++; }
"*" { printf("MULTIPLY\n"); columnNum++; }
"/" { printf("DIVIDE\n"); columnNum++; }
"%" { printf("MODULO\n"); columnNum++; }

"<" { printf("LESSTHAN\n"); columnNum++; }
"=" { printf("EQUAL\n"); columnNum++; }
">" { printf("GREATERTHAN\n"); columnNum++; }
"=/=" { printf("NOTEQUAL\n"); columnNum += 3; }
"<=" { printf("LESSOREQUAL\n"); columnNum += 2; }
">=" { printf("GREATEROREQUAL\n"); columnNum += 2; }

"," { printf("COMMA\n"); columnNum++; }
";" { printf("ENDLINE\n"); columnNum++; }
":" { printf("FUNCTION\n"); columnNum++; }

{ALPHA}+({ALPHA}|{DIGIT}|_)* { printf("IDENT %s\n", yytext); columnNum += strlen(yytext); }
{DIGIT}+ { printf("NUMBER %s\n", yytext); columnNum += strlen(yytext); }

~.+~ { columnNum += strlen(yytext); }

" " { columnNum++; }
[\t] { columnNum++; }
[\n] { columnNum = 1; }

. { printf("Error at line %d, column %d: unrecognized symbol \"%s\"\n", yylineno, columnNum, yytext); columnNum++; }

%%

int main(void) {
    printf("Ctrl+D to quit\n");
    yylex();
}
