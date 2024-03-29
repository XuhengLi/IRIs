open Ast
open Sast

module StringMap = Map.Make(String)
let check (globals, functions) =
    (* Verify a list of bindings has no duplicate names *)
  let check_binds (kind : string) (binds : bind list) =
    let rec dups = function
        [] -> ()
      | ((_,n1) :: (_,n2) :: _) when n1 = n2 ->
        raise (Failure ("duplicate " ^ kind ^ " " ^ n1))
      | _ :: t -> dups t
    in dups (List.sort (fun (_,a) (_,b) -> compare a b) binds)
  in
    (**** Check global variables ****)

  check_binds "global" globals;

    (**** Check functions ****)

    (* Collect function declarations for built-in functions: no bodies *)
  let built_in_decls =
    let add_bind map (typ, name, fm) = StringMap.add name {
      typ = typ;
      fname = name;
      formals = fm;
      locals = []; body = [] } map
    in List.fold_left add_bind StringMap.empty
       [(Int, "print", [(String, "x")]);
        (Int, "printi", [(Int, "x")]);
        (Int, "printf", [(Float, "x")]);
        (Int, "printb", [(Bool, "x")]);
        (Int, "strlen", [(String, "x")]);
        (Int, "strcmp", [(String, "x");(String, "x1")]);
        (String, "strcat", [(String, "x1");(String, "x2")]);
        (String, "strcpy", [(String, "x");(String, "x1")]);
        (Int, "inputint", [(String, "x")]);
        (Float, "inputfloat", [(String, "x")]);
        (String, "inputstring", [(String, "x")]);
        (String, "calloc", [(Int, "x1")]);
        (Int, "free", [(String, "x")]);
        (Int, "inputgui", [(Int, "x")]);
        (Int, "cmd", [(String, "x")]);
        (Int, "sendmail", [(String, "x1");(String, "x2")]);
        (String, "inputfile", [(String, "x1");(Int, "x")]);
        (*add built-in function here*)]
  in
    (* Add function name to symbol table *)
  let add_func map fd =
    let built_in_err = "function " ^ fd.fname ^ " may not be defined"
    and dup_err = "duplicate function " ^ fd.fname
    and make_err er = raise (Failure er)
    and n = fd.fname (* Name of the function *)
    in match fd with (* No duplicate functions or redefinitions of built-ins *)
         _ when StringMap.mem n built_in_decls -> make_err built_in_err
       | _ when StringMap.mem n map -> make_err dup_err
       | _ ->  StringMap.add n fd map
  in
    (* Collect all function names into one symbol table *)
  let function_decls = List.fold_left add_func built_in_decls functions
  in
      (* Return a function from our symbol table *)
  let find_func s =
    try StringMap.find s function_decls
    with Not_found -> raise (Failure ("unrecognized function " ^ s))
  in

  let _ = find_func "main"
  in (* Ensure "main" is defined *)

  let check_function func =
    (* Make sure no formals or locals are duplicates *)
    check_binds "formal" func.formals;
    check_binds "local" func.locals;
      (* Raise an exception if the given rvalue type cannot be assigned to
         the given lvalue type *)
    let check_assign lvaluet rvaluet err =
      if lvaluet = rvaluet then lvaluet else raise (Failure err)
    in
    (* Build local symbol table of variables for this function *)
    let symbols = List.fold_left (fun m (ty, name) -> StringMap.add name ty m)
                  StringMap.empty (globals @ func.formals @ func.locals )
    in
    (* Return a variable from our local symbol table *)
    let type_of_identifier s = 
    try StringMap.find s symbols
    with Not_found -> raise (Failure ("undeclared identifier " ^ s))
    in
    let list_access_type = function
       List(t) -> t
     | _ -> raise (Failure ("illegal list access") )
    in

    let list_type s = match (List.hd s) with
       Lint _ -> List(Int)
     | Lfloat _ -> List(Float)
     | Lbool _ -> List(Bool)
     | Lstring _ -> List(String)
     (* TODO | (* nested list *) *)
     | _ -> raise ( Failure ("Cannot instantiate a list of that type"))
    in

    let rec check_all_list_literal m ty idx =
     let length = List.length m
     in
     match (ty, List.nth m idx) with
       (List(Int), Lint _) -> if idx == length - 1 then List(Int) else check_all_list_literal m (List(Int)) (succ idx)
     | (List(Float), Lfloat _) -> if idx == length - 1 then List(Float) else check_all_list_literal m (List(Float)) (succ idx)
     | (List(Bool), Lbool _) -> if idx == length - 1 then List(Bool) else check_all_list_literal m (List(Bool)) (succ idx)
     | (List(String), Lstring _) -> if idx == length - 1 then List(String) else check_all_list_literal m (List(String)) (succ idx)
     (* TODO | (* nested list *) *)
     | _ -> raise (Failure ("illegal list literal"))
    in
     (* Return a semantically-checked expression, i.e., with a type *)
    let rec expr = function
        Lint  l -> (Int, SLint l)
      | Lfloat l -> (Float, SLfloat l)
      | Lbool l  -> (Bool, SLbool l)
      | Lstring s -> (String, SLstring s)
      | Id s       -> (type_of_identifier s, SId s)
      | Llist l -> ((check_all_list_literal l (list_type l) 0), SLlist (List.map expr l))
      | Ltuple l -> (Tuple(List.map (fun e -> fst (expr e)) l), SLtuple (List.map expr l))
      | Assign(var, e) as ex ->
            (match var with 
              _ when StringMap.mem var function_decls ->
                    let args =  (match e with
                                  Ltuple l -> l
                                | _ -> [e]
                                )
                    and fname = var
                    in
                    expr (Call(fname, args))
            | _ ->
              let lt = type_of_identifier var
              and (rt, e') = expr e
              in
              let err = "illegal assignment " ^ string_of_typ lt ^ " = " ^
               string_of_typ rt ^ " in " ^ string_of_expr ex
              in (check_assign lt rt err, SAssign(var, (rt, e')))
            )

      | Getn(s, e) -> let e' = expr e in
                      let _ = (match e' with
                           (Int, _) -> e'
                          | _ -> raise (Failure ("attempting to access with a non-integer type"))) in
                          ( list_access_type (type_of_identifier s), SGetn(s, e') )
      | Unop(op, e) as ex ->
        let (t, e') = expr e
        in
        let ty = match op with
            Neg when t = Int || t = Float -> t
          | Not when t = Bool -> Bool
          | _ -> raise (Failure ("illegal unary operator " ^
                        string_of_uop op ^ string_of_typ t ^
                        " in " ^ string_of_expr ex))
        in (ty, SUnop(op, (t, e')))
      | Binop(e1, op, e2) as e ->
        let (t1, e1') = expr e1
        and (t2, e2') = expr e2
        in
           (* All binary operators require operands of the same type *)
        let same = t1 = t2
        in
           (* Determine expression type based on operator and operand types *)
        let ty = match op with
            Add | Sub | Mult | Div when same && t1 = Int   -> Int
          | Add | Sub | Mult | Div when same && t1 = Float -> Float
          | Equal | Neq            when same               -> Bool
          | Less | Leq | Greater | Geq
                      when same && (t1 = Int || t1 = Float) -> Bool
          | And | Or when same && t1 = Bool -> Bool
          | _ -> raise (
          Failure ("illegal binary operator " ^
                        string_of_typ t1 ^ " " ^ string_of_op op ^ " " ^
                        string_of_typ t2 ^ " in " ^ string_of_expr e))
        in (ty, SBinop((t1, e1'), op, (t2, e2')))
      | Call(fname, args) as call ->
          let fd = find_func fname
          in
          let param_length = List.length fd.formals
          in
            if List.length args != param_length then
              raise (Failure ("expecting " ^ string_of_int param_length ^
                              " arguments in " ^ string_of_expr call))
            else
              let check_call (ft, _) e =
                let (et, e') = expr e
                in
                let err = "illegal argument found " ^ string_of_typ et ^
                  " expected " ^ string_of_typ ft ^ " in " ^ string_of_expr e
                in (check_assign ft et err, e')
              in
              let args' = List.map2 check_call fd.formals args
              in (fd.typ, SCall(fname, args'))
      | Length(e) as len ->
        let e' = expr e in (match e' with 
            (List(_), SId _)
            | (_, SLlist(_)) -> (Int, SLength e')
            | _ -> raise(Failure ("length can only applied to list" ^ string_of_expr len))
        )

    in

    let check_bool_expr e =
      let (t', e') = expr e
      and err = "expected Boolean expression in " ^ string_of_expr e
      in if t' != Bool then raise (Failure err) else (t', e')
    in
(* Return a semantically-checked statement i.e. containing sexprs *)
    let rec check_stmt = function
        Expr e -> SExpr (expr e)
      | If(p, b1, b2) -> SIf(check_bool_expr p, check_stmt b1, check_stmt b2)
      | While(p, s) -> SWhile(check_bool_expr p, check_stmt s)
      | Return e -> let (t, e') = expr e in
         if t = func.typ then SReturn (t, e')
         else raise (
              Failure ("return gives " ^ string_of_typ t ^ " expected " ^
              string_of_typ func.typ ^ " in " ^ string_of_expr e))

      (* A block is correct if each statement is correct and nothing
         follows any Return statement.  Nested blocks are flattened. *)
      | Block sl ->
          let rec check_stmt_list = function
              [Return _ as s] -> [check_stmt s]
            | Return _ :: _   -> raise (Failure "nothing may follow a return")
            | Block sl :: ss  -> check_stmt_list (sl @ ss) (* Flatten blocks *)
            | s :: ss         -> check_stmt s :: check_stmt_list ss
            | []              -> []
         in SBlock(check_stmt_list sl)
      | Setn(s, e1, e2) ->
        SSetn(type_of_identifier s, s, expr e1, expr e2)
    in (* body of check_function *)
    {
      styp = func.typ;
      sfname = func.fname;
      sformals = func.formals;
      slocals  = func.locals;
      sbody = match check_stmt (Block func.body) with
        SBlock(sl) -> sl
        | _ -> raise (Failure ("internal error: block didn't become a block?"))
    }
  in (globals, List.map check_function functions)
