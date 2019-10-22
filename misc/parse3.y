
%left '+'
%token n

%%

L               : L ';' E
                | E
                ;

E               : E '+' P
                | P
                ;

P               : n
                ;

%%
