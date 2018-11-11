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
%token INT FLOAT BOOL STRING
%token RETURN
%token <string> LSTR ID LFLT
%token <int> LINT
%token <bool> LBOOL

%start program
%type <Ast.program> program

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

%%

/* functions are */
program:
  decls EOF { $1 }

decls:
    { [], [] }
    | decls vdecl NEWLINE         { ($2 @ fst $1), snd $1 }
    | decls fdecl NEWLINE         { fst $1, ($2 :: snd $1) }

/* start of decls */
fdecl:
    TYPE ID LPAR param RPAR NEWLINE vdecl_list stmt_list ENDFUN
    { { typ = $1;
        fname = $2;
        formals = List.rev $4;
        locals = List.rev $7;
        body = List.rev $8 } }

param:
                    { [] }
    | param_list    { $1 }

param_list:
    TYPE ID                     { [($1, $2)] }
    | param_list COMMA TYPE ID  { ($3, $4) :: $1 }

TYPE:
    basic_type          { $1 }
    | basic_type LSQR RSQR      { List($1)}

basic_type:
    FLOAT               { Float }
    | INT               { Int}
    | STRING            { String }
    | BOOL              { Bool }

/* end of decls */

/* end of rule_list */

stmt_list:
    {[]}
    | stmt_list stmt {$2 :: $1}

stmt:
    | expr NEWLINE                              { Expr $1 }
    | RETURN expr NEWLINE                       { Return($2) }
    | IF LPAR expr RPAR stmt ELSE stmt ENDIF    { If($3, $5, $7) }
    | WHILE LPAR expr RPAR stmt ENDLOOP         { While($3, $5) }
    /*| LPAR expr_list RPAR PIPE TYPE id_list NEWLINE { VarMulDecl($2, $5, $6)}*/

vdecl_list:
    /* nothing */    { [] }
    | vdecl_list vdecl { List.append $2 $1 }

/* TODO: Modify TYPE id_list return value */
vdecl:
    /* TYPE id_list NEWLINE { $1, $2 } */
    TYPE id_list NEWLINE { List.map (fun id -> ($1, id)) $2}
    /*| expr PIPE TYPE ID NEWLINE { Vdecl($3, $4, $1) }*/

id_list:
    | ID { [$1] }
    | ID COMMA id_list { $1 :: $3 }

expr_list:
    | expr { [$1] }
    | expr COMMA expr_list { $1 :: $3 }


expr:
      LSTR                      { Lstring($1) }
    | LFLT                      { Lfloat($1) }
    | LINT                      { Lint($1) }
    | LBOOL                     { Lbool($1) }
    | ID                        { Id($1) }
    | LSQR expr_list RSQR       { Llist($2) }
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
    | expr PIPE ID       { Assign($3, $1) }
    | ID LSQR expr RSQR       { Getn($1, $3) }
    | ID LPAR args_opt RPAR     { Call($1, $3) }
    | LPAR expr RPAR            { $2 }

args_opt:
    { [] }
    | args_list { List.rev $1 }

args_list:
    expr { [$1] }
    | args_list COMMA expr { $3 :: $1 }
