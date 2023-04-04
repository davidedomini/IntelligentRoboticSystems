-- Put your global variables here

MAX_VELOCITY = 15
L = 0
n_steps = 0
PROX_TH = 0.4
MOVE_STEPS = 10
local vector = require "vector"


--[[ This function is executed every time you press the 'execute'
     button ]]
function init()
	L = robot.wheels.axis_length
	n_steps = 0
end

function limitVelocity(v)
    if v > MAX_VELOCITY then
      return MAX_VELOCITY
    elseif v < -MAX_VELOCITY then
      return -MAX_VELOCITY
    else
      return v
    end
  end

function toDifferential(v)
    vl = v.length + (-L/2) * v.angle
    vr = v.length + L/2 * v.angle
    vl = limitVelocity(vl)
    vr = limitVelocity(vr)
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

	if max < PROX_TH and l == 0 then
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
    max, i_max = find_prox()
    proximityAngle = robot.proximity[i_max].angle
    return { length = max, angle = (-(math.abs(proximityAngle)/proximityAngle)*math.pi + proximityAngle) }
end

function phototaxis()
    v_pa = {length = 0.0, angle = 0.0}
    max, i_max = find_light()
    v_pa.length = 1 - max
    v_pa.angle = robot.light[i_max].angle
    return v_pa
end

function step()

    behaviors = {
        random_walk(),
        obstacle_avoidance(),
        phototaxis()
    }

    result_vector = { length = 0.0,  angle = 0.0 }

    for i=1,#behaviors do
        result_vector = vector.vec2_polar_sum(result_vector, behaviors[i])
    end

    vl, vr = toDifferential(result_vector)
    robot.wheels.set_velocity(vl,vr)

end


function reset()
end

function destroy()
   x = robot.positioning.position.x
   y = robot.positioning.position.y
   d = math.sqrt(x^2 + y^2)
   log("distance: "..d)
end




