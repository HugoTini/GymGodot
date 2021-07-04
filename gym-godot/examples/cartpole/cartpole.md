# Cartpole environment example

![cartpole](./notebook_images/output.gif)

A pole is attached by an un-actuated joint to a cart, which moves along a frictionless track. The pendulum starts upright, and the goal is to prevent it from falling over by increasing and reducing the cart's velocity.

## Observations

Continuous `Box(4)` :

|Idx|Observation|Min|Max|
|-|-|-|-|
|0|Cart Position|-40|40|
|1|Cart Velocity|-Inf|Inf|
|2|Pole Angle|-pi/8|pi/8|
|3|Pole Angle Velocity|-Inf|Inf|

## Actions

`Discrete(2)` :
|Value|Action|
|-|-|
|0|Push cart to the left|
|1|Push cart to the right|

## Reward

Reward is +1.0 for every step taken.

## Episode Termination:

- Absolute pole angle is more than pi/8.
- Absolute cart z-position is more than 40 (the cart reaches the edge of the screen).

## Learning script example

[tutorial.ipynb](./tutorial.ipynb)


