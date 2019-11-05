#include <stdbool.h>
#include <ruby.h>

#define YYDEBUG 1

#include "./parse.h.inc"

static void rb_parsey_yyprint(FILE *yyo, enum yytokentype tok, const YYSTYPE valp);
#define YYPRINT(out, tok, val) rb_parsey_yyprint(out, tok, val)

static VALUE cBisonWrapper;

static enum yytokentype yylex(VALUE parser);
static void yyerror(VALUE parser, char const *s);

#include "./parse.inc"

static enum yytokentype
yylex(VALUE parser)
{
    VALUE next_token;
    int i;

    next_token = rb_funcall(parser, rb_intern("next_token"), 0);
    Check_Type(next_token, T_FIXNUM);
    i = FIX2INT(next_token);

    if (i >= YYNTOKENS) {
        rb_raise(rb_eRangeError, "token %d is invalid should less than %d", i, YYNTOKENS);
    }

    return yytoknum[i];
}

static void
yyerror(VALUE parser, char const *s)
{
}


const unsigned long yytranslate_len = sizeof(yytranslate) / sizeof(yytranslate[0]);
const unsigned long yyrline_len = sizeof(yyrline) / sizeof(yyrline[0]);
static const unsigned long yytname_len = sizeof(yytname) / sizeof(yytname[0]);
static const unsigned long yytoknum_len = sizeof(yytoknum) / sizeof(yytoknum[0]);
static const unsigned long yypact_len = sizeof(yypact) / sizeof(yypact[0]);
static const unsigned long yydefact_len = sizeof(yydefact) / sizeof(yydefact[0]);
static const unsigned long yypgoto_len = sizeof(yypgoto) / sizeof(yypgoto[0]);
static const unsigned long yydefgoto_len = sizeof(yydefgoto) / sizeof(yydefgoto[0]);
static const unsigned long yytable_len = sizeof(yytable) / sizeof(yytable[0]);
static const unsigned long yycheck_len = sizeof(yycheck) / sizeof(yycheck[0]);
static const unsigned long yystos_len = sizeof(yystos) / sizeof(yystos[0]);
static const unsigned long yyr1_len = sizeof(yyr1) / sizeof(yyr1[0]);
static const unsigned long yyr2_len = sizeof(yyr2) / sizeof(yyr2[0]);

static void
rb_parsey_yyprint(FILE *yyo, enum yytokentype tok, const YYSTYPE valp)
{
}

static VALUE
rb_parsey_yyparse(VALUE parser)
{
    yyparse(parser);

    return Qtrue;
}

static void
rb_parsey_set_yydebug(bool b)
{
    yydebug = b;
}

static VALUE
rb_parsey_enable_yydebug(VALUE parser)
{
    rb_parsey_set_yydebug(true);

    return Qtrue;
}

static VALUE
rb_parsey_disable_yydebug(VALUE parser)
{
    rb_parsey_set_yydebug(false);

    return Qfalse;
}

static VALUE
rb_parsey_s_yytranslate(VALUE module)
{
    /* Last entry of yytranslate is YY_NULLPTR */
    unsigned long l = yytranslate_len - 1;
    VALUE ary = rb_ary_new_capa(l);

    for (unsigned long i = 0; i < l; i++) {
        rb_ary_push(ary, INT2FIX(yytranslate[i]));
    }

    return ary;
}

static VALUE
rb_parsey_s_yyrline(VALUE module)
{
    /* Last entry of yyrline is YY_NULLPTR */
    unsigned long l = yyrline_len - 1;
    VALUE ary = rb_ary_new_capa(l);

    for (unsigned long i = 0; i < l; i++) {
        rb_ary_push(ary, INT2FIX(yyrline[i]));
    }

    return ary;
}

static VALUE
rb_parsey_s_yytname(VALUE module)
{
    /* Last entry of yytname is YY_NULLPTR */
    unsigned long l = yytname_len - 1;
    VALUE ary = rb_ary_new_capa(l);

    for (unsigned long i = 0; i < l; i++) {
        rb_ary_push(ary, rb_str_new_cstr(yytname[i]));
    }

    return ary;
}

static VALUE
rb_parsey_s_yytoknum(VALUE module)
{
    VALUE ary = rb_ary_new_capa(yytoknum_len);

    for (unsigned long i = 0; i < yytoknum_len; i++) {
        rb_ary_push(ary, INT2FIX(yytoknum[i]));
    }

    return ary;
}

static VALUE
rb_parsey_s_yypact(VALUE module)
{
    VALUE ary = rb_ary_new_capa(yypact_len);

    for (unsigned long i = 0; i < yypact_len; i++) {
        rb_ary_push(ary, INT2FIX(yypact[i]));
    }

    return ary;
}

static VALUE
rb_parsey_s_yydefact(VALUE module)
{
    VALUE ary = rb_ary_new_capa(yydefact_len);

    for (unsigned long i = 0; i < yydefact_len; i++) {
        rb_ary_push(ary, INT2FIX(yydefact[i]));
    }

    return ary;
}

static VALUE
rb_parsey_s_yypgoto(VALUE module)
{
    VALUE ary = rb_ary_new_capa(yypgoto_len);

    for (unsigned long i = 0; i < yypgoto_len; i++) {
        rb_ary_push(ary, INT2FIX(yypgoto[i]));
    }

    return ary;
}

