%{
#include<stdio.h>
#include<string.h>
#define ifcomment 0
#define ifstring 1
#define ifkeyword 2
#define ifidentifier 3
#define ifoperator 4
#define ifdigit 5

int lnnumber = 0;
int tablelength = 0;
struct sym_table
{
	char name[20];
	char value[50];
	int lnnumber;
}table[100];
%}
%%

\/\*([^*]|[\r\n]|(\*+([^*/]|[\r\n])))*\*+\/|\/\/.* {fprintf(yyout,"%s","");}


\".*\" {fprintf(yyout,"%s",yytext); inserttable(ifstring, yytext);}


if|while|else|int|float|double|long|continue|break|default|switch|case {fprintf(yyout,"%s",yytext); inserttable(ifkeyword, yytext);}


[a-zA-Z_][a-zA-Z0-9_]* {fprintf(yyout,"%s",yytext); inserttable(ifidentifier, yytext);}


\+|=|-|\*|\/|<|>|==|<=|>=|&&|\|\|\(|\)|\{|\}|; {fprintf(yyout,"%s",yytext); inserttable(ifoperator, yytext);}


[0-9]+[.]?[0-9]* {fprintf(yyout,"%s",yytext); inserttable(0, yytext); inserttable(ifdigit, yytext);}


\n\n+ {++lnnumber;}


. {fprintf(yyout,"%s",yytext);}

%%
int main(int argc, char *argv[10])
{
	
	tablelength = 0;
	lnnumber = 1;
	
	yyin = fopen(argv[1],"r");

	yyout = fopen(argv[2],"w");
	

	yylex();

	fclose(yyout);

	int i = 0;
	
	printf("Line number,Token Name,Token Value");
	printf("\n");
	for (i=0;i<tablelength;++i)
	{
		printf("%d,%s,%s",  table[i].lnnumber, table[i].name, table[i].value);
		printf("\n");
	}	
	return 0;

}

int inserttable (int type,char* textstring)
{
    if(type==1)
    {
   			table[tablelength].lnnumber = lnnumber;
			strcpy(table[tablelength].name,"String");		
			strcpy(table[tablelength].value,textstring);						 
			
    }
    else if(type==2)
    {
    		table[tablelength].lnnumber = lnnumber;
			strcpy(table[tablelength].name,"Keyword");		
			strcpy(table[tablelength].value,textstring);
			
    }
    else if(type==3)
    {
    		table[tablelength].lnnumber = lnnumber;
			strcpy(table[tablelength].name,"Identifier");		
			strcpy(table[tablelength].value,textstring);
			
    }
    else if(type==4)
    {
    		table[tablelength].lnnumber = lnnumber;
			strcpy(table[tablelength].name,"Operator");		
			strcpy(table[tablelength].value,textstring);
			
    
    }
    else if(type==5)
    {
    		table[tablelength].lnnumber = lnnumber;
			strcpy(table[tablelength].name,"Digit");	
			strcpy(table[tablelength].value,textstring);
    }
    else
    {
    		
    }
	
	tablelength++;
}

int yywrap()
{
return 1;
}

