{open Parser}

rule token =
    parse [' ' '\t' '\r' '\n']  { token lexbuf }  (* whitespace *)
    | "/*"                      { comment lexbuf }(* start comment *)
    (* operators*)
    | '+'                       { PLUS }
    | '-'                       { MINUS }
    | '*'                       { TIMES }
    | '/'                       { DIVIDE}
    (* pipe *)
    | '|'                       { PIPE }
    (* parathen *)
    | '['                       { LSQR }
    | ']'                       { RSQR }
    | '('                       { LPAR }
    | ')'                       { RPAR }
    (* logic *)
    | '='                       { EQ }
    | "!="                      { NEQ }
    | '<'                       { LT }
    | '>'                       { GT }
    | "||"                       { OR }
    | '&&'                       { AND }
    | ("true"|"false") as lit   { BOOL(bool_of_string bl)}
    (* num *)
    | ['0' - '9']+ as lit       {INT(int_of_string lit)}
    | ['0' - '9']*.['0' - '9']+ as lit  {FLT(float_of_string lit)}
    | ['0' - '9']+.['0' - '9']* as lit  {FLT(float_of_string lit)}
    (* String *)
    | '"'(['\000' - '\033' '\035' - '\127']* as str)'"' {STRINGLIT(str)}
    (* ID *)
    | ['a' - 'z' 'A' - 'Z']['a' - 'z' 'A' - 'Z' '0' - '9' '_']* as id { ID(id) }
    | _ as ch { raise (Failure("invalid character detected" ^ Char.escaped ch)) }
    (* key words *)
    | ("int"|"float"|"string"|"bool") as tp {TYPE(tp)}
    | "if"                      { IF }
    | "else"                    { ELSE }
    | "elif"                    { ELIF }
    | "fi"                      { FI}
    | "while"                   { WHILE }
    | "end"                     { END }
    | "continue"                { CONTINUE }
    | "break"                   { BREAK }
    | "Siri"                    { SIRI}
    and comment = parse "*/" {token lexbuf} (* end comment *)
    | _ {comment lexbuf}
