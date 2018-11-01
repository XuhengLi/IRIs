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
    | ("true"|"false") as bl    { LBOOL(bool_of_string bl) }
    (* num *)
    | ['0' - '9']+ as lit       { LINT(int_of_string lit) }
    | ['0' - '9']*'.'['0' - '9']+ as lit  { LFLT(lit) }
    | ['0' - '9']+'.'['0' - '9']* as lit  { LFLT(lit) }
    (* String *)
    | '"'((['\000' - '\033' '\035' - '\127']|"\\\"")* as str)'"' { LSTR(str) }
    (* ID *)
    | ['a' - 'z' 'A' - 'Z']['a' - 'z' 'A' - 'Z' '0' - '9' '_']* as id { ID(id) }
    | _ as ch { raise (Failure("invalid character detected" ^ Char.escaped ch)) }
    (* key words *)
    | "int"                     { INT }
    | "float"                   { FLOAT }
    | "string"                  { STRING }
    | "bool"                    { BOOL }
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
