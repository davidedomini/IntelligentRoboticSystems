-- Put your global variables here

MOVE_STEPS = 15
MAX_VELOCITY = 10
PROX_THRESHOLD = 0.4
Dv = 15
n_steps = 0
n_steps_avoid = 0
avoiding = false

-- Aggregation hyper-parameters
W = 0.1
S = 0.01
Ps_max = 0.99
Pw_min = 0.005
alpha = 0.1 
beta = 0.05
MAXRANGE = 60
Ds = 0.9
Dw = 0.001

moving = 1

function level_random_walk()
    if (n_steps % MOVE_STEPS) == 0 then
        left_v = robot.random.uniform(0,MAX_VELOCITY)
        right_v = robot.random.uniform(0,MAX_VELOCITY)
        n_steps = 0
    end
    n_steps = n_steps + 1
    return left_v, right_v
end

function level_obstacle_avoidance()
    left_v, right_v = level_random_walk()
    max = -1
	i_max = -1
    proximity_sensor_to_use = { 1, 2, 3, 4, 5, 6, 24, 23, 22, 21, 20, 19 }
	for i=1,#proximity_sensor_to_use do
        index = proximity_sensor_to_use[i]
		if robot.proximity[index].value > max then
			max = robot.proximity[index].value
			i_max = index
		end
	end

	if max >= PROX_THRESHOLD then
        n_steps = 0
        -- need to avoid
        --log("AVOID --- inibisco LIGHT")
        n_steps_avoid = 0
        avoiding = true
        if (i_max >= 1) and (i_max <= 6) then
            -- Turn right
            --log("[AVOID] -- turn right")
            left_v = Dv
            right_v = -Dv
        elseif (i_max >= 19) and (i_max <= 24) then
            -- Turn left
            --log("[AVOID] -- turn left")
            left_v = -Dv
            right_v = Dv
        end
        n_steps_avoid = n_steps_avoid + 1
	end

	if (avoiding == true) and (max < PROX_THRESHOLD) then

        if (n_steps_avoid % MOVE_STEPS) == 0 then
            n_steps_avoid = 0
            avoiding = false
        else
            --log("[AVOID] -- keep going straight")
            left_v = Dv
            right_v = Dv
            n_steps_avoid = n_steps_avoid + 1
        end
	end

    return left_v, right_v
end

function count_neighbours()
    number_robot_sensed = 0
    for i = 1, #robot.range_and_bearing do
        -- for each robot seen, check if it is close enough.
        if robot.range_and_bearing[i].range < MAXRANGE and robot.range_and_bearing[i].data[1]==1 then
            number_robot_sensed = number_robot_sensed + 1
        end
    end 
    return number_robot_sensed
end


function check_floor()
    N = 0
    for i = 1, #robot.motor_ground do
        if robot.motor_ground[i].value == 0 then
            N = N + 1
        end
    end
    if N == 4 then 
        return 1
    else 
        return 0
    end
end

function level_aggregation()
    left_v, right_v = level_random_walk()
    N = count_neighbours()

    if moving == 1 then 
        -- think about whether to stop

        floor = check_floor()

        Ps = math.min(Ps_max, S+alpha*N +( Ds*floor))
        log("Ps:" .. Ps)
        t = robot.random.uniform()

        if t < Ps then 
            -- stop
            moving = 0
            left_v = 0
            right_v = 0
            robot.range_and_bearing.set_data(1,1)
            robot.leds.set_all_colors("red")
        else
            -- keep moving
            robot.range_and_bearing.set_data(1,0)
            robot.leds.set_all_colors("green")
        end

    else
        -- think about whether to move
        floor = check_floor()
        Pw = math.max(Pw_min, W-beta*N - (Dw*floor))
        log("Pw:" .. Pw)
        t = robot.random.uniform()

        if t < Pw then 
            -- move
            moving = 1
            robot.range_and_bearing.set_data(1,0)
            robot.leds.set_all_colors("green")
        else
            -- keep standing still 
            left_v = 0
            right_v = 0
            robot.range_and_bearing.set_data(1,1)
            robot.leds.set_all_colors("red")
        end

    end

    return left_v, right_v
end
--[[ This function is executed every time you press the 'execute'
     button ]]
function init()
	left_v = robot.random.uniform(0,MAX_VELOCITY)
	right_v = robot.random.uniform(0,MAX_VELOCITY)
	robot.wheels.set_velocity(left_v,right_v)
	n_steps = 0
    robot.leds.set_all_colors("green")
end


--[[ This function is executed at each time step
     It must contain the logic of your controller ]]
function step()
    left_v, right_v = level_aggregation()
    robot.wheels.set_velocity(left_v,right_v)
end


--[[ This function is executed every time you press the 'reset'
     button in the GUI. It is supposed to restore the state
     of the controller to whatever it was right after init() was
     called. The state of sensors and actuators is reset
     automatically by ARGoS. ]]
function reset()
	left_v = robot.random.uniform(0,MAX_VELOCITY)
	right_v = robot.random.uniform(0,MAX_VELOCITY)
	robot.wheels.set_velocity(left_v,right_v)
	n_steps = 0
	n_steps_avoid = 0
	avoiding = false
    moving = 1
    robot.leds.set_all_colors("green")
end


--[[ This function is executed only once, when the robot is removed
     from the simulation ]]
function destroy()
end




