---
title: "I Built an Artificial Life Simulation in C++"
date: 2026-04-04
slug: artificial-life-simulation
github: "https://github.com/Nyxox-debug/OKIOS"
featured_image: /nyxox/images/okios.png
categories:
  - projects
tags:
  - cpp
  - opengl
  - neural-networks
  - simulation
  - neuroevolution

---

I've always been curious about emergence. How does organized, purposeful behavior arise from simple rules? How does a colony of ants, with no central planner, manage to build complex structures and find food efficiently?

So I built **OKIOS** — named after the Greek *οἶκος*, meaning home or habitat. It's a 3D artificial life simulation where creatures with neural-network brains learn to survive entirely on their own. No predefined roles. No hand-coded behaviors. Just pressure, time, and mutation.

<!--more-->

## The Idea

The premise is simple: spawn a population of identical agents in a shared 3D environment. Each agent starts with no knowledge and the same capabilities. Food is scattered across the terrain. Eat enough, reproduce. Starve, die.

Over time, behavioral patterns emerge. Not because I programmed them — but because survival pressure selects for them.

The core question I wanted to explore:

> How does organized structure emerge from decentralized, self-interested agents?

## What It Looks Like

The world is a procedurally generated terrain rendered with OpenGL. Creatures are small cubes with red tails — the tail tracks behind the body via a joint system. Food items are small golden cubes scattered across the map. The camera is free-fly so you can watch the simulation from any angle.

Each frame runs 60 simulation steps at a fixed timestep, so the creatures are thinking and moving much faster than real time.

## The Architecture

The simulation is built around an **Entity-Component System (ECS)**. Every object in the world — creature, food, light source — is just an integer ID. Components attach data to that ID:

- `TransformComponent` — position, rotation, scale
- `VelocityComponent` — current velocity
- `MeshComponent` — renderable geometry
- `LifeComponent` — health, hunger, meals eaten
- `BrainComponent` — the neural network
- `JointComponent` — attaches a tail to a parent body

Systems then operate on entities that have the right combination of components. `MovementSystem` reads velocity and writes position. `LifeSystem` drains health when hungry. `BrainSystem` runs the neural network and outputs a movement direction.

The separation is clean. The brain doesn't know about rendering. The renderer doesn't know about physics.

## The Brain

Each creature has a small feedforward neural network:

```
Inputs (5) → Hidden Layer (8, tanh) → Outputs (2, tanh)
```

The inputs are:
- Normalized health
- Normalized hunger
- Direction to nearest food (2D vector)
- Distance to nearest food (normalized)

The outputs are a 2D movement direction vector. The creature steers toward whatever the network says.

```cpp
output Brain::forward(const input &in) const {
  const std::array<float, 5> inputs = {
    in.health, in.hunger,
    in.direction.x, in.direction.y,
    in.distance
  };
  // hidden layer with tanh activation
  for (int i = 0; i < 8; i++) {
    float sum = biasHidden[i];
    for (int j = 0; j < 5; j++)
      sum += weightsInputHidden[i * 5 + j] * inputs[j];
    hidden[i] = std::tanh(sum);
  }
  // output layer
  for (int i = 0; i < 2; i++) {
    float sum = biasOutput[i];
    for (int j = 0; j < 8; j++)
      sum += weightsHiddenOutput[i * 8 + j] * hidden[j];
    out[i] = std::tanh(sum);
  }
  return {glm::vec2(out[0], out[1])};
}
```

Simple. But what matters is *how the weights get trained* — and that's where the interesting journey happened.

## The Training Journey: From REINFORCE to Neuroevolution

This is the part that taught me the most.

### First Attempt: REINFORCE

My first instinct was to use the **REINFORCE algorithm** — a classic policy gradient method from reinforcement learning. The idea is straightforward: run the agent, collect rewards, and nudge the network weights in the direction that made good outcomes more likely.

The reward signal was tied to health and hunger:

```cpp
life.reward = (life.health / life.maxHealth) - (life.hunger / life.maxHunger);
life.cumulativeReward += life.reward * dt;
```

In theory, the agent should learn to keep its health high and its hunger low — which means finding food.

