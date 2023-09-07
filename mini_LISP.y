%{
    #include <stdio.h>
    #include <string.h>
    #include <stdbool.h>
    #include <stdlib.h>
void yyerror(const char *message);
void Error(int cnt);
void TypeError();
int id_size = 0;
%}
%code requires
{
	struct Var
	{
		int type;			//定義回傳值類型
		int ival;			//type=1
		char string[100];	//type=2
		bool bval;			
		int result_plus;    
		int result_multi;   
		bool result_equal;  
		bool result_and;    
		bool result_or;  
	};
	struct ID_Def{
		char name[500];
		struct Var data;
	};
	struct ID_Def DefID[105];
	
}
%union{
	struct Var item;
}
%token Mod And Or Not Def If 
%token print_num print_bool
%token <item> Bool_value Number ID
%type <item> exp exps Variable
%type <item> Num_op PLUS MINUS MULTIPLY DIVIDE MODULUS GREATER SMALLER EQUAL
%type <item> Logical_op And_op Or_op Not_op
%type <item> IF_exp test_exp then_exp else_esp
%left <ival>'+' '-'
%left <ival>'*'
%%
program		: stmts	{};
stmts		: stmt stmts
			|{}
			;
stmt		: exp
			| def-stmt
			| print-stmt
			;
print-stmt	: '(' print_num exp ')'		{
											if($3.type==2){	//ID 做type checking(Bonus 2)
												//printf();
											}
											else if ($3.type==1){	//int
												printf("%d\n",$3.ival);
											}
											else{ TypeError(); return(0);}
										}
			| '(' print_bool exp ')'	{
											if($3.type==2){	//ID 做type checking(Bonus 2)
												
											}
											else if($3.type==3){ //bool
												if($3.bval) printf("#t\n");
												else	printf("#f\n");
											}
											else{ TypeError(); return(0);}
										}
			;
exp			: Bool_value	{$$.type=3; $$.bval=$1.bval;}
			| Number		{$$.type=1; $$.ival=$1.ival;$$.result_equal=true;}
			| Variable		{	//variable還沒做type checking
								int i;
								for(i = 0; i < id_size; i++){
									if(strcmp(DefID[i].name, $1.string) == 0){
										$$=DefID[i].data;
										strncpy($$.string, $1.string, (sizeof($1.string) / sizeof(char)));
									}
								}
							}
			| Num_op		{$$=$1;}
			| Logical_op	{$$=$1;}
			| IF_exp		{$$=$1;}
			;
Num_op		: PLUS		{ $$ = $1;	//$$.ival = $1.ival; $$.type=$1.type;}
			| MINUS		{ $$ = $1; }
			| MULTIPLY	{ $$ = $1; }
			| DIVIDE	{ $$ = $1; }
			| MODULUS	{ $$ = $1; }
			| GREATER	{ $$ = $1; }
			| SMALLER	{ $$ = $1; }
			| EQUAL		{ $$ = $1; }
			;
exps		: exp exps	{
							$$=$1;
							$$.result_equal=false;
							if($1.ival==$2.ival){
									$$.result_equal=true;	//當前兩個值
							}
							$$.result_equal=$$.result_equal && $2.result_equal;	 //$2.result_equal存之前的值
							$$.result_and=$1.bval && $2.result_and;
							$$.result_or=$1.bval||$2.result_or;
							$$.result_plus=$1.ival+$2.result_plus;
							$$.result_multi=$1.ival*$2.result_multi;
						}
			| exp	{
						$$=$1;
						if($1.type==3){
							$$.result_and = $1.bval;
							$$.result_or = $1.bval;
							$$.result_plus = $1.ival;
							$$.result_multi = $1.ival;
						}
						else if($1.type==1){
							$$.result_equal = true;
							$$.result_plus = $1.ival;
							$$.result_multi = $1.ival;
						}
					}
			;
PLUS		: '(''+' exp exps')'	{
										$$.type=1;
										$$.ival=$3.ival+$4.result_plus;
									}
			;
MINUS		: '(''-' exp exp')'	{
										$$.type=1;
										$$.ival=$3.ival-$4.ival;	//minus沒有連減一次兩個數字
									}
			;
MULTIPLY	: '(''*' exp exps')'	{
										$$.type=1;
										$$.ival=$3.ival*$4.result_multi;
									}
			; 
DIVIDE		:'(''/' exp exp ')'		{
										$$.type=1;
										$$.ival=$3.ival/$4.ival;
									}
			;
MODULUS	: '(' Mod exp exp ')'	{
										$$.type=1;
										$$.ival=$3.ival%$4.ival;
								}
			;
GREATER		: '(''>' exp exp ')'	{
										$$.type=3;
										$$.bval=false;
										if($3.ival>$4.ival){
											$$.bval=true;
										}
									}
			;
SMALLER		: '(''<' exp exp ')'	{
										$$.type=3;
										$$.bval=false;
										if($3.ival<$4.ival){
											$$.bval=true;
										}
									}
			;
EQUAL		: '(''=' exp exps ')'	{
										$$.type=3;
										$$.bval=false;
										if($3.ival==$4.ival){
											$$.bval=true;
										}
										$$.bval=$$.bval && $4.result_equal;
									}
			;
			
Logical_op	: And_op{$$=$1;}
			| Or_op	{$$=$1;}
			| Not_op{$$=$1;}
			;
And_op		: '(' And exp exps ')'	{
										$$.type=3;
										$$.bval=$3.bval && $4.result_and;
									}
			;
Or_op		: '(' Or exp exps ')'	{
										$$.type=3;
										$$.bval=$3.bval || $4.result_or;
									}
			;
Not_op		: '(' Not exp ')'	{
										$$.type=3;
										$$.bval=!($3.bval);
								}
			;
def-stmt	: '(' Def Variable exp ')' 	{
											DefID[id_size].data.type=$4.type;
											strncpy(DefID[id_size].name,$3.string,(sizeof($3.string)/sizeof(char)));
											DefID[id_size].data.bval=$4.bval;
											DefID[id_size].data.ival=$4.ival;
											id_size++;
										}
			;
Variable	: ID	{
						$$=$1;
						strncpy($$.string,$1.string,(sizeof($1.string)/sizeof(char)));
					}
			;
///skip function 

IF_exp		: '('If test_exp then_exp else_esp ')'	{
														if($3.type==3 && $3.bval){	//true
															$$=$4;
														}
														else if($3.type!=3){TypeError();}
														else{$$=$5;}
													}
			;
test_exp	: exp	{ $$ = $1; }
		;
then_exp	: exp	{ $$ = $1; }
			;
else_esp	: exp	{ $$ = $1; }
			;
			
%%
void yyerror (const char *message)
{
	fprintf (stderr, "%s\n",message);
		
}
void TypeError(){
	printf("Type error!\n");
	exit(0);
}
int main(int argc, char *argv[]) {
	yyparse();
    return(0);
}