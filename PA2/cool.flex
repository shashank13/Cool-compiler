/*
 *  The scanner definition for COOL.
 */

/*
 *  Stuff enclosed in %{ %} in the first section is copied verbatim to the
 *  output, so headers and global definitions are placed here to be visible
 * to the code in the file.  Don't remove anything that was here initially
 */
%{
#include <cool-parse.h>
#include <stringtab.h>
#include <utilities.h>

/* The compiler assumes these identifiers. */
#define yylval cool_yylval
#define yylex  cool_yylex
 
/* Max size of string constants */
#define MAX_STR_CONST 1025
#define YY_NO_UNPUT   /* keep g++ happy */

extern FILE *fin; /* we read from this file */

/* define YY_INPUT so we read from the FILE fin:
 * This change makes it possible to use this scanner in
 * the Cool compiler.
 */
#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
	if ( (result = fread( (char*)buf, sizeof(char), max_size, fin)) < 0) \
		YY_FATAL_ERROR( "read() in flex scanner failed");

char string_buf[MAX_STR_CONST]; /* to assemble string constants */
char *string_buf_ptr;
int string_buf_cnt;
int NestCommentCount = 0;
extern int curr_lineno;
extern int verbose_flag;

extern YYSTYPE cool_yylval;

/*
 *  Add Your own definitions here
 */
bool string_contain_nullCharacter = false;
bool string_buf_add(char c) {
	if (string_buf_cnt >= MAX_STR_CONST) {
		string_buf_cnt++;
		return false;
	}
	string_buf[string_buf_cnt++] = c;
	return true;
}
void string_buf_clear() {
	string_buf_cnt = 0;
}
%}

/*
 * Define names for regular expressions here.
 */

DARROW          =>
IF 		[iI][fF]
FI		[fF][iI]
IN		[iI][nN]
%x STRING_CONST NestedComment DashComment
%%

 /*
  *  Nested comments
  */
"--" { BEGIN(DashComment); }
<DashComment,NestedComment,INITIAL>"\n" {
	curr_lineno++;
	if (YYSTATE == DashComment)	
		BEGIN(INITIAL);
}
<DashComment>. {}

<NestedComment>\\(.|\n) {}

