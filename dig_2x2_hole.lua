local hole = require("hole_2x2")
local ct = require("codetools")
local tt = require("turtletools")

io.write("Enter the direction to mine (left/right): ")
local next_hole_direction = io.read()

if next_hole_direction ~= "left" and next_hole_direction ~= "right" then	-- temporary fix
	print("not a valid direction")
	return
end

local turn = tt.turn_functions[next_hole_direction]
local opposite_turn = tt.turn_functions[next_hole_direction == "left" and "right" or "left"]

local currentFuel = turtle.getFuelLevel()
local y = 95

print("Fuel Level: ", currentFuel)

io.write("Enter number of iterations: ")
local iterations = tonumber(io.read())

local cost = 3 * iterations * (y + 65)
-- the above calculation is the simplified version of the below:
-- max_y * 2 -> cost to mine down and dig
-- + 1 -> first dig down
-- + may_y -> cost to return to surface from bedrock
-- * iterations -> number of times to loop
-- + (2 * iterations) max number of moves to move to next section
local startingFuel = currentFuel

if startingFuel < cost then
	print("You don't have enough fuel")
	return
else
	print("Maximum cost: " .. cost)
end

local placeTorches = ct.verifyTorchDownSetting(false)

--[[
	-- NOTES --
	currently I want to figure out a way to pass a dictionary to the main dig function, however I'm not sure what will happen to this 
		upper level 2x2 digging program. I can imagine a few digging scripts that may reuse the 2x2 dig hole function, but in that case
		I would want to pass the hole type as part of an option within the dictionary. Therefore this upper level program would
		be obsolete. In order to generalize the 2x2 hole, we would need to take the first iteration of digging a 2x2 square. 
		from there we can modify or move the turtle to create more 2x2 squares in other directions.
	
	
	-- TO DO --
-- 1 create a UI to set the Y level, iterations, orientation, torch placement
-- 2 automate the number of iterations performed by making calculations based on fuel level and Y level
-- 3 create a way to track fuel level and refuel automatically
-- 5 check other scripts that use dig_2x2_hole and update the use of the boolean direction value
-- 6 have the hole.dig() function return a boolean (true or false based on horizontal position and the turtle's proximity), and a tabl
--	of information that includes blocks that were dug
-- 7 find a way to have the turtle mine blocks around even though it found an invalid block in the last position of the dig loop
-- 8 find a way to give the main dig funtion a dictionary of options and have the function handle those options
-- 9 let the M.dig() function accept a blacklist of digging blocks

	-- DEBUG NOTES--

	
	-- Working on: 
	-- making sure opposite turn works when the turtle goes to the right
	-- figuring out other use cases for the hole.dig() function and how to generalize it
	
		

			
		@variable goal boolean: direction of new holes to be dug; set by the user at the start of the program; 
		true -> start the next new hole to the right
		false -> start the next new hole to the left
		
		Mhole.dig() [MAIN DIGGING FUNCTION]: returns a boolean that represents the horizontal_position of the turtle on the 2x2 grid (left or right half);
		we compare this to the direction of the next_hole_direction to determine how many spaces to move to the next hole.
		true -> will start the next new hole to the right
		false -> will start the next new hole to the left
		
]]

local horizontal_position
for i=1,iterations do
	horizontal_position = hole.dig(next_hole_direction, placeTorches)
	turn() -- turn towards the next hole

	if horizontal_position == next_hole_direction then
		tt.forward(1)
	else
		tt.forward(2)
	end

	if i ~= iterations then
		opposite_turn() -- this turn prepares the turtle for the next hole
	end
end

turn()
tt.forward(3)

local fuelCurrentlyExpended = startingFuel - turtle.getFuelLevel()
print("Complete!")
print("Fuel Remaining:", turtle.getFuelLevel())
print("Total Fuel Used:", startingFuel - turtle.getFuelLevel())