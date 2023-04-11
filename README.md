# OptionalLanguage

Programming Language: `Optional`

Extension: `.opt`

Compiler Name: `Required`

| Language Feature | Code Example |
|----------------------|---------|
|Integer scalar variables|<pre># x;<br># y;<br># sum, avg;</pre>|
|One-dimensional arrays of integers|<pre>#[] a; #[5] a; a[3] <- a[4]</pre>|
|Assignment Statements|<pre>a <- b;<br>a <- 5;</pre>|
|Arithmetic Operators|<pre>a + b;<br>a - b;<br>a * b;<br>a / c;<br>a % b;</pre>|
|Relational Operators|<pre>a < b;<br>a = b;<br>a > b;<br>a =/= c;<br>a <= b;<br>a >= b;</pre>|
|While Loop|<pre>whilst (a = b) {<br>    exit;<br>    next;<br>}</pre>|
|If-then-else Statements|<pre>if (a = b) {<br>    ... <br>}<br>otherwise {<br>    ... <br>}</pre>|
|Read and Write Statements|<pre>get a;<br>give a;</pre>|
|Comments|<pre>~ Comment ~</pre>|
|Functions|<pre>myFunction: (input_a, input_b) {<br>    return;<br>}</pre>|

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
