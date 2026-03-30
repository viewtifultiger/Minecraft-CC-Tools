--[[
	-- NOTES --
	
	
	-- TO DO --
-- 1 create a UI to set the Y level, iterations, orientation, torch placement
-- 2 automate the number of iterations performed by making calculations based on fuel level and Y level
-- 3 create a way to track fuel level and refuel automatically
-- 7 find a way to navigate to the next hole position in order to dig upwards
-- 4 create movement functions and have them receive a context
-- 5 create a function that prints important stats

	-- DEBUG NOTES--
		-- find out why the same item can end up in different item slots even though the stacks are not full
	
	-- Working on: 
		
]]

local horizontal_2x2 = require("hole_2x2")
local tt = require("turtletools")
local context_builder = require("context_builder")


local context = context_builder.create()
local state = context.state
local dig_config = context.dig_config
local stats = state.stats
----------------------------------------------
dig_config.next_hole_direction = "left"
------------VARIABLES-------------------------
local next_hole_direction = dig_config.next_hole_direction
------------FUNCITONS-------------------------
local dig_hole_down = horizontal_2x2.dig_hole_down
local turn = tt.turn_functions[next_hole_direction]
local opposite_turn = tt.turn_functions[next_hole_direction == "left" and "right" or "left"] -- consider moving horizontal_flip() in hole_2x2 elsewhere



state.fuel = turtle.getFuelLevel()
local startingFuel = state.fuel
state.position["y"] = 95
dig_config.iterations = 1

print("Fuel Level: ", state.fuel)


-- 3 moves per level (going down/going up/sidemovement) * number of levels (current + 63 below y=0 + 2 for moving to next iteration) * total iterations 
local max_cost = 3 * (state.position["y"] + 65) * dig_config.iterations

if startingFuel < max_cost then
	print("You don't have enough fuel")
	return false
else
	print("Maximum cost: ", max_cost)
end

local success
for i=1,dig_config.iterations do
	success = dig_hole_down(next_hole_direction, context)
	turn() -- turn towards the next hole

	if state.horizontal_position == next_hole_direction then
		tt.forward(1)
	else
		tt.forward(2)
	end

	if i ~= dig_config.iterations then
		opposite_turn() -- this turn prepares the turtle for the next hole
	end
end

turn()
tt.forward(3)

print("Success:", success)
print("Fuel Remaining:", turtle.getFuelLevel())
print("Total Fuel Used:", startingFuel - turtle.getFuelLevel())

print("Total Blocks Mined: ", stats.blocks_mined)
print("Stone Blocks Mined: ", stats.blocks_mined_by_name["minecraft:stone"])
