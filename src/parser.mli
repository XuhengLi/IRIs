type token =
  | COMMA
  | LPAR
  | RPAR
  | LSQR
  | RSQR
  | IF
  | ELIF
  | ENDIF
  | ELSE
  | ENDFUN
  | NEWLINE
  | WHILE
  | ENDLOOP
  | BREAK
  | CONTINUE
  | TRUE
  | FALSE
  | PLUS
  | MINUS
  | TIMES
  | DIVIDE
  | MOD
  | EQ
  | NEQ
  | LEQ
  | GEQ
  | LT
  | GT
  | OR
  | AND
  | NOT
  | EOF
  | PIPE
  | INT
  | FLOAT
  | BOOL
  | STRING
  | RETURN
  | LSTR of (string)
  | ID of (string)
  | LFLT of (string)
  | LINT of (int)
  | LBOOL of (bool)

val program :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> Ast.program
