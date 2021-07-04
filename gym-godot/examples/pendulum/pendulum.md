# Pendulum environment example

![pendulum](./output.gif)

The pendulum starts with random initial rotation, the goal is to swing it up so it stays upright.

## Observations

Continuous `Box(3)` :

|Idx|Observation|Min|Max|
|-|-|-|-|
|0|Cos Theta |-1|1|
|1|Sin Theta|-1|1|
|2|Angle Velocity (`theta_dt`)|-2|2|

Theta is the angle of the pendulum with respect to the vertical, in [-pi, pi].

## Actions

`Box(1)` :

|Idx|Action|Min|Max|
|-|-|-|-|
|0|Torque Force (`torque`)|-2|2|

## Reward

Reward is `-cost` where `cost = theta^2 + 0.1*theta_dt^2 + 0.001*torque^2`.

## Episode Termination

No termination event (`is_done()` always returns `False`).

## Learning script example

[learn.py](./learn.py) (to be launched from within the script's own folder), uses [Stable-Baseline](https://github.com/DLR-RM/stable-baselines3).


