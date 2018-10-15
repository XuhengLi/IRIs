%{
open Ast
let quote_remover a = String.sub a 1 ((String.length a) - 2);;
%}

%token SEMI COMMA LPR RPR LBK RBK LBC RBC
%token IF ELIF ELSE ENDIF WHILE
%token TRUE FALSE
%token PLUS MINUS TIMES DIVIDE MOD EQ NEQ LEQ REQ
%token RAPPEND LAPPEND LR RL AND OR NOT
%token FILE REGEX EOF ASSIGN
%token RETURN BOOL FLOAT STRING INT
%token <string> ID REGEX_STRING STRING_T FILE_T
%token <int> INT_T
%token <float> FLOAT_T
%token <bool> BOOL_T

%nonassoc ELSE
%right ASSIGN
%left OR
%left AND
%left EQ NEQ
%left LR RL LEQ REQ
%left PLUS MINUS
%left TIMES DIVIDE
%right NOT
%left LBK RBK

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
    typ ID LPR formal_list RPR LBC vdecl_list stmt_list RBC
    { { ftyp = $1;
        fname = $2;
        formals = $4;
        locals = List.rev $7;
        body = List.rev $8 } }

typ:
    | VOID { Void }
    | STRING { String }
    | FLOAT { Float }
    | BOOL { Bool }
    | INT { Int }
    | FILE { File }

formal_list:
                    { [] }
    | formal_list formal_decl  { $2 :: $1 }

formal_decl:
    typ ID         { VarDecl($1, $2, Noexpr) }
    | COMMA typ ID { VarDecl($2, $3, Noexpr) }

vdecl_list:
                       { [] }
    | vdecl_list vdecl { $2 :: $1 }

/*
vdecl:
    typ ID SEMI { VarDecl($1, $2, Noexpr) }
    | typ ID LBK INT_T RBK SEMI {VarDecl(Arr($1, $4), $2, Noexpr)}
    | typ ID LBK INT_T RBK ASSIGN expr SEMI {VarDecl(Arr($1, $4), $2, $7)}
    | typ ID ASSIGN expr SEMI { VarDecl($1, $2, $4) }
*/

/**/
array_list:
    /* nothing */ { [] }
    | LBK INT_T RBK array_list { $2 :: $4 }

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
| expr SEMI { Expr $1 }
| RETURN expr SEMI { Return($2) }
| LBC stmt_list RBC { Block(List.rev $2) }
| IF LPR expr RPR stmt ELSE stmt ENDIF   { If($3, $5, $7) }
| WHILE LPR expr RPR stmt ENDWHILE { While($3, $5) }

expr_opt:
     { Noexpr }
     | expr { $1 }

expr:
      STRING_T           { Sliteral(quote_remover($1)) }
    | FLOAT_T            { Fliteral($1) }
    | INT_T              { Literal($1)  }
    | BOOL_T             { BoolLit($1)  }
    | FILE_T             { FileLiteral($1)  }
    | ID                 { Id($1) }
	| LBK expr_list RBK  { Array_Lit($2) }
    | expr PLUS   expr   { Binop($1, Add,   $3) }
    | expr MINUS  expr   { Binop($1, Sub,   $3) }
    | expr TIMES  expr   { Binop($1, Mult,  $3) }
    | expr DIVIDE expr   { Binop($1, Div,   $3) }
    | expr EQ     expr   { Binop($1, Equal, $3) }
    | expr NEQ    expr   { Binop($1, Neq,   $3) }
    | expr RL     expr   { Binop($1, Less,  $3) }
    | expr LEQ    expr   { Binop($1, Leq,   $3) }
    | expr LR     expr   { Binop($1, Greater, $3) }
    | expr REQ    expr   { Binop($1, Geq,   $3) }
    | expr AND    expr   { Binop($1, And,   $3) }
    | expr OR     expr   { Binop($1, Or,    $3) }
    | MINUS       expr   { Unop(Neg, $2) }
    | NOT expr           { Unop(Not, $2) }
    | expr ASSIGN expr   { Assign($1, $3) }
    /*| LBK RBK            { Call("create", []) }*/
    | expr LBK expr RBK    { Array_Index($1, $3) }
    | ID LPR args_opt RPR { Call($1, $3) }
    | LPR expr RPR       { $2 }

expr_list:
    | expr { [$1] }
    | expr COMMA expr_list { $1 :: $3 }

args_opt:
    { [] }
    | args_list { List.rev $1 }
args_list:
    expr { [$1] }
    | args_list COMMA expr { $3 :: $1 }

/* start of regex */
single_regex:
    REGEX_STRING { $1 }
/* end of regex */
