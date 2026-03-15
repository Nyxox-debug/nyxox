---
title: "Building a 3D Renderer from Scratch"
date: 2026-01-27
slug: 3d-renderer-scratch
github: "https://github.com/Nyxox-debug/Model-render"
categories:
  - projects
tags:
  - c++
  - opengl
  - graphics
  - shaders
---

I've always been curious about what happens inside game engines when they render a 3D model. You know that feeling when you use Unity or Unreal without understanding what's actually happening on the GPU? That's exactly why I decided to build my own 3D renderer from scratch using C++ and OpenGL.

No engines. No magic. Just raw graphics programming.

<!--more-->

## Why Build a Renderer?

Here's the thing - I've used game engines for years, but I never really understood how a 3D model actually gets converted into pixels on my screen. How do textures get applied? How does the camera move through space? 

So I thought, why not build one myself? The goal wasn't to compete with Unity or Unreal. It was to understand the fundamentals - to demystify what's actually happening when you call `Draw()` on a mesh.

## What I Built

The result is a real-time 3D model renderer that can:

- Load 3D models in OBJ format (using Assimp)
- Apply textures - diffuse, specular, and normal maps
- Compile custom GLSL shaders
- Move around with WASD + mouse look (first-person camera)
- Handle the complete rendering pipeline

The renderer runs at 60 FPS and shows a textured 3D model. That's it. But the journey to get there taught me more about graphics programming than years of using game engines.

## The Core Concepts

Let me walk you through what I learned along the way.

### How a 3D Model Gets Rendered

It starts with vertices - points in 3D space that define a shape. These vertices get processed through what's called the **rendering pipeline**:

1. **Model transformation** - Move vertices from model space to world space
2. **View transformation** - Move vertices to camera space  
3. **Projection transformation** - Apply perspective (things get smaller as they get farther)
4. **Rasterization** - Convert those 3D points into 2D pixels on your screen

The magic happens in the shaders - little programs that run on your GPU for each vertex and each pixel.

### The Code

Here's how the main render loop looks:

```cpp
while (!glfwWindowShouldClose(window)) {
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // Calculate matrices
    glm::mat4 view = glm::lookAt(cameraPos, cameraPos + cameraFront, cameraUp);
    glm::mat4 projection = glm::perspective(45.f, ratio, 0.1f, 100.f);
    
    // Upload to GPU
    shader->setMat4("view", view);
    shader->setMat4("projection", projection);
    
    // Draw!
    model->Draw(*shader);
    
    glfwSwapBuffers(window);
}
```

The key insight? Every frame, we're recalculating matrices based on camera position, then uploading them to the GPU as "uniform variables" - values that stay the same for all vertices in that frame.

### The Camera System

First-person camera control is actually pretty interesting math. You have:
- **Yaw** - rotation left/right
- **Pitch** - rotation up/down

And you convert those angles into a direction vector using spherical coordinates:

```cpp
front.x = cos(yaw) * cos(pitch);
front.y = sin(pitch);  
front.z = sin(yaw) * cos(pitch);
```

Simple, but it works perfectly for WASD movement.

## Key Takeaways

Building this renderer taught me several important things:

1. **OpenGL is just an API** - It's not magic, it's a standardized way to talk to your GPU. You give it data, it gives you pixels.

2. **The rendering pipeline is everywhere** - Model→View→Projection isn't just for games. It's the foundation of all 3D graphics.

3. **Shaders are powerful** - Those little GLSL programs are where all the visual magic happens.

4. **Game engines hide a lot** - Unity and Unreal do incredible things, but they hide all this complexity. There's nothing wrong with that, but understanding it gives you more control.

## What Would I Do Differently?

If I were to build this again, I'd:
- Add Blinn-Phong lighting earlier (makes models look much better)
- Use a proper scene graph instead of single-model rendering
- Add shadow mapping (still haven't tackled that!)

## Final Thoughts

This project took about 2 weeks of evenings to complete. It's not perfect, but it works - and more importantly, I now understand what's happening when I use any 3D engine.

If you're curious about graphics programming, I'd highly recommend building something similar. You don't need to write a full engine. Just start with rendering a single triangle, then add textures, then add a camera. Each step teaches you something new.

The code is available if you want to take a look. Happy rendering!
