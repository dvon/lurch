%option noyywrap

%{

#define FALSE 0
#define TRUE 1

FILE *trans = NULL;
int i = 0, ands = 0;
int dash = TRUE, in_code = FALSE, out_code = FALSE;
int before_all = FALSE, before = FALSE, before_each = FALSE, score = FALSE, after_all = FALSE,
  after = FALSE, after_each = FALSE, hash = FALSE, print = FALSE, tr_incr = FALSE;

%}

%x C_COMMENT
%x NOW
%x NOW_COMMENT
%x IN
%x OUT
%x NEXT

%%

<INITIAL>\%                   { fprintf(trans, "%%"); }
<INITIAL>^"void _before_all"  { before_all = TRUE; fprintf(trans, "%s", yytext); }
<INITIAL>^"void _before"      { before = TRUE; fprintf(trans, "%s", yytext); }
<INITIAL>^"void _before_each" { before_each = TRUE; fprintf(trans, "%s", yytext); }
<INITIAL>^"void _score"       { score = TRUE; fprintf(trans, "%s", yytext); }
<INITIAL>^"void _after_all"   { after_all = TRUE; fprintf(trans, "%s", yytext); }
<INITIAL>^"void _after"       { after = TRUE; fprintf(trans, "%s", yytext); }
<INITIAL>^"void _after_each"  { after_each = TRUE; fprintf(trans, "%s", yytext); }
<INITIAL>^"void _hash"        { hash = TRUE; fprintf(trans, "%s", yytext); }
<INITIAL>^"void _print"       { print = TRUE; fprintf(trans, "%s", yytext); }
<INITIAL>^"void _tr_incr"     { tr_incr = TRUE; fprintf(trans, "%s", yytext); }
<INITIAL>.|\n                 { fprintf(trans, "%s", yytext); }
<INITIAL>^\%\%[ \t]*\n*       { !before_all ? fprintf(trans, "void _before_all(void) {}\n") :
                                  fprintf(trans, "/* void _before_all(void) {} */\n");
                                !before ? fprintf(trans, "void _before(void) {}\n") :
                                  fprintf(trans, "/* void _before(void) {} */\n");
                                !before_each ? fprintf(trans, "void _before_each(void) {}\n") :
                                  fprintf(trans, "/* void _before_each(void) {} */\n");
			        !score ? fprintf(trans, "void _score(void) {}\n") :
                                  fprintf(trans, "/* void _score(void) {} */\n");
                                !after_all ? fprintf(trans, "void _after_all(void) {}\n") :
                                  fprintf(trans, "/* void _after_all(void) {} */\n");
                                !after ? fprintf(trans, "void _after(void) {}\n") :
                                  fprintf(trans, "/* void _after(void) {}*/\n");
                                !after_each ? fprintf(trans, "void _after_each(void) {}\n") :
                                  fprintf(trans, "/* void _after_each(void) {} */\n");
                                !hash ? fprintf(trans, "void _hash(unsigned int *h) {}\n") :
                                  fprintf(trans, "/* void _hash(unsigned int *h) {} */\n");
                                !print ? fprintf(trans, "void _print(char *c) { *c = '\\0'; }\n") :
                                  fprintf(trans, "/* void _print(char *c) { *c = '\\0'; } */\n");
			        !tr_incr ? fprintf(trans, "void _tr_incr(_Tran *tr) {}\n") :
                                  fprintf(trans, "/* void _tr_incr(_Tran *tr) {} */");
                                fprintf(trans, "int _in(int and) { return _trans(and, _IN); }\n");
	                        fprintf(trans, "int _out(int and) { return _trans(and, _OUT); }\n");
	                        fprintf(trans, "int _trans(int and, int caller)\n");
	                        fprintf(trans, "{\n  switch (and)\n    {\n"); BEGIN NOW; }
<INITIAL>"/*"                 { fprintf(trans, "%s", yytext); BEGIN C_COMMENT; }

