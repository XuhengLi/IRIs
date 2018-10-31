type action = Ast | Compile

let () =
  let ast = parse.program Scanner.token lexbuf in
    print_string (Ast.string_of_program ast)