static VALUE
rb_parsey_s_yydefgoto(VALUE module)
{
    VALUE ary = rb_ary_new_capa(yydefgoto_len);

    for (unsigned long i = 0; i < yydefgoto_len; i++) {
        rb_ary_push(ary, INT2FIX(yydefgoto[i]));
    }

    return ary;
}

static VALUE
rb_parsey_s_yytable(VALUE module)
{
    VALUE ary = rb_ary_new_capa(yytable_len);

    for (unsigned long i = 0; i < yytable_len; i++) {
        rb_ary_push(ary, INT2FIX(yytable[i]));
    }

    return ary;
}

static VALUE
rb_parsey_s_yycheck(VALUE module)
{
    VALUE ary = rb_ary_new_capa(yycheck_len);

    for (unsigned long i = 0; i < yycheck_len; i++) {
        rb_ary_push(ary, INT2FIX(yycheck[i]));
    }

    return ary;
}

static VALUE
rb_parsey_s_yystos(VALUE module)
{
    VALUE ary = rb_ary_new_capa(yystos_len);

    for (unsigned long i = 0; i < yystos_len; i++) {
        rb_ary_push(ary, INT2FIX(yystos[i]));
    }

    return ary;
}

static VALUE
rb_parsey_s_yyr1(VALUE module)
{
    VALUE ary = rb_ary_new_capa(yyr1_len);

    for (unsigned long i = 0; i < yyr1_len; i++) {
        rb_ary_push(ary, INT2FIX(yyr1[i]));
    }

    return ary;
}

static VALUE
rb_parsey_s_yyr2(VALUE module)
{
    VALUE ary = rb_ary_new_capa(yyr2_len);

    for (unsigned long i = 0; i < yyr2_len; i++) {
        rb_ary_push(ary, INT2FIX(yyr2[i]));
    }

    return ary;
}

static VALUE
rb_parsey_s_yypact_ninf(VALUE module)
{
    return INT2FIX(YYPACT_NINF);
}

static VALUE
rb_parsey_s_yylast(VALUE module)
{
    return INT2FIX(YYLAST);
}

static VALUE
rb_parsey_s_yyntokens(VALUE module)
{
    return INT2FIX(YYNTOKENS);
}

static VALUE
rb_parsey_s_yynnts(VALUE module)
{
    return INT2FIX(YYNNTS);
}

static VALUE
rb_parsey_s_yynrules(VALUE module)
{
    return INT2FIX(YYNRULES);
}

static VALUE
rb_parsey_s_yynstates(VALUE module)
{
    return INT2FIX(YYNSTATES);
}

void
Init_parzer(void)
{
    VALUE mParzer = rb_define_module("Parzer");
    cBisonWrapper = rb_define_class_under(mParzer, "BisonWrapper", rb_cObject);

    rb_define_method(cBisonWrapper, "yyparse", rb_parsey_yyparse, 0);
    rb_define_method(cBisonWrapper, "enable_yydebug", rb_parsey_enable_yydebug, 0);
    rb_define_method(cBisonWrapper, "disable_yydebug", rb_parsey_disable_yydebug, 0);

    rb_define_singleton_method(mParzer, "yytranslate", rb_parsey_s_yytranslate, 0);
    rb_define_singleton_method(mParzer, "yyrline", rb_parsey_s_yyrline, 0);
    rb_define_singleton_method(mParzer, "yytname", rb_parsey_s_yytname, 0);
    rb_define_singleton_method(mParzer, "yytoknum", rb_parsey_s_yytoknum, 0);
    rb_define_singleton_method(mParzer, "yypact", rb_parsey_s_yypact, 0);
    rb_define_singleton_method(mParzer, "yydefact", rb_parsey_s_yydefact, 0);
    rb_define_singleton_method(mParzer, "yypgoto", rb_parsey_s_yypgoto, 0);
    rb_define_singleton_method(mParzer, "yydefgoto", rb_parsey_s_yydefgoto, 0);
    rb_define_singleton_method(mParzer, "yytable", rb_parsey_s_yytable, 0);
    rb_define_singleton_method(mParzer, "yycheck", rb_parsey_s_yycheck, 0);
    rb_define_singleton_method(mParzer, "yystos", rb_parsey_s_yystos, 0);
    rb_define_singleton_method(mParzer, "yyr1", rb_parsey_s_yyr1, 0);
    rb_define_singleton_method(mParzer, "yyr2", rb_parsey_s_yyr2, 0);
    rb_define_singleton_method(mParzer, "yypact_ninf", rb_parsey_s_yypact_ninf, 0);
    rb_define_singleton_method(mParzer, "yylast", rb_parsey_s_yylast, 0);
    rb_define_singleton_method(mParzer, "yyntokens", rb_parsey_s_yyntokens, 0);
    rb_define_singleton_method(mParzer, "yynnts", rb_parsey_s_yynnts, 0);
    rb_define_singleton_method(mParzer, "yynrules", rb_parsey_s_yynrules, 0);
    rb_define_singleton_method(mParzer, "yynstates", rb_parsey_s_yynstates, 0);
}
