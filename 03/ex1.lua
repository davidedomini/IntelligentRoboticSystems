-- Put your global variables here

MOVE_STEPS = 15
MAX_VELOCITY = 10
PROX_THRESHOLD = 0.4
Dv = 15
n_steps = 0
n_steps_avoid = 0
avoiding = false


function level_random_walk()
    if (n_steps % MOVE_STEPS) == 0 then
        left_v = robot.random.uniform(0,MAX_VELOCITY)
        right_v = robot.random.uniform(0,MAX_VELOCITY)
        n_steps = 0
    end
    n_steps = n_steps + 1
    return left_v, right_v
end

function level_phototaxis()
    left_v, right_v = level_random_walk()

    max = 0
    i_max = 1
    for i=1,24 do
        if robot.light[i].value > max then
            max = robot.light[i].value
            i_max = i
        end
    end

    if max ~= 0 then
        log("LIGHT --- inibisco RANDOM")
        -- inibisco quello sotto
        n_steps = 0
        if i_max == 1 or i_max == 24 then
            left_v = Dv
            right_v = Dv
        elseif i_max > 1 and i_max <= 12 then
            log("[LIGHT] -- turn left")
            left_v = -Dv
            right_v = Dv
        elseif i_max >= 13 and i_max < 24 then
            log("[LIGHT] -- turn right")
            left_v = Dv
            right_v = -Dv
        end
    end

    return left_v, right_v
end

function level_obstacle_avoidance()
    left_v, right_v = level_phototaxis()
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
        -- need to avoid
        log("AVOID --- inibisco LIGHT")
        n_steps_avoid = 0
        avoiding = true
        if (i_max >= 1) and (i_max <= 6) then
            -- Turn right
            log("[AVOID] -- turn right")
            left_v = Dv
            right_v = -Dv
        elseif (i_max >= 19) and (i_max <= 24) then
            -- Turn left
            log("[AVOID] -- turn left")
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
            log("[AVOID] -- keep going straight")
            left_v = Dv
            right_v = Dv
            n_steps_avoid = n_steps_avoid + 1
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
end


--[[ This function is executed at each time step
     It must contain the logic of your controller ]]
function step()
    left_v, right_v = level_obstacle_avoidance()
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
end



--[[ This function is executed only once, when the robot is removed
     from the simulation ]]
function destroy()
   -- put your code here
   x = robot.positioning.position.x
   y = robot.positioning.position.y
   d = math.sqrt(x^2 + y^2)
   log("distance: "..d)
end




