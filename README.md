# OptionalLanguage

Programming Language: `Optional`

Extension: `.opt`

Compiler Name: `Required`

| Language Feature | Code Example |
|----------------------|---------|
|Integer scalar variables|`# x; # y; # sum, avg;`|
|One-dimensional arrays of integers|`#[] a; #[5] a; a[3] <- a[4]`|
|Assignment Statements|`a <- b; a <- 5;`|
|Arithmetic Operators|`a + b; a - b; a * b; a / c; a % b;`|
|Relational Operators|`a < b; a = b; a > b; a =/= c; a <= b; a >= b;`|
|While Loop|`whilst (); exit; next;`|
|If-then-else Statements|`if () ... otherwise ...`|
|Read and Write Statements|`get a; give a;`|
|Comments|`~ Comment ~`|
|Functions|`myFunction: (input_a, input_b) { ... return; }`|

|Symbols|Tokens|
|---------|-----|
|#|INT|
|variable|IDENT|
|get|READ|
|give|WRITE|
|whilst|WHILE|
|exit|EXIT|
|next|CONTINUE|
|if|IF|
|otherwise|ELSE|
|[|LBRACK|
|]|RBRACK|
|(|LPAREN|
|)|RPAREN|
|;|ENDLINE|
|<-|ASSIGN|
|+|ADD|
|-|SUBTRACT|
|*|MULT|
|/|DIVIDE|
|%|MODULUS|
|=|EQUAL|
|=/=|NOTEQUAL|
|<=|LESSOREQUAL|
|>=|GREATEROREQUAL|
|~|COMMENT|
|:|FUNCTION|
|return|RETURN|
