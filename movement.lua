local dir = require("direction")

M = {}

local move_functions = {
    forward = turtle.forward,
    back = turtle.back,
    up = turtle.up,
    down = turtle.down,
}
local turn_functions = {
    right = turtle.turnRight,
    left = turtle.turnLeft
}

local function context_checker(context)
    if type(context) ~= "table" then
        error("invalid context: not a table", 3)
    end
end

--[[
    NOTES:
        -- When the turtle moves:
            -- changes state.position by 1 (x, y, or z)
            -- reduce state.fuel by 1
            --------------------------------
            -- changes stats.total_moves  
        x and z position changes
        -- North (back)   : + Z --
        -- North (forward): - Z --
        -- South (forward): + Z --
        -- South (back)   : - Z --
        -- West  (back)   : + X
        -- West  (forward): - X
        -- East  (forward): + X --
        -- East  (back)   : - X --

]]
-----------------------------------------------MOVEMENT----------------------------------------------------------------------------------------------
local function move(direction, state) --> boolean Whether the turtle could successfully move, string | nil The reason the turtle could not turn
    if type(state) ~= "table" then
        error("move: context.state is not a table", 2)
    end
    local movement = move_functions[direction]
    local position = state.position
    local vectors = dir.VECTORS
    local directions = dir.DIRECTIONS

    -- position changes
    if dir.VALID_DIRECTIONS[direction] then
        local success, reason = movement()
        if not success then
            return false, reason
        elseif direction == directions.UP or direction == directions.DOWN then
            position.y = position.y + vectors[direction].y
        elseif dir.VALID_FACINGS[state.facing] then
            position.x = position.x + (direction == directions.FORWARD and vectors[state.facing].x or -1 * (vectors[state.facing].x))
            position.z = position.z + (direction == directions.FORWARD and vectors[state.facing].z or -1 * (vectors[state.facing].z))
        else
            error("invalid context.state.facing: " .. '"' .. tostring(state.facing) .. '"', 2)
        end
    else
        error("invalid direction: " .. '"' .. tostring(direction) .. '"', 2)
    end

    state.fuel = state.fuel - 1
    state.stats.total_moves = state.stats.total_moves + 1
    return true, nil
end

function M.move(direction, context)
    context_checker(context)
    return move(direction, context.state)
end

function M.forward(context)
    context_checker(context)
    return move(dir.DIRECTIONS.FORWARD, context.state)
end

function M.back(context)
    context_checker(context)
    return move(dir.DIRECTIONS.BACK, context.state)
end

function M.up(context)
    context_checker(context)
    return move(dir.DIRECTIONS.UP, context.state)
end

function M.down(context)
    context_checker(context)
    return move(dir.DIRECTIONS.DOWN, context.state)
end
----------------------------------------------TURNING------------------------------------------------------------------------------------------------
--[[
]]
local function turn(direction, state) --> boolean Whether the turtle could succesfully turn, string | nil The reason the turtle could not turn
    --[[
    -- When turtle turns:
        -- change state.facing direction
    ]]
    if dir.VALID_TURN_DIRECTIONS[direction] then
        local success, reason = turn_functions[direction]()
        if not success then
            return false, reason
        elseif dir.VALID_FACINGS[state.facing] then
            state.facing =
            ((direction == dir.TURN_DIRECTIONS.LEFT) and dir.LEFT_TURN[state.facing]) or dir.RIGHT_TURN[state.facing]
        else
            error("invalid state.facing: " .. "'" .. tostring(state.facing) .. '"', 2)
        end
    else
        error("invalid direction: " .. '"' .. tostring(direction) .. '"', 2)
    end
    return true, nil
end
function M.turn(direction, context)
    context_checker(context_checker)
    return turn(direction, context.state)
end
function M.turnLeft(context)
    context_checker(context)
    return turn(dir.TURN_DIRECTIONS.LEFT, context.state)
end
function M.turnRight(context)
    context_checker(context)
    return turn(dir.TURN_DIRECTIONS.RIGHT, context.state)
end


return M