local context_builder = require("context_builder")
local dig_core = require("dig_core")
local direct = require("direction")

local M = {}

----------------PUBLIC-FUNCTIONS-----------------------------------------------------------------------------------------------------------------------
--[[
	vertical_direction string (must be "forward", "up", or "down"): ; context table: context_builder.create() or similar and must have a blacklist
]]
function M.inspect_if_blacklisted(vertical_direction, context) --> --> success boolean: if block present and not blacklisted; table block_data | nil (empty block)
	direct.validate_vertical_direction(vertical_direction, 3)
	context = context or context_builder.create()
	context_builder.run_checks(context, {"dig_config", "blacklist"}, 3)
	return dig_core.inspect_if_blacklisted(vertical_direction, context.dig_config.blacklist)
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
	return dig_core.try_dig(vertical_direction, context)
end
