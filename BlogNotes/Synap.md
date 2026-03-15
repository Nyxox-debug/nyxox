# Synap: A Minimal Deep Learning Framework

**A comprehensive technical deep-dive into building an autograd engine and tensor library from scratch**

---

## 1. Project Overview

### What the Project Does

Synap is a minimal deep learning framework that implements tensor operations and automatic differentiation from scratch. It consists of a C++ core that handles the heavy computational work, with Python bindings that provide a clean, user-friendly API. The project draws inspiration from Andrej Karpathy's micrograd, but implements it with a typed C++ foundation for performance and type safety.

At its core, Synap provides:

- **Tensor Operations**: Multi-dimensional array support with shape, stride, and offset management
- **Automatic Differentiation**: Reverse-mode autodiff via a dynamic computation graph
- **Neural Network Primitives**: Building blocks for constructing MLPs (Multi-Layer Perceptrons)
- **Python Integration**: Seamless usage from Python through pybind11 bindings

### The Problem It Solves

Building an understanding of how deep learning frameworks work under the hood is essential for any machine learning practitioner. Most people interact with PyTorch or TensorFlow without understanding the fundamental mechanics of:

1. How tensors store and manipulate multi-dimensional data
2. How automatic differentiation tracks computations and computes gradients
3. How neural networks forward and backward propagate signals

Synap solves this by providing a minimal, readable implementation that demonstrates these core concepts without the overwhelming complexity of production frameworks.

### Key Features

The framework includes a comprehensive set of features:

**Tensor Operations:**
- Basic arithmetic: `add`, `sub`, `mul`, `div`
- Linear algebra: `matmul`, `transpose`
- Activation functions: `relu`, `sigmoid`, `tanh`
- Reduction operations: `sum`, `mean`
- Loss functions: `mse`, `softmax_cross_entropy`
- Utility operations: `concat`, `view`, `clone`

**Autograd System:**
- Dynamic computation graph construction during forward pass
- Reverse-mode automatic differentiation
- Gradient accumulation with support for fan-out (tensor used multiple times)
- Topological sorting for correct gradient propagation

**Neural Network Modules (Python):**
- `Module`: Base class with parameter management
- `Neuron`: Single neuron with weights and bias
- `Layer`: Collection of neurons
- `MLP`: Multi-layer perceptron composition

**Broadcasting Support:**
- Scalar-tensor operations
- Row broadcast: `[M,N] + [N]`
- Column broadcast: `[M,N] + [M,1]`

---

## 2. Architecture Overview

### High-Level System Design

Synap follows a layered architecture that separates concerns cleanly:

```
┌─────────────────────────────────────────────────────────────┐
│                     Python Layer (nn.py)                     │
│    Module, Neuron, Layer, MLP - Pure Python NN components   │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│               Python Bindings (bindings.cpp)                 │
│          pybind11 layer exposing C++ to Python              │
│       Tensor class, static methods, tensor_data()           │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   C++ Core (tensor.cpp)                      │
│  Tensor operations, autograd, computation graph building    │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│              Storage Layer (storage.h)                       │
│         Raw float array with shared ownership               │
└─────────────────────────────────────────────────────────────┘
```

### Major Components and Their Interactions

**Storage (storage.h)**
The foundational layer is the `Storage` struct, which holds a raw heap-allocated float array and its size. It's managed via `std::shared_ptr`, allowing multiple tensors to share the same underlying data without ownership headaches. When a tensor is created, it either allocates new storage or references existing storage through a view constructor.

**Tensor (tensor.h, tensor.cpp)**
The `Tensor` class is the heart of the system. Each tensor maintains:
- A shared pointer to `Storage`
- Shape vector describing dimensions
- Stride vector for efficient indexing
- Offset into the storage
- Autograd fields: `requires_grad` flag, gradient tensor, parent references, and a backward function

The Tensor class supports two primary constructors:
1. **Allocating constructor**: Creates new storage with the specified shape
2. **View constructor**: Creates a tensor that shares storage with an existing tensor

**Operations (tensor.cpp)**
Every operation function (add, mul, matmul, etc.) follows a consistent pattern:
1. Compute the forward pass result
2. If gradient tracking is enabled, store parent references
3. Create a closure (backward_fn) that computes gradients for each parent using the chain rule

**Python Bindings (bindings.cpp)**
The pybind11 layer exposes the C++ Tensor class to Python. It creates a `synap` module with:
- The `Tensor` class with all its methods
- Static methods for each operation
- Helper functions like `tensor_data()` to extract values

