%{
#include <stdio.h>
%}

DIGIT [0-9]
ALPHA [a-zA-Z]

%%

get { printf("READ\n"); }
give { printf("WRITE\n"); }
whilst { printf("WHILE\n"); }
exit { printf("EXIT\n"); }
next { printf("CONTINUE\n"); }
if { printf("IF\n"); }
otherwise { printf("ELSE\n"); }

{ALPHA}+({ALPHA}|{DIGIT}|_)* { printf("IDENT %s\n", yytext); }
{DIGIT}+ { printf("NUMBER %s\n", yytext); }

. { printf("**Error. Unidentified token '%s'\n", yytext); }

%%

int main(void) {
    printf("Ctrl+D to quit\n");
    yylex();
}
