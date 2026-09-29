local tt = require("ghost_tools")
local context_builder = require("context_builder")
local movement = require("ghost.movement")
local direct = require("direction")
local dig_core = require("ghost.dig")
local DIG_REASONS = dig_core.DIG_REASONS

local M = {}
local try_dig = dig_core.try_dig

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
----------------------------------------------------------------------------
--- ASSUMING THESE ARE VALIDATED: start_mining_towards, context, context.state
--- "basic_structure", "stats", "blocks_mined", "blocks_mined_by_name", "blacklist"
------------------------------------------------------------------------------
local function dig_2x2_square(start_mining_towards, context) --> boolean: if square was completed; string: reason why the square failed; table context
	-------------TABLES----------------------------------------------------------------------------
	local state = context.state
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
	movement.forward(context)
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
]]

--@param options dig_options
--@param state turtle_states
-------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------

local function dig_hole_down(start_mining_towards, context) --> success boolean; context context_builder
	-------------TABLES----------------------------------------------------------------------------
	local state = context.state
	local dig_config = context.dig_config
	-------------LOCALS----------------------------------------------------------------------------
	local success, dug, block_data, reason
	-----------------------------------------------------------------------------------------------

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
		movement.down(context)
		success, reason = dig_2x2_square(start_mining_towards, context)
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
	return true, context
end

local function dig_hole_up(start_mining_towards, context, target_y) --> success boolean; context context_builder
	-------------TABLES----------------------------------------------------------------------------
	local state = context.state
	local dig_config = context.dig_config
	-------------LOCALS----------------------------------------------------------------------------
	local success, dug, block_data, reason
	-----------------------------------------------------------------------------------------------
	while state.position.y < target_y do
		-----------------------SETTINGS-HANDLING---------------------------------------------------
		if dig_config.place_torches and state.depth % 8 == 0 then
			tt.torch()
		end
		if state.depth % 12 == 0 then
			tt.cleanInventory()
		end
		------------------------MAIN DIG LOOP------------------------------------------------------
		dug, block_data, reason = try_dig("up", context)
		if STOP_REASONS[reason] then
			break
		end
		movement.up(context)
		success, reason = dig_2x2_square(start_mining_towards, context)
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
	return true, context
end

local function dig_around_bedrock(direction)
	--[[
	1- down
		if bedrock found, turtle has a clear space at its level, so we can go in a circle and mine down
			move to 2, mine down, move to 4 mine down, move to 3 mine down
	2 - forward
		if berock found, turtle still hasnt cleared all blocks on current level.
			try 3 and then 4
	3 - side
		if berock found, turtle needs to clear 4
			move forward and turn and mine 4
	4 - forward
		if bedrock found, the turtle can still check the the next lavel down with no issue
			check down, if the turtle can go down, mine the level below and return once bedrock is found
	]]


	--[[
	1- down
		if bedrock found, turtle has a clear space at its level, so we can go in a circle and mine down
			move to 2, mine down, move to 4 mine down, move to 3 mine down
	]]
	if (direction == "down") then
		for i=1, 3 do
			movement.forward()
			dig_core.down()
			movement.turn_left()
		end
			movement.turn_left()
	--[[
		2 - forward
		if berock found, turtle still hasnt cleared 3 or 4 on current level.
			continue the rest of the square loop
				]]
	elseif (direction == "forward") then
		dig_core.down()
		movement.turn_left()
		dig_core.dig()
		-- if no bedrock
		movement.forward()
		movement.turn_right()
		dig_core.dig()

	end

end

------------------API----------------------------------------------------
function M.dig_2x2_square(start_mining_towards, context)
	direct.validate_turn_direction(start_mining_towards, 3)
	context = context or context_builder.create()
	return dig_2x2_square(start_mining_towards, context)
end
function M.dig_hole_down(start_mining_towards, context)
	direct.validate_turn_direction(start_mining_towards, 3)
	context = context or context_builder.create()
	return dig_hole_down(start_mining_towards, context)
end
function M.dig_hole_up(start_mining_towards, context, target_y)
	direct.validate_turn_direction(start_mining_towards, 3)
	context = context or context_builder.create()
	return dig_hole_up(start_mining_towards, context, target_y)
end
function M.dig_around_bedrock(context)
	context = context or context_builder.create()
	return dig_around_bedrock(context)
end

return M