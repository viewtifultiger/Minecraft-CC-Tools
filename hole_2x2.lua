local ct = require("codetools")
local tt = require("turtletools")
local turtle_states = require("turtle_states")
local dig_options = require("dig_options")
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
]]
--[[
	-- WORKING ON --
 - 2 collect information about the blocks that are dug during the dig_2x2_square
 -- have dig_2x2_square return an informative state of the turtle
 -- merging the horizontal position into the state when returning from the dig_2x2_square
 -- remove the direction parameter and use the state and options.
 -- add a default options tabl

]]
local function record_mined_block(state, block_name)
		state.stats.blocks_mined_by_name[block_name] = (state.stats.blocks_mined_by_name[block_name] or 0) + 1
end
local function flip_horizontal_direction(direction)
	return direction == "left" and "right" or "left"
end

local function dig_2x2_square(direction_to_mine, state, options) -- direction_to_mine: string
	-----TABLES-------
	state = state or turtle_states.create_state()
	options = options or dig_options.create_dig_option()
	-----FUNCTIONS----
	local dig = tt.inspect_and_dig
	local turn = tt.turn_functions[direction_to_mine]
	local opposite_turn = tt.turn_functions[flip_horizontal_direction(direction_to_mine)]
	-------------------
	state.horizontal_position = flip_horizontal_direction(direction_to_mine)


	local dug, block_data

	-- 1st block
	dug, block_data = dig("forward", options.blacklist) 
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

--@param next_hole_direction string: determines the direction of the next hole
--@param placeTorches boolean: determines whether the turtle should place torches 
-------------------------------------------------------------------------------------------------------------------------------------------------------
function M.dig(options, state)
	options = options or {}
	state = state or turtle_state.create_state()
	local valid, tabl -- valid_block: bool; tabl: table block data
	local mining_direction = options.next_hole_direction
	local horizontal_position = mining_direction == "left" and "right" or "left" -- turtle starts at the opposite end of where it intends to mine
	local dig = tt.inspect_and_dig
	local dig_square = dig_2x2_square
	local depth = 0

	tt.selectEmptySlot()

	while true do
		-- Place torches every 8 blocks
		if options.place_torches and depth % 8 == 0 then
			tt.torch()
		end

		-- Clean Invetory every 12 block
		if depth % 12 == 0 then
			tt.cleanInventory()
		end
	
------------------------MAIN DIG LOOP-------------------------------------------------
		valid, tabl = dig("down", DEFAULT_BLACKLIST)

		if not valid then
			break
		end

		turtle.down()
		depth = ct.inc(depth)

		valid, horizontal_position = dig_square(mining_direction)

		if not valid then
			break
		end

		mining_direction = mining_direction == "left" and "right" or "left"

	end
--------------------------------------------------------------------------------------------------
	tt.cleanInventory()
	tt.returnToSurface(depth)
	return horizontal_position

end

return M