<INITIAL,NestedComment>"(*" {
	if (NestCommentCount == 0)
		BEGIN(NestedComment);
	NestCommentCount++;
	//printf("YYSTATE = %d %d\n",YYSTATE, NestCommentCount);
}
<NestedComment>"(" {}
<NestedComment>[^(*\n\\]* { }
<NestedComment>"*"+[^(*)\n\\]*
<NestedComment><<EOF>> {
	BEGIN(INITIAL);
	cool_yylval.error_msg = "EOF in a nested comment";
	return ERROR;
}
<INITIAL,NestedComment>"*"+")" {
	if (NestCommentCount == 0) {
		cool_yylval.error_msg = "Close comment parentheses didn't match open parentheses";
		return ERROR;
	}
	if (--NestCommentCount == 0) 
		BEGIN(INITIAL);
}


 /*
  *  The multiple-character operators.
  */


 /*
  * Keywords are case-insensitive except for the values true and false,
  * which must begin with a lower-case letter.
  */

f[Aa][Ll][Ss][Ee] {
	cool_yylval.boolean = false;
	return BOOL_CONST;
}
t[Rr][Uu][Ee] {
	cool_yylval.boolean = true;
	return BOOL_CONST;
}
[lL][fF]		{ return IF; }
[cC][lL][aA][sS][sS] { 
	return CLASS; 
}
[eE][Ll][Ss][Ee] { return ELSE; }
[Ff][Ii] { return FI; }
[Ii][Ff] { return IF; }
[Ii][Nn] { return IN; }
[Ii][Nn][Hh][Ee][Rr][Ii][Tt][Ss] { return INHERITS; }
[Ii][Ss][Vv][Oo][Ii][Dd] { return ISVOID; }
[Ll][Ee][Tt] { return LET; }
[Ll][Oo][Oo][Pp] { return LOOP; }
[Pp][Oo][Oo][Ll] { return POOL; }
[Tt][Hh][Ee][Nn] { return THEN; }
[Ww][Hh][Ii][Ll][Ee] { return WHILE; }
[Cc][Aa][Ss][Ee] { return CASE; }
[Ee][Ss][Aa][Cc] { return ESAC; }
[Nn][Ee][Ww] {  return NEW; }
[Oo][Ff] { return OF; }
[Nn][Oo][Tt] { return NOT; }

 /*
  *  String constants (C syntax)
  *  Escape sequence \c is accepted for all characters c. Except for 
  *  \n \t \b \f, the result is c.
  *
  */
\"	{ 
		string_buf_clear();
		BEGIN STRING_CONST;
}
<STRING_CONST>\" {	
		if (string_buf_cnt >= MAX_STR_CONST) {
			cool_yylval.error_msg = "string_const is too long, bigger than 1024 characters";
			BEGIN(INITIAL);
			return ERROR;
		}
		if (string_contain_nullCharacter) {
			string_contain_nullCharacter = false;
			cool_yylval.error_msg = "string_const contain null character";
			BEGIN(INITIAL);
			return ERROR;
		}
		string_buf[string_buf_cnt] = '\0';
		//printf("!!! %s %s\n",yytext, string_buf);
		cool_yylval.symbol = stringtable.add_string(string_buf);
		BEGIN(INITIAL);
		return STR_CONST;
}
<STRING_CONST><<EOF>> { 
	cool_yylval.error_msg = "EOF in a string"; 
	BEGIN(INITIAL);
	return ERROR; 
}
<STRING_CONST>"\0" { string_contain_nullCharacter = true; } 
<STRING_CONST>\\"\0" { string_contain_nullCharacter = true; } 
<STRING_CONST>\n { 
	cool_yylval.error_msg = "STR_CONST contain non-escaped newline";
	BEGIN(INITIAL);
	return ERROR; 
}
<STRING_CONST>\\t	{ string_buf_add('\t'); }
<STRING_CONST>\\n   { string_buf_add('\n'); }
<STRING_CONST>\\b   { string_buf_add('\b'); }
<STRING_CONST>\\f   { string_buf_add('\f'); }
<STRING_CONST>\\[^\0]	{ 
	//if (string_buf_cnt > 1000) printf("%d\n",string_buf_cnt);
	if (yytext[1] == '\n') {
		curr_lineno++;
	}
	string_buf_add(yytext[1]);
}
<STRING_CONST>[^\\\n\"\0]+  {
                 char *yptr = yytext;
                 	while ( *yptr )
                 	{
                    	string_buf_add(*yptr++);                
                    }
                 }

 /*
  * Integers, Identifiers, and Special Notation
  *
  */
[0-9]+	{
	cool_yylval.symbol = inttable.add_string(yytext);
	return INT_CONST; 
}

[a-z][a-zA-Z0-9_]*	{
	cool_yylval.symbol = idtable.add_string(yytext);
	return OBJECTID;
}

[A-Z][a-zA-Z0-9_]*	{
	cool_yylval.symbol = idtable.add_string(yytext);
	return TYPEID;
}
"=>" { return DARROW; }
"<-" { return ASSIGN; }
"<=" { return LE; }

[\f\r\t\v ] 			/* eat whitespace */

"+" { return '+'; }
"/" { return('/'); }
"-" { return('-'); }
"*" { return('*'); }
"=" { return('='); }
"<" { return('<'); }
"." { return('.'); }
"~" { return('~'); }
"," { return(','); }
";" { return(';'); }
":" { return(':'); }
"(" { return('('); }
")" { return(')'); }
"@" { return('@'); }
"{" { return('{'); }
"}" { return('}'); }

. { 
	char* tp = new char[2];
	strcpy(tp, yytext);
	cool_yylval.error_msg = tp; 
	return ERROR; 
}
 /*
  * KeyWords
  *
  */
	


                               