<C_COMMENT>"*/"               { fprintf(trans, "%s", yytext); BEGIN INITIAL; }
<C_COMMENT>.|\n               { fprintf(trans, "%s", yytext); }

<NOW>[ \t]+                   { }
<NOW>.+:                      { ECHO; fprintf(yyout, " "); }
<NOW>[^.;]                    { ECHO; } 
<NOW>(;|.)[ \t]*\n            { ECHO; } 
<NOW>\.|;                     { fprintf(yyout, "%s ", yytext); ands++; BEGIN IN; }

<IN>[ \t]+                    { if (i) fprintf(trans, "%s", yytext); }
<IN>\(                        { if (!i++) { in_code = TRUE; fprintf(trans,
                                  "      case %i :\n        if (caller == _IN) return ", ands); }
                                fprintf(trans, "%s", yytext); }
<IN>\)                        { fprintf(trans, "%s", yytext); if (!--i) fprintf(trans, ";\n"); }
<IN>,/[ \t]*\(                { if (i) fprintf(trans, "%s", yytext); else dash = FALSE; }
<IN>,                         { if (i) fprintf(trans, "%s", yytext); else { dash = FALSE; fprintf(yyout, ", "); } }
<IN>[^;]                      { if (i) fprintf(trans, "%s", yytext); else ECHO; }
<IN>;                         { if (i) fprintf(trans, "%s", yytext);
                                else { if (dash && in_code) fprintf(yyout, "-"); dash = TRUE;
                                  fprintf(yyout, "; "); BEGIN OUT; } }

<OUT>[ \t]+                   { if (i) fprintf(trans, "%s", yytext); }
<OUT>\{                       { if (!i++) { if (!in_code) { fprintf(trans,
		                    "      case %i :\n        if (caller == _IN) return _TRUE;\n", ands); }
                                  out_code = TRUE; fprintf(trans, "        if (caller == _OUT) "); }
                                fprintf(trans, "%s", yytext); }
<OUT>\}                       { fprintf(trans, "%s", yytext); if (!--i) fprintf(trans, " return _TRUE;\n"); }
<OUT>,/[ \t]*\{               { if (i) fprintf(trans, "%s", yytext); else dash = FALSE; }
<OUT>,                        { if (i) fprintf(trans, "%s", yytext); else { dash = FALSE; fprintf(yyout, ", "); } }
<OUT>[^;]                     { if (i) fprintf(trans, "%s", yytext); else ECHO; }
<OUT>;                        { if (i) fprintf(trans, "%s", yytext);
                                else { if (in_code && !out_code) { fprintf(trans,
			            "        if (caller == _OUT) return _TRUE;\n"); }
                                  if (dash && out_code) fprintf(yyout, "-");
                                  dash = TRUE; in_code = out_code = FALSE; fprintf(yyout, "; "); BEGIN NEXT; } }

<NEXT>[ \t]+                  { }
<NEXT>[^;.]                   { ECHO; }
<NEXT>\.|;                    { fprintf(yyout, "%s ", yytext); BEGIN NOW; }

%%

int main(int argc, char **argv)
{
  if (((trans = fopen("trans.c", "w")) != NULL) &&
      ((yyin = fopen(*++argv, "r")) != NULL) &&
      ((yyout = fopen("states", "w")) != NULL))
    {
      fprintf(trans, "#include \"lurch.h\"\n");
      fprintf(trans, "#define _FALSE 0\n");
      fprintf(trans, "#define _TRUE 1\n\n");
      fprintf(trans, "enum { _IN, _OUT };\n\n");
      yylex();
      fprintf(trans, "      default : return _TRUE;\n");
      fprintf(trans, "    }\n");
      fprintf(trans, "}\n");
      fclose(trans);
      fprintf(yyout, "\n");
      fclose(yyin);
      fclose(yyout);
      system("flex -olurch.c lurch.lex\n");
      system("gcc lurch.c trans.c -o lurch\n");
    }

  return 0;
}

