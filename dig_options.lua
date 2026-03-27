local M = {}

function M.create_dig_option()
    return {

	["place_torches"] = false,

	blacklist = {
		["minecraft:bedrock"] = true,
	}
}
end

return M