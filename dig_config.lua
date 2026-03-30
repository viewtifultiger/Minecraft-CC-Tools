local DEFAULT_BLACKLIST = require("_black_list_blocks")

local M = {}

function M.create()
    return {
		["place_torches"] = false,
		blacklist = DEFAULT_BLACKLIST,
	}
end

return M