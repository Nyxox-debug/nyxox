# Software Engineer

Full-stack software engineer with strong foundations in backend architecture, systems programming, and modern web development. Passionate about building reliable, performant systems and understanding how things work at every layer of the stack.

---

## About Me

I am a software engineer driven by a deep curiosity for how software systems work end-to-end. My interests span from implementing programming languages from scratch to building real-time graphics applications and deep learning frameworks. I believe that understanding fundamentals—whether it's compiler design, GPU rendering pipelines, or automatic differentiation—makes one a more effective engineer regardless of specialization.

I enjoy tackling complex problems that require thinking across multiple abstraction layers, from high-level user interfaces down to memory management and system-level optimizations. My approach to engineering emphasizes clean architecture, thoughtful design decisions, and building systems that are both correct and performant.

---

## Technical Skills

### Languages

| Language | Experience |
|----------|------------|
| **Go** | Production backend services, CLI tools, API development |
| **C++** | Systems programming, OpenGL graphics, performance-critical applications |
| **Rust** | Systems programming, memory-safe implementations |
| **TypeScript** | Frontend development, type-safe React/Next.js applications |
| **Python** | Data analysis, machine learning, scripting, C++ bindings |

### Backend & Systems

- **Web Frameworks**: Next.js, Express, REST API design
- **Database**: SQL, NoSQL patterns, data modeling
- **System Design**: Microservices, event-driven architecture, distributed systems concepts
- **Concurrency**: Goroutines, async patterns, thread-safe data structures
- **Performance**: Profiling, optimization, memory management

### Frontend & UI

- **Frameworks**: React, Next.js with App Router
- **Styling**: CSS modules, Tailwind, responsive design
- **Graphics**: WebGL, OpenGL, custom shader programming

### Tools & Environment

- **Version Control**: Git, GitHub workflows
- **Containerization**: Docker, container orchestration
- **Operating Systems**: Linux, CLI tooling, system programming
- **Build Systems**: CMake, Go modules, npm/pnpm

---

## Professional Experience

### Backend Engineer – Telehealth Platform

Designed and implemented backend services for a HIPAA-compliant telehealth platform serving thousands of patients. Built RESTful APIs that handle sensitive patient data with strict security requirements, implementing proper authentication (OAuth 2.0/JWT), authorization, and encryption at rest and in transit.

Key responsibilities included:
- Designing and implementing microservice architecture for appointment scheduling, video session management, and patient records
- Building scalable API endpoints with proper error handling, validation, and rate limiting
- Optimizing database queries and implementing caching strategies to reduce latency
- Implementing real-time features using WebSockets for live consultation updates
- Collaborating with frontend engineers to define clean API contracts
- Ensuring HIPAA compliance through access controls, audit logging, and secure data handling practices
- Writing comprehensive unit and integration tests to ensure reliability

### Frontend Engineer – Web Application Team

Built responsive, performant web applications using React and Next.js for healthcare dashboards and patient-facing interfaces. Worked closely with design teams to implement accessible, pixel-perfect UIs while maintaining strong code quality.

Key responsibilities included:
- Developing component-based UI architectures with React and TypeScript
- Implementing server-side rendering and static generation with Next.js
- Integrating REST APIs and handling complex state management
- Optimizing frontend performance through code splitting, lazy loading, and bundle analysis
- Ensuring cross-browser compatibility and mobile responsiveness
- Implementing accessibility standards (WCAG 2.1)
- Collaborating with backend teams to define and consume API contracts

---

## Projects

### Bat — Programming Language Interpreter

**Overview**

Bat is a complete interpreted programming language implemented from scratch in Go. It features a REPL interface, first-class functions, closures, and a clean architecture demonstrating the fundamental concepts behind language implementation. The project serves as an educational exploration of how compilers and interpreters work under the hood.

**Tech Stack**

- Go (standard library only, no external dependencies)
- Custom lexer, parser, and evaluator

**Key Features**

- Lexical analysis with tokenization
- Pratt parser for operator precedence handling
- Abstract Syntax Tree (AST) representation
- First-class functions with closures
- Variables, conditionals, and arithmetic operations
- Interactive REPL with colored error output

**Architecture / Implementation**

The interpreter follows the classic three-stage pipeline:

