# SmallC Interpreter

July 11th, 2017

Introduction
------------
Implementing a small subset of an interpreter and typechecker for SmallC, a small C-like language. The language supports variables, `int` and `bool` types, equality and comparison operations, math and boolean operations, control flow, and printing, all while maintaining static type-safety and being Turing complete!

The language consists of expressions from the `expr` type and statements from the `stmt` type. These algebraic types can be used to represent the full space of properly formed SmallC programs. Their definitions are found in the `types.ml` file. This file should be a constant reference to the data types involved in successfully working with SmallC.

Files
-------------
-  OCaml Files
  - **eval.ml**
  - **eval.mli**: This is the _interface_ for `eval.ml`. It defines what types and functions are visible to modules outside of `eval.ml` (such as `smallc.ml`, listed below).
  - **lexer.cm[oi]** and **parser.cm[oi]**: These precompiled object and interface files contain the lexer and parser used for turning plain files into OCaml datatypes. 
  - **smallc.ml**: A frontend to interpreter used to build the `smallc` executable target.
  - **types.ml**: This file contains all type definitions.
  - **utils.ml** and **testUtils.ml**: These files contain functions for testing and debugging. The small part of **utils.ml** that concerns the implementing is called out very explicitly when it is needed later in the document.
- Submission Scripts and Other Files
  - **Makefile**: This is used to build the public tests by simply running the command `make`.

Compilation, Tests, and Running
-------------------------------
In order to compile your project, simply run the `make` command and our `Makefile` will handle the compilation process for you, just as in 216. After compiling your code, three executable files will be created:
- public
- smallc

The public tests can be run by simply running `public` (i.e. `./public` in the terminal; think of this just like with a.out in C).

The Evaluator
-------------

### eval_expr

`eval_expr` takes an environment `env` and an expression `e` and produces the result of _evaluating_ `e`, which is something of type `value` (`Val_Int` or `Val_Bool`).

#### Int

Integer literals evaluate to a `Val_Int` of the same value.

#### Bool

Boolean literals evaluate to a `Val_Bool` of the same value.

#### Id

An identifier evaluates to whatever value it is mapped to by the environment. Should raise a `DeclarationError` if the identifier has no binding.

#### Plus, Sub, Mult, Div, and Pow

*These rules are jointly classified as BinOp-Int in the formal semantics.*

These mathematical operations operate only on integers and produce a `Val_Int` containing the result of the operation. All operators must work for all possible integer values, positive or negative, except for division, which will raise a `DivByZeroError` exception on an attempt to divide by zero. If either of the expressions to perform these operations on is not an integer, a `TypeError` should be raised.

#### Or and And

*These rules are jointly classified as BinOp-Bool in the formal semantics.*

These logical operations operate only on booleans and produce a `Val_Bool` containing the result of the operation. If either of the expressions to perform these operations on is not a boolean, a `TypeError` should be raised.

#### Not

The unary not operator operates only on booleans and produces a `Val_Bool` containing the negated value of the contained expression. If the expression in the `Not` is not a boolean, a `TypeError` should be raised.

#### Greater, Less, GreaterEqual, LessEqual

*These rules are jointly classified as BinOp-Int in the formal semantics*

These relational operators operate only on integers and produce a `Val_Bool` containing the result of the operation. If either of the expressions to perform these operations on evaluates to a non-integer type, a `TypeError` should be raised.

#### Equal and NotEqual

These equality operators operate both on integers and booleans, but both subexpressions must be of the same type. The operators produce a `Val_Bool` containing the result of the operation. If the two expressions to perform these operations on evaluate to mismatched types (i.e. one boolean and one integer), a `TypeError` should be raised.

### Part 2: eval_stmt

`eval_stmt` takes an environment `env` and a statement `s` and produces an updated `eval_environment` as a result. This environment is represented as `a` in the formal semantics, but will be referred to as the environment in this document.

#### NoOp

`NoOp` is short for "no operation" and should do just that - nothing at all. It is used to terminate a chain of sequence statements, and is much like the empty list in OCaml in that way. The environment should be returned unchanged when evaluating a `NoOp`.

#### Seq

The sequencing statement is used to compose whole programs as a series of statements. When evaluating `Seq`,  evaluate the first substatement under the environment `env` to create an updated environment `env'`. Then, evaluate the second substatement under `env'`, returning the resulting environment.

#### Declare

The declaration statement is used to create new variables in the environment. If a variable of the same name has already been declared, a `DeclarationError` should be raised. Otherwise, if the type being declared is `Type_Int`, a new binding to the value `Val_Int(0)` should be made in the environment. If the type being declared is `Type_Bool`, a new binding to the value `Val_Bool(false)` should be made in the environment. The updated environment should be returned.

#### Assign

The assignment statement assigns new values to already-declared variables. If the variable hasn't been declared before assignment, a `DeclarationError` should be raised. If the variable has been declared to a different type than the one being assigned into it, a `TypeError` should be raised. Otherwise, the environment should be updated to reflect the new value of the given variable, and an updated environment should be returned.

#### If

The `if` statement consists of three components - a guard expression, an if-body statement and an else-body statement. The guard expression must evaluate to a boolean - if it does not, a `TypeError` should be raised. If it evaluates to true, the if-body should be evaluated. Otherwise, the else-body should be evaluated instead. The environment resulting from evaluating the correct body should be returned.

#### While

The while statement consists of two components - a guard expression and a body statement. The guard expression must evaluate to a boolean - if it does not, a `TypeError` should be raised. If it evaluates to `true`, the body should be evaluated to produce a new environment and the entire loop should then be evaluated again under this new environment, returning the environment produced by the reevaluation. If the guard evaluates to `false`, the current environment should simply be returned.

*The formal semantics rule for while loops is particularly helpful!*

#### Print

The print statement is access to standard output. First, the expression to `print` should be evaluated. Print supports both integers and booleans. Integers should print in their natural forms (i.e. printing `Val_Int(10)` should print "10". Booleans should print in plaintext (i.e. printing `Val_Bool(true)` should print "true" and likewise for "false"). Whatever is printed should always be followed by a newline.

<!-- Link References -->
[list doc]: https://caml.inria.fr/pub/docs/manual-ocaml/libref/List.html
[hack github]: https://github.com/facebook/hhvm/tree/master/hphp/hack
[semantics document]: semantics.pdf

<!-- These should always be left alone or at most updated -->
[pervasives doc]: https://caml.inria.fr/pub/docs/manual-ocaml/libref/Pervasives.html
[git instructions]: ../git_cheatsheet.md
[submit server]: submit.cs.umd.edu
[web submit link]: image-resources/web_submit.jpg
[web upload example]: image-resources/web_upload.jpg
