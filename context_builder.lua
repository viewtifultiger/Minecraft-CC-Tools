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
]]
local function basic_structure_checker(context, level)
	if type(context.state) ~= "table" then
		error('missing context.state; "' .. tostring(context.state) .. '" is not a table', level or 2)
	end
	if type(context.dig_config) ~= "table" then
		error('missing context.dig_config; "' .. tostring(context.dig_config) .. '" is not a table', level or 2)
	end
end
--------------------STATE----------------------------------------------------
local function state_checker(context, level)
	if type(context.state) ~= "table" then
		error('missing context.state; "' .. tostring(context.state) .. '" is not a table', level or 2)
	end
end
local function facing_checker(context, level)
    local facing = context.state.facing
    if type(facing) ~= "string" then
        error('context missing state.facing; "' .. tostring(facing) .. '" is not a string', level or 2)
    end
end
local function fuel_checker(context, level)
    local fuel = context.state.fuel
    if type(fuel) ~= "number" then
        error('context missing state.fuel; "' .. tostring(fuel) .. '" is not a number', level or 2)
    end
end
local function depth_checker(context, level)
    local depth = context.state.depth
    if type(depth) ~= "number" then
        error('context missing state.depth; "' .. tostring(depth) .. '" is not a number', level or 2)
    end
end
local function position_checker(context, level)
    local position = context.state.position
    if type(position) ~= "table" then
        error('context missing state.position; "' .. tostring(position) .. '" is not a table', level or 2)
    end
end
local function position_x_checker(context, level)
    local position = context.state.position.x
    if type(position) ~= "number" then
        error('invalid  state.position.x; "' .. tostring(position) .. '" is not a number', level or 2)
    end
end
local function position_y_checker(context, level)
    local position = context.state.position.y
    if type(position) ~= "number" then
        error('invalid  state.position.y; "' .. tostring(position) .. '" is not a number', level or 2)
    end
end
local function position_z_checker(context, level)
    local position = context.state.position.z
    if type(position) ~= "number" then
        error('invalid  state.position.z; "' .. tostring(position) .. '" is not a number', level or 2)
    end
end
local function stats_checker(context, level)
    local stats = context.state.stats
    if type(stats) ~= "table" then
        error('context missing state.stats; "' .. tostring(stats) .. '" is not a table', level or 2)
    end
end
local function total_moves_checker(context, level)
    local total_moves = context.state.stats.total_moves
    if type(total_moves) ~= "number" then
        error('state missing stats.total_moves; "' .. tostring(total_moves) .. '" is not a number', level or 2)
    end
end
-------------------DIG_CONFIG-------------------------------------------------
local function dig_config_checker(context, level)
	if type(context.dig_config) ~= "table" then
		error('missing context.dig_config; "' .. tostring(context.dig_config) .. '" is not a table', level or 2)
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
    ["state"] = state_checker,
    ["facing"]= facing_checker,
    ["fuel"] = fuel_checker,
    ["depth"] = depth_checker,
    ["position"] = position_checker,
    ["position_x"] = position_x_checker,
    ["position_y"] = position_y_checker,
    ["position_z"] = position_z_checker,
    ["stats"] = stats_checker,
    ["total_moves"] = total_moves_checker,
    ["blocks_mined"] = blocks_mined_checker,
    ["blocks_mined_by_name"] = blocks_mined_by_name_checker,
    ["dig_config"] = dig_config_checker,
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
