%{
#include <stdio.h>
%}

DIGIT [0-9]
ALPHA [a-zA-Z]

%%

“#” { printf(“ISV\n”); }

get { printf("READ\n"); }
give { printf("WRITE\n"); }
whilst { printf("WHILE\n"); }
exit { printf("EXIT\n"); }
next { printf("CONTINUE\n"); }
if { printf("IF\n"); }
otherwise { printf("ELSE\n"); }
return { printf("RETURN\n"); }

“[“ { printf(“LBRACK\n”); }
“]” { printf(“RBRACK\n”); }

"{" { printf(“LBRACE\n”); }
"}" { printf(“RBRACE\n”); }

“(“ { printf(“LPAREN\n”); }
“)” { printf(“RPAREN\n”); }

“<-” { printf(“ASSIGN\n”); }

“+” { printf(“ADD\n”); }
“-” { printf(“SUBTRACT\n”); }
“*” { printf(“MULTIPLY\n”); }
“/” { printf(“DIVIDE\n”); }
“%” { printf(“MODULO\n”); }

“<” { printf(“LESSTHAN\n”); }
“=” { printf(“EQUAL\n”); }
“>” { printf(“GREATERTHAN\n”); }
“=/=” { printf(“NOTEQUAL\n”); }
“<=” { printf(“LESSOREQUAL\n”); }
“>=” { printf(“GREATEROREQUAL\n”); }

"," { printf(“COMMA\n”); }
";" { printf(“ENDLINE\n”); }
":" { printf(“FUNCTION\n”); }

{ALPHA}+({ALPHA}|{DIGIT}|_)* { printf("IDENT %s\n", yytext); }
{DIGIT}+ { printf("NUMBER %s\n", yytext); }

~.+~

. { printf("**Error. Unidentified token '%s'\n", yytext); }

%%

int main(void) {
    printf("Ctrl+D to quit\n");
    yylex();
}
