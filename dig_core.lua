

local M = {}

local inspect_functions = {
	forward = turtle.inspect,
	up = turtle.inspectUp,
	down = turtle.inspectDown
}
local dig_functions = {
	forward = turtle.dig,
	up = turtle.digUp,
	down = turtle.digDown
}
local DIG_REASONS = {
	DUG = "dug",
	EMPTY = "nothing to dig",
	BLACKLISTED = "block is blacklisted",
	DIG_FAILED = "dig failed",
	LIQUID = "cannot dig liquids",
}
local LIQUID_BLOCKS = {
	["minecraft:water"] = true,
	["minecraft:lava"] = true
}
M.DIG_REASONS = DIG_REASONS

local function record_mined_block(state, block_name)
	local stats = state.stats
	stats.blocks_mined_by_name[block_name] =
		(stats.blocks_mined_by_name[block_name] or 0) + 1
	stats.blocks_mined = stats.blocks_mined + 1

end
-- ASUMING ALL ARGUMENTS ARE PRE-VERIFIED--------------------------------------------------------------------------------------------------------------
function M.inspect_if_blacklisted(direction, blacklist) --> bool: is block is valid; table (block data): nil if no block data
	local block_is_present, block_data = inspect_functions[direction]()
	return blacklist[block_data.name] or false, type(block_data) == "table" and block_data or nil
end
-------------------------------------------------------------------------------------------------------------------------------------------------------

--[[

]]
function M.try_dig(direction, context) --> bool: is block is valid; table (block data): nil if no block data; string dig reason of bool
	local blacklist = context.dig_config.blacklist
	local blacklisted, block_data = M.inspect_if_blacklisted(direction, blacklist) -- CHECK IF PROPERLY USED

	if not blacklisted and block_data then
		if LIQUID_BLOCKS[block_data.name] then
			return false, block_data, DIG_REASONS.LIQUID
		end

		local success, err = dig_functions[direction]()

		if success then -- block is valid, block has data, something was dug
			if context then
				record_mined_block(context.state, block_data.name)
			end
			return true, block_data, DIG_REASONS.DUG
		else
			return false, block_data, DIG_REASONS.DIG_FAILED
		end
	elseif not blacklisted then	-- empty
		return false, nil, DIG_REASONS.EMPTY
	else
		return false, block_data, DIG_REASONS.BLACKLISTED
	end
end

return M