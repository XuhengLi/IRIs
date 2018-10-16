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
  | RETURN
  | TYPE of (string)
  | ID of (string)
  | STRING of (string)
  | INT of (int)
  | FLOAT of (float)
  | BOOL of (bool)

val program :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> Ast.program
