(* Code generation: translate takes a semantically checked AST and
produces LLVM IR

LLVM tutorial: Make sure to read the OCaml version of the tutorial

http://llvm.org/docs/tutorial/index.html

Detailed documentation on the OCaml LLVM library:

http://llvm.moe/
http://llvm.moe/ocaml/

*)

module L = Llvm
module A = Ast
open Sast

module StringMap = Map.Make(String)

(* translate : Sast.program -> Llvm.module *)
let translate (globals, functions) =
  let context    = L.global_context ()
  in

  (* Create the LLVM compilation module into which
     we will generate code *)
  let the_module = L.create_module context "IRIs"
  in

  (* Get types from the context *)
  let i32_t      = L.i32_type    context
  and i8_t       = L.i8_type     context
  and i1_t       = L.i1_type     context
  and float_t    = L.double_type context
  and void_t     = L.void_type   context
  in

  let str_t      = L.pointer_type i8_t
  and list_t     = L.pointer_type i8_t
  and tuple_t     = L.pointer_type i8_t
  in

  (* Return the LLVM type for a MicroC type *)
  let ltype_of_typ = function
      A.Int   -> i32_t
    (* TODO: Modify Bool type *)
    | A.Bool  -> i8_t
    | A.Float -> float_t
    | A.String  -> str_t
    (* TODO: Add list type *)
    | A.List l -> list_t
    | A.Tuple (_) -> tuple_t
  in

  (* Create a map of global variables after creating each *)
  let global_vars : L.llvalue StringMap.t =
    let global_var m (t, n) =
      let init = match t with
          A.Float -> L.const_float (ltype_of_typ t) 0.0
        | _ -> L.const_int (ltype_of_typ t) 0
      in StringMap.add n (L.define_global n init the_module) m
    in List.fold_left global_var StringMap.empty globals in

  let printf_t : L.lltype =
      L.var_arg_function_type i32_t [| L.pointer_type i8_t |]
  in
  let printf_func : L.llvalue =
      L.declare_function "printf" printf_t the_module
  in
  let printb_func : L.llvalue =
      L.declare_function "printf" printf_t the_module
  in
  let printbig_t : L.lltype =
      L.function_type i32_t [| i32_t |]
  in
  let printbig_func : L.llvalue =
      L.declare_function "printbig" printbig_t the_module
  in
  let inputint_t : L.lltype =
      L.function_type i32_t [| str_t |]
  in
  let inputint_func : L.llvalue =
      L.declare_function "inputint" inputint_t the_module
  in
  let inputstring_t : L.lltype =
      L.function_type str_t [| str_t |]
  in
  let inputstring_func : L.llvalue =
      L.declare_function "inputstring" inputstring_t the_module
  in
  let inputfloat_t : L.lltype =
      L.function_type float_t [| str_t |]
  in
  let inputfloat_func : L.llvalue =
      L.declare_function "inputfloat" inputfloat_t the_module
  in
  let inputfile_t : L.lltype =
      L.function_type str_t [| str_t;i32_t|]
  in
  let inputfile_func : L.llvalue =
      L.declare_function "inputfile" inputfile_t the_module
  in
  let cmd_t : L.lltype =
      L.function_type i32_t [| str_t|]
  in
  let cmd_func : L.llvalue =
      L.declare_function "cmd" cmd_t the_module
  in
  let inputgui_t : L.lltype =
      L.function_type i32_t [| i32_t |]
  in
  let inputgui_func : L.llvalue =
      L.declare_function "inputgui" inputgui_t the_module
  in
  let sendmail_t : L.lltype =
      L.function_type i32_t [|str_t;str_t|]
  in
  let sendmail_func : L.llvalue =
      L.declare_function "sendmail" sendmail_t the_module
  in
  (* Declare the built-in strlen() function  *)
  let strlen_t : L.lltype =
      L.function_type i32_t [| str_t |]
  in
  let strlen_func : L.llvalue =
      L.declare_function "strlen" strlen_t the_module
  in

  (* Declare the built-in strcmp() function *)
  let strcmp_t : L.lltype =
      L.function_type i32_t [| str_t; str_t|]
  in
  let strcmp_func : L.llvalue =
      L.declare_function "strcmp" strcmp_t the_module
  in
  (* Declare the built-in strcat() function *)
  let strcat_t : L.lltype =
      L.function_type str_t [| str_t; str_t|]
  in

  let strcat_func : L.llvalue =
      L.declare_function "strcat" strcat_t the_module
  in

  (* Declare the built-in strcpy() function *)
  let strcpy_t : L.lltype =
      L.function_type str_t [| str_t; str_t|]
  in
  let strcpy_func : L.llvalue =
      L.declare_function "strcpy" strcpy_t the_module
  in
  (* Declare the list_append() functions *)
  let append_double_t : L.lltype =
      L.var_arg_function_type list_t [| list_t; i32_t |]
  in
  let append_double_func : L.llvalue =
      L.declare_function "append_double" append_double_t the_module
  in
  let append_int_t : L.lltype =
      L.var_arg_function_type list_t [| list_t; i32_t |]
  in
  let append_int_func : L.llvalue =
      L.declare_function "append_int" append_int_t the_module
  in
  let getn_int_t : L.lltype =
      L.function_type i32_t [| list_t; i32_t |]
  in
  let getn_int_func : L.llvalue =
      L.declare_function "getn_int" getn_int_t the_module
  in
  let getn_double_t : L.lltype =
      L.function_type float_t [| list_t; i32_t |]
  in
  let getn_double_func : L.llvalue =
      L.declare_function "getn_double" getn_double_t the_module
  in
  let setn_int_t : L.lltype =
      L.function_type void_t [| list_t; i32_t; i32_t|]
  in
  let setn_int_func : L.llvalue =
      L.declare_function "setn_int" setn_int_t the_module
  in
  let setn_double_t : L.lltype =
      L.function_type void_t [| list_t; i32_t; float_t|]
  in
  let setn_double_func : L.llvalue =
      L.declare_function "setn_double" setn_double_t the_module
  in
  let sassign_t : L.lltype =
      L.function_type str_t [| str_t; str_t;|]
  in
  let sassign_func : L.llvalue =
      L.declare_function "sassign" sassign_t the_module
  in
  let length_t : L.lltype =
      L.function_type i32_t [| list_t |]
  in
  let length_func : L.llvalue =
      L.declare_function "length" length_t the_module
  in
  (* Declare heap storage function *)
  let calloc_t = L.function_type str_t [| i32_t ; i32_t|] in
  let calloc_func = L.declare_function "calloc" calloc_t the_module in

  (* Declare free from heap *)
  let free_t = L.function_type str_t [| str_t |] in
  let free_func = L.declare_function "free" free_t the_module in
  (* Define each function (arguments and return type) so we can
     call it even before we've created its body *)
  let function_decls : (L.llvalue * sfunc_decl) StringMap.t =
    let function_decl m fdecl =
      let name = fdecl.sfname
      and formal_types =
          Array.of_list (List.map (fun (t,_) -> ltype_of_typ t) fdecl.sformals)
      in
      let ftype = L.function_type (ltype_of_typ fdecl.styp) formal_types
      in StringMap.add name (L.define_function name ftype the_module, fdecl) m
    in List.fold_left function_decl StringMap.empty functions
  in

  (* Fill in the body of the given function *)
  let build_function_body fdecl =
    let (the_function, _) = StringMap.find fdecl.sfname function_decls
    in
    let builder = L.builder_at_end context (L.entry_block the_function)
    in

    let int_format_str = L.build_global_stringptr "%d\n" "fmt" builder
    and float_format_str = L.build_global_stringptr "%g\n" "fmt" builder
    in
    (* Construct the function's "locals": formal arguments and locally
       declared variables.  Allocate each on the stack, initialize their
       value, if appropriate, and remember their values in the "locals" map *)
    let local_vars =
      let add_formal m (t, n) p =
        L.set_value_name n p;
        let local = L.build_alloca (ltype_of_typ t) n builder
        in ignore (L.build_store p local builder);
           StringMap.add n local m

      (* Allocate space for any locally declared variables and add the
       * resulting registers to our map *)
        and add_local m (t, n) =
          let local_var = L.build_alloca (ltype_of_typ t) n builder
          in (match t with 
              Int -> ignore (L.build_store (L.const_int i32_t 0) local_var builder); StringMap.add n local_var m
            | Float -> ignore (L.build_store (L.const_float float_t 0.0) local_var builder); StringMap.add n local_var m
            | String
            | List(_) -> ignore (L.build_store (L.const_pointer_null (L.pointer_type i8_t)) local_var builder); StringMap.add n local_var m
            | Bool -> ignore (L.build_store (L.const_int i8_t 0) local_var builder); StringMap.add n local_var m
            | Tuple _ -> ignore (L.build_store (L.const_pointer_null (L.pointer_type i8_t)) local_var builder); StringMap.add n local_var m)
      in

      let formals = List.fold_left2 add_formal StringMap.empty fdecl.sformals
          (Array.to_list (L.params the_function))
      in List.fold_left add_local formals fdecl.slocals
    in

    (* Return the value for a variable or formal argument.
       Check local names first, then global names *)
    let lookup n = try StringMap.find n local_vars
                   with Not_found -> StringMap.find n global_vars
    in

    let build_string e builder =
      let str = L.build_global_stringptr e "str" builder
      in
      let null = L.const_int i32_t 0
      in L.build_in_bounds_gep str [| null |] "str" builder
    in
    (* Construct code for an expression; return its value *)
    let rec expr builder ((sx, e) : sexpr) = match e with
        SLint i  -> L.const_int i32_t i
      | SLbool b  -> L.const_int i1_t (if b then 1 else 0)
      | SLfloat l -> L.const_float_of_string float_t l
      | SId s       -> L.build_load (lookup s) s builder
      | SLstring s -> build_string s builder
      (* TODO: List support *)
      | SLlist l -> let list_builder l = Array.of_list (List.map (expr builder) l)
                    in
                    (match sx with
                    List(Int) -> L.build_call append_int_func (Array.append [|L.const_pointer_null list_t; L.const_int i32_t (List.length l);|] (list_builder l)) "append_int" builder
                    | List(Float) -> L.build_call append_double_func (Array.append [|L.const_pointer_null list_t; L.const_int i32_t (List.length l);|] (list_builder l)) "append_double" builder
                    | _ -> raise (Failure "List type error"))
      | SLtuple l -> let t = L.const_struct context (Array.of_list (List.map (expr builder) l))
                    in
                    let null = L.const_int i32_t 0
                    in L.build_in_bounds_gep t [| null |] "tpl" builder
      | SAssign (s, e) -> let n = try lookup s
                                  with Not_found -> 

                                  let (fdef, fdecl) = StringMap.find s function_decls
                                  in
                                  let llargs = List.rev (List.map (expr builder) (List.rev [e]))
                                  in
                                  let result = (match fdecl.styp with
                                          | _ -> s ^ "_result")
                                  in L.build_call fdef (Array.of_list llargs) result builder

                          in
                        (match e with
                          (String, SLstring(l)) -> let e' = L.build_call sassign_func [|L.build_load n s builder; expr builder e;|] "sassign" builder
                                    in ignore(L.build_store e' n builder); e'
                          | _ -> let e' = expr builder e
                                in ignore(L.build_store e' n builder); e')
      | SGetn(s, e) -> (match sx with
                        Int -> L.build_call getn_int_func [|L.build_load (lookup s) s builder; expr builder e;|] "getn_int" builder
                        | Float -> L.build_call getn_double_func [|L.build_load (lookup s) s builder; expr builder e;|] "get_double" builder
                        | _ -> raise (Failure "List type error"))
      | SBinop ((A.Float,_ ) as e1, op, e2) ->
        let e1' = expr builder e1
        and e2' = expr builder e2
        in
        (match op with
          A.Add     -> L.build_fadd
        | A.Sub     -> L.build_fsub
        | A.Mult    -> L.build_fmul
        | A.Div     -> L.build_fdiv
        | A.Equal   -> L.build_fcmp L.Fcmp.Oeq
        | A.Neq     -> L.build_fcmp L.Fcmp.One
        | A.Less    -> L.build_fcmp L.Fcmp.Olt
        | A.Leq     -> L.build_fcmp L.Fcmp.Ole
        | A.Greater -> L.build_fcmp L.Fcmp.Ogt
        | A.Geq     -> L.build_fcmp L.Fcmp.Oge
        | A.And
        | A.Or ->
          raise (Failure "internal error: semant should have rejected and/or on float")
          ) e1' e2' "tmp" builder
        | SBinop (e1, op, e2) ->
          let e1' = expr builder e1
          and e2' = expr builder e2
          in
          (match op with
            A.Add     -> L.build_add
          | A.Sub     -> L.build_sub
          | A.Mult    -> L.build_mul
          | A.Div     -> L.build_sdiv
          | A.And     -> L.build_and
          | A.Or      -> L.build_or
          | A.Equal   -> L.build_icmp L.Icmp.Eq
          | A.Neq     -> L.build_icmp L.Icmp.Ne
          | A.Less    -> L.build_icmp L.Icmp.Slt
          | A.Leq     -> L.build_icmp L.Icmp.Sle
          | A.Greater -> L.build_icmp L.Icmp.Sgt
          | A.Geq     -> L.build_icmp L.Icmp.Sge
          ) e1' e2' "tmp" builder
          | SUnop(op, ((t, _) as e)) ->
            let e' = expr builder e
            in
            (match op with
              A.Neg when t = A.Float -> L.build_fneg
            | A.Neg                  -> L.build_neg
            | A.Not                  -> L.build_not) e' "tmp" builder 
          | SLength(e) ->
              L.build_call length_func [| (expr builder e) |] "length" builder
            | SCall ("print", [e]) ->
              L.build_call printf_func [|(expr builder e)|] "printf" builder
            | SCall ("printb", [e]) ->
              L.build_call printb_func [|int_format_str; (expr builder e)|]
              "printf" builder
            | SCall ("printi", [e]) ->
              L.build_call printf_func [|int_format_str ; (expr builder e)|]
              "printf" builder
            | SCall ("printbig", [e]) ->
              L.build_call printbig_func [| (expr builder e) |]
              "printbig" builder
            | SCall ("printf", [e]) ->
              L.build_call printf_func [| float_format_str ; (expr builder e) |]
              "printf" builder
            | SCall ("strlen", [e]) ->
              L.build_call strlen_func [|(expr builder e)|] "strlen" builder
            | SCall ("inputint", [e]) ->
              L.build_call inputint_func [| (expr builder e) |] "inputint" builder
            | SCall ("inputfloat", [e]) ->
              L.build_call inputfloat_func [| (expr builder e) |] "inputfloat" builder
            | SCall ("cmd", [e]) ->
              L.build_call cmd_func [| (expr builder e) |] "cmd" builder
            | SCall ("inputstring", [e]) ->
              L.build_call inputstring_func [| (expr builder e) |] "inputstring" builder
            | SCall ("sendmail", [e1; e2]) ->
              L.build_call sendmail_func [| (expr builder e1);(expr builder e2) |] "sendmail" builder
            | SCall ("inputgui", [e]) ->
              L.build_call inputgui_func [| (expr builder e) |] "inputgui" builder
            | SCall ("inputfile", [e1; e2]) ->
              L.build_call inputfile_func [|(expr builder e1); (expr builder e2)|]
              "inputfile" builder  
            | SCall ("strcmp", [e1; e2]) ->
              L.build_call strcmp_func [|(expr builder e1); (expr builder e2)|]
              "strcmp" builder
            | SCall ("strcat", [e1; e2]) ->
              L.build_call strcat_func [|(expr builder e1); (expr builder e2)|]
              "strcat" builder
            | SCall ("strcpy", [e1; e2]) ->
              L.build_call strcpy_func [|(expr builder e1); (expr builder e2)|]
              "strcpy" builder
            | SCall("calloc", [e]) ->
              L.build_call calloc_func [|L.const_int i32_t 1; (expr builder e)|] "calloc" builder
            | SCall("free", [e]) ->
              L.build_call free_func [| (expr builder e) |] "free" builder
            | SCall (f, args) ->
              let (fdef, fdecl) = StringMap.find f function_decls
              in
              let llargs = List.rev (List.map (expr builder) (List.rev args))
              in
              let result = (match fdecl.styp with
                      | _ -> f ^ "_result")
              in L.build_call fdef (Array.of_list llargs) result builder
    in

    (* LLVM insists each basic block end with exactly one "terminator"
       instruction that transfers control.  This function runs "instr builder"
       if the current block does not already have a terminator.  Used,
       e.g., to handle the "fall off the end of the function" case. *)
    let add_terminal builder instr =
      match L.block_terminator (L.insertion_block builder) with
        Some _ -> ()
      | None -> ignore (instr builder)
    in

    (* Build the code for the given statement; return the builder for
       the statement's successor (i.e., the next instruction will be built
       after the one generated by this call) *)

    let rec stmt builder = function
        SBlock sl -> List.fold_left stmt builder sl
      | SExpr e -> ignore(expr builder e); builder
      | SReturn e -> ignore(match fdecl.styp with
                              (* Special "return nothing" instr *)

                              (* Build return statement *)
                            | _ -> L.build_ret (expr builder e) builder );
                     builder
      | SSetn(t, s, e1, e2) -> ignore((match t with
                                List(Int) -> L.build_call setn_int_func
                                            [|L.build_load (lookup s) s builder;
                                            expr builder e1; expr builder e2;|]
                                            "" builder
                              | List(Float) -> L.build_call setn_double_func
                                              [|L.build_load (lookup s) s builder;
                                              expr builder e1; expr builder e2;|]
                                              "" builder
                              | _ -> raise (Failure "List type error"))); builder
      | SIf (predicate, then_stmt, else_stmt) ->
          let bool_val = expr builder predicate
          in
          let merge_bb = L.append_block context "merge" the_function
          in
          let build_br_merge = L.build_br merge_bb
          in (* partial function *)

          let then_bb = L.append_block context "then" the_function
          in add_terminal (stmt (L.builder_at_end context then_bb) then_stmt)
                          build_br_merge;

          let else_bb = L.append_block context "else" the_function
          in add_terminal (stmt (L.builder_at_end context else_bb) else_stmt)
                          build_br_merge;

             ignore(L.build_cond_br bool_val then_bb else_bb builder);
             L.builder_at_end context merge_bb

      | SWhile (predicate, body) ->
        let pred_bb = L.append_block context "while" the_function
        in ignore(L.build_br pred_bb builder);

        let body_bb = L.append_block context "while_body" the_function
        in add_terminal (stmt (L.builder_at_end context body_bb) body)
                        (L.build_br pred_bb);

        let pred_builder = L.builder_at_end context pred_bb
        in
        let bool_val = expr pred_builder predicate
        in

        let merge_bb = L.append_block context "merge" the_function
        in ignore(L.build_cond_br bool_val body_bb merge_bb pred_builder);
           L.builder_at_end context merge_bb

      (* Implement for loops as while loops *)

    in

    (* Build the code for each statement in the function *)
    let builder = stmt builder (SBlock fdecl.sbody)
    in

    (* Add a return if the last block falls off the end *)
    add_terminal builder (match fdecl.styp with
       (* A.Void -> L.build_ret_void*)
      | A.Float -> L.build_ret (L.const_float float_t 0.0)
      | t -> L.build_ret (L.const_int (ltype_of_typ t) 0))
  in

  List.iter build_function_body functions;
  the_module
