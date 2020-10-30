%{
#include <stdio.h>
#include "y.tab.h"
#include<ctype.h>
#include<malloc.h>
int yylex();
void comment();
int check_type();
YYSTYPE yylval;
YYLTYPE yylloc;
/*Para el tipo del token CONSTANT*/
#define INTVAL 0
#define DOUBLEVAL 1
#define CHARVAL 2
char *buffer = NULL;
int buffer_size = 0;
#define isodigit(x) ((x) >= '0' && (x) <='7')
#define hextoint(x) (isdigit((x)) ? (x) - '0' : ((x) - 'A') + 10)
void yyerror(char *message);
#define YY_USER_ACTION {yylloc.first_column = yylloc.last_column + 1; yylloc.last_column = yylloc.first_column + yyleng - 1;}
%}

D			[0-9]
L			[a-zA-Z_]
H			[a-fA-F0-9]
E			[Ee][+-]?{D}+
FS			(f|F|l|L)
IS			(u|U|l|L)*
hex         (x|X)[0-9a-fA-F]{1,2}
oct         [0-7]{1,3}
%x INSTRING INCHAR

%%
"/*"			{ comment(); }

"auto"			{return(AUTO); }
"break"			{return(BREAK); }
"case"			{return(CASE); }
"char"			{return(CHAR); }
"const"			{return(CONST); }
"continue"		{return(CONTINUE); }
"default"		{return(DEFAULT); }
"do"			{return(DO); }
"double"		{return(DOUBLE); }
"else"			{return(ELSE); }
"enum"			{return(ENUM); }
"extern"		{return(EXTERN); }
"float"			{return(FLOAT); }
"for"			{return(FOR); }
"goto"			{return(GOTO); }
"if"			{return(IF); }
"int"			{return(INT); }
"long"			{return(LONG); }
"register"		{return(REGISTER); }
"return"		{return(RETURN); }
"short"			{return(SHORT); }
"signed"		{return(SIGNED); }
"sizeof"		{return(SIZEOF); }
"static"		{return(STATIC); }
"struct"		{return(STRUCT); }
"switch"		{return(SWITCH); }
"typedef"		{return(TYPEDEF); }
"union"			{return(UNION); }
"unsigned"		{return(UNSIGNED); }
"void"			{return(VOID); }
"volatile"		{return(VOLATILE); }
"while"			{return(WHILE); }

{L}({L}|{D})*		    {   /*Lee nombre de variables o funciones*/
                            yylval.str = strdup(yytext); 
                            
                            return(check_type()); 
                        }

0[xX]{H}+{IS}?		    {   /*Lee caraceres hexadecimales y los convierte a entero*/
                            yylval.val.ival = strtol(yytext,NULL,16); 
                            yylval.val.typ = INTVAL;

                            return(CONSTANT); 
                        }

0{D}+{IS}?		        {   /*Lee caracteres octales y los convierte a entero*/
                            yylval.val.ival = strtol(yytext,NULL,8);
                            yylval.val.typ = INTVAL;
                            
                            return(CONSTANT); 
                        }
{D}+{IS}?		        {   /*Lee digitos enteros*/
                            yylval.val.ival = atol(yytext);
                            yylval.val.typ = INTVAL; 

                            return(CONSTANT); 
                        }

{D}+{E}{FS}?		    {   /*Lee digitos con exponenciales*/
                            yylval.val.dval = atof(yytext);
                            yylval.val.typ = DOUBLEVAL;

                            return(CONSTANT); 
                        }

{D}*"."{D}+({E})?{FS}?	{   /*Lee digitos exponenciales con decimal*/
                            yylval.val.dval = atof(yytext);
                            yylval.val.typ = DOUBLEVAL;

                            return(CONSTANT); 
                        }

{D}+"."{D}*({E})?{FS}?	{   /*Segunda manera de leer los digitos exponenciales con punto decimal*/
                            yylval.val.dval = atof(yytext);
                            yylval.val.typ = DOUBLEVAL;

                            return(CONSTANT); 
                        }

L?\"                    {   /*Busca el inicio de una cadena que empieza por comillas*/
                            buffer = malloc(1);
                            buffer_size = 1; 
                            strcpy(buffer,""); 
                            BEGIN(INSTRING);
                        }

L?\'                    {   /*Busca el inicio de una cadena que empieza con apostrofe*/
                            buffer = malloc(1);
                            buffer_size = 1; 
                            strcpy(buffer,""); 
                            BEGIN(INCHAR);
                        }

<INSTRING,INCHAR>\n     {   yyerror("Unterminates character or string literal");
                            free(buffer);
                            BEGIN(INITIAL);
                        }

<INSTRING,INCHAR><<EOF>> {   yyerror("EOF in string");
                            free(buffer);
                            BEGIN(INITIAL);
                        }

