-- Put your global variables here

MOVE_STEPS = 15
MAX_VELOCITY = 10
PROX_THRESHOLD = 1.0
Dv = 15

n_steps = 0


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


	prox_front = robot.proximity[1].value + robot.proximity[24].value
	prox_front_east = robot.proximity[21].value + robot.proximity[20].value
	prox_front_west = robot.proximity[5].value + robot.proximity[4].value

	if prox_front > PROX_THRESHOLD or prox_front_east > PROX_THRESHOLD or prox_front_west > PROX_THRESHOLD then
		log("avoid obstacle")
		robot.wheels.set_velocity(-(12+Dv),12+Dv)
		n_steps = n_steps + 1

	elseif n_steps > 0 then

		n_steps = n_steps + 1
		log("since avoided obstacle i go straight")
		robot.wheels.set_velocity(Dv,Dv)
		if (n_steps % MOVE_STEPS == 0) then
			n_steps = 0
		end
	else

		max = 0
		i_max = 1
		for i=1,24 do
			if robot.light[i].value > max then
				max = robot.light[i].value
				i_max = i
			end
		end

		log("i_max"..i_max)

		if i_max == 1 or i_max == 24 then
			robot.wheels.set_velocity(Dv,Dv)
		elseif i_max > 1 and i_max <= 12 then
			log("turn left")
			robot.wheels.set_velocity(-Dv,Dv)
		elseif i_max >= 13 and i_max < 24 then
			log("turn left")
			robot.wheels.set_velocity(Dv,-Dv)
		end


	end


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
