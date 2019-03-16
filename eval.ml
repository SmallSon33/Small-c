open Types
open Utils

exception TypeError of string
exception DeclarationError of string
exception DivByZeroError

let rec lookup env e = match env with
  [] -> raise (DeclarationError "DeclarationError")
  | (h,v) :: t -> if e = h then v else lookup t e

let rec lookup' env e = match env with
    [] -> false
    | (h,v) :: t -> if e = h then true else lookup' t e



let rec eval_expr env e = match e with
  | Id (a) -> lookup env a
  | Int(a) -> Val_Int(a)
  | Bool (a) -> Val_Bool(a)
  | Plus(a,b) -> (match(eval_expr env a,eval_expr env b) with
                  |(Val_Int(x),Val_Int(y))->Val_Int(x+y)
                  | (_,_) -> raise (TypeError "Type error plus"))

  | Sub(a,b) -> (match(eval_expr env a,eval_expr env b) with
                  |(Val_Int(x),Val_Int(y))->Val_Int(x-y)
                  | (_,_) -> raise (TypeError "Type error sub"))

  | Mult(a,b) -> (match(eval_expr env a,eval_expr env b) with
                  |(Val_Int(x),Val_Int(y))->Val_Int(x*y)
                  | (_,_) -> raise (TypeError "Type error mult"))

  | Div(a,b) -> (match(eval_expr env a,eval_expr env b) with
                  |(Val_Int(x),Val_Int(y))->
                    if y = 0 then raise (DivByZeroError)
                    else Val_Int(x/y)
                  | (_,_) -> raise (TypeError "Type error div"))
  | Pow(a,b) -> (match(eval_expr env a,eval_expr env b) with
                  |(Val_Int(x),Val_Int(y))->Val_Int(int_of_float
                      (float_of_int x** float_of_int y))
                  | (_,_) -> raise (TypeError "Type error mult"))
  | Or(a,b) -> (match(eval_expr env a,eval_expr env b) with
                  (Val_Bool(x),Val_Bool(y))->Val_Bool(x||y)
                  | (_,_) -> raise (TypeError "Type error or"))

  | And(a,b) ->(match(eval_expr env a,eval_expr env b) with
                  |(Val_Bool(x),Val_Bool(y))->Val_Bool(x&&y)
                  | (_,_) -> raise (TypeError "Type error and"))

  | Not(a) -> (let x = eval_expr env a in match x with
                  | Val_Bool x -> Val_Bool(not x)
                  | _ -> raise (TypeError "Type error or"))

  | Greater(a,b) ->(match(eval_expr env a,eval_expr env b) with
                  |(Val_Int(x),Val_Int(y))->Val_Bool(x>y)
                  | (_,_) -> raise (TypeError "Type error greater"))

  | GreaterEqual(a,b) -> (match(eval_expr env a,eval_expr env b) with
                  |(Val_Int(x),Val_Int(y))->Val_Bool(x>=y)
                  | (_,_) -> raise (TypeError "Type error GreaterEqual"))

  | Less(a,b) -> (match(eval_expr env a,eval_expr env b) with
                  |(Val_Int(x),Val_Int(y))->Val_Bool(x<y)
                  | (_,_) -> raise (TypeError "Type error less"))

  | LessEqual(a,b) ->(match(eval_expr env a,eval_expr env b) with
                  |(Val_Int(x),Val_Int(y))->Val_Bool(x<=y)
                  | (_,_) -> raise (TypeError "Type error LessEqual"))

  | Equal(a,b) -> (match(eval_expr env a,eval_expr env b) with
                  |(Val_Int(x),Val_Int(y))->Val_Bool(x=y)
                  |(Val_Bool(x),Val_Bool(y))->Val_Bool(x=y)
                  | (_,_) -> raise (TypeError "Type error greater"))

  | NotEqual(a,b)->(match(eval_expr env a,eval_expr env b) with
                  |(Val_Int(x),Val_Int(y))->Val_Bool(x!=y)
                  |(Val_Bool(x),Val_Bool(y))->Val_Bool(x!=y)
                  | (_,_) -> raise (TypeError "Type error greater"))


let rec eval_stmt env s = match s with
  |NoOp -> env

  |Seq(s1,s2) -> let e1' = eval_stmt env s1 in
                 eval_stmt e1' s2

  |Declare(d,s1) ->
                if (lookup' env s1) then
                  raise (DeclarationError "exits")
                else
                (match d with
                | Type_Int -> (s1,Val_Int 0) ::env
                | Type_Bool -> (s1, Val_Bool false) ::env
                )

  |Assign(s1,e) -> (if (lookup' env s1) = false then
                      raise (DeclarationError "not exits")
                   else
                   let v = lookup env s1 in
                   match v with
                   |Val_Int a -> (let e'=eval_expr env e in
                                 match e' with
                                 |Val_Int a' -> (s1,e') :: env
                                 |_ -> raise(TypeError "Can only be int"))

                   |Val_Bool b-> (let e'=eval_expr env e in
                                 match e' with
                                 |Val_Bool b' -> (s1,e') :: env
                                 |_ -> raise(TypeError "Can only be bool"))

                   )

  |If(e,s1,s2) -> let b = eval_expr env e in
                  (match b with
                   | Val_Bool x -> if x then eval_stmt env s1 else eval_stmt env s2
                   | _ -> raise (TypeError "type error"))

  |While(e,s1) -> (let v = eval_expr env e in
                  match v with
                  | Val_Bool b ->
                    if b then let s1'=eval_stmt env s1 in eval_stmt s1' (While(e,s1))
                    else env
                  | _ -> raise (TypeError "Type error"))

  |Print(e) -> (let e' = eval_expr env e in
                match e' with
                | Val_Bool b -> if b then (print_output_bool true;
                                          print_output_newline ();
                                          env)
                                else (print_output_bool false;
                                     print_output_newline ();
                                     env)
                | Val_Int a -> (print_output_int a;
                               print_output_newline ();
                               env)
                )