<INSTRING,INCHAR>[^\\\n"'] {buffer = realloc(buffer,buffer_size+yyleng+1);
                            buffer_size += yyleng;
                            strcat(buffer,yytext);
                            if(YY_START==INCHAR && buffer_size>2)
                                yyerror("Illegal length of character literal");
                            }
<INSTRING>\\\n          /*Ignore this*/

<INSTRING,INCHAR>\\{hex} {  int temp = 0, loop = 0;
                            for(loop=yyleng-2; loop>0; loop--){
                                temp <<= 4;
                                temp += hextoint(toupper(yytext[yyleng-loop]));
                            }
                            buffer = realloc(buffer,buffer_size+1);
                            buffer[buffer_size-1] = temp;
                            buffer[buffer_size] = '\0';
                            buffer_size += 1;
                            if(YY_START==INCHAR && buffer_size>2)
                                yyerror("Illegal length of character literal");
                            }

<INSTRING,INCHAR>\\{oct} {  int temp = 0, loop = 0;
                            for(loop=yyleng-1; loop>0; loop--){
                                temp <<= 3;
                                temp += (yytext[yyleng-loop] - '0');
                            }
                            buffer = realloc(buffer,buffer_size+1);
                            buffer[buffer_size-1] = temp;
                            buffer[buffer_size] = '\0';
                            buffer_size += 1;
                            if(YY_START==INCHAR && buffer_size>2)
                                yyerror("Illegal length of character literal");
                            }

<INSTRING,INCHAR>\\[^\n] {  buffer = realloc(buffer, buffer_size+1);
                            switch(yytext[yyleng-1]){
                                case 'b' : buffer[buffer_size-1] = '\b'; break;
                                case 't' : buffer[buffer_size-1] = '\t'; break;
                                case 'n' : buffer[buffer_size-1] = '\n'; break;
                                case 'v' : buffer[buffer_size-1] = '\v'; break;
                                case 'f' : buffer[buffer_size-1] = '\f'; break;
                                case 'r' : buffer[buffer_size-1] = '\r'; break;
                                default  : buffer[buffer_size-1] = yytext[yyleng-1]; 
                            }
                            buffer[buffer_size] = '\0';
                            buffer_size += 1;
                            if(YY_START==INCHAR && buffer_size>2)
                                yyerror("Illegal length of character literal");
                        }

<INSTRING,INCHAR>\"     {   if(YY_START==INSTRING){
                                yylval.str = buffer;
                                BEGIN(INITIAL);
                                return(STRING_LITERAL);
                            }
                            buffer = realloc(buffer,buffer_size+yyleng+1);
                            buffer_size += yyleng;
                            strcat(buffer,yytext);
                            if(buffer_size>2)
                                yyerror("Illegal length of character literal");
                        }

<INSTRING,INCHAR>\'     {   if(YY_START==INCHAR){
                                yylval.val.cval = buffer[0];
                                if(buffer_size>2)
                                    yyerror("Illegal length of character literal");
                                yylval.val.typ = CHARVAL;

                                free(buffer);
                                BEGIN(INITIAL);
                                return(CONSTANT);
                            }
                            buffer = realloc(buffer,buffer_size+yyleng+1);
                            buffer_size += yyleng;
                            strcat(buffer,yytext);
                        }    


"..."			{   return(ELLIPSIS); }
">>="			{   return(RIGHT_ASSIGN); }
"<<="			{   return(LEFT_ASSIGN); }
"+="			{   return(ADD_ASSIGN); }
"-="			{   return(SUB_ASSIGN); }
"*="			{   return(MUL_ASSIGN); }
"/="			{   return(DIV_ASSIGN); }
"%="			{   return(MOD_ASSIGN); }
"&="			{   return(AND_ASSIGN); }
"^="			{   return(XOR_ASSIGN); }
"|="			{   return(OR_ASSIGN); }
">>"			{   return(RIGHT_OP); }
"<<"			{   return(LEFT_OP); }
"++"			{   return(INC_OP); }
"--"			{   return(DEC_OP); }
"->"			{   return(PTR_OP); }
"&&"			{   return(AND_OP); }
"||"			{   return(OR_OP); }
"<="			{   return(LE_OP); }
">="			{   return(GE_OP); }
"=="			{   return(EQ_OP); }
"!="			{   return(NE_OP); }
";"			    {   return(';'); }
("{"|"<%")		{   return('{'); }
("}"|"%>")		{   return('}'); }
","			    {   return(','); }
":"			    {   return(':'); }
"="			    {   return('='); }
"("			    {   return('('); }
")"			    {   return(')'); }
("["|"<:")		{   return('['); }
("]"|":>")		{   return(']'); }
"."			    {   return('.'); }
"&"			    {   return('&'); }
"!"			    {   return('!'); }
"~"			    {   return('~'); }
"-"			    {   return('-'); }
"+"			    {   return('+'); }
"*"			    {   return('*'); }
"/"			    {   return('/'); }
"%"			    {   return('%'); }
"<"			    {   return('<'); }
">"			    {   return('>'); }
"^"			    {   return('^'); }
"|"			    {   return('|'); }
"?"			    {   return('?'); }

