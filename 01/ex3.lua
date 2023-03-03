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
	prox_back = robot.proximity[12].value + robot.proximity[13].value

	if prox_front > PROX_THRESHOLD or prox_back > PROX_THRESHOLD then
		log("avoid obstacle")
		robot.wheels.set_velocity(0,Dv)
		n_steps = n_steps + 1

	elseif n_steps > 0 then

		n_steps = n_steps + 1

		robot.wheels.set_velocity(Dv,Dv)
		if (n_steps % MOVE_STEPS == 0) then
			n_steps = 0
		end
	else
		l = {1,2,3,4} --random init

		l[1] = robot.light[1].value + robot.light[24].value --light_front
		l[2] = robot.light[12].value + robot.light[13].value --light_back
		l[3] = robot.light[18].value + robot.light[19].value --light_right
		l[4] = robot.light[6].value + robot.light[7].value --light_left

		max = 0
		i_max = 1
		for i=1,4 do
			if l[i] > max then
				max = l[i]
				i_max = i
			end
		end

		if i_max == 1 then
			--light front
			robot.wheels.set_velocity(Dv,Dv)
		elseif i_max == 2 then
			--light back
			robot.wheels.set_velocity(-Dv,-Dv)
		elseif i_max == 3 then
			--light right
			robot.wheels.set_velocity(Dv,0)
		elseif i_max == 4 then
			--light left
			robot.wheels.set_velocity(0,Dv)
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
end
