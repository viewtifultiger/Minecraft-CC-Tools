local M = {}

function M.create()
    return {
	["place_torches"] = false,
	blacklist = {
		["minecraft:bedrock"] = true,
	}
}
end

return M