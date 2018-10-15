{open Parser}

rule token =
    parse [' ' '\t' '\r']       { token lexbuf }  (* whitespace *)
    | '\n'                      { NEWLINE }
    | "/*"                      { comment lexbuf }(* start comment *)
    (* operators*)
    | '+'                       { PLUS }
    | '-'                       { MINUS }
    | '*'                       { TIMES }
    | '/'                       { DIVIDE}
    | '%'                       { MOD }
    (* pipe *)
    | '|'                       { PIPE }
    (* parathen *)
    | '['                       { LSQR }
    | ']'                       { RSQR }
    | ','                       { COMMA }
    | '('                       { LPAR }
    | ')'                       { RPAR }
    (* logic *)
    | '='                       { EQ }
    | "!="                      { NEQ }
    | "<="                      { LEQ }
    | ">="                      { GEQ }
    | '<'                       { LT }
    | '>'                       { GT }
    | "||"                      { OR }
    | "&&"                      { AND }
    | '!'                       { NOT }
    | ("true"|"false") as bl    { BOOL(bool_of_string bl)}
    (* num *)
    | ['0' - '9']+ as lit       {INT(int_of_string lit)}
    | ['0' - '9']*.['0' - '9']+ as lit  {FLT(float_of_string lit)}
    | ['0' - '9']+.['0' - '9']* as lit  {FLT(float_of_string lit)}
    (* String *)
    | '"'(['\000' - '\033' '\035' - '\127']* as str)'"' {STRING(str)}
    (* ID *)
    | ['a' - 'z' 'A' - 'Z']['a' - 'z' 'A' - 'Z' '0' - '9' '_']* as id { ID(id) }
    | _ as ch { raise (Failure("invalid character detected" ^ Char.escaped ch)) }
    (* key words *)
    | ("int"|"float"|"string"|"bool") as tp {TYPE(tp)}
    | "if"                      { IF }
    | "else"                    { ELSE }
    | "elif"                    { ELIF }
    | "fi"                      { ENDIF }
    | "while"                   { WHILE }
    | "return"                  { RETURN }
    | "end"                     { ENDLOOP }
    | "continue"                { CONTINUE }
    | "break"                   { BREAK }
    | "Siri"                    { ENDFUN }
    | eof                       { EOF }
    and comment = parse "*/" {token lexbuf} (* end comment *)
    | _ {comment lexbuf}
