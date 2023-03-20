# Lab 03: The Subsumption Architecture

## Goal

The robot is expected to be able to find a light source and go towards it, while avoiding collisions with othe objects, such as walls, boxes and other robots. The robot should reach the target as fast as possible and, once reached it, it should stay close to it (either standing or moving). For physical constraints the wheel velocity cannot exceed the value 15 (i.e.,  15<sup>2</sup> m/s). The robot (a footbot) is equipped with both light and proximity sensors.

## Notes

The robot controller is designed by means of the subsumption architecture. This approach allows the definition of the robot behaviour in an incremental way, it is composed by three levels with different priorities. Each level might inhibit the levels below. 

![architecture](./imgs/architecture.png)

- **Random Walk**: ability to perform random movements in the arena (it is the level with the lowest priority).

- **Phototaxis**: ability to go towards a light source, considering an arena without obstacles. Whenever the robot senses a light source this level inhibits the random walk level.

- **Obstacle avoidanc**: ability to avoid obstacles. Whenever the robot senses a dangerous obstacle this level inhibits the levels below and sets the wheels velocities in order to avoid the collision with the obstacle. 