```
Source Code → Lexer → Tokens → Parser → AST → Evaluator → Objects → Output
```

The lexer performs character-by-character scanning with look-ahead to recognize keywords, identifiers, integers, and operators. The parser uses Pratt parsing (top-down operator precedence) to construct the AST without a formal grammar specification—each token type knows how to parse itself in both prefix and infix contexts.

The evaluator recursively traverses the AST using type switches, implementing the semantics of each language construct. The environment stores variable bindings as a symbol table. Functions are first-class values that capture their environment, enabling closures.

**Engineering Challenges**

Implementing closures correctly required careful consideration of scope capture and lifetime management. The environment design needed to balance simplicity with correctness—using a flat global scope simplified implementation but limited true lexical scoping. The project also required handling error propagation across all pipeline stages, from lexer (illegal tokens) through parser (syntax errors) to evaluator (runtime errors).

**What I Learned**

This project deepened my understanding of how programming languages are structured, from the lowest-level lexical analysis to high-level semantic interpretation. I gained hands-on experience with Pratt parsing, a powerful technique that elegantly handles operator precedence without grammar formalisms. The project also reinforced Go's strengths in building maintainable, readable systems software.

---

### Synap — Deep Learning Framework

**Overview**

Synap is a minimal deep learning framework that implements tensor operations and automatic differentiation from scratch. Written in C++ for performance with Python bindings via pybind11, it demonstrates how frameworks like PyTorch work internally. The framework can actually train neural networks on real tasks.

**Tech Stack**

- C++17 for core tensor operations and autograd engine
- Python for high-level API and neural network modules
- pybind11 for C++/Python interoperability

**Key Features**

- Tensor operations: matmul, element-wise ops, activations, reductions
- Reverse-mode automatic differentiation via dynamic computation graph
- Neural network primitives: Neuron, Layer, MLP
- Broadcasting support for mixed-dimension operations
- Zero-copy tensor views through shared storage

**Architecture / Implementation**

The system uses a layered architecture:

```
Python API (nn.py) → pybind11 bindings → C++ Core (tensor.cpp) → Storage layer
```

The Storage struct holds raw float arrays managed by `std::shared_ptr`, enabling multiple tensors to share underlying data. Tensors maintain shape, stride, and offset information for efficient indexing and zero-copy views.

Every operation follows a consistent pattern: compute the forward pass result, then if gradient tracking is enabled, store parent references and a closure (backward_fn) that computes gradients using the chain rule. The backward pass performs a topological sort of the computation graph and iterates in reverse order, accumulating gradients.

**Engineering Challenges**

Implementing matrix multiplication's backward pass required careful application of matrix calculus identities (∂L/∂A = grad_out × Bᵀ). Broadcasting gradient reduction needed specific handling for row and column broadcast patterns. The closure-based autograd design required careful lifetime management—capturing parent tensors by reference while ensuring they outlive the closure.

**What I Learned**

This project provided deep insight into how deep learning frameworks track computations and compute gradients. Implementing reverse-mode autodiff from scratch clarified concepts that are often hidden behind library abstractions. The C++/Python hybrid architecture taught valuable lessons about language interoperability and when to use each language's strengths.

---

### 3D Model Renderer — OpenGL Graphics Engine

**Overview**

A real-time 3D model renderer built from scratch using C++ and OpenGL, without relying on game engines. The renderer loads OBJ models with materials, applies custom GLSL shaders, and implements an interactive first-person camera. The project demonstrates how graphics programming works at a low level.

**Tech Stack**

- C++17
- OpenGL 3.3 Core Profile
- GLFW for window management
- GLAD for OpenGL loading
- GLM for mathematics
- Assimp for model loading
- stb_image for texture loading

**Key Features**

- OBJ model loading with material support
- Multi-texture support (diffuse, specular, normal, height)
- Custom GLSL vertex and fragment shaders
- First-person camera with WASD movement and mouse look
- Frame-rate independent movement using delta time
- Bounding box calculation for automatic camera positioning

**Architecture / Implementation**

The engine follows a component-based architecture:

- **Engine**: Central coordinator managing window, input, render loop
- **Model**: Loads 3D geometry via Assimp, processes scene graph recursively
- **Mesh**: Individual drawable geometry with VAO/VBO/EBO management
- **Shader**: GLSL compilation and uniform management
- **Transform**: Position, rotation, scale data structure

