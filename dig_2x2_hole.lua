--[[
	-- NOTES --
	
	
	-- TO DO --
-- 0 create a way to save context onto floppy disks
-- 1 create a UI to set the Y level, iterations, orientation, torch placement
-- 3.consider creating your own turtle module
-- 2 creating a way to feed instructions to the turtle from a table or other data structure ex. (digf, movf, digup, movup, trnleft.., etc)
-- 3 automate the number of iterations performed by making calculations based on fuel level and Y level
-- 4 create a way to refuel automatically
-- 5 find a way to navigate to the next hole position in order to dig upwards
-- 6 create a hole_2x2.dig_hole_up() -- instead of returning the turtle after reaching bedrock, make the turtle dig a hole from bottom to top
-- update the turtle tools and investigate the code tools
-- 7 create a function that prints important stats
-- consider finding a way to use context_builder.run_checks without worrying about the order of the check strings
-- find a way to skip checks when using the public move function
	-- DEBUG NOTES--
		-- find out why the same item can end up in different item slots even though the stacks are not full
	
	-- Working on:
	-- update functions to use movment_core
]]

local horizontal_2x2 = require("hole_2x2")
local context_builder = require("context_builder")
local movement = require("movement")

local context = context_builder.create()
local state = context.state
local dig_config = context.dig_config
----------------------------------------------
dig_config.next_hole_direction = "left"
state.facing = "east"
------------VARIABLES-------------------------
local starting_fuel = state.fuel
------------FUNCITONS-------------------------

print("Fuel Level: ", starting_fuel)
state.position = {x = 93, y = 95, z = 69}
dig_config.iterations = 1

-- 3 moves per level (going down/going up/sidemovement) * number of levels (current + 63 below y=0 + 2 for moving to next iteration) * total iterations 
local max_cost = 3 * (state.position.y + 65) * dig_config.iterations

if starting_fuel < max_cost then
	print("You don't have enough fuel")
	return false
else
	print("Maximum cost: ", max_cost)
end

local success
for i=1,dig_config.iterations do
	-- success = horizontal_2x2.dig_hole_down(dig_config.next_hole_direction, context)
	success = horizontal_2x2.dig_hole_down(dig_config.next_hole_direction, context)
	movement.turn(dig_config.next_hole_direction, context)

	-- reposition turtle on the next hole location
	if state.horizontal_position == dig_config.next_hole_direction then
		movement.forward(context)
	else
		movement.forward(context)
		movement.forward(context)
	end

	if i ~= dig_config.iterations then
		movement.turn_opposite(dig_config.next_hole_direction, context)
	end
end

movement.turn(dig_config.next_hole_direction, context)

for i=1, 3 do movement.forward(context) end

print("Success:", success)
print("Total Blocks Mined: ", state.stats.blocks_mined)
print("Starting Fuel:", starting_fuel)
print("Current Fuel:", state.fuel)
print("Calculated Fuel Used:", (starting_fuel - state.fuel))
print("Total Moves:", state.stats.total_moves)
print("Facing:", state.facing)
print("Position (x,y,z):, ", state.position.x, state.position.y, state.position.z)