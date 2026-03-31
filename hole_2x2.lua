local tt = require("turtletools")
local context_builder = require("context_builder")
local movement = require("movement")
local DIG_REASONS = tt.DIG_REASONS

local M = {}

--[[
	Notes:
]]

--[[TO DO --
-- 1 find an algorithm to "clean up" after finding all blocks to be invalid (mine blocks not checked)
]]
--[[
	-- WORKING ON --
	
]]
---------------------------------------------------------------------
local STOP_REASONS = {
	[DIG_REASONS.BLACKLISTED] = true,
	[DIG_REASONS.DIG_FAILED] = true
}
---------------------------------------------------------------------
local function flip_horizontal_direction(direction)
	return direction == "left" and "right" or "left"
end
--[[
	--@param direction_to_mine string "left" | "right"
	---@param context context_builder
]]
-------------------------------------------------------------------------------------------------------------------------------------------------------
local function dig_2x2_square(start_mining_towards, context) --> boolean, turtle_state; state changes: horizontal_position, blocks_mined, blocks_mined_by_name
	if start_mining_towards ~= "left" and start_mining_towards ~= "right" then
		error('invalid direction, expected "left" or "right", got "' .. tostring(start_mining_towards) .. '"', 2)
	end
	-------------TABLES----------------------------------------------------------------------------
	context = context or context_builder.create()
	local state = context.state
	local dig_config = context.dig_config
	local blacklist = dig_config.blacklist
	------------FUNCTIONS--------------------------------------------------------------------------
	local try_dig = tt.try_dig
	local turn = tt.turn_functions[start_mining_towards]
	local opposite_turn = tt.turn_functions[flip_horizontal_direction(start_mining_towards)]
	--------CONTEXT-ASSIGNMENT---------------------------------------------------------------------
	state.horizontal_position = flip_horizontal_direction(start_mining_towards)
	-------------LOCALS----------------------------------------------------------------------------
	local dug, block_data, reason
	-----------------------------------------------------------------------------------------------
	
	dug, block_data, reason = try_dig("forward", context)
	if STOP_REASONS[reason] then	-- found an invalid block
		return false, context, reason
	end

	turn()

	dug, block_data, reason = try_dig("forward", context)
	if STOP_REASONS[reason] then	-- found an invalid block
		opposite_turn()
		return false, context, reason
	end

	-- horizontal movement
	movement.move("forward", context)
	state.horizontal_position = flip_horizontal_direction(state.horizontal_position)
	opposite_turn()

	dug, block_data, reason = try_dig("forward", context)
	if STOP_REASONS[reason] then	-- found an invalid block
		return false, context, reason
	end

	return true, context, reason
end
function M.dig_2x2_square(start_mining_towards, context)
	return dig_2x2_square(start_mining_towards, context)
end

--@param options dig_options
--@param state turtle_states
-------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------

function M.dig_hole_down(start_mining_towards, context) --> success boolean; context context_builder
	-------------TABLES----------------------------------------------------------------------------
	context = context or context_builder.create()
	local state = context.state
	local dig_config = context.dig_config
	------------FUNCTIONS--------------------------------------------------------------------------
	local try_dig = tt.try_dig
	local dig_square = dig_2x2_square
	--------CONTEXT-ASSIGNMENT---------------------------------------------------------------------
	state.depth = 0
	-------------LOCALS----------------------------------------------------------------------------
	local success, dug, block_data, reason
	-----------------------------------------------------------------------------------------------

	tt.selectEmptySlot()

	while true do
		-----------------------SETTINGS-HANDLING---------------------------------------------------
		if dig_config.place_torches and state.depth % 8 == 0 then
			tt.torch()
		end
		if state.depth % 12 == 0 then
			tt.cleanInventory()
		end
		------------------------MAIN DIG LOOP------------------------------------------------------
		dug, block_data, reason = try_dig("down", context)
		if STOP_REASONS[reason] then
			break
		end

		movement.move("down", context)
		state.depth = state.depth + 1

		success, _, reason = dig_square(start_mining_towards, context)
		if STOP_REASONS[reason] then
			break
		end

		start_mining_towards = flip_horizontal_direction(start_mining_towards)
		-------------------------------------------------------------------------------------------
	end
	tt.cleanInventory()
	tt.returnToSurface(state.depth)
	return true, context
end

return M