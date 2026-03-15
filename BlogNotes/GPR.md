# GPR-Analyzer: A Hybrid Go and Python Codebase Analysis Tool

A technical deep-dive into a multi-language project for analyzing GitHub repositories using Abstract Syntax Trees

---

## 1. Project Overview

GPR-Analyzer (GitHub Parser and Analyzer) is a lightweight demonstration project that showcases how to effectively combine two powerful programming languages—Go and Python—into a cohesive codebase analysis pipeline. The project was created primarily as an educational exercise to gain a better understanding of Abstract Syntax Trees (ASTs) and how they are generated and processed.

### What the Project Does

GPR-Analyzer accepts any public GitHub repository URL, clones it to a local temporary directory, and performs a comprehensive static analysis of the codebase. The analysis extracts:

- **Complexity metrics**: Function counts, class counts, conditional statements, loops, and AST depth
- **Code structure**: Function definitions, class definitions, imports, and global variables
- **Dependencies**: Import statements, function calls, and external references
- **Aggregate statistics**: Total files, total lines, total functions, and language distribution

### The Problem It Solves

Understanding the structure and complexity of an unfamiliar codebase can be a daunting task. This project provides an automated way to extract meaningful metrics from any GitHub repository, helping developers quickly assess:

- The overall size and complexity of a project
- The distribution of code across different programming languages
- The architectural patterns used (function-oriented vs. object-oriented)
- Potential areas of complexity that might need refactoring

### Key Features

1. **Multi-language support**: The analyzer can process over 25 programming languages including Python, JavaScript, TypeScript, Java, C, C++, Go, Rust, Ruby, PHP, and more
2. **AST-based analysis**: Uses tree-sitter to generate precise Abstract Syntax Trees for accurate code parsing
3. **Recursive directory traversal**: Builds a complete file tree of the codebase while excluding hidden directories
4. **JSON output**: Produces structured JSON output that can be easily consumed by any frontend
5. **Simple web interface**: Provides a minimal HTML/JavaScript frontend for user interaction

---

## 2. Architecture Overview

The project follows a client-server architecture with a clear separation of concerns between the Go backend and the Python analysis engine.

### High-Level System Design

```
┌─────────────┐      POST /form      ┌─────────────────┐
│   Browser   │ ──────────────────►  │  Go Web Server  │
│  (Frontend) │                      │  (main.go)      │
└─────────────┘                      └────────┬────────┘
                                             │
                                    ┌────────▼────────┐
                                    │ Validate URL    │
                                    │ Clone Repository│
                                    │ Execute Python   │
                                    │ Parse JSON       │
                                    └────────┬────────┘
                                             │
                                    ┌────────▼────────┐
                                    │ Python Analyzer │
                                    │ (main.py)       │
                                    └────────┬────────┘
                                             │
                    ┌─────────────┬──────────▼──────────┬─────────────┐
                    │             │                    │             │
               ┌────▼────┐   ┌────▼────┐         ┌────▼────┐   ┌────▼────┐
               │FileTree │   │  AST    │         │ Report  │   │ Metrics │
               │ Module  │   │Analyzer │         │ Generator│   │Calculation│
               └─────────┘   └─────────┘         └─────────┘   └─────────┘
```

### Major Components

1. **Go Backend (cmd/server/)**
   - `main.go`: Application entry point that starts the HTTP server
   - `api/api.go`: Handles HTTP routing and static file serving
   - `handler/FormHandler.go`: Processes form submissions, validates URLs, orchestrates the analysis pipeline
   - `internal/clone/clone.go`: Git repository cloning functionality
   - `internal/types/`: Go data structures for JSON response serialization

2. **Python Analyzer (analyzer/)**
   - `main.py`: Entry point that coordinates the analysis pipeline
   - `filetree/tree.py`: Builds the directory structure representation
   - `ast_tools/analyzer.py`: Core AST analysis engine
   - `ast_tools/parser.py`: File parsing using tree-sitter
   - `ast_tools/languages.py`: Language-specific grammar loading
   - `report_generator.py`: JSON output generation

