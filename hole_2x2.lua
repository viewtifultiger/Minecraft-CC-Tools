local tt = require("turtletools")
local dig_core = require("dig_core")
local context_builder = require("context_builder")
local movement = require("movement")
local DIG_REASONS = dig_core.DIG_REASONS
local direct = require("direction")

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
---------------------HELPERS------------------------------------------
local STOP_REASONS = {
	[DIG_REASONS.BLACKLISTED] = true,
	[DIG_REASONS.DIG_FAILED] = true
}
local function flip_horizontal_direction(direction)
	return direction == "left" and "right" or "left"
end
--[[
	--@param direction_to_mine string "left" | "right"
	---@param context context_builder
]]
-------------------------------------------------------------------------------------------------------------------------------------------------------
local function dig_2x2_square(start_mining_towards, context) --> boolean, turtle_state; state changes: horizontal_position, blocks_mined, blocks_mined_by_name
	-------------TABLES----------------------------------------------------------------------------
	local state = context.state
	------------FUNCTIONS--------------------------------------------------------------------------
	local try_dig = dig_core.try_dig
	local forward = movement.forward
	--------CONTEXT-ASSIGNMENT---------------------------------------------------------------------
	state.horizontal_position = flip_horizontal_direction(start_mining_towards)
	-------------LOCALS----------------------------------------------------------------------------
	local dug, block_data, reason
	-----------------------------------------------------------------------------------------------
	-- 1st block
	dug, block_data, reason = try_dig("forward", context)
	if not dug and STOP_REASONS[reason] then	-- found an invalid block
		return false, reason, context
	end
	-- 2nd block
	movement.turn(start_mining_towards, context)
	dug, block_data, reason = try_dig("forward", context)
	if not dug and STOP_REASONS[reason] then	-- found an invalid block
		movement.turn_opposite(start_mining_towards, context)
		return false, reason, context
	end
	-- horizontal movement
	forward(context)
	state.horizontal_position = flip_horizontal_direction(state.horizontal_position)
	movement.turn_opposite(start_mining_towards, context)
	-- 3rd block
	dug, block_data, reason = try_dig("forward", context)
	if not dug and STOP_REASONS[reason] then	-- found an invalid block
		return false, reason, context
	end
	return true, nil, context
end

--[[
	WARNING: context_builder.context_blacklist_checker only checks if the blacklist is a table. Proper key and value checks would be necessary
				to warn the user of an improper blacklist. For full customizability.. we may allow this if the user wants to continue. Possibly
				check for a CUSTOM_BLACKLIST = true within the blacklist or permanently append (or advise to append) it for the user if the user 
				agrees to use their current blacklist
]]
function M.dig_2x2_square(start_mining_towards, context)
	direct.turn_direction_checker(start_mining_towards, 3)
	context = context or context_builder.create()
	context_builder.context_checker(context, 3)
	context_builder.context_blacklist_checker(context, 3) --!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!WARNING!!!!!!!!!!!!!!!!!!!!!!!!!!!
	return dig_2x2_square(start_mining_towards, context)
end

--@param options dig_options
--@param state turtle_states
-------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------

local function dig_hole_down(start_mining_towards, context) --> success boolean; context context_builder
	-------------TABLES----------------------------------------------------------------------------
	local state = context.state
	local dig_config = context.dig_config
	------------FUNCTIONS--------------------------------------------------------------------------
	local try_dig = tt.try_dig
	try_dig("up")
	local dig_square = dig_2x2_square
	local down = movement.down
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

		down(context)

		success, reason = dig_square(start_mining_towards, context)
		if STOP_REASONS[reason] then
			break
		end

		start_mining_towards = flip_horizontal_direction(start_mining_towards)
		-------------------------------------------------------------------------------------------
	end

	if reason == DIG_REASONS.DIG_FAILED then
		error("DIGGING FAILED: " .. reason, 2)
		return false, context
	end

	tt.cleanInventory()
	tt.returnToSurface(state.depth, context)
	return true, context
end
function M.dig_hole_down(start_mining_towards, context)
	direct.turn_direction_checker(start_mining_towards, 3)
	context = context or context_builder.create()
	context_builder.context_checker(context, 3)
	context_builder.context_blacklist_checker(context, 3) --!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!WARNING!!!!!!!!!!!!!!!!!!!!!!!!!!!
	return dig_hole_down(start_mining_towards, context)
end

return M