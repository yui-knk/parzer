/* 478191229X P.282 */

%token C D

%%
s_dash          : s
                ;

s               : c c
                ;

c               : C c
                | D
                ;
