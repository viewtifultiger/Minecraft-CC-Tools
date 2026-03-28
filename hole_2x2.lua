local ct = require("codetools")
local tt = require("turtletools")
local turtle_states = require("turtle_states")
local dig_config = require("dig_config")
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
local function record_mined_block(state, block_name)
		state.stats.blocks_mined_by_name[block_name] = (state.stats.blocks_mined_by_name[block_name] or 0) + 1
end
local function flip_horizontal_direction(direction)
	return direction == "left" and "right" or "left"
end

--[[
	--@param direction_to_mine string
	---@param state turtle_state
	---@param options dig_options
]]
local function dig_2x2_square(direction_to_mine, state, options) --> boolean, turtle_state
	-----TABLES-------
	state = state or turtle_states.create_state()
	options = options or dig_options.create_dig_option()
	-----FUNCTIONS----
	local dig = tt.inspect_and_dig
	local turn = tt.turn_functions[direction_to_mine]
	local opposite_turn = tt.turn_functions[flip_horizontal_direction(direction_to_mine)]
	------------------
	state.horizontal_position = flip_horizontal_direction(direction_to_mine)
	------------------
	local dug, block_data

	-- 1st block
	dug, block_data = dig("forward", options.blacklist, state)
	if not dug then
		return false, state
	elseif block_data and block_data.name then
		record_mined_block(state, block_data.name)
	end

	turn()

	-- 2nd block
	dug, block_data = dig("forward", options.blacklist)
	if not dug then
		opposite_turn()
		return false, state
	elseif block_data and block_data.name then
		record_mined_block(state, block_data.name)
	end

	turtle.forward()
	state.horizontal_position = flip_horizontal_direction(state.horizontal_position)
	opposite_turn()

	-- 3rd block
	dug, block_data = dig("forward", options.blacklist)
	if not dug then
		return false, state
	elseif block_data and block_data.name then
		record_mined_block(state, block_data.name)
	end

	return true, state
end
-------------------------------------------------------------------------------------------------------------------------------------------------------
function M.dig_2x2_square(direction_to_mine, state, options)
	return dig_2x2_square(direction_to_mine, state, options)
end

--@param options dig_options
--@param state turtle_states
-------------------------------------------------------------------------------------------------------------------------------------------------------
function M.dig(next_hole_direction, state, options)
	-----TABLES-------
	state = state or turtle_states.create_state()
	options = options or dig_options.create_dig_option()
	-----FUNCTIONS----	
	local dig = tt.inspect_and_dig
	local dig_square = dig_2x2_square
	------------------
	local mining_direction = next_hole_direction
	state.depth = 0
	------------------
	local success, tabl
	

	tt.selectEmptySlot()

	while true do
		-- Place torches every 8 blocks
		if options.place_torches and state.depth % 8 == 0 then
			tt.torch()
		end

		-- Clean Invetory every 12 block
		if state.depth % 12 == 0 then
			tt.cleanInventory()
		end
	
------------------------MAIN DIG LOOP-------------------------------------------------
		success, tabl = dig("down", DEFAULT_BLACKLIST) --WORKING ON MODIFYING INSPECT_AND_DIG

		if not success then
			break
		end

		turtle.down()
		depth = ct.inc(depth)

		success, state = dig_square(mining_direction)

		if not success then
			break
		end

		mining_direction = mining_direction == "left" and "right" or "left"

	end
--------------------------------------------------------------------------------------------------
	tt.cleanInventory()
	tt.returnToSurface(depth)
	return valid, state

end

return M