[ \t\v\f\r]		{
                }
\n              {   yylloc.first_line++;
                    yylloc.first_column = yylloc.last_column = 0;
                }                
.			{ /* ignore bad characters */ }

%%

int yywrap()
{
	return(1);
}

void yyerror(char *message){
    printf("\nError: %s at line %d clumn %d\n",message, yylloc.first_line+1, yylloc.first_column+1);
    exit(1);
}

void comment()
{
	char c, c1;

loop:
	while ((c = input()) != '*' && c != 0)
		if(c=='\n'){
            yylloc.first_line++;
            yylloc.first_column = 0;
        }

	if ((c1 = input()) != '/' && c != 0)
	{
		unput(c1);
		goto loop;
	}

	if (c != 0 && c=='\n'){
        yylloc.first_line++;
        yylloc.first_column = 0;
    }
}


int check_type()
{
/*
* pseudo code --- this is what it should check
*
*	if (yytext == type_name)
*		return(TYPE_NAME);
*
*	return(IDENTIFIER);
*/

/*
*	it actually will only return IDENTIFIER
*/

	return(IDENTIFIER);
}

void printchr(char c){
    if(c == '\a'){
        printf("\\a");
    }
    else if(c == '\b'){
        printf("\\b");
    }
    else if(c == '\f'){
        printf("\\f");
    }
    else if(c == '\n'){
        printf("\\n");
    }
    else if(c == '\r'){
        printf("\\r");
    }
    else if(c == '\t'){
        printf("\\t");
    }
    else if(c == '\v'){
        printf("\\v");
    }
    else
        printf("%c",c);
}

void printstr(char *str){
    char c;
    while((c = *str++) != '\0'){
        printchr(c);
    }
}

char *stoken[] = {
    "IDENTIFIER",
    "CONSTANT",
    "STRING_LITERAL",
    "SIZEOF",
    "PTR_OP",
    "INC_OP",
    "DEC_OP",
    "LEFT_OP",
    "RIGHT_OP",
    "LE_OP",
    "GE_OP",
    "EQ_OP",
    "NE_OP",
    "AND_OP",
    "OR_OP",
    "MUL_ASSIGN",
    "DIV_ASSIGN",
    "MOD_ASSIGN",
    "ADD_ASSIGN",
    "SUB_ASSIGN",
    "LEFT_ASSIGN",
    "RIGHT_ASSIGN",
    "AND_ASSIGN",
    "XOR_ASSIGN",
    "OR_ASSIGN",
    "TYPE_NAME",
    "TYPEDEF",
    "EXTERN",
    "STATIC",
    "AUTO",
    "REGISTER",
    "CHAR",
    "SHORT",
    "INT",
    "LONG",
    "SIGNED",
    "UNSIGNED",
    "FLOAT",
    "DOUBLE",
    "CONST",
    "VOLATILE",
    "VOID",
    "STRUCT",
    "UNION",
    "ENUM",
    "ELLIPSIS",
    "CASE",
    "DEFAULT",
    "IF",
    "ELSE",
    "SWITCH",
    "WHILE",
    "DO",
    "FOR",
    "GOTO",
    "CONTINUE",
    "BREAK",
    "RETURN"
};

int main(int argc, const char* argv[]){
    int d;
    if(argc >= 0)
        yyin = fopen(argv[1], "r");
    while((d = yylex()) !=0){
       
        if(d>=IDENTIFIER && d<=RETURN){
            printf("<%s",stoken[d-IDENTIFIER]);
            switch(d){
                case IDENTIFIER:
                    printf(",%s",yylval.str);
                    break;
                case CONSTANT:
                    switch(yylval.val.typ){
                        case INTVAL:
                            printf(",%d",yylval.val.ival);
                            break;
                        case DOUBLEVAL:
                            printf(",%g",yylval.val.dval);
                            break;
                        case CHARVAL:
                            printf(",'");
                            printf(",%d",yylval.val.cval);
                            printf("'");
                            break;
                    }
                    break;
                case STRING_LITERAL:
                    printf(",\"");
                    printstr(yylval.str);
                    printf("\"");
                    break;       
            }
            printf(">");
        }
        else
            printf("%c",d);
    }
    printf("\n");
    return 0;
}