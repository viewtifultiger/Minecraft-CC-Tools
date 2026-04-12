--[[
	-- NOTES --
	When it comes to the bedrock level, y = -59 is cut-off point where bedrock stops spawning
	
	
	-- TO DO --
-- 0 create a way to save context onto floppy disks
-- 1 create a UI to set the Y level, iterations, orientation, torch placement
-- 3.consider creating your own turtle module
-- 2 creating a way to feed instructions to the turtle from a table or other data structure ex. (digf, movf, digup, movup, trnleft.., etc)
-- 3 automate the number of iterations performed by making calculations based on fuel level and Y level
-- 4 create a way to refuel automatically
-- 7 create a function that prints important stats

	-- DEBUG NOTES--
		-- find out why the same item can end up in different item slots even though the stacks are not full
	
	-- Working on:
	
]]

package.path = package.path .. ";/lib/?.lua"

local tt = require("turtletools")
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
local next_hole_direction = dig_config.next_hole_direction
------------FUNCITONS-------------------------

print("Fuel Level: ", starting_fuel)
state.position = {x = 93, y = 95, z = 49}
dig_config.iterations = 2

-- 3 moves per level (going down/going up/sidemovement) * number of levels (current + 63 below y=0 + 2 for moving to next iteration) * total iterations 
local max_cost = 3 * (state.position.y + 65) * dig_config.iterations

if starting_fuel < max_cost then
	print("You don't have enough fuel")
	return false
else
	print("Maximum cost: ", max_cost)
end

-----------------------------------------------------------------------------------------
for i=1, dig_config.iterations, 2 do
	horizontal_2x2.dig_hole_down(dig_config.next_hole_direction, context)
	if (i + 1) > dig_config.iterations then
		tt.return_to_surface(state.depth, context)
		break
	end
	while (state.position.y < -59) do
		movement.up(context)
	end
	movement.turn(dig_config.next_hole_direction, context)
	-- reposition turtle on the next hole location
	if state.horizontal_position == dig_config.next_hole_direction then
		tt.try_dig("forward", context)
		movement.forward(context)
	else
		movement.forward(context)
		tt.try_dig("forward", context)
		movement.forward(context)
	end
	movement.turn_opposite(dig_config.next_hole_direction, context)
	horizontal_2x2.dig_hole_up(dig_config.next_hole_direction, context, 95)
end

movement.turn(dig_config.next_hole_direction, context)
movement.turn(dig_config.next_hole_direction, context)
---------------------------------------------------------------------------------------------
for i=1, 3 do movement.forward(context) end

print("Success:", success)
print("Total Blocks Mined: ", state.stats.blocks_mined)
print("Starting Fuel:", starting_fuel)
print("Current Fuel:", state.fuel)
print("Calculated Fuel Used:", (starting_fuel - state.fuel))
print("Total Moves:", state.stats.total_moves)
print("Facing:", state.facing)
print("Position (x,y,z):, ", state.position.x, state.position.y, state.position.z)