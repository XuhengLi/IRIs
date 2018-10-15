%{
open Ast
let quote_remover a = String.sub a 1 ((String.length a) - 2);;
%}

%token COMMA LPAR RPAR LSQR RSQR
%token IF ELIF ENDIF ELSE ENDFUN
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
%right ASSIGN
%left OR
%left AND
%left EQ NEQ
%left LR RL LEQ REQ
%left PLUS MINUS
%left TIMES DIVIDE
%left PIPE
%right NOT
%left LSQR RSQR

%start program
%type <Ast.program> program
%%

/* functions are */
program:
    { [], [] }
    | program vdecl    { ($2 :: fst $1), snd $1 }
    | program fdecl    { fst $1, ($2 :: snd $1) }

/* start of decls */
fdecl:
    typ ID LPAR param_list RPAR vdecl_list stmt_list ENDFUN
    { { ftyp = $1;
        fname = $2;
        params = $4;
        locals = List.rev $6;
        body = List.rev $7 } }

typ:
    | STRING { String }
    | FLOAT { Float }
    | BOOL { Bool }
    | INT { Int }

param_list:
                    { [] }
    | param_list formal_decl  { $2 :: $1 }

formal_decl:
    typ ID         { VarDecl($1, $2, Noexpr) }
    | COMMA typ ID { VarDecl($2, $3, Noexpr) }

vdecl_list:
                       { [] }
    | vdecl_list vdecl { $2 :: $1 }

/*
vdecl:
    typ ID SEMI { VarDecl($1, $2, Noexpr) }
    | typ ID LSQR INT_T RSQR SEMI {VarDecl(Arr($1, $4), $2, Noexpr)}
    | typ ID LSQR INT_T RSQR ASSIGN expr SEMI {VarDecl(Arr($1, $4), $2, $7)}
    | typ ID ASSIGN expr SEMI { VarDecl($1, $2, $4) }
*/

/**/
array_list:
    /* nothing */ { [] }
    | LSQR INT_T RSQR array_list { $2 :: $4 }

bind:
    | typ ID array_list
        { List.fold_right (fun a (b, c) -> (Arr(b, a), c)) $3 ($1,$2) }

vdecl:
    | bind SEMI { VarDecl(fst $1, snd $1, Noexpr) }
    | bind ASSIGN expr SEMI { VarDecl(fst $1, snd $1, $3) }

/* end of decls */


/* start of rule_list */
rule_list:
    {[]}
    | rule_list rdecl {$2 :: $1}

rdecl:
    pattern action {$1, $2}

pattern:
    REGEX single_regex REGEX {RegexPattern($2)}

action:
    LBC vdecl_list stmt_list RBC {List.rev $2, List.rev $3}
/* end of rule_list */

stmt_list:
    {[]}
    | stmt_list stmt {$2 :: $1}

stmt:
| expr NEWLINE { Expr $1 }
| RETURN expr NEWLINE { Return($2) }
| IF LPAR expr RPAR stmt ELSE stmt ENDIF   { If($3, $5, $7) }
| WHILE LPAR expr RPAR stmt ENDWHILE { While($3, $5) }

expr:
      STRING           { Sliteral(quote_remover($1)) }
    | FLOAT            { Fliteral($1) }
    | INT              { Literal($1)  }
    | BOOL             { BoolLit($1)  }
    | ID                 { Id($1) }
	| LSQR expr_list RSQR  { Array_Lit($2) }
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
    | expr PIPE expr   { Assign($3, $1) }
    | expr LSQR expr RSQR    { Array_Index($1, $3) }
    | ID LPAR args_opt RPAR { Call($1, $3) }
    | LPAR expr RPAR       { $2 }

expr_list:
    | expr { [$1] }
    | expr NEWLINE expr_list { $1 :: $3 }

args_opt:
    { [] }
    | args_list { List.rev $1 }
args_list:
    expr { [$1] }
    | args_list COMMA expr { $3 :: $1 }
