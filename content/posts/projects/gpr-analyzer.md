---
title: "Building a GitHub Analyzer with Go and Python"
description: "How I built a repository analyzer that combines Go, Python, tree-sitter, and AST traversal to report code structure and complexity."
date: 2025-12-05
slug: github-analyzer-go-python
github: "https://github.com/Nyxox-debug/repo-scan"

categories:
  - projects

tags:
  - go
  - python
  - ast
  - tree-sitter
  - developer-tools
---

Ever wanted to quickly understand what a GitHub repository looks like without cloning and exploring it yourself? I built a tool that does exactly that - paste any GitHub URL, and it analyzes the entire codebase, extracting complexity metrics, code structure, and language distribution.

The best part? It combines Go and Python in a way that showcases how to pick the right tool for each job.

<!--more-->

## The Idea

I was working on a project and needed to understand a large open-source codebase quickly. Manually exploring files and trying to understand the architecture was tedious. 

Wouldn't it be nice, I thought, if I could just paste a URL and get a report?

- How many files? How many functions?
- What's the language breakdown?
- Where are the complex areas?

So I built GPR-Analyzer - a web tool that clones a repo and runs static analysis on it.

## Architecture: Go + Python

Here's why I chose this hybrid approach:

**Go** handles:
- Web server (HTTP routing)
- Repository cloning (using go-git)
- Executing the Python analyzer as a subprocess
- Parsing JSON responses

**Python** handles:
- File system traversal
- AST generation (using tree-sitter)
- Code analysis and metrics

The key design decision was keeping them decoupled. Go just executes Python and reads JSON from stdout. This means you could swap Python for anything - Ruby, Node.js, whatever - without touching Go code.

## How It Works

Here's the flow:

1. You paste a URL like `https://github.com/user/repo`
2. Go validates it's a valid GitHub URL
3. Go clones the repo to a temporary directory
4. Go spawns Python to analyze it
5. Python walks every file, parses ASTs, counts functions/classes
6. Python outputs JSON
7. Go parses JSON and sends it back to the browser

The interface is dead simple - a text input and a submit button. That's it.

## The Interesting Parts

### AST Analysis with tree-sitter

Tree-sitter is incredible. It generates precise Abstract Syntax Trees for code, which means you can actually understand code structure rather than just regex matching.

For example, counting functions in Python:

```python
def calculate_complexity(node):
    if 'function' in node.type.lower():
        function_count += 1
    for child in node.children:
        calculate_complexity(child)
```

Simple recursive tree traversal. But it works across 25+ languages!

### The Interface Between Languages

I kept the Go↔Python interface dead simple:

```python
# Python outputs JSON to stdout
print(json.dumps(report))

# Go captures it
cmd := exec.Command("python3", "analyzer/main.py")
output, _ := cmd.CombinedOutput()
```

No sockets, no HTTP between them. Just stdout. This makes debugging easy too - you can run the Python script manually and see exactly what it outputs.

## What I Learned

1. **Language mixing is practical** - Using Go for orchestration and Python for analysis played to each language's strengths

2. **tree-sitter is powerful** - It's not just for editors. Any code analysis tool can benefit from precise ASTs

3. **Simple interfaces win** - The JSON-over-stdout pattern is nothing fancy, but it's robust and easy to debug

## What's Missing

There's a lot more I could add:
- Cyclomatic complexity metrics
- Coupling analysis between files
- Visualization of code structure
- Support for private repos

Maybe version 2?

## Check It Out

The project is ready to use if you want to try it. Clone the repo, run `./run`, and open `http://localhost:8081`. Paste any public GitHub URL and see what it finds.

It's fascinating to see what these tools reveal about different codebases!
