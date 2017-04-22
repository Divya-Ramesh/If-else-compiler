//bottom-up parsing tries to find a rightmost derivation of a given string backwards. 
%{
#include <stdio.h>
#include <stdlib.h>

extern FILE *fp;
FILE * f1;
char st[1000][10];
int top=0;
%}
%token MAIN
%token INT VOID 
%token IF ELSE 
%token NUM ID
%token INCLUDE
%right ASGN 
%left LOR
%left LAND
%left BOR
%left BXOR
%left BAND
%left EQ NE 
%left LE GE LT GT
%left '+' '-' 
%left '*' '/' '@'
%left '~'

%nonassoc IFX IFX1
%nonassoc ELSE
  
%%

pgmstart 			: TYPE MAIN '(' ')' STMTS
				;

STMTS 	: '{' STMT1 '}'|
				;
STMT1			: STMT  STMT1
				|
				;

STMT 			: STMT_DECLARE    
				| STMT_ASSGN  
				| STMT_IF
				| ';'
				;

				

EXP 			: EXP LT{push();printf("%s\n",st[top]);} EXP {codegen_logical();}
				| EXP LE{push();printf("%s\n",st[top]);} EXP {codegen_logical();}
				| EXP GT{push();printf("%s\n",st[top]);} EXP {codegen_logical();}
				| EXP GE{push();printf("%s\n",st[top]);} EXP {codegen_logical();}
				| EXP NE{push();printf("%s\n",st[top]);} EXP {codegen_logical();}
				| EXP EQ{push();printf("%s\n",st[top]);} EXP {codegen_logical();}
				| EXP '+'{push();printf("%s\n",st[top]);} EXP {codegen_algebric();}
				| EXP '-'{push();printf("%s\n",st[top]);} EXP {codegen_algebric();}
				| EXP '*'{push();printf("%s\n",st[top]);} EXP {codegen_algebric();}
				| EXP '/'{push();printf("%s\n",st[top]);} EXP {codegen_algebric();}
                                | EXP LOR{push();printf("%s\n",st[top]);} EXP {codegen_logical();}
				| EXP LAND{push();printf("%s\n",st[top]);} EXP {codegen_logical();}
				| EXP BOR{push();printf("%s\n",st[top]);} EXP {codegen_logical();}
				| EXP BXOR{push();printf("%s\n",st[top]);} EXP {codegen_logical();}
				| EXP BAND{push();printf("%s\n",st[top]);} EXP {codegen_logical();}
				| '(' EXP ')'
				| ID {check();push();printf("%s\n",st[top]);}
				| NUM {push();printf("%s\n",st[top]);}
				;


STMT_IF 			: IF '(' EXP ')'  {if_label1();} STMTS ELSESTMT 
				;
ELSESTMT		: ELSE {if_label2();} STMTS {if_label3();}
				| {if_label3();}
				;



STMT_DECLARE 	: TYPE {setType();}  ID {STMT_DECLARE();} IDS   
				;


IDS 			: ';'
				| ','  ID {STMT_DECLARE();} IDS 
				;


STMT_ASSGN		: ID {push();printf("%s\n",st[top]);} ASGN {push();printf("%s\n",st[top]);} EXP {codegen_assign();} ';'
				;


TYPE			: INT
				| VOID
				
				;

%%

#include <ctype.h>
#include"lex.yy.c"
int count=0;


int i=0;
char temp[2]="t";

int label[200];
int lnum=0;
int ltop=0;
char type[10];
struct Table
{
	char id[20];
	char type[10];
}table[10000];
int tableCount=0;

int main(int argc, char *argv[])
{
	yyin = fopen(argv[1], "r");
	f1=fopen("output","w");
	
   if(!yyparse())
		printf("\nParsing complete\n");
	else
	{
		printf("\nParsing failed\n");
		exit(0);
	}
	
	fclose(yyin);
	fclose(f1);
	intermediateCode();
    return 0;
}
         
