-- Put your global variables here

MAX_VELOCITY = 15
L = 0
local vector = require "vector"

--[[ This function is executed every time you press the 'execute'
     button ]]
function init()
	L = robot.wheels.axis_length
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


function perceptual_schema()
    max = 0
    i_max = 1
    for i=1,#robot.light do
        if robot.light[i].value > max then
            max = robot.light[i].value
            i_max = i
        end
    end

    light = max
    angle = robot.light[i_max].angle
    return light, angle
end

function motor_schema(light, angle)
    v = 1 - light
    omega = angle
    return v, omega
end

function conversion(v, omega)
    vl = v + (-L/2) * omega
    vr = v + L/2 * omega
    vl, vr = check_vel(vl, vr)
    return vl, vr
end

--[[ This function is executed at each time step
     It must contain the logic of your controller ]]
function step()

    light, angle = perceptual_schema()
    v, omega =  motor_schema(light, angle)
    vl, vr = conversion(v, omega)
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




