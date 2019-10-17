/* https://www.cs.uic.edu/~spopuri/cparser.html */

/*
 * (1) L → L;E
 * (2) L → E
 * (3) E → E,P
 * (4) E → P
 * (5) P → a
 * (6) P → (M)
 * (7) M → ε
 * (8) M → L
 */

%token tLPAREN "("
%token tRPAREN ")"

%%
L               : L ';' E
                | E
                ;
E               : E ',' P
                | P
                ;
P               : 'a'
                | tLPAREN M tRPAREN
                ;
M               : /* nothing */
                | L
                ;
%%
