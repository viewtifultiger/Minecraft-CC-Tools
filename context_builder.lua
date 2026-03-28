local turtle_states = require("turtle_states")
local dig_config = require("dig_config")

local M = {}

function M.create(overrides)
    overrides = overrides or {}

    return {
        state = overrides.state or turtle_states.create(),
        dig_config = overrides.options or dig_config.create()
    }
end

return M