{ open Parser }

rule token =
    parse [' ' '\t' '\r']       { token lexbuf }  (* whitespace *)
    | [' ' '\t' '\r' '\n']*'|'[' ' '\t' '\r' '\n']* { PIPE }
    | "/*"                      { comment lexbuf }(* start comment *)
    (* operators*)
    | '+'
    | [' ' '\t' '\r' '\n']*'|'[' ' '\t' '\r' '\n']*'+'                    { PLUS }
    | '-'
    | [' ' '\t' '\r' '\n']*'|'[' ' '\t' '\r' '\n']*'-'                    { MINUS }
    | '*'
    | [' ' '\t' '\r' '\n']*'|'[' ' '\t' '\r' '\n']*'*'                    { TIMES }
    | '/'
    | [' ' '\t' '\r' '\n']*'|'[' ' '\t' '\r' '\n']*'/'                    { DIVIDE}
    | '%'
    | [' ' '\t' '\r' '\n']*'|'[' ' '\t' '\r' '\n']*'%'                     { MOD }
    | ['\n']+                   { NEWLINE }
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
    (* String *)
    | '"'                       {
                                    let buffer = Buffer.create 1
                                    in LSTR(str_of_string buffer lexbuf)
                                }
    (* ID *)
    | ['a' - 'z' 'A' - 'Z']['a' - 'z' 'A' - 'Z' '0' - '9' '_']* as id { ID(id) }
    | _ as ch { raise (Failure("invalid character detected " ^ Char.escaped ch)) }
    and comment =
    parse "*/" { token lexbuf } (* end comment *)
    | _ { comment lexbuf }
    and str_of_string buffer =  (* can be more functional *)
    parse '"' { Buffer.contents buffer}
    | "\\t"   { Buffer.add_char buffer '\t'; str_of_string buffer lexbuf }
    | "\\n"   { Buffer.add_char buffer '\n'; str_of_string buffer lexbuf }
    | "\\\""  { Buffer.add_char buffer '"'; str_of_string buffer lexbuf }
    | "\\\\"  { Buffer.add_char buffer '\\'; str_of_string buffer lexbuf }
    | _ as ch { Buffer.add_char buffer ch; str_of_string buffer lexbuf }
    (* ref:https://stackoverflow.com/questions/5793702/using-ocamllex-for-lexing-strings-the-tiger-compiler *)
