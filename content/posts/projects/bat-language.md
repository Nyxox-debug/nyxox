---
title: "I Built a Programming Language in Go"
date: 2025-12-29
slug: programming-language-go
pinned: true
github: "https://github.com/Nyxox-debug/bat"
categories:
  - projects
tags:
  - go
  - interpreter
  - compiler
  - ast
---

I've always been fascinated by programming languages. How does code actually become a running program? What happens when you type `let x = 5;` in a REPL?

So I built my own. Meet **Bat** - a tiny interpreted programming language written entirely in Go. It's not useful for production, but it taught me how interpreters actually work.

<!--more-->

## The Goal

I didn't set out to create something practical. I wanted to understand:

- How do lexers turn text into tokens?
- How do parsers build syntax trees?
- How does the evaluator actually run code?

Building a language from scratch is the best way to answer these questions.

## What Bat Looks Like

It's a simple, Lisp-ish language with a REPL:

```
>> let x = 5;
5
>> let y = 3;
3
>> let add = fn(a, b) { return a + b; };
fn(a, b) { ... }
>> add(x, y);
8
>> if (x > 3) { 10 } else { 0 };
10
```

You can define functions, use conditionals, do arithmetic. Pretty standard stuff - but all implemented from scratch.

## The Three Stages

Every interpreter has three stages:

```
Source Code → Lexer → Tokens → Parser → AST → Evaluator → Result
```

Let me walk through each one.

### 1. Lexer: Breaking Text into Tokens

The lexer reads character by character and groups them into meaningful tokens.

For example, `let x = 5;` becomes:
- `LET` - keyword
- `IDENT` "x" - variable name
- `ASSIGN` "=" - operator
- `INT` "5" - number
- `SEMICOLON` ";" - delimiter

The key insight is **look-ahead**. When the lexer sees `=`, it peeks at the next character. If it's another `=`, it knows it's `==` (equality), not assignment.

```go
if l.peekChar() == '=' {
    // It's == !
    l.readChar()
    tok = Token{Type: EQ, Literal: "=="}
}
```

### 2. Parser: Building the AST

Tokens aren't enough - we need to understand structure. That's where the parser comes in.

Bat uses **Pratt parsing** (top-down operator precedence). It's a clever technique where each token type knows how to parse itself:

```go
func (p *Parser) parseExpression(precedence int) Expression {
    // Get the prefix parser for current token (e.g., number, identifier)
    prefix := p.prefixParseFns[p.curToken.Type]
    leftExp := prefix()
    
    // While next operator binds tighter, let it consume more
    for precedence < p.peekPrecedence() {
        infix := p.infixParseFns[p.peekToken.Type]
        p.nextToken()
        leftExp = infix(leftExp)
    }
    return leftExp
}
```

For `2 + 3 * 4`:
1. Parse `2` as a number
2. See `+` with lower precedence than `*`
3. Parse `3 * 4` as a complete expression (multiplication binds tighter)
4. Result: `Add(Int(2), Mul(Int(3), Int(4)))`

The AST represents this hierarchy explicitly.

### 3. Evaluator: Running the AST

The evaluator recursively walks the tree:

```go
func Eval(node Node) Object {
    switch node := node.(type) {
    case *IntegerLiteral:
        return &Integer{Value: node.Value}
    case *InfixExpression:
        left := Eval(node.Left)
        right := Eval(node.Right)
        return evalInfix(node.Operator, left, right)
    case *LetStatement:
        val := Eval(node.Value)
        env.Set(node.Name.Value, val)
    // ... and so on
    }
}
```

It's surprisingly simple. Each node type knows how to evaluate itself. The evaluator just dispatches to the right function.

## The Interesting Challenges

### Handling Scope

Bat uses a simple environment (symbol table):

```go
type Environment struct {
    store map[string]Object
}
```

Functions look up variables in this environment. True closures would require nested scopes - but for a minimal interpreter, a single global environment works.

### Operator Precedence

Pratt parsing made this elegant, but getting it right took trial and error. Does `*` bind tighter than `+`? What about `==` vs `<`? The precedence constants encode this:

```go
const (
    LOWEST = iota
    EQUALS      // ==
    LESSGREATER // < or >
    SUM         // + or -
    PRODUCT     // * or /
)
```

### Error Handling

Errors can happen at any stage:
- Lexer: unknown character
- Parser: unexpected token  
- Evaluator: undefined variable

Each stage collects and reports errors. The REPL shows them with a friendly message (and some ASCII art bat).

## What I Learned

1. **Interpreters are approachable** - I expected this to be complex, but the core ideas are actually simple

2. **Pratt parsing is elegant** - No grammar files, no code generators. Just functions that know how to parse

3. **Type switches are powerful** - Go's switch on types (not values) is perfect for the evaluator pattern

4. **Separation of concerns** - Lexer doesn't know about parsing, parser doesn't know about evaluation. Clean interfaces.

## The Code

It's all in Go:

- `lexer/` - tokenization
- `parser/` - AST construction  
- `evaluator/` - execution
- `repl/` - the interactive prompt

Clone it, run `go run main.go`, and you get a working REPL. Try defining functions, using variables, whatever.

## Why This Matters

You probably won't use Bat in production. But understanding how languages work changes how you think about code.

Now when I write Python or JavaScript, I see the lexer, parser, and evaluator underneath. It's a different perspective - and a useful one.

The bat flies at night, and now I know how it processes your code from start to finish.
