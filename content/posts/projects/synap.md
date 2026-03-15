---
title: "Building a Neural Network Framework from Scratch"
date: 2026-02-24
slug: deep-learning-framework-scratch
categories:
  - projects
tags:
  - c++
  - python
  - deep-learning
  - autograd
  - tensors
---

I use PyTorch every day at work. It's incredible - but I've always wondered: how does it actually work under the hood? How does `backward()` actually compute gradients through a neural network?

So I built my own minimal deep learning framework called **Synap**. It's written in C++ for performance, with Python bindings via pybind11. No external ML libraries - just raw tensor operations and automatic differentiation from scratch.

<!--more-->

## Why Build Another Framework?

This wasn't about competing with PyTorch. That would be insane.

It was about understanding. I use `loss.backward()` without thinking, but the magic behind automatic differentiation always seemed mysterious. Building it myself was the best way to learn.

Plus, Andrej Karpathy's micrograd inspired me. I wanted to do something similar but with C++ for the core operations - partly for performance, partly because I wanted to understand how to bridge C++ and Python.

## What I Built

Synap gives you:

- **Tensors** - Multi-dimensional arrays with shape, stride, and offset
- **Autograd** - Reverse-mode automatic differentiation
- **Neural networks** - MLPs with layers and neurons
- **Python API** - Clean Python interface to C++ core

```python
import synap as sp

# Create tensors
x = sp.Tensor([1, 4], requires_grad=True)
x.set_values([1, 2, 3, 4])

# Build a simple MLP
model = nn.MLP(4, [8, 1])

# Forward pass
out = model(x)

# Compute loss
loss = sp.Tensor.mse(out, target)

# Backward pass - the magic happens here
loss.backward()
```

## How Autograd Works

This was the most interesting part to implement.

The key insight is that you build a **computation graph** as you do operations. Each tensor knows what created it - its parents and the operation that produced it.

Here's how multiplication works:

```cpp
// Forward: c = a * b
out->data()[i] = a->data()[i] * b->data()[i];

// Backward: da = db * dout, db = da * dout  
out->backward_fn_ = [out, a, b]() {
    a->grad->data()[i] += b->data()[i] * out->grad->data()[i];
    b->grad->data()[i] += a->data()[i] * out->grad->data()[i];
};
```

Each operation captures its own backward logic in a closure. When you call `backward()`:

1. Start with gradient = 1.0 at the loss
2. Build topological order of the computation graph
3. Traverse in reverse, calling each backward_fn

The topological sort is crucial - you need to process operations in the right order so gradients flow correctly from output to input.

## The C++ / Python Bridge

Using pybind11 was surprisingly pleasant. Here's how I expose a tensor to Python:

```cpp
py::class_<Tensor>(m, "Tensor")
    .def(py::init<std::vector<size_t>, bool>())
    .def("set_values", &Tensor::set_values)
    .def("backward", &Tensor::backward)
    .def_property_readonly("shape", &Tensor::shape);
```

That's it. A few lines and I can use C++ tensors from Python. The performance-critical math runs in C++, but the API feels Pythonic.

## Training a Neural Network

The ultimate test - can Synap actually learn?

```python
# XOR dataset
X = [[0,0], [0,1], [1,0], [1,1]]
y = [[0], [1], [1], [0]]

model = nn.MLP(2, [4, 1])

for epoch in range(100):
    for xi, yi in zip(X, y):
        # Forward
        out = model(xi)
        loss = sp.Tensor.mse(out, yi)
        
        # Backward
        model.zero_grad()
        loss.backward()
        
        # Update weights
        for param in model.parameters():
            # gradient descent
            ...
```

And it works! After training, the MLP correctly learns XOR. The gradients flow, the weights update, the loss decreases. Magic? No - just math.

## What I Learned

1. **Autograd is elegant** - The closure-based approach is clean. Each operation encapsulates its own gradient logic.

2. **Dynamic graphs are easier** - Synap rebuilds the graph each forward pass (like PyTorch eager mode). Static graphs (like TensorFlow 1.x) are more complex but allow more optimization.

3. **Broadcasting is tricky** - Supporting `[M,N] + [N]` operations means carefully tracking how gradients should reduce back.

4. **C++/Python interop is practical** - pybind11 made this surprisingly smooth.

## The Code

It's all there if you want to explore. The C++ core is in `src/synap/`, the Python bindings in `bindings.cpp`, and the neural network modules in `python/nn.py`.

Set it up with CMake, build, and you can import `synap` in Python. Try creating tensors, doing operations, calling backward() - see the gradients flow!

## What's Next?

There's plenty more to add:
- More operations (convolution, pooling)
- GPU support via CUDA
- Optimizers beyond SGD
- Batch training

But for now, I'm happy with what Synap demonstrates: the core ideas behind deep learning frameworks, implemented from scratch.
