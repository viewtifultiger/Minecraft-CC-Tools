--[[
	-- NOTES --
	
	
	-- TO DO --
-- 1 create a UI to set the Y level, iterations, orientation, torch placement
-- 2 automate the number of iterations performed by making calculations based on fuel level and Y level
-- 3 create a way to track fuel level and refuel automatically
-- 5 check other scripts that use dig_2x2_hole and update the use of the boolean direction value
-- 6 have the hole.dig() function return a boolean (true or false based on horizontal position and the turtle's proximity), and a tabl
--	of information that includes blocks that were dug
-- 7 find a way to have the turtle mine blocks around even though it found an invalid block in the last position of the dig loop

	-- DEBUG NOTES--

	
	-- Working on: 
	refactor the dig function to only take a context as an argument
		
]]

local hole = require("hole_2x2")
local ct = require("codetools")
local tt = require("turtletools")
local context_builder = require("context_builder")


local next_hole_direction = "left"

if next_hole_direction ~= "left" and next_hole_direction ~= "right" then	-- temporary fix
	print("not a valid direction")
	return false
end

local turn = tt.turn_functions[next_hole_direction]
local opposite_turn = tt.turn_functions[next_hole_direction == "left" and "right" or "left"]

local currentFuel = turtle.getFuelLevel()
local y = 95

print("Fuel Level: ", currentFuel)

local iterations = 1

-- 3 moves per level (going down/going up/sidemovement) * number of levels (current + 63 below y=0 + 2 for moving to next iteration) * total iterations 
local max_cost = 3 * (y + 65) * iterations
local startingFuel = currentFuel

if startingFuel < max_cost then
	print("You don't have enough fuel")
	return false
else
	print("Maximum cost: ", max_cost)
end

local success
local context = context_builder.create()
local state = context.state
local stats = state.stats
local blocks_mined = stats.blocks_mined
local blocks_mined_by_name = state.stats.blocks_mined_by_name
-- local dig_config = context.dig_config

state.horizontal_position = "left"


for i=1,iterations do
	success = hole.dig(state.horizontal_position)
	turn() -- turn towards the next hole

	if state.horizontal_position == next_hole_direction then
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
print("Success:", success)
print("Fuel Remaining:", turtle.getFuelLevel())
print("Total Fuel Used:", startingFuel - turtle.getFuelLevel())

print("Total Blocks Mined: ", blocks_mined)
print("Cobblestone Blocks Mined: ", blocks_mined_by_name["minecraft:cobblestone"])
