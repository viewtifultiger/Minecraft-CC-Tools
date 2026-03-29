local ct = require("codetools")
local tt = require("turtletools")
local context_builder = require("context_builder")
local DEFAULT_BLACKLIST = require("_black_list_blocks")

local M = {}

--[[
	Notes:
]]

--[[TO DO --
-- 1 find an algorithm to "clean up" after finding all blocks to be invalid (mine blocks not checked)
 - 2 collect information about the blocks that are dug during the dig_2x2_square
 - 3 collect information about the blocks that are dug during the dig_and_inspect
 - 4 change inspect_and_dig to return false when no block is mined
 - change the logic in the digging functions to handle false digs and in valid blocks
]]
--[[
	-- WORKING ON --
 - 2 collect information about the blocks that are dug during the dig_2x2_square
 -- have dig return an informative state of the turtle
 -- add a default options tabl to the dig function
 -- change inspect_and_dig function to handle states/options
 -- 4 change inspect_and_dig to return false when no block is mined
 -- moving the block counting to the lower level dig functions
 -- merging options and state into a higher lever context tabl

]]

local function flip_horizontal_direction(direction)
	return direction == "left" and "right" or "left"
end

--[[
	--@param direction_to_mine string
	---@param state turtle_state
	---@param options dig_options
]]
-------------------------------------------------------------------------------------------------------------------------------------------------------
local function dig_2x2_square(direction_to_mine, context) --> boolean, turtle_state
	if direction_to_mine ~= "left" and direction_to_mine ~= "right" then
		error('invalid direction, expected "left" or "right", got "' .. tostring(direction_to_mine) .. '"', 2)
	end
	-----TABLES-------
	context = context or context_builder.create()
	local state = context.state
	local dig_config = context.dig_config
	-----FUNCTIONS----
	local dig_and_count = tt.inspect_and_dig
	local turn = tt.turn_functions[direction_to_mine]
	local opposite_turn = tt.turn_functions[flip_horizontal_direction(direction_to_mine)]
	------------------
	state.horizontal_position = flip_horizontal_direction(direction_to_mine)
	------------------
	local dug, block_data

	-- 1st block
	dug, block_data = dig_and_count("forward", context)
	if not dug and block_data then	-- found an invalid block
		return false, context
	end

	turn()

	-- 2nd block
	dug, block_data = dig_and_count("forward", context)
	if not dug and block_data then -- found an invalid block
		opposite_turn()
		return false, context
	end

	turtle.forward()
	state.horizontal_position = flip_horizontal_direction(state.horizontal_position)
	opposite_turn()

	-- 3rd block
	dug, block_data = dig_and_count("forward", context)
	if not dug and block_data then	-- found an invalid block
		return false, context
	end

	return true, context
end
function M.dig_2x2_square(direction_to_mine, state, options)
	return dig_2x2_square(direction_to_mine, state, options)
end

--@param options dig_options
--@param state turtle_states
-------------------------------------------------------------------------------------------------------------------------------------------------------
function M.dig(next_hole_direction, context)
	-----TABLES-------
	context = context or context_builder.create()
	local state = context.state
	local dig_config = context.dig_config
	-----FUNCTIONS----	
	local dig = tt.inspect_and_dig
	local dig_square = dig_2x2_square
	------------------
	local mining_direction = next_hole_direction
	state.depth = 0
	------------------
	local success, dug, block_data

	tt.selectEmptySlot()

	while true do
		-- Place torches every 8 blocks
		if dig_config.place_torches and state.depth % 8 == 0 then
			tt.torch()
		end

		-- Clean Invetory every 12 block
		if state.depth % 12 == 0 then
			tt.cleanInventory()
		end
	
------------------------MAIN DIG LOOP-------------------------------------------------
		dug, block_data = dig("down", context)

		if not dug and block_data then
			break
		end

		turtle.down()
		state.depth = ct.inc(state.depth)

		success = dig_square(mining_direction, context)

		if not success then -- an invalid block was found in the square
			break
		end

		mining_direction = flip_horizontal_direction(mining_direction)

	end
--------------------------------------------------------------------------------------------------
	tt.cleanInventory()
	tt.returnToSurface(depth)
	return true, context

end

return M