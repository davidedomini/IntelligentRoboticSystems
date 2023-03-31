-- Put your global variables here

MAX_VELOCITY = 15
L = 0
n_steps = 0
PROX_TH = 0.4
MOVE_STEPS = 10


--[[ This function is executed every time you press the 'execute'
     button ]]
function init()
	L = robot.wheels.axis_length
	n_steps = 0
end

function check_vel(vl, vr)
    if vl > MAX_VELOCITY then
        vl = MAX_VELOCITY
    end
    if vr > MAX_VELOCITY then
        vr = MAX_VELOCITY
    end
    return vl, vr
end

function toDifferential(v)
    vl = v.length + (-L/2) * v.angle
    vr = v.length + L/2 * v.angle
    vl, vr = check_vel(vl, vr)
    return vl, vr
end

function find_prox()
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
    return max, i_max
end

function find_light()
    max = 0
    i_max = 1
    for i=1,#robot.light do
        if robot.light[i].value > max then
            max = robot.light[i].value
            i_max = i
        end
    end
    return max, i_max
end

function random_walk()
    v_rw = {length = 0.0, angle = 0.0}

    max, i_max = find_prox()
    l, l_index = find_light()

	if max < PROX_TH && l == 0 then
        if (n_steps % MOVE_STEPS) == 0 then
            v_rw.angle = robot.random.uniform(-math.pi, math.pi)
            v_rw.length = 1
            n_steps = 0
        else
            v_rw.angle = 0
            v_rw.length = 1
        end
        n_steps = n_steps + 1
	else
        n_steps = 0
        v_rw.angle = 0
        v_rw.length = 0
	end

    return v_rw
end

function obstacle_avoidance()
    v_oa = {length = 0.0, angle = 0.0}

    max, i_max = find_prox()

    if max >= PROX_TH then
        log("AVOIDING")
        v_oa.length = max
        v_oa.angle = - math.pi
    end

    return v_oa
end

function phototaxis()
    v_pa = {length = 0.0, angle = 0.0}
    max, i_max = find_light()
    v_pa.length = 1 - max
    v_pa.angle = robot.light[i_max].angle
    return v_pa
end

--[[ This function is executed at each time step
     It must contain the logic of your controller ]]
function step()
    local vector = require "vector"
    v_rw = random_walk()
    v_oa = obstacle_avoidance()
    v_pa = phototaxis()
    v_1 = vector.vec2_polar_sum(v_rw, v_oa)
    v = vector.vec2_polar_sum(v_1, v_pa)
    vl, vr = toDifferential(v)
    robot.wheels.set_velocity(vl,vr)

end


--[[ This function is executed every time you press the 'reset'
     button in the GUI. It is supposed to restore the state
     of the controller to whatever it was right after init() was
     called. The state of sensors and actuators is reset
     automatically by ARGoS. ]]
function reset()
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