In practice, it was a mess. The gradient estimates were extremely noisy. The network weights oscillated wildly. Agents would briefly stumble toward food, then forget. The population kept dying before anything useful could be learned. The fundamental problem with REINFORCE in this setting is that the reward signal is sparse and delayed — the agent doesn't know *which* of its many decisions actually led to finding food.

### Second Attempt: Neuroevolution

I went looking for alternatives and landed on **neuroevolution** — specifically, training the neural network through a genetic algorithm rather than gradient descent.

The idea is to treat the network weights as a genome. Instead of computing gradients, you:

1. Keep a population of agents with different weight configurations
2. Let them run — survivors that eat more get to reproduce
3. Offspring inherit the parent's weights with small random mutations
4. Repeat

```cpp
Brain Brain::mutate(float mutationRate, std::mt19937 &rng) const {
  std::uniform_real_distribution<float> dist(-1.0f, 1.0f);
  Brain child = *this;
  for (auto &w : child.weightsInputHidden)
    w += dist(rng) * mutationRate;
  for (auto &w : child.weightsHiddenOutput)
    w += dist(rng) * mutationRate;
  for (auto &b : child.biasHidden)
    b += dist(rng) * mutationRate;
  for (auto &b : child.biasOutput)
    b += dist(rng) * mutationRate;
  return child;
}
```

Reproduction is gated behind eating 4 meals. The best-performing creatures (sorted by cumulative reward) reproduce first:

```cpp
std::sort(ranked.begin(), ranked.end(), std::greater<>());
for (auto &[score, id] : ranked) {
  if (life.mealAmount < 4) continue;
  Brain childBrain = world.sentients.at(id).brain.mutate(0.1f, getRng());
  spawnCreature(world, verts, idx, childBrain);
}
```

This worked dramatically better. Within a few generations, creatures reliably navigate toward food. No gradient computation, no backprop — just selection pressure and noise.

The key insight is that **neuroevolution sidesteps the credit assignment problem entirely**. You don't need to know which decision caused the reward. You just need to know which agent survived longer — and nature handles the rest.

## Other Systems

### Movement & Physics

The movement system applies velocity, clamps speed, adds gravity, and snaps creatures to terrain height. Creatures can't walk off the map — boundary collision zeroes out the relevant velocity component.

Rotation is handled by smoothly interpolating toward the direction of movement using `glm::mix`, so creatures naturally face where they're going.

### Collision

AABB collision detection between all non-tail entities. On overlap, the minimum penetration axis is resolved by pushing both bodies apart. If only one body is dynamic (e.g., a creature hitting a static object), the full penetration goes to the dynamic one. Velocities are swapped or zeroed accordingly.

### Population Management

A minimum population floor keeps the simulation alive. If the creature count drops below 6, the system spawns new creatures by mutating the best surviving brain — or a fresh random one if everyone is dead.

```cpp
if (creatureCount < MIN_POPULATION) {
  Brain seedBrain = world.sentients.empty()
    ? freshBrain
    : world.sentients.begin()->second.brain.mutate(0.05f, getRng());
  // spawn needed creatures from mutated seed
}
```

## What I Learned

**REINFORCE is hard to tune in sparse environments.** Policy gradient methods need dense, frequent reward signals to work well. A creature wandering a large terrain, eating occasionally, doesn't get that signal often enough.

**Neuroevolution is surprisingly robust.** No learning rate, no gradient clipping, no replay buffer. Just mutation rate and selection pressure. For simulations where you can run many agents in parallel, it's a remarkably practical approach.

**ECS makes simulation code clean.** Systems only care about the components they need. Adding a new behavior means adding a new system — nothing else changes.

**Emergence is real and weird to watch.** Once the brains are even slightly trained, you start seeing group behavior that you never programmed. Clusters form around food. Some creatures patrol. It's not intelligence — but it looks like something.

## What's Next

OKIOS is still a work in progress. Some things I want to explore:

- Agent-to-agent perception (can creatures detect each other?)
- Predator/prey dynamics
- More complex terrain with resource scarcity zones
- Crossover between two parent brains, not just mutation

The simulation currently answers a small version of the big question. But the bigger question — true emergent cooperation and specialization — is still ahead.

The habitat is just getting started.