3. **Frontend (public/)**
   - `index.html`: Simple HTML form for URL input
   - `script.js`: JavaScript for form handling and response rendering
   - `style.css`: Basic styling (currently minimal)

### How Components Interact

The interaction flow follows a sequential pipeline:

1. User submits a GitHub URL through the web interface
2. Go server validates the URL format
3. Go clones the repository to a local `tmp/` directory
4. Go executes the Python analyzer as a subprocess
5. Python walks the directory tree, parses each file's AST
6. Python outputs JSON to stdout
7. Go captures the output, parses it, and returns it to the client
8. JavaScript renders the analysis results in the browser

---

## 3. Repository Structure

```
GPR-Analyzer/
├── cmd/                          # Go command-line applications
│   └── server/                  # Main server application
│       ├── main.go              # Entry point
│       ├── main_test.go         # Tests
│       ├── api/
│       │   └── api.go           # HTTP routing and server setup
│       └── handler/
│           └── FormHandler.go   # Request handling logic
├── internal/                    # Go internal packages
│   ├── clone/
│   │   ├── clone.go            # Git repository cloning
│   │   └── clone_test.go        # Tests
│   └── types/
│       ├── dependencies.go     # Dependency data structures
│       ├── structure.go        # Code structure types
│       ├── complexity.go       # Complexity metric types
│       ├── metrics.go          # Aggregate metric types
│       └── file.go             # File data structure
├── analyzer/                    # Python analysis engine
│   ├── main.py                 # Entry point for Python analysis
│   ├── report_generator.py     # JSON output generation
│   ├── requirements.txt        # Python dependencies
│   ├── filetree/
│   │   └── tree.py            # Directory tree building
│   └── ast_tools/
│       ├── analyzer.py         # Core AST analysis logic
│       ├── parser.py           # File parsing with tree-sitter
│       ├── languages.py        # Language grammar loading
│       └── utils.py            # AST conversion utilities
├── public/                     # Static web assets
│   ├── index.html             # HTML form
│   ├── script.js              # Frontend JavaScript
│   └── style.css              # CSS styling
├── docs/                       # Documentation
│   ├── General.md             # High-level architecture docs
│   ├── Analyzer.md            # Python analyzer details
│   ├── Setup.md               # Setup instructions
│   ├── Frontend.png           # Architecture diagram
│   └── Backend.png            # Backend diagram
├── go.mod                      # Go module definition
├── go.sum                      # Go dependency checksums
└── run                         # Shell script to run the server
```

### Purpose of Each Major Folder

