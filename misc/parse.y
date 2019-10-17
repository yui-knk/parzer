/* 478191229X P.282 */

%token c d

%%
S_DASH          : S
                ;

S               : C C
                ;

C               : c C
                | d
                ;
