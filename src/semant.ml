open Ast

module StringMap = Map.Make(String)
let check (globals, functions) =
    (* Verify a list of bindings has no duplicate names *)
    let check_binds (kind : string) (binds : bind list) =
      let rec dups = function
          [] -> ()
        |	((_,n1) :: (_,n2) :: _) when n1 = n2 ->
        raise (Failure ("duplicate " ^ kind ^ " " ^ n1))
        | _ :: t -> dups t
      in dups (List.sort (fun (_,a) (_,b) -> compare a b) binds)
    in
    (**** Check global variables ****)

    check_binds "global" globals;

    (**** Check functions ****)

    (* Collect function declarations for built-in functions: no bodies *)
    let built_in_decls =
        let add_bind map (name, ty) = StringMap.add name {
          typ = Int;
          fname = name;
          formals = [(ty, "x")];
          locals = []; body = [] } map
        in List.fold_left add_bind StringMap.empty [ ("print", Int);
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

        let _ = find_func "main" in (* Ensure "main" is defined *)

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
             | Lint _ -> SList(Int, List.length s)
             | Lfloat _ -> SList(Float, List.length s)
             | Lbool _ -> SList(Bool, List.length s)
             | (* nested list *)
             | _ -> raise ( Failure ("Cannot instantiate a list of that type")) in

           let rec check_all_list_literal m ty idx =
             let length = List.length m in
             match (ty, List.nth m idx) with
               (List(Int, _), Lint _) -> if idx == length - 1 then List(Int, length) else check_all_list_literal m (List(Int, length)) (succ idx)
             | (List(Float, _), Lfloat _) -> if idx == length - 1 then List(Float, length) else check_all_list_literal m (List(Float, length)) (succ idx)
             | (List(Bool, _), Lbool _) -> if idx == length - 1 then List(Bool, length) else check_all_list_literal m (List(Bool, length)) (succ idx)
             | (* nested list *)
             | _ -> raise (Failure ("illegal list literal"))
           in
           (* Return a semantically-checked expression, i.e., with a type *)
           let rec expr = function
                 Lint  l -> (Int, SLint l)
               | Lfloat l -> (Float, SLfloat l)
               | Lbool l  -> (Bool, SLbool l)
               | Lstring s -> (String, Sstring, s)
               | Id s       -> (type_of_identifier s, SId s)
               | Llist s -> check_all_list_literal s (list_type s) 0
               | Assign(var, e) as ex ->
                     let lt = type_of_identifier var
                     and (rt, e') = expr e in
                     let err = "illegal assignment " ^ string_of_typ lt ^ " = " ^
                       string_of_typ rt ^ " in " ^ string_of_expr ex
                     in (check_assign lt rt err, SAssign(var, (rt, e')))
               | Getn(s, e1) -> let _ = (match (expr e1) with
                                     (Int, SLint l) -> (Int, SLint l)
                                    | _ -> raise (Failure ("attempting to access with a non-integer type"))) in
                                    list_access_type (type_of_identifier s)
               | Unop(op, e) as ex ->
                  let (t, e') = expr e in
                  let ty = match op with
                      Neg when t = Int || t = Float -> t
                    | Not when t = Bool -> Bool
                    | _ -> raise (Failure ("illegal unary operator " ^
                                  string_of_uop op ^ string_of_typ t ^
                                  " in " ^ string_of_expr ex))
               in (ty, SUnop(op, (t, e')))
               | Binop(e1, op, e2) as e ->
                   let (t1, e1') = expr e1
                   and (t2, e2') = expr e2 in
                   (* All binary operators require operands of the same type *)
                   let same = t1 = t2 in
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

       in (* body of check_function *)
       { styp = func.typ;
         sfname = func.fname;
         sformals = func.formals;
         slocals  = func.locals;
         sbody = match check_stmt (Block func.body) with
    	SBlock(sl) -> sl
         | _ -> raise (Failure ("internal error: block didn't become a block?"))
       }
  in (globals, List.map check_function functions)
