local context_builder = require("context_builder")
local direct = require("direction")

local M = {}


---------------------------------------------------------------------------------------------------------------------------------------------------------
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
local function inspect_if_blacklisted(direction, blacklist) --> bool: is block is valid; table (block data): nil if no block data
	local block_is_present, block_data = inspect_functions[direction]()
	return blacklist[block_data.name] or false, type(block_data) == "table" and block_data or nil
end
--[[
    ASSUMING THESE ARE VALIDATED: 	"basic_structure", "stats", "blocks_mined", "blocks_mined_by_name", "blacklist"
]]
local function try_dig(direction, context) --> bool: is block is valid; table (block data): nil if no block data; string dig reason of bool
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

----------------PUBLIC-FUNCTIONS-----------------------------------------------------------------------------------------------------------------------
--[[
    vertical_direction string (must be "forward", "up", or "down"): ; context table: context_builder.create() or similar and must have a blacklist
]]
function M.inspect_if_blacklisted(vertical_direction, context) --> --> success boolean: if block present and not blacklisted; table block_data | nil (empty block)
    direct.validate_vertical_direction(vertical_direction, 3)
    context = context or context_builder.create()
    context_builder.run_checks(context, {"dig_config", "blacklist"}, 3)
    return inspect_if_blacklisted(vertical_direction, context.dig_config.blacklist)
end
--[[
    vertical_direction string (must be "forward", "up", or "down"): ; context table: context_builder.create() or similar and must have a blacklist 
        and must have stats
]]
function M.try_dig(vertical_direction, context) --> boolean: if block was dug; table | nil (if empty block); string reason for the returned boolean
    direct.validate_vertical_direction(vertical_direction, 3)
    context = context
    context_builder.run_checks(context, {"basic_structure", "stats", "blocks_mined",
                                            "blocks_mined_by_name", "blacklist"}, 3) --check state, dig_config, blacklist, stats, blocks_mined, blocks_mined by name
    return try_dig(vertical_direction, context)
end

return M