- **cmd/server/**: Contains the Go application's entry point and HTTP handling logic
- **internal/**: Contains reusable Go packages that are not exposed to external modules
- **analyzer/**: The Python-based code analysis engine
- **public/**: Static files served to web clients
- **docs/**: Project documentation explaining architecture and usage

---

## 4. Technology Stack

### Go (Backend)

The project uses Go version 1.25.3 with the following key dependency:

- **go-git v6**: A pure Go implementation of Git, used for cloning repositories without requiring the git CLI tool

```go
require github.com/go-git/go-git/v6 v6.0.0-20251118162427-2784eeea7f86
```

Go was chosen as the orchestration layer because:
1. It provides excellent standard library support for HTTP servers
2. The `exec.Command` package makes subprocess execution straightforward
3. go-git offers a clean API for repository operations
4. Go's JSON parsing capabilities are built-in and performant

### Python (Analysis Engine)

The Python component uses:

- **tree-sitter 0.25.2**: A parser generator tool and an incremental parsing library
- **Language grammars**: tree-sitter bindings for multiple programming languages

The Python requirements include:
```
tree-sitter==0.25.2
requests==2.32.5
certifi==2025.10.5
```

Python was chosen for the analysis layer because:
1. tree-sitter has excellent Python bindings
2. The Python ecosystem makes rapid prototyping and experimentation easy
3. File system operations and AST traversal are straightforward in Python

### Frontend

- **Vanilla HTML/JavaScript**: No frameworks used—just simple form submission and DOM manipulation
- **CSS**: Minimal styling included

### Why This Technology Mix?

The project demonstrates a common pattern in software engineering: using the right tool for each job. Go excels at systems programming, network services, and process orchestration. Python shines in data analysis, text processing, and working with parsing libraries. By combining both, the project leverages the strengths of each language while keeping the interface between them simple (JSON over stdout).

---

## 5. Execution Flow

### How the Program Starts

1. The user runs the `./run` shell script from the project root
2. The script executes `go run cmd/server/main.go`
3. `main.go` initializes the public directory path
4. It starts the HTTP server in a goroutine via `api.ServeStatic()`
5. The server listens on port 8081

### Important Entry Points

**Go Side:**
- `cmd/server/main.go:16` - The `main()` function initializes and starts the server
- `cmd/server/api/api.go:9` - The `ServeStatic()` function sets up HTTP routes
- `cmd/server/handler/FormHandler.go:16` - The `FormHandler()` function handles POST requests to `/form`

**Python Side:**
- `analyzer/main.py:1` - Entry point that imports and runs the analysis pipeline
- The script expects a `tmp/` directory to exist with the cloned repository

### Request/Data Flow Through the System

```
1. User Input
   │
   ▼
2. Browser sends POST to http://localhost:8081/form
   │
   ▼
3. Go HTTP Server (api.ServeStatic)
   │
   ▼
4. FormHandler validates GitHub URL
   │
   ▼
5. clone.CloneRepo() - Clone repository to tmp/
   │
   ▼
6. exec.Command("python3", "analyzer/main.py")
   │
   ▼
7. Python: FileTree(directory_str)
   │  - Recursively walks tmp/ directory
   │  - Identifies source files by extension
   │  - Parses each file's AST
   │
   ▼
8. Python: analyze_codebase(tree)
   │  - Creates ASTAnalyzer for each file
   │  - Calculates complexity metrics
   │  - Extracts code structure
   │  - Identifies dependencies
   │
   ▼
9. Python: ReportGenerator.return_json_report()
   │
   ▼
10. JSON output to stdout
    │
    ▼
11. Go captures output, parses JSON
    │
    ▼
12. HTTP response to browser
    │
    ▼
13. JavaScript renders results
```

---

## 6. Core Modules Explained

### Go Backend Modules

#### FormHandler (cmd/server/handler/FormHandler.go)

This module is the heart of the Go backend. It handles the entire analysis workflow:

```go
func FormHandler(w http.ResponseWriter, r *http.Request) {
    // 1. Validate HTTP method
    if r.Method != http.MethodPost { ... }
    
    // 2. Read request body
    body, err := io.ReadAll(r.Body)
    
    // 3. Validate GitHub URL
    valid, err := IsValidGitHubURL(input)
    
    // 4. Clone repository
    err = clone.CloneRepo(input)
    
    // 5. Execute Python analyzer
    cmd := exec.Command("python3", "analyzer/main.py")
    output, err := cmd.CombinedOutput()
    
    // 6. Parse JSON response
    var report types.AnalysisReport
    json.Unmarshal(output, &report)
    
    // 7. Send response to client
    json.NewEncoder(w).Encode(report)
}
```

The URL validation function checks:
- Valid HTTP/HTTPS scheme
- Host must be `github.com`
- Path must be in format `/user/repo`

#### Clone Module (internal/clone/clone.go)

This module uses go-git to clone repositories:

```go
func CloneRepo(url string) error {
    // Get working directory
    wd, err := os.Getwd()
    tmpDir := filepath.Join(wd, "tmp")
    
    // Remove old temporary directory
    os.RemoveAll(tmpDir)
    
    // Clone repository
    r, err := git.PlainClone(tmpDir, &git.CloneOptions{
        URL:               url,
        RecurseSubmodules: git.DefaultSubmoduleRecursionDepth,
    })
    
    // Get HEAD commit information
    ref, err := r.Head()
    commit, err := r.CommitObject(ref.Hash())
    
    return nil
}
```

#### Type Definitions (internal/types/)

The Go types mirror the Python data structures for JSON serialization:

- **AnalysisReport**: Top-level container with BasicAnalysis
- **BasicAnalysis**: Contains file list and aggregate metrics
- **AggregateMetrics**: Total lines, functions, classes, imports, language distribution
- **File**: Individual file data with complexity, structure, dependencies
- **Complexity**: Node counts, depth, function/class/conditional/loop counts
- **Structure**: Functions, classes, imports, global variables
- **Dependencies**: Import list, function calls, external references

### Python Analysis Modules

#### FileTree (analyzer/filetree/tree.py)

This module builds a hierarchical representation of the codebase:

```python
def FileTree(path):
    result = []
    for element in os.listdir(path):
        if element.startswith("."):
            continue  # Skip hidden directories
        
        if os.path.isdir(full_path):
            children = FileTree(full_path)  # Recursive call
            if children:
                result.append({"type": "dir", "name": element, "children": children})
        elif is_source_file(element):
            # Read file and parse AST
            with open(full_path, "r") as f:
                lines = len(f.readlines())
            node = {"type": "file", "name": element, "lines": lines}
            ast = parse_file_ast(full_path)
            node["ast"] = ast
            result.append(node)
    return result
```

The module maintains a comprehensive list of source file extensions (over 25 languages supported).

#### AST Analyzer (analyzer/ast_tools/analyzer.py)

This is the core analysis engine. It performs four main analyses:

**1. Complexity Calculation:**
```python
def calculate_complexity(self):
    complexity = {
        'total_nodes': 0,
        'max_depth': 0,
        'function_count': 0,
        'class_count': 0,
        'conditional_count': 0,
        'loop_count': 0,
    }
    def traverse(node, depth=0):
        complexity['total_nodes'] += 1
        complexity['max_depth'] = max(complexity['max_depth'], depth)
        
        node_type = node.get('type', '')
        if 'function' in node_type.lower():
            complexity['function_count'] += 1
        if 'class' in node_type.lower():
            complexity['class_count'] += 1
        if node_type in ['if_statement', 'conditional_expression']:
            complexity['conditional_count'] += 1
        if node_type in ['for_statement', 'while_statement']:
            complexity['loop_count'] += 1
        
        for child in node.get('children', []):
            traverse(child, depth + 1)
    
    traverse(self.ast)
    return complexity
```

**2. Structure Extraction:**
- Identifies function declarations and definitions
- Identifies class declarations and definitions
- Collects import statements
- Tracks global variables

**3. Dependency Analysis:**
- Extracts import statements
- Identifies function and method calls
- Tracks external references

**4. Metrics Calculation:**
- AST depth calculation
- Node counting
- Statement counting
- Expression counting
- Language-specific metrics (Python, Go)

#### Parser (analyzer/ast_tools/parser.py)

The parser uses tree-sitter to generate ASTs:

```python
def parse_file_ast(full_path):
    ext = full_path.split(".")[-1]
    
    if ext not in file_ext:
        return None
    
    parser = Parser(file_ext[ext])
    
    with open(full_path, "r") as f:
        source = f.read()
    
    tree = parser.parse(source.encode("utf8"))
    return to_dict(tree.root_node)
```

The `to_dict` utility converts tree-sitter nodes to dictionaries recursively.

#### Language Configuration (analyzer/ast_tools/languages.py)

Maps file extensions to tree-sitter language grammars:

```python
GRAMMAR_CONFIG = {
    'py': ('tree_sitter_python', 'language'),
    'js': ('tree_sitter_javascript', 'language'),
    'ts': ('tree_sitter_typescript', 'language_typescript'),
    'java': ('tree_sitter_java', 'language'),
    'c': ('tree_sitter_c', 'language'),
    'go': ('tree_sitter_go', 'language'),
    'rs': ('tree_sitter_rust', 'language'),
    # ... more languages
}
```

The `load_grammars()` function dynamically loads available language modules at startup.

#### Report Generator (analyzer/report_generator.py)

Handles JSON output generation:

```python
def return_json_report(self, basic_analysis):
    combined = {'basic_analysis': basic_analysis}
    print(json.dumps(combined, indent=2))
```

The class can also save reports to files for debugging purposes.

---

## 7. Key Algorithms or Logic

### Recursive File Tree Building

The Python `FileTree` function uses recursion to traverse directories:

```python
def FileTree(path):
    result = []
    for element in os.listdir(path):
        full_path = os.path.join(path, element)
        
        if os.path.isdir(full_path):
            children = FileTree(full_path)  # Recurse into subdirectory
            if children:
                result.append({"type": "dir", "name": element, "children": children})
        elif is_source_file(element):
            # Process file
            ...
    return result
```

Key design decisions:
- Hidden files/directories (starting with `.`) are skipped
- Empty directories are not included in the output
- Non-source files are filtered out using the extension check
- AST parsing is attempted but errors are caught gracefully

### AST Traversal and Analysis

The complexity calculation traverses the entire AST tree:

```python
def traverse(node, depth=0):
    complexity['total_nodes'] += 1
    complexity['max_depth'] = max(complexity['max_depth'], depth)
    
    # Count specific node types
    node_type = node.get('type', '')
    if 'function' in node_type.lower():
        complexity['function_count'] += 1
    # ... more counts
    
    # Recurse into children
    for child in node.get('children', []):
        traverse(child, depth + 1)
```

The algorithm:
1. Starts at the root node with depth 0
2. Increments the node count
3. Updates maximum depth if current depth is higher
4. Identifies node type and increments relevant counters
5. Recursively processes all children with depth + 1

### URL Validation

The Go URL validation ensures the input is a valid GitHub repository:

```go
func IsValidGitHubURL(raw string) (bool, error) {
    parsed, err := url.Parse(raw)
    
    if parsed.Scheme != "https" && parsed.Scheme != "http" {
        return false, fmt.Errorf("invalid scheme: %s", parsed.Scheme)
    }
    
    if parsed.Host != "github.com" {
        return false, fmt.Errorf("invalid host: %s", parsed.Host)
    }
    
    parts := strings.Split(strings.Trim(parsed.Path, "/"), "/")
    if len(parts) < 2 || parts[0] == "" || parts[1] == "" {
        return false, fmt.Errorf("path must be /user/repo")
    }
    
    return true, nil
}
```

This validation is intentionally strict to ensure only public GitHub repositories are processed.

---

## 8. Design Decisions

### Why Go as the Orchestrator?

Go was chosen for the orchestration layer because:
1. **Built-in HTTP server**: The `net/http` package provides everything needed
2. **Easy subprocess execution**: `exec.Command` makes running the Python script trivial
3. **JSON handling**: Built-in support with `encoding/json`
4. **Git operations**: go-git provides a pure Go implementation without CLI dependencies

### Why Python for Analysis?

Python was chosen for the analysis engine because:
1. **tree-sitter bindings**: Excellent Python library for AST generation
2. **Rapid development**: Easier to experiment with parsing logic
3. **Rich standard library**: File operations are straightforward

### Why JSON Over stdout?

The Python analyzer outputs JSON directly to stdout, which Go captures. This design:
- Keeps the interface simple (text stream)
- Makes debugging easy (can run Python manually)
- Is language-agnostic (could swap Python for another language)
- Separates data from logging (stderr used for debug messages)

### Repository Cloning Strategy

The project clones to a `tmp/` directory that is deleted and recreated for each request:

```go
// Remove old tmp directory
if err := os.RemoveAll(tmpDir); err != nil {
    return fmt.Errorf("could not delete tmp: %w", err)
}

r, err := git.PlainClone(tmpDir, &git.CloneOptions{
    URL:               url,
    RecurseSubmodules: git.DefaultSubmoduleRecursionDepth,
})
```

This ensures:
- Fresh analysis for each request
- No disk space accumulation over time
- Consistent state for each analysis

### Type Design

The Go type definitions mirror the Python data structures exactly. This ensures:
- Clean JSON serialization
- No data loss between Python output and Go parsing
- Clear contract between the two systems

---

## 9. How Everything Fits Together

### End-to-End Operation

1. **User Interaction**
   - User opens `http://localhost:8081/`
   - Sees a simple form with a text input and submit button
   - Enters a GitHub repository URL (e.g., `https://github.com/user/repo`)
   - Clicks submit

2. **Frontend Processing**
   - JavaScript intercepts form submission
   - Sends POST request to `/form` with the URL as body
   - Displays "Processing..." while waiting
   - Receives JSON response
   - Renders the analysis results in the page

3. **Go Backend Processing**
   - Receives POST request at `/form` endpoint
   - Validates the GitHub URL format
   - Clones the repository to `tmp/` directory
   - Executes Python analyzer as subprocess
   - Captures stdout from Python
   - Parses JSON into Go structs
   - Returns JSON response to frontend

4. **Python Analysis Processing**
   - Receives no direct input (reads from `tmp/` directory)
   - Builds file tree of the cloned repository
   - For each source file:
     - Parses AST using tree-sitter
     - Calculates complexity metrics
     - Extracts code structure
     - Identifies dependencies
   - Aggregates metrics across all files
   - Outputs JSON to stdout

5. **Result Rendering**
   - JavaScript receives the complete analysis
   - Displays summary: total files, lines, functions, classes
   - Lists each file with its complexity and structure
   - Shows language distribution

### Data Flow Summary

```
GitHub URL → Go FormHandler → validate URL
                                    ↓
                              clone.CloneRepo(url)
                                    ↓
                              tmp/ directory created
                                    ↓
                              exec.Command("python3", "analyzer/main.py")
                                    ↓
                              Python FileTree() builds directory structure
                                    ↓
                              parse_file_ast() generates AST for each file
                                    ↓
                              ASTAnalyzer.analyze() extracts metrics
                                    ↓
                              aggregate_metrics computed
                                    ↓
                              JSON output to stdout
                                    ↓
                              Go parses JSON, returns to client
                                    ↓
                              JavaScript renders analysis
```

---

## 10. Conclusion

GPR-Analyzer demonstrates an effective pattern for combining multiple programming languages in a single application. By leveraging Go's strengths in network programming and process orchestration, and Python's strengths in code analysis and parsing, the project creates a powerful codebase analysis tool.

### Key Architectural Insights

1. **Separation of Concerns**: Go handles the "ilities" (reliability, maintainability, deployability), while Python handles the core analysis logic. This makes the system easier to maintain and extend.

2. **Simple Interfaces**: The JSON-over-stdout interface between Go and Python keeps the systems decoupled. Changing the analysis algorithm doesn't require changes to Go, and vice versa.

3. **Multi-Language Support**: The tree-sitter integration provides broad language coverage, making the analyzer useful for many different types of projects.

4. **Educational Value**: The project serves its stated purpose of understanding ASTs and how they are generated. It provides a concrete example of:
   - How language parsers work
   - How to traverse tree data structures
   - How to calculate code complexity metrics
   - How to combine multiple programming languages effectively

### Potential Extensions

While the project focuses on basic analysis, there are many directions for potential expansion:
- Add more sophisticated complexity metrics (cyclomatic complexity, coupling)
- Support for visualizing the codebase structure
- Integration with code quality tools
- Support for analyzing specific commits or branches
- Comparison between repository versions

The project successfully achieves its goal of being a minimal, educational demonstration while still providing practical utility for basic codebase analysis.