### Important Design Decisions

**Dynamic vs Static Computation Graph**: Synap uses a dynamic computation graph built during the forward pass. This means the graph is reconstructed each time operations are executed, similar to PyTorch's eager mode. This is simpler to implement and debug than static graphs.

**Shared Storage with Views**: By using shared storage, operations like `view()` (reshape) are zero-copy operations. This is memory-efficient and mirrors how NumPy and PyTorch work.

**Closure-based Backward Functions**: Each operation captures its inputs in a lambda/closure that computes gradients when called. This approach is elegant and matches how frameworks like micrograd work.

**Gradient Accumulation**: Gradients use `+=` rather than assignment, which correctly handles the case where a tensor is used multiple times in computation (fan-out).

---

## 3. Repository Structure

```
Synap/
├── src/
│   ├── synap/
│   │   ├── tensor.h          # Tensor class declaration
│   │   ├── tensor.cpp        # Tensor operations + autodiff implementation
│   │   ├── storage.h         # Shared float storage struct
│   │   ├── scalar-based.h   # Value struct for scalar autograd (reference)
│   │   └── scalar-based.cpp # Scalar autograd implementation
│   ├── bindings.cpp          # pybind11 Python bindings
│   │
├── python/
│   ├── nn.py                 # Neural network modules (Neuron, Layer, MLP)
│   ├── test_grad_descent.py  # Gradient descent training demo
│   ├── test_backwardpass.py  # Backward pass demonstration
│   ├── tests/                # Test suite
│   │   ├── test_tensor.py    # Tensor operation tests
│   │   ├── test_autodiff.py  # Autodiff verification
│   │   └── ...
│   │
├── stubs/
│   └── synap.pyi             # Python type stubs for IDE support
│
├── docs/
│   ├── setup.md              # Build and installation instructions
│   └── Tensors.md            # Tensor internals technical reference
│
├── extern/
│   └── pybind11/            # pybind11 as a git submodule
│
├── CMakeLists.txt            # Build configuration
├── CMakePresets.json         # CMake presets for building
└── README.md                 # Project overview
```

**Purpose of Each Major Folder and File:**

- **src/synap/tensor.h**: Header defining the Tensor class interface, including constructors, data access, and friend declarations for operations
- **src/synap/tensor.cpp**: Implementation of all tensor operations and the autograd system
- **src/synap/storage.h**: Simple struct for managing raw float memory with shared ownership
- **src/bindings.cpp**: pybind11 module definition exposing C++ to Python
- **python/nn.py**: Pure Python neural network abstractions built on top of synap tensors
- **stubs/synap.pyi**: Type hints for Python IDE support
- **docs/**: Documentation files for setup and technical details

---

## 4. Technology Stack

### Languages

**C++17**: The core tensor operations and autograd engine are implemented in C++17. This provides:
- Performance for numerical computations
- Type safety through the type system
- Smart pointers for memory management
- Standard library containers and algorithms

**Python**: The high-level API and neural network modules are in Python. Python serves as:
- The primary user-facing API
- The implementation language for NN modules (Neuron, Layer, MLP)
- The testing and demonstration language

### Frameworks and Libraries

**pybind11**: This library creates the bridge between C++ and Python. It generates binding code that allows Python to:
- Create and manipulate C++ Tensor objects
- Call C++ functions with Python arguments
- Pass Python lists/arrays to C++ and back

**CMake**: The build system manages compilation of C++ code and integration with pybind11. CMake presets provide convenient build configurations.

### Why These Technologies

**C++ for Core Operations**: Numerical tensor operations benefit from C++'s performance. No Python interpreter overhead for the hot loops of matrix multiplication and gradient computation.

**Python for High-Level API**: Python is the lingua franca of machine learning. Its readability makes the framework accessible for learning, and the neural network modules are naturally expressed in Python.

**pybind11**: The de facto standard for C++/Python interoperability. It's lightweight, well-maintained, and integrates seamlessly with CMake.

---

## 5. Execution Flow

### How the Program Starts

When you import `synap` in Python, the following happens:

1. **Python interpreter loads the compiled `.so`/`.pyd` module**
2. **pybind11 initialization runs**, registering the `Tensor` class and all static methods
3. **The module is ready** for creating tensors and performing operations

### Important Entry Points

**Creating a Tensor:**
```python
t = synap.Tensor([2, 3], requires_grad=True)
t.set_values([1, 2, 3, 4, 5, 6])
```
This flows through pybind11 to the C++ Tensor constructor, which allocates storage and computes strides.

**Performing Operations:**
```python
c = synap.Tensor.add(a, b)
```
- Python calls the static `add` method through pybind11
- C++ `add()` function:
  1. Creates a new output tensor
  2. Computes forward pass: `c[i] = a[i] + b[i]`
  3. If `requires_grad`, stores parents and backward_fn closure

**Backward Pass:**
```python
loss.backward()
```
1. Sets `loss.grad = [1.0]` (implicit upstream gradient)
2. Calls `build_topo()` to perform depth-first traversal and create a topological ordering
3. Iterates in reverse topological order, calling each `backward_fn()` to accumulate gradients

### Request/Data Flow Through the System

```
User Code (Python)
       │
       ▼
pybind11 wrapper (bindings.cpp)
       │
       ▼
C++ Tensor operations (tensor.cpp)
       │
       ├──► Forward pass: compute values
       │
       └──► Build computation graph:
             - Record parents
             - Store backward_fn closure
       
When backward() is called:
       │
       ▼
Topological sort (build_topo)
       │
       ▼
Reverse iteration calling backward_fn
       │
       ▼
Gradients accumulated in parent tensors
```

---

## 6. Core Modules Explained

### Storage (storage.h)

The `Storage` struct is elegantly simple:

```cpp
struct Storage {
    float* data;
    size_t size;

    Storage(size_t size) : size(size) {
        data = new float[size]();
    }

    ~Storage() {
        delete[] data;
    }
};

using StoragePtr = std::shared_ptr<Storage>;
```

**Key design points:**
- Raw float pointer for direct memory access
- `std::shared_ptr` enables multiple tensors to share the same storage
- Constructor zero-initializes the array with `()`
- Destructor properly deallocates to prevent memory leaks

### Tensor Class (tensor.h)

The Tensor class uses `std::enable_shared_from_this` to allow capturing `shared_from_this()` in closures:

```cpp
class Tensor : public std::enable_shared_from_this<Tensor> {
public:
    Tensor(std::vector<size_t> shape, bool requires_grad = false);
    Tensor(StoragePtr storage, std::vector<size_t> shape,
           std::vector<size_t> stride, size_t offset, bool requires_grad);

    float* data();
    const float* data() const;
    const std::vector<size_t>& shape() const;

    std::shared_ptr<Tensor> clone() const;
    std::shared_ptr<Tensor> view(const std::vector<size_t>& new_shape) const;

    void zero_grad();
    void backward(std::shared_ptr<Tensor> grad_output);
    void set_values(const std::vector<float>& values);

    bool requires_grad;
    std::shared_ptr<Tensor> grad;

private:
    StoragePtr storage_;
    std::vector<size_t> stride_;
    size_t offset_;
    std::vector<std::shared_ptr<Tensor>> parents_;
    std::function<void()> backward_fn_;
};
```

**Member variables explained:**
- `storage_`: Shared pointer to the underlying float array
- `shape_`: Dimensions of the tensor (e.g., [2, 3] for 2 rows, 3 columns)
- `stride_`: Step size (in elements) to advance in each dimension
- `offset_`: Starting position in the storage array
- `parents_`: Input tensors this operation depends on
- `backward_fn_`: Closure that computes and accumulates gradients

**Stride and Offset:**
For a tensor with shape [2, 3] and row-major order:
- Default strides = [3, 1] (to move to next row, skip 3 elements; to move to next column, skip 1)
- Element at position (i, j) is at storage[i * 3 + j]

The view operation creates a new tensor with different shape/strides but same storage—enabling zero-copy reshape.

### Tensor Operations (tensor.cpp)

Every operation follows this pattern in `mul()`:

```cpp
std::shared_ptr<Tensor> mul(const std::shared_ptr<Tensor>& a,
                            const std::shared_ptr<Tensor>& b) {
    auto out = std::make_shared<Tensor>(a->shape_,
                                        a->requires_grad || b->requires_grad);

    size_t n = numel(a->shape_);
    for (size_t i = 0; i < n; ++i)
        out->data()[i] = a->data()[i] * b->data()[i];

    if (out->requires_grad) {
        out->parents_ = {a, b};
        out->backward_fn_ = [out, a, b, n]() {
            for (size_t i = 0; i < n; ++i) {
                if (a->requires_grad)
                    a->grad->data()[i] += b->data()[i] * out->grad->data()[i];
                if (b->requires_grad)
                    b->grad->data()[i] += a->data()[i] * out->grad->data()[i];
            }
        };
    }
    return out;
}
```

**Forward pass**: Compute element-wise multiplication
**Backward pass**: Using chain rule:
- ∂L/∂a = ∂L/∂out × ∂out/∂a = grad_out × b
- ∂L/∂b = ∂L/∂out × ∂out/∂b = grad_out × a

### Autograd System

**Building the computation graph:**

During forward operations, each output tensor records:
1. Its parent tensors (`parents_`)
2. A backward function that knows how to compute gradients

**Topological Sort (build_topo):**

```cpp
void Tensor::build_topo(const std::shared_ptr<Tensor>& t,
                        std::unordered_set<Tensor*>& visited,
                        std::vector<std::shared_ptr<Tensor>>& topo) {
    if (visited.count(t.get()))
        return;
    visited.insert(t.get());

    for (auto& p : t->parents_) {
        build_topo(p, visited, topo);
    }

    topo.push_back(t);
}
```

This depth-first traversal visits all ancestors before adding the current tensor to the list, producing a topological order where all dependencies come before dependent nodes.

**Backward Pass:**

```cpp
void Tensor::backward(std::shared_ptr<Tensor> grad_output) {
    if (!grad) {
        grad = std::make_shared<Tensor>(shape_, false);
    }

    size_t n = numel(shape_);

    if (grad_output) {
        std::copy(grad_output->data(), grad_output->data() + n, grad->data());
    } else {
        std::fill(grad->data(), grad->data() + n, 1.0f);
    }

    std::vector<std::shared_ptr<Tensor>> topo;
    std::unordered_set<Tensor*> visited;
    build_topo(shared_from_this(), visited, topo);

    for (auto it = topo.rbegin(); it != topo.rend(); ++it) {
        (*it)->backward_fn_();
    }
}
```

1. Initialize gradient (1.0 for scalar loss, or use provided gradient)
2. Build topological order
3. Traverse in **reverse** order, calling backward_fn to propagate gradients

### Neural Network Modules (nn.py)

The Python-side neural network classes build on top of the synap tensor API:

```python
class Neuron(Module):
    def __init__(self, nin, nonlin=True):
        self.w = synap.Tensor([nin, 1], requires_grad=True)
        self.w.set_values([random.uniform(-1,1) for _ in range(nin)])
        self.b = synap.Tensor([1], requires_grad=True)
        self.b.set_values([0])
        self.nonlin = nonlin

    def __call__(self, x: synap.Tensor):
        if len(x.shape()) == 1:
            x = x.view([1, x.shape()[0]])
        z = synap.Tensor.add(synap.Tensor.matmul(x, self.w), self.b)
        if self.nonlin:
            z = synap.Tensor.relu(z)
        return z
```

**Key observations:**
- Weights and biases are tensors with `requires_grad=True`
- Forward pass: matmul + bias add + optional activation
- The `__call__` method makes Neuron instances callable like functions

```python
class MLP(Module):
    def __init__(self, nin, nouts):
        sz = [nin] + nouts
        self.layers = [
            Layer(sz[i], sz[i+1], nonlin=(i != len(nouts)-1))
            for i in range(len(nouts))
        ]

    def __call__(self, x: synap.Tensor):
        for layer in self.layers:
            x = layer(x)
        return x
```

MLP chains layers together, applying each sequentially to produce the final output.

---

## 7. Key Algorithms and Logic

### Matrix Multiplication (matmul)

The forward pass implements the standard triple loop:

```cpp
for (size_t i = 0; i < M; ++i)
    for (size_t j = 0; j < N; ++j) {
        float sum = 0.0f;
        for (size_t k = 0; k < K; ++k)
            sum += a->data()[i * K + k] * b->data()[k * N + j];
        out->data()[i * N + j] = sum;
    }
```

For A (M×K) and B (K×N), result is M×N.

The backward pass uses the matrix calculus identities:
- ∂L/∂A = grad_out × B^T
- ∂L/∂B = A^T × grad_out

Implemented as:
```cpp
for (size_t i = 0; i < M; ++i)
    for (size_t j = 0; j < K; ++j)
        if (a->requires_grad)
            for (size_t n = 0; n < N; ++n)
                a->grad->data()[i * K + j] +=
                    out->grad->data()[i * N + n] * b->data()[j * N + n];
```

### Softmax Cross-Entropy

This loss function combines softmax activation with cross-entropy loss in a numerically stable way:

**Forward pass:**
1. Shift logits by subtracting max (prevents overflow in exp):
   ```cpp
   logits_shifted[i] = logits[i] - max_vals[row]
   ```
2. Compute exp and softmax:
   ```cpp
   probs[i] = exp(logits_shifted[i]) / sum(exp(logits_shifted))
   ```
3. Compute cross-entropy:
   ```cpp
   loss = -sum(targets * log(probs)) / batch_size
   ```

**Backward pass** simplifies beautifully:
```cpp
grad_logits = (probs - targets) / batch_size
```

This is numerically stable because we compute softmax inside the forward pass and reuse those probabilities during backprop.

### Broadcasting and Gradient Reduction

Synap supports specific broadcasting patterns with proper gradient handling:

**Row broadcast [M,N] + [N]:**
- Forward: each row of the M×N tensor adds the N-element vector
- Backward: gradient to the broadcast tensor sums across rows:
  ```cpp
  b->grad->data()[j] += out->grad->data()[i * N + j];  // sum over i
  ```

**Column broadcast [M,N] + [M,1]:**
- Forward: each column of the M×N tensor adds the M-element vector
- Backward: gradient sums across columns:
  ```cpp
  b->grad->data()[i] += out->grad->data()[i * N + j];  // sum over j
  ```

### Topological Sort

The `build_topo` function performs a depth-first search:

```
         loss
        /   \
       a     b
      / \   /
     c   d e
    /
   f
```

DFS visits: f → c → d → a → e → b → loss

Then reversing gives the correct backprop order: loss → b → a → d → c → f

This ensures gradients are propagated correctly through the entire computation graph.

---

## 8. Design Decisions

### Why Dynamic Computation Graph?

Synap uses a dynamic graph built during forward execution rather than a static graph defined beforehand. This design choice:

**Advantages:**
- Simpler to implement and debug
- Supports Python control flow naturally (if/for while building graph)
- Matches PyTorch's eager execution model
- Easier to understand for learning purposes

**Trade-offs:**
- Less optimization opportunity compared to static graphs
- Graph reconstruction overhead on every forward pass
- Memory for storing graph structure

For a learning project, dynamic graphs are the right choice—they're more intuitive and the performance difference is negligible for educational use.

### Why Shared Storage?

The storage sharing mechanism enables:

1. **Zero-copy views**: Reshaping a tensor doesn't copy data
2. **Memory efficiency**: Multiple views of data share the same storage
3. **Correct gradient flow**: Views maintain their connection to original storage

This mirrors NumPy and PyTorch behavior, teaching important concepts about tensor memory management.

### Why Closure-based Backward Functions?

Each operation captures its inputs in a lambda/closure:

```cpp
out->backward_fn_ = [out, a, b, n]() {
    // gradient computation
};
```

**Benefits:**
- Clean encapsulation of gradient logic
- Parent tensors captured by reference (needed for gradient accumulation)
- Matches the micrograd pattern that's well-documented for learning

**Alternative considered:** Virtual method dispatch (like PyTorch's `torch::autograd::Function`). This is more complex and better suited for extension by users—Synap doesn't need that level of generality.

### Gradient Accumulation vs Assignment

The backward functions use `+=` instead of `=` when accumulating gradients:

```cpp
a->grad->data()[i] += b->data()[i] * out->grad->data()[i];
```

This correctly handles **fan-out**: when a tensor is used in multiple places in the computation graph, it should receive the sum of gradients from all downstream uses. The user must call `zero_grad()` before each backward pass to start fresh.

### Python-only Neural Network Modules

The Neuron, Layer, and MLP classes are implemented in pure Python rather than C++:

**Reasons:**
- Simpler to modify and experiment with
- Leverages Python's dynamic nature for cleaner code
- The C++ core handles the computationally intensive parts
- Demonstrates how to build on top of the tensor library

---

## 9. How Everything Fits Together

Let's trace through a complete example: training an MLP on a simple task.

### Step 1: Create Input and Target

```python
x = synap.Tensor([1, 4], requires_grad=False)
x.set_values([1, 2, 3, 4])

y = synap.Tensor([1, 1], requires_grad=False)
y.set_values([10])
```

- Python calls through pybind11 to C++ Tensor constructor
- C++ allocates storage for 4 elements
- Strides computed as [4, 1] for row-major order

### Step 2: Create Model

```python
model = nn.MLP(4, [4, 1])
```

- Creates an MLP with 4 inputs, one hidden layer of 4 neurons, 1 output
- Each Neuron creates weight tensor (4×1) and bias tensor (1)
- All parameters have `requires_grad=True`

### Step 3: Forward Pass

```python
out = model(x)
```

1. First layer processes input through matmul, bias add, ReLU
2. Each operation records its backward_fn
3. Second layer processes through matmul, bias add (no activation on output)
4. Output tensor has a chain of parent references forming the computation graph

### Step 4: Compute Loss

```python
loss = synap.Tensor.mse(out, y)
```

- MSE computes: mean((out - y)^2)
- This creates a new tensor with additional backward_fn entries
- Now we have a complete graph from parameters → output → loss

### Step 5: Backward Pass

```python
model.zero_grad()
loss.backward()
```

1. `zero_grad()` fills all parameter gradients with 0
2. `backward()`:
   - Sets loss.grad = [1.0]
   - Builds topological order: parameters → ... → loss
   - Calls backward_fn in reverse order
   - Each gradient flows back through the chain rule

### Step 6: Parameter Update

```python
for param in model.parameters():
    values = synap.tensor_data(param)
    grads = param.grad_values
    param.set_values([v - lr * g for v, g in zip(values, grads)])
```

- Extract parameter values and gradients from C++ to Python
- Apply gradient descent: w = w - lr * grad
- Update tensors with new values

This cycle repeats for multiple epochs, gradually improving the model's predictions.

---

## 10. Conclusion

Synap represents a thoughtfully designed minimal deep learning framework that successfully bridges the gap between high-level ML library usage and understanding underlying mechanics. Its architecture demonstrates several important concepts that transfer directly to working with production frameworks like PyTorch.

**Key architectural takeaways:**

The **layered design** separates concerns cleanly: storage handles memory, tensors manage data and metadata, operations implement computations with gradient logic, and Python provides the accessible API. This separation makes the codebase navigable and each component understandable in isolation.

The **dynamic computation graph** approach, while not optimal for all production scenarios, provides an excellent learning model. Students can print tensors at any point, add debugging output to backward functions, and trace through exactly what happens during forward and backward passes.

The **closure-based autograd** pattern is elegant and compact. Each operation encapsulates its own gradient logic, making the system extensible—adding new operations requires only implementing forward and backward passes together.

**What makes this project valuable:**

1. **Readability over optimization**: The code prioritizes understanding over marginal performance gains
2. **Complete system**: From storage allocation through neural network training, users see the whole picture
3. **Python-C++ balance**: Performance-critical code in C++, flexible logic in Python
4. **Clean interfaces**: The pybind11 bindings demonstrate proper C++/Python interoperability

The project successfully accomplishes its goal: demonstrating how deep learning frameworks work internally through a minimal, educational implementation that remains functional enough to actually train neural networks.

---

## Appendix: Operations Reference

| Operation | Forward | Backward |
|-----------|---------|----------|
| `add(a, b)` | `a + b` | `∂a += grad`, `∂b += grad` |
| `sub(a, b)` | `a - b` | `∂a += grad`, `∂b -= grad` |
| `mul(a, b)` | `a * b` | `∂a += b * grad`, `∂b += a * grad` |
| `div(a, b)` | `a / b` | `∂a += grad/b`, `∂b -= grad*a/b²` |
| `matmul(a, b)` | `A @ B` | `∂A += grad @ Bᵀ`, `∂B += Aᵀ @ grad` |
| `transpose(x)` | `xᵀ` | `∂x += gradᵀ` |
| `relu(x)` | `max(0, x)` | `∂x += grad * (x > 0)` |
| `sigmoid(x)` | `σ(x)` | `∂x += σ(x)(1-σ(x)) * grad` |
| `tanh(x)` | `tanh(x)` | `∂x += (1-tan²(x)) * grad` |
| `exp(x)` | `eˣ` | `∂x += eˣ * grad` |
| `sum(x)` | `Σxᵢ` | `∂xᵢ += grad[0]` |
| `mean(x)` | `Σxᵢ/n` | `∂xᵢ += grad[0]/n` |
| `mse(pred, tgt)` | `mean((pred-tgt)²)` | `∂pred += 2(pred-tgt)/n` |
| `softmax_cross_entropy` | stable SCE | `∂logits += (softmax - targets)/n` |
| `concat(tensors)` | flat join | gradient split back |
| `view(shape)` | reshape | element-wise copy |