The rendering pipeline transforms vertices through model, view, and projection matrices:

```
Model Space → World Space (Model Matrix) → View Space (View Matrix) → Clip Space (Projection Matrix)
```

The vertex shader performs this transformation in a single line: `gl_Position = projection * view * model * vec4(aPos, 1.0);`

**Engineering Challenges**

Implementing mouse look required converting spherical coordinates (yaw/pitch) to Cartesian direction vectors while avoiding gimbal lock. The bounding box calculation needed to iterate through all vertices to find min/max bounds for camera positioning. Texture deduplication prevented loading the same texture file multiple times when referenced by different meshes.

**What I Learned**

This project demystified how game engines handle graphics programming under the hood. I gained deep understanding of the OpenGL pipeline, from buffer management to shader programs. The camera system implementation clarified 3D math concepts including transformation matrices, coordinate systems, and frame-rate independent movement.

---

### GPR-Analyzer — Multi-Language Codebase Analysis Tool

**Overview**

GPR-Analyzer (GitHub Parser and Analyzer) is a hybrid Go/Python application that accepts any public GitHub repository URL, clones it, and performs comprehensive static analysis using Abstract Syntax Trees. It extracts complexity metrics, code structure, and dependencies across 25+ programming languages.

**Tech Stack**

- Go for orchestration, HTTP server, Git operations
- Python for AST analysis using tree-sitter
- Vanilla HTML/JavaScript for frontend
- go-git for repository cloning

**Key Features**

- Multi-language AST parsing (25+ languages via tree-sitter)
- Complexity metrics: function count, class count, conditionals, loops, AST depth
- Code structure extraction: functions, classes, imports, globals
- Interactive web interface
- JSON output for easy consumption

**Architecture / Implementation**

The system uses a client-server architecture:

```
Browser → Go HTTP Server → Python Analyzer → tree-sitter AST → JSON Output
```

The Go backend handles HTTP routing, URL validation, and repository cloning via go-git. It executes the Python analyzer as a subprocess, capturing JSON output from stdout. The Python analyzer uses tree-sitter to generate ASTs, traverses them to extract metrics, and builds a hierarchical file tree.

The AST analyzer recursively traverses tree nodes, counting function definitions, class definitions, conditional statements, and loops. It also extracts imports and dependencies by analyzing specific node types.

**Engineering Challenges**

Supporting 25+ languages required creating a flexible grammar configuration system that maps file extensions to tree-sitter language modules. The recursive file tree building needed to handle hidden directories, non-source files, and gracefully handle parse errors. The Go/Python interface design used JSON over stdout for simple, debuggable inter-process communication.

**What I Learned**

This project taught me how Abstract Syntax Trees represent code structure and how to traverse them for analysis. The multi-language support demonstrated how tree-sitter provides grammar-independent parsing. The Go/Python hybrid architecture showed how to leverage each language's strengths—Go for systems programming and network services, Python for rapid prototyping and parsing.

---

## Engineering Interests

I am particularly interested in:

- **High-Performance Systems**: Understanding what makes systems fast, from algorithmic complexity to memory layout, cache behavior, and SIMD optimization
- **Backend Architecture**: Designing scalable, maintainable server systems with proper separation of concerns, error handling, and observability
- **Programming Language Design**: How interpreters and compilers work, language semantics, and the tradeoffs in language design choices
- **Developer Tooling**: Building tools that enhance programmer productivity, from CLI utilities to IDE extensions
- **Concurrent Programming**: Goroutines, async patterns, thread-safe data structures, and the challenges of parallel execution
- **Machine Learning Systems**: How frameworks like PyTorch work internally, from tensor operations to automatic differentiation

---

## Conclusion

I am a software engineer who thrives on understanding systems at every level. Whether implementing a programming language from scratch, building a graphics renderer with raw OpenGL, creating a deep learning framework, or designing backend services for production systems, I approach each problem with a focus on clean architecture and fundamental understanding.

My projects demonstrate experience across the full stack—from writing compilers and low-level graphics code to building web applications and REST APIs. I am always eager to tackle new challenges that require deep thinking and a multi-layered understanding of software systems.