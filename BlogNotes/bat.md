# Building an Interpreter from Scratch: A Deep Dive into the Bat Programming Language

## 1. Project Overview

The Bat programming language is a simple, interpreted language written entirely in Go. Inspired by classic educational languages like Lisp and influenced by modern language implementation tutorials, Bat demonstrates the fundamental concepts behind how interpreters and programming languages work under the hood.

### What the Project Does

Bat is a small programming language that allows users to write and execute code through a REPL (Read-Eval-Print Loop) interface. Users can type expressions and statements directly into the terminal, and the system immediately evaluates and displays the result. The language supports essential programming constructs including arithmetic operations, variable bindings, conditional statements, and first-class functions with closures.

### The Problem It Solves

This project serves an educational purpose: it provides a concrete, working example of how programming languages are built from the ground up. Many developers use programming languages daily without understanding the pipeline that transforms source code into executing programs. Bat demystifies this process by implementing each stage of language processing—lexical analysis, parsing, and evaluation—as separate, understandable components.

### Key Features

The language supports several fundamental programming constructs that demonstrate the core concepts of interpreter design:

- **Arithmetic Operations**: Addition, subtraction, multiplication, and division with proper operator precedence
- **Boolean Operations**: True/false values with comparison operators (==, !=, <, >)
- **Variables and Bindings**: The `let` keyword creates named references to values
- **Conditional Statements**: If-else expressions for branching control flow
- **First-Class Functions**: Functions as values that can be defined, stored in variables, and invoked
- **Return Statements**: Functions can return values to their callers
- **REPL Interface**: Interactive command-line environment for immediate feedback

## 2. Architecture Overview

Bat follows the classic interpreter architecture with three primary stages: lexical analysis (tokenization), parsing (syntactic analysis), and evaluation (semantic analysis). Each stage transforms the input in a specific way and passes its output to the next stage.

### High-Level System Design

The interpreter pipeline flows as follows: source code enters as a string through the Lexer, which produces a stream of Tokens. These tokens feed into the Parser, which builds an Abstract Syntax Tree (AST) representing the program's structure. Finally, the Evaluator traverses the AST and produces runtime values called Objects.

```
Source Code → Lexer → Tokens → Parser → AST → Evaluator → Objects → Output
```

This three-stage pipeline is a fundamental pattern in both compilers and interpreters. The key insight is that each stage has a clear responsibility and communicates through well-defined data structures.

### Major Components and Their Interactions

The system consists of seven distinct packages, each handling a specific aspect of language processing:

- **token**: Defines the vocabulary of the language—the different kinds of meaningful units that can appear in source code
- **lexer**: Transforms raw character input into a stream of tokens through character-by-character analysis
- **ast**: Provides the node types that form the tree representation of programs
- **parser**: Consumes tokens and arranges them into a hierarchical AST structure using Pratt parsing
- **object**: Defines the runtime value types that the interpreter works with during execution
- **environment**: Manages variable bindings and scope, acting as a symbol table during evaluation
- **evaluator**: Walks the AST and produces results by interpreting each node according to its semantics
- **repl**: Provides the user-facing interface that ties all components together

### Important Design Decisions

Several architectural choices shaped this implementation. First, the project uses a direct AST interpretation model rather than compiling to bytecode, which keeps the implementation simple and easier to understand. Second, the parser employs Pratt parsing (also called top-down operator precedence parsing), which elegantly handles operator precedence without requiring a complex grammar specification. Third, the object system uses Go interfaces to define a common type for all runtime values, enabling type switching during evaluation.

## 3. Repository Structure

The project is organized as a standard Go module with packages corresponding to each major component:

```
bat/
├── main.go              # Application entry point
├── go.mod               # Go module definition
├── token/               # Token type definitions
│   └── token.go
├── lexer/               # Lexical analyzer
│   └── lexer.go
├── ast/                 # Abstract Syntax Tree nodes
│   └── ast.go
├── parser/              # Parser implementation
│   └── parser.go
├── object/              # Runtime object types
│   ├── object.go
│   └── environment.go
├── evaluator/           # AST evaluator
│   └── evaluator.go
└── repl/                # Read-Eval-Print Loop
    └── repl.go
```

### Purpose of Each Major File

**main.go** serves as the entry point, initializing the REPL and welcoming the user. It obtains the current user's information for a personalized greeting and then delegates to the REPL package.

**token/token.go** defines all token types as constants, including identifiers, integers, operators, delimiters, and keywords. It also provides a lookup function that converts identifier strings (like "fn" or "let") into their corresponding keyword tokens.

**lexer/lexer.go** implements the tokenizer that scans input character by character. It recognizes different token types based on character patterns—letters for identifiers and keywords, digits for numbers, and special characters for operators and delimiters.

**ast/ast.go** defines the data structures representing the syntactic elements of the language. Every node type implements the Node interface with TokenLiteral() and String() methods for debugging and string representation.

**parser/parser.go** builds the AST from the token stream. It uses Pratt parsing to handle operator precedence correctly and registers prefix and infix parse functions for each token type.

**object/object.go** defines the runtime value types that the evaluator works with. These include Integer, Boolean, Null, ReturnValue, and Error types, all implementing the Object interface.

**object/environment.go** implements the environment that stores variable bindings. It's essentially a map from identifier strings to Object values, representing the current scope.

**evaluator/evaluator.go** is the heart of the interpreter. It recursively evaluates AST nodes, implementing the semantics of each language construct. The Eval function uses a type switch to dispatch to the appropriate evaluation function for each node type.

**repl/repl.go** implements the interactive console. It reads lines of input, feeds them through the full pipeline (lexer → parser → evaluator), and prints the results.

## 4. Technology Stack

### Languages, Frameworks, and Libraries

The entire project is implemented in **Go** (version 1.25.4), chosen for several compelling reasons. Go's strong standard library provides all necessary functionality without external dependencies—file I/O, string manipulation, and buffered I/O for the REPL all come from the standard library. The language's simplicity and readability make it ideal for educational code, and its performance characteristics are more than sufficient for an interpreted language.

Go's interface system proved particularly valuable for this project. Both AST nodes and runtime Objects use interfaces (Node and Object respectively), allowing polymorphic handling of different node types through type switches. The garbage collector handles memory management automatically, eliminating the need for manual memory allocation and deallocation.

### Why These Technologies

This project could theoretically be implemented in any programming language, but Go offers specific advantages for interpreter construction. The type switch mechanism in Go maps naturally to the visitor pattern commonly used in interpreters. Goroutines aren't directly used here, but Go's concurrency model would enable interesting extensions like parallel evaluation.

Go's strict typing catches many errors at compile time, while its zero-value initialization and simple syntax reduce boilerplate. These factors combine to make Go an excellent choice for implementing language tools and compilers.

## 5. Execution Flow

Understanding how the program starts and processes input reveals the complete lifecycle of code execution in Bat.

### How the Program Starts

When a user runs `go run main.go`, the program begins execution in the main function defined in main.go. The function performs minimal setup: it retrieves the current user's information for a personalized greeting, prints welcome messages, and then calls `repl.Start(os.Stdin, os.Stdout)`.

The Start function in the repl package initializes the environment (a fresh empty scope for variables), then enters an infinite loop that repeatedly prompts for input, processes it, and displays results.

### Important Entry Points

The REPL loop in repl.Start() is the primary entry point for user interaction. Within each iteration, the flow proceeds through three main functions:

1. **lexer.New(line)** creates a new Lexer instance initialized with the input line
2. **parser.New(l)** creates a Parser consuming tokens from the lexer
3. **evaluator.Eval(program, env)** evaluates the parsed AST in the environment

Each stage can fail—the parser might encounter syntax errors, or the evaluator might encounter runtime errors—and these errors are caught and displayed to the user before the loop continues.

### Request/Data Flow Through the System

When a user types `let x = 5;` and presses enter, the following transformation occurs:

1. The lexer scans the characters and produces tokens: LET("let"), IDENT("x"), ASSIGN("="), INT("5"), SEMICOLON(";")
2. The parser recognizes this as a LetStatement, parsing the identifier "x" as the variable name and the expression "5" as the value
3. The evaluator encounters the LetStatement, evaluates the expression (yielding an Integer object with value 5), and stores it in the environment under the key "x"

When the user subsequently types `x;`, the same pipeline runs, but the evaluator looks up "x" in the environment and returns the stored value.

## 6. Core Modules Explained

### Token Module (token/token.go)

The token package defines the fundamental building blocks of the language. Every meaningful unit in source code is represented as a Token with a Type and a Literal string.

```go
type Token struct {
    Type    TokenType
    Literal string
}
```

The Type is one of the defined constants (IDENT, INT, PLUS, LET, etc.), while the Literal contains the actual string value. For identifiers, the Literal holds the name; for integers, it holds the numeric string representation.

The keywords map provides a lookup table converting identifier strings into their keyword token types:

```go
var keywords = map[string]TokenType{
    "fn":     FUNCTION,
    "let":    LET,
    "true":   TRUE,
    "false":  FALSE,
    "if":     IF,
    "else":   ELSE,
    "return": RETURN,
}
```

### Lexer Module (lexer/lexer.go)

The lexer performs lexical analysis, converting a string of characters into a sequence of tokens. It uses a simple character-by-character scanning approach with look-ahead capability.

The Lexer struct maintains:
- **input**: the source string being scanned
- **position**: current position in the input (pointing to current character)
- **readPosition**: position of the next character (look-ahead)
- **ch**: the current character being processed

The key insight is the look-ahead mechanism. When the lexer sees '=', it checks if the next character is also '=', which would indicate the equality operator "==". This requires reading ahead one character before deciding:

```go
if l.peekChar() == '=' {
    ch := l.ch
    l.readChar()
    tok = token.Token{Type: token.EQ, Literal: string(ch) + string(l.ch)}
}
```

The lexer recognizes:
- Letters (a-z, A-Z, _) for identifiers and keywords
- Digits (0-9) for integers
- Single-character tokens for operators and delimiters
- Whitespace (skipped but not discarded)

### AST Module (ast/ast.go)

The Abstract Syntax Tree represents the hierarchical structure of a program. Each node type corresponds to a language construct, and the tree structure captures how these constructs nest within each other.

The AST defines three core interfaces:

```go
type Node interface {
    TokenLiteral() string
    String() string
}

type Statement interface {
    Node
    statementNode()
}

type Expression interface {
    Node
    expressionNode()
}
```

The Statement vs Expression distinction is fundamental: statements perform actions (like variable binding or return) but don't produce values, while expressions evaluate to values. This separation simplifies the evaluator's logic.

Key node types include:
- **Program**: root node containing all statements
- **LetStatement**: variable bindings (`let x = 5;`)
- **ReturnStatement**: function return values (`return 5;`)
- **ExpressionStatement**: bare expressions (`5 + 3;`)
- **IntegerLiteral**: numeric constants (`42`)
- **Boolean**: true/false literals
- **Identifier**: variable references (`x`)
- **PrefixExpression**: unary operations (`-5`, `!true`)
- **InfixExpression**: binary operations (`5 + 3`, `x == y`)
- **IfExpression**: conditional expressions (`if (x > 0) { ... }`)
- **FunctionLiteral**: function definitions (`fn(x) { ... }`)
- **CallExpression**: function calls (`add(1, 2)`)

### Parser Module (parser/parser.go)

The parser transforms the token stream into an AST. Bat uses Pratt parsing, also known as top-down operator precedence parsing, which handles operator precedence elegantly without a traditional grammar specification.

The parser maintains two tokens at all times:
- **curToken**: the current token being examined
- **peekToken**: the next token (look-ahead)

This dual-token approach enables the parser to make decisions based on what comes next while retaining context about the current token.

The precedence system ranks operators by their binding strength:

```go
const (
    LOWEST = iota
    EQUALS      // ==
    LESSGREATER // < or >
    SUM         // + or -
    PRODUCT     // * or /
    PREFIX      // - or !
    CALL        // function calls
)
```

Higher precedence values mean stronger binding. Multiplication (*) binds tighter than addition (+), which is why `2 + 3 * 4` evaluates as `2 + (3 * 4)`.

The Pratt parsing algorithm works by:
1. Looking up a prefix parse function for the current token to handle the initial expression
2. Then checking if subsequent tokens are infix operators with higher precedence
3. If so, letting those operators "take over" parsing their right-hand sides
4. Repeating until no higher-precedence operators remain

This approach handles complex expressions naturally. For `1 + 2 * 3`:
- Parser starts with "1" (an integer literal)
- Sees "+" with precedence SUM
- Since peek precedence (PRODUCT) > current precedence (LOWEST), it continues
- Parses "2 * 3" as a complete expression (PRODUCT binds tighter)
- Returns the complete tree: InfixExpression(+, 1, InfixExpression(*, 2, 3))

### Object Module (object/object.go and environment.go)

The object system defines the runtime values that the interpreter produces. Each Object implements the Object interface:

```go
type Object interface {
    Type() ObjectType
    Inspect() string
}
```

The Type() method returns a string identifying the type (useful for type checking), while Inspect() returns a string representation suitable for display.

The defined types are:
- **Integer**: holds int64 values for numeric operations
- **Boolean**: holds true/false values
- **Null**: represents the absence of a value (printed as "null")
- **ReturnValue**: wraps values returned from functions
- **Error**: represents runtime errors with a message

The Environment provides the symbol table functionality:

```go
type Environment struct {
    store map[string]Object
}
```

It offers Get() to retrieve values by name and Set() to store new bindings. In this implementation, there's no nested scoping—only a single global environment. A more sophisticated implementation would support scope chaining for proper function closures.

### Evaluator Module (evaluator/evaluator.go)

The evaluator is the heart of the interpreter, implementing the semantics of each language construct. The central Eval function uses a type switch to dispatch to specialized evaluation functions:

```go
func Eval(node ast.Node, env *object.Environment) object.Object {
    switch node := node.(type) {
    case *ast.Program:
        return evalProgram(node.Statements, env)
    case *ast.ExpressionStatement:
        return Eval(node.Expression, env)
    case *ast.IntegerLiteral:
        return &object.Integer{Value: node.Value}
    // ... handles all other node types
    }
}
```

The evaluation follows these key principles:

1. **Recursive Descent**: Each node type has a corresponding evaluation function that may recursively evaluate child nodes
2. **Environment Lookups**: When encountering identifiers, the evaluator looks them up in the environment
3. **Short-Circuit Evaluation**: For boolean operations, the evaluator checks conditions and may not evaluate all operands
4. **Error Propagation**: Errors are returned as Error objects and bubble up through the call stack

The prefix operator handling demonstrates the pattern:

```go
func evalPrefixExpression(operator string, right object.Object) object.Object {
    switch operator {
    case "!":
        return evalBangOperatorExpression(right)
    case "-":
        return evalMinusPrefixOperatorExpression(right)
    }
}
```

The bang operator (!) converts truthy values to false and falsy values to true, following JavaScript-like truthiness rules where null is falsy and non-null objects are truthy.

Infix operators (binary operations) dispatch to specialized handlers:

```go
func evalInfixExpression(operator string, left, right object.Object) object.Object {
    switch {
    case left.Type() == object.INTEGER_OBJ && right.Type() == object.INTEGER_OBJ:
        return evalIntegerInfixExpression(operator, left, right)
    // ... handles other type combinations
    }
}
```

### REPL Module (repl/repl.go)

The REPL ties everything together into an interactive experience. It uses Go's bufio.Scanner to read lines from standard input, processes each line through the full pipeline, and writes results to standard output.

Error handling is particularly user-friendly: when the parser encounters errors (like missing expected tokens), it collects all errors and displays them in a formatted message with the bat ASCII art:

```
                       _..-'(                       )'-.._
                    ./'. '||\.       (\_/)       .//|' .'\.
                 ./'.|'.'||||\|..    )O O(    ..|//|||'.'|.'\.
```

This playful error message demonstrates how language tools can maintain personality while delivering useful information.

## 7. Key Algorithms and Logic

### Lexical Analysis: Character Classification

The lexer uses simple classification functions to determine character types:

```go
func isLetter(ch byte) bool {
    return 'a' <= ch && ch <= 'z' || 'A' <= ch && ch <= 'Z' || ch == '_'
}

func isDigit(ch byte) bool {
    return '0' <= ch && ch <= '9'
}
```

These functions enable the lexer to distinguish between identifiers (starting with letters), integers (starting with digits), and special characters (operators and delimiters).

### Pratt Parsing: Precedence Climbing

The core parsing algorithm in `parseExpression` demonstrates the Pratt parsing approach:

```go
func (p *Parser) parseExpression(precedence int) ast.Expression {
    prefix := p.prefixParseFns[p.curToken.Type]
    leftExp := prefix()
    
    for !p.peekTokenIs(token.SEMICOLON) && precedence < p.peekPrecedence() {
        infix := p.infixParseFns[p.peekToken.Type]
        p.nextToken()
        leftExp = infix(leftExp)
    }
    return leftExp
}
```

This algorithm:
1. Parses a "prefix" expression (literal value or parenthesized expression)
2. While the next operator has higher precedence than the current level
3. Lets that operator consume its operands recursively
4. Returns when no higher-precedence operators remain

For `add(1, 2 + 3)`, the CALL precedence enables the parser to handle function arguments correctly—the arguments are parsed at a lower precedence level, allowing expressions like `2 + 3` to parse as a single argument.

### Truthiness and Boolean Logic

The evaluator implements JavaScript-style truthiness where every value is inherently truthy except for specific falsy values:

```go
func isTruthy(obj object.Object) bool {
    switch obj {
    case NULL:
        return false
    case TRUE:
        return true
    case FALSE:
        return false
    default:
        return true
    }
}
```

This means non-null, non-boolean objects (like integers) are truthy, which simplifies the implementation while providing intuitive behavior.

### Boolean Object Caching

The evaluator caches the TRUE and FALSE boolean objects:

```go
var (
    NULL  = &object.Null{}
    TRUE  = &object.Boolean{Value: true}
    FALSE = &object.Boolean{Value: false}
)
```

This optimization ensures that boolean comparisons can return the singleton objects rather than allocating new ones each time. When evaluating `true == true`, both sides refer to the same object instance, making identity comparison (`left == right`) equivalent to value comparison.

## 8. Design Decisions

### Why Pratt Parsing

Traditional parser generators (like yacc or bison) require formal grammar specifications and generate large, complex parsers. Pratt parsing offers a simpler alternative that handles operator precedence naturally without grammar files. Each token type knows how to parse itself in both prefix and infix contexts, making the parser modular and easy to extend.

The tradeoff is that more complex language features (like prefix operators with different semantics or unusual syntax) require more sophisticated handling. For Bat's simple C-like syntax, Pratt parsing is ideal.

### Why Direct Interpretation

Bat directly interprets the AST rather than compiling to bytecode or machine code. This choice significantly simplifies the implementation—no intermediate representation is needed, no virtual machine must be implemented, and the mapping from AST to behavior is direct and visible.

The performance cost is acceptable for an educational project and for the use cases Bat targets (REPL interaction and learning). Direct interpretation trades execution speed for implementation simplicity.