yyerror(char *s) {
	printf("Syntax error in line number : %d : %s %s\n", yylineno, s, yytext );
}
    
push()
{
  	strcpy(st[++top],yytext);
}

codegen_logical()
{
 	sprintf(temp,"$t%d",i);
  	fprintf(f1,"%s\t=\t%s\t%s\t%s\n",temp,st[top-2],st[top-1],st[top]);
  	top-=2;
 	strcpy(st[top],temp);
 	i++;
}

codegen_algebric()
{
 	sprintf(temp,"$t%d",i);
  	fprintf(f1,"%s\t=\t%s\t%s\t%s\n",temp,st[top-2],st[top-1],st[top]);
  	top-=2;
 	strcpy(st[top],temp);
 	i++;
}
codegen_assign()
{
 	fprintf(f1,"%s\t=\t%s\n",st[top-2],st[top]);
 	top-=3;
}
 
if_label1()
{
 	lnum++;
 	fprintf(f1,"\tif( not %s)",st[top]);
 	fprintf(f1,"\tgoto $L%d\n",lnum);
 	label[++ltop]=lnum;
}

if_label2()
{
	int x;
	lnum++;
	x=label[ltop--]; 
	fprintf(f1,"\t\tgoto $L%d\n",lnum);
	fprintf(f1,"$L%d: \n",x); 
	label[++ltop]=lnum;
}

if_label3()
{
	int y;
	y=label[ltop--];
	fprintf(f1,"$L%d: \n",y);
	top--;
}



check()
{
	char temp[20];
	strcpy(temp,yytext);
	int flag=0;
	for(i=0;i<tableCount;i++)
	{
		if(!strcmp(table[i].id,temp))
		{
			flag=1;
			break;
		}
	}
	if(!flag)
	{
		yyerror("Variable not declared");
		exit(0);
	}
}

setType()
{
	strcpy(type,yytext);
}


STMT_DECLARE()
{
	char temp[20];
	int i,flag;
	flag=0;
	strcpy(temp,yytext);
	for(i=0;i<tableCount;i++)
	{
		if(!strcmp(table[i].id,temp))
			{
			flag=1;
			break;
				}
	}
	if(flag)
	{
		yyerror("Redeclaration");
		exit(0);
	}
	else
	{
		strcpy(table[tableCount].id,temp);
		strcpy(table[tableCount].type,type);
		tableCount++;
	}
}

intermediateCode()
{      //printf("intermediate \n");
	int Labels[100000];
	char buf[100];
	f1=fopen("output","r");
	int flag=0,lineno=1;
	memset(Labels,0,sizeof(Labels));
	while(fgets(buf,sizeof(buf),f1)!=NULL)
	{
		//printf("%s",buf);
		if(buf[0]=='$'&&buf[1]=='$'&&buf[2]=='L')
		{
			int k=atoi(&buf[3]);
			Labels[k]=lineno;
			
		}
		else
		{
			lineno++;
		}
	}
	fclose(f1);
	f1=fopen("output","r");
	lineno=0;

	while(fgets(buf,sizeof(buf),f1)!=NULL)
	{
		
		if(buf[0]=='$'&&buf[1]=='$'&&buf[2]=='L')
		{
			;
		}
		else
		{
			flag=0;
			lineno++;
			printf("%3d.\t",lineno);
			int len=strlen(buf),i,flag1=0;
			for(i=len-3;i>=0;i--)
			{
				if(buf[i]=='$'&&buf[i+1]=='$'&&buf[i+2]=='L')
				{
					flag1=1;
					break;
				}
//printf("%c ** %c ** %c ** %d\n",buf[i],buf[i+1],buf[i+2],lineno);

			}
			if(flag1)
			{
				buf[i]=='\0';
				int k=atoi(&buf[i+3]),j;
				for(j=0;j<i;j++)
					printf("%c",buf[j]);
				printf(" %d\n",Labels[k]);
			}
			else printf("%s",buf);
		}
	}
	printf("%3d.\tend\n",++lineno);
	fclose(f1);
}
