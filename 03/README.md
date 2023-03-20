# Lab 03: The Subsumption Architecture

## Goal

The robot is expected to be able to find a light source and go towards it, while avoiding collisions with othe objects, such as walls, boxes and other robots. The robot should reach the target as fast as possible and, once reached it, it should stay close to it (either standing or moving). For physical constraints the wheel velocity cannot exceed the value 15 (i.e.,  15<sup>2</sup> m/s). The robot (a footbot) is equipped with both light and proximity sensors.

## Overview

The robot controller is designed by means of the subsumption architecture. This approach allows the definition of the robot behaviour in an incremental way, it is composed by three levels with different priorities. Each level might inhibit the levels below. 

![architecture](./imgs/architecture.png)

- **Random Walk**: ability to perform random movements in the arena (it is the level with the lowest priority).

- **Phototaxis**: ability to go towards a light source, considering an arena without obstacles. Whenever the robot senses a light source this level inhibits the random walk level.

- **Obstacle avoidance**: ability to avoid obstacles. Whenever the robot senses a dangerous obstacle this level inhibits the levels below and sets the wheels velocities in order to avoid the collision with the obstacle. 

Each level is a Finite State Machine:
![architecture](./imgs/FMS.png)

## Implementation

Since in Argos only sequential processes can be run the subsumption arichitecture has been implemented with some variants. In order to implement and extensible code each level is represented by a function, the step function only calls the level with the highest priority, then each level:
1. Calls the lower level 
2. Executes its behaviour, if it is needed it will inhibit the underlying levels, otherwise it let the signal they emit (i.e., the velocity) pass. 