### Why Single-Level Scope

The environment uses a flat structure with no nested scopes. Variables are stored in a single map without support for nested lexical scoping. This simplifies the implementation considerably—a more sophisticated interpreter would use a chain of environments where each function call creates a new scope that can access its enclosing scope.

The tradeoff is that Bat doesn't support true closures in the lexical sense. When a function references a variable, it looks up the name in the global environment, not in the scope where the function was defined. This is a known limitation but keeps the implementation accessible.

### Error Handling Philosophy

Errors are handled at each stage of the pipeline:
- The lexer produces ILLEGAL tokens for unrecognized characters
- The parser collects error messages when expected tokens are missing
- The evaluator returns Error objects for undefined identifiers and type mismatches

This approach allows errors to propagate naturally through the system. The REPL catches parser errors and displays them; evaluator errors are displayed as the result of evaluation.

## 9. How Everything Fits Together

The complete execution pipeline demonstrates how the components collaborate to transform source code into results:

**Step 1: Lexical Analysis**
When a user enters `let x = 5 + 3;`, the lexer scans characters sequentially. It produces tokens: LET → IDENT("x") → ASSIGN → INT("5") → PLUS → INT("3") → SEMICOLON. Each token captures the token type and the literal string value.

**Step 2: Parsing**
The parser builds an AST from these tokens. It recognizes the LET statement structure: expect IDENT, then ASSIGN, then parse an expression. The expression parsing uses Pratt parsing to handle "5 + 3" correctly—the PLUS operator has lower precedence than the implicit lowest precedence, so it builds InfixExpression(PLUS, IntegerLiteral(5), IntegerLiteral(3)).

**Step 3: Evaluation**
The evaluator traverses this tree. For the LetStatement:
1. Evaluate the value expression: evaluate 5 + 3
2. First evaluate the left side (5) → Integer(5)
3. Evaluate the right side (3) → Integer(3)
4. Apply the PLUS operator → Integer(8)
5. Store the result in the environment under "x"

When the user subsequently types `x;`, the evaluator looks up "x" in the environment and returns Integer(8), which displays as "8".

**Handling Functions**
Function definitions create FunctionLiteral nodes containing parameter lists and a block statement body. When encountered during evaluation, they become first-class values stored in the environment. Function calls create CallExpression nodes that:
1. Evaluate the function expression (looking up the identifier)
2. Evaluate each argument expression
3. Create a new environment for the function call
4. Bind parameters to arguments in that environment
5. Evaluate the function body in the new environment
6. Return the result (unwrapping ReturnValue if necessary)

## 10. Conclusion

The Bat programming language demonstrates the fundamental architecture of interpreted languages in a clean, understandable implementation. By building each component—the tokenizer, parser, and evaluator—as separate, focused modules, the project makes the complex task of language implementation approachable.

The key insights this project illuminates include:

**Lexical analysis** transforms linear character streams into meaningful tokens, the basic vocabulary of the language. Simple pattern matching and look-ahead enable recognition of keywords, identifiers, numbers, and operators.

**Pratt parsing** provides an elegant solution to operator precedence without formal grammars. By associating precedence levels with tokens and allowing operators to recursively consume their operands, it builds correct parse trees naturally.

**Abstract Syntax Trees** serve as the bridge between parsing and execution, representing program structure as hierarchical data that can be traversed and interpreted.

**Direct interpretation** executes the AST directly, producing values through recursive evaluation. While not the fastest approach, it clearly maps source code constructs to runtime behavior.

**The evaluator pattern** using type switches over node types is a common and effective approach in interpreters, enabling clear handling of each language construct.

This project provides a solid foundation for understanding how programming languages work under the hood. From here, one could explore bytecode compilers, garbage collectors, JIT compilation, type systems, and many other advanced topics in language implementation.

The bat flies at night, and now you understand how it processes code from start to finish.
