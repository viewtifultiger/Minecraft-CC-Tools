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

--[[
    NOTES:
        we don't entirely validate the base context within context_checker. Sometimes we only want to validate a particular set of keys. We might
        want to split the context_checker into smaller functions for each key check. We can then create custom checkers depending on what is
        needed, such as a base checker or a state, state.stats, state.stats.blocks_mined_by_name and so on. 
        checking everything at once would be unecessary
]]


local function basic_structure_checker(context, level)
	if type(context.state) ~= "table" then
		error('missing context.state; "' .. tostring(context.state) .. '" is not a table', level or 2)
	end
	if type(context.dig_config) ~= "table" then
		error('missing context.dig_config; "' .. tostring(context.dig_config) .. '" is not a table', level or 2)
	end
end
local function dig_config_checker(context, level)
	if type(context.dig_config) ~= "table" then
		error('missing context.dig_config; "' .. tostring(context.dig_config) .. '" is not a table', level or 2)
	end
end
local function stats_checker(context, level)
    local stats = context.state.stats
    if type(stats) ~= "table" then
        error('context missing state.stats; "' .. tostring(stats) .. '" is not a table', level or 2)
    end
end
local function blocks_mined_checker(context, level)
    local blocks_mined = context.state.stats.blocks_mined
    if type(blocks_mined) ~= "number" then
        error('context missing stats.blocks_mined; "' .. tostring(blocks_mined) .. '" is not a number', level or 2)
    end
end
local function blocks_mined_by_name_checker(context, level)
    local blocks_mined_by_name = context.state.stats.blocks_mined_by_name
    if type(blocks_mined_by_name) ~= "table" then
        error('context missing stats.blocks_mined_by_name; "' .. tostring(blocks_mined_by_name) .. '" is not a table', level or 2)
    end
end
local function blacklist_checker(tabl, level)
    local context_blacklist = tabl.dig_config.blacklist
    if type(context_blacklist) ~= "table" then
        error('context missing dig_config.blacklist; "' .. tostring(context_blacklist) .. '" is not a table', level or 2 )
    end
end

local CHECKS = {
    ["basic_structure"] = basic_structure_checker,
    ["dig_config"] = dig_config_checker,
    ["stats"] = stats_checker,
    ["blocks_mined"] = blocks_mined_checker,
    ["blocks_mined_by_name"] = blocks_mined_by_name_checker,
    ["blacklist"] = blacklist_checker
}
function M.run_checks(context, checks, level)
    if type(context) ~= "table" then
        error("expected context table; received " .. '"' .. tostring(context) .. '"', level or 2)
    end
    for i = 1, #checks do
        local name = checks[i]
        if type(name) ~= "string" then
            error('check names but be strings; received "' .. name .. '"', level or 2)
        end

        local check = CHECKS[name]

        if not check then
            error('unknown context check: "' .. name .. '"', level or 2)
        end
        check(context, (level + 1) or 3)
    end
end

return M