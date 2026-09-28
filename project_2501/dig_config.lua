local DEFAULT_BLACKLIST = require("data.blacklist_block_list")

local M = {}

function M.create()
    return {
		["place_torches"] = false,
		blacklist = DEFAULT_BLACKLIST,
	}
end

return M