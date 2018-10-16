%{
open Ast
%}

%token COMMA LPAR RPAR LSQR RSQR
%token IF ELIF ENDIF ELSE ENDFUN NEWLINE
%token WHILE ENDLOOP BREAK CONTINUE
%token TRUE FALSE
%token PLUS MINUS TIMES DIVIDE MOD
%token EQ NEQ LEQ GEQ LT GT OR AND NOT
%token EOF PIPE
%token RETURN
%token <string> TYPE
%token <string> ID
%token <string> STRING
%token <int> INT
%token <float> FLOAT
%token <bool> BOOL

%nonassoc ELSE
%left PIPE
%left OR
%left AND
%left EQ NEQ
%left LEQ GEQ LT GT
%left PLUS MINUS
%left TIMES DIVIDE MOD
%right NOT
%left LSQR RSRQ

%start program
%type <Ast.program> program
%%

/* functions are */
program:
    { [], [] }
    /*| program vdecl    { ($2 :: fst $1), snd $1 }*/
    | program fdecl    { fst $1, ($2 :: snd $1) }

/* start of decls */
fdecl:
    TYPE ID LPAR param RPAR stmt_list ENDFUN
    { { ftyp = $1;
        fname = $2;
        params = $4;
        body = List.rev $6 } }

param:
                    { [] }
    | param_list    { $1 }

param_list:
    TYPE ID                      {[($1, $2)]}
    | TYPE ID COMMA param_list   {($1, $2) :: $4}

/* end of decls */

/* end of rule_list */

stmt_list:
    {[]}
    | stmt_list stmt {$2 :: $1}

stmt:
    | expr NEWLINE { Expr $1 }
    | RETURN expr NEWLINE { Return($2) }
    | IF LPAR expr RPAR stmt ELSE stmt ENDIF   { If($3, $5, $7) }
    | WHILE LPAR expr RPAR stmt ENDLOOP { While($3, $5) }
    | TYPE id_list NEWLINE { VarDecl($1, $2) }
    /*| LPAR expr_list RPAR PIPE TYPE id_list NEWLINE { VarMulDecl($2, $5, $6)}*/

id_list:
    ID { [$1] }
    | ID COMMA id_list { $1 :: $3 }

expr_list:
    | expr { [$1] }
    | expr COMMA expr_list { $1 :: $3 }


expr:
      STRING                    { String($1) }
    | FLOAT                     { Float($1) }
    | INT                       { Int($1)  }
    | BOOL                      { Bool($1)  }
    | ID                        { Id($1) }
    | TYPE LSQR expr_list RSQR  { List($1, $3) }
    | expr PLUS   expr   { Binop($1, Add,   $3) }
    | expr MINUS  expr   { Binop($1, Sub,   $3) }
    | expr TIMES  expr   { Binop($1, Mult,  $3) }
    | expr DIVIDE expr   { Binop($1, Div,   $3) }
    | expr EQ     expr   { Binop($1, Equal, $3) }
    | expr NEQ    expr   { Binop($1, Neq,   $3) }
    | expr LT     expr   { Binop($1, Less,  $3) }
    | expr LEQ    expr   { Binop($1, Leq,   $3) }
    | expr GT     expr   { Binop($1, Greater, $3) }
    | expr GEQ    expr   { Binop($1, Geq,   $3) }
    | expr AND    expr   { Binop($1, And,   $3) }
    | expr OR     expr   { Binop($1, Or,    $3) }
    | MINUS       expr   { Unop(Neg, $2) }
    | NOT expr           { Unop(Not, $2) }
    | expr PIPE expr     { Assign($3, $1) }
    | expr LSQR expr RSQR       { Getn($1, $3) }
    | ID LPAR args_opt RPAR     { Call($1, $3) }
    | LPAR expr RPAR            { $2 }

args_opt:
    { [] }
    | args_list { List.rev $1 }

args_list:
    expr { [$1] }
    | args_list COMMA expr { $3 :: $1 }
