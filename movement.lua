local context_builder = require("context_builder")
local direct = require("direction")

M = {}

local move_functions = {
    forward = turtle.forward,
    back = turtle.back,
    up = turtle.up,
    down = turtle.down,
}
local turn_functions = {
    left = turtle.turnLeft,
    right = turtle.turnRight
}

--[[
    NOTES:
        -- When the turtle moves:
            -- changes state.position by 1 (x, y, or z)
            -- reduce state.fuel by 1
            -- depth (up or down movement)
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
    local movement = move_functions[direction]
    local position = state.position
    local vectors = direct.VECTORS
    local directions = direct.MOVEMENT_DIRECTIONS
    local success, reason = movement()

    if not success then
        return false, reason
    elseif direction == directions.UP or direction == directions.DOWN then
        position.y = position.y + vectors[direction].y
        state.depth = state.depth + (-1 * vectors[direction].y)
    else
        position.x = position.x + (direction == directions.FORWARD and vectors[state.facing].x or -1 * (vectors[state.facing].x))
        position.z = position.z + (direction == directions.FORWARD and vectors[state.facing].z or -1 * (vectors[state.facing].z))
    end

    state.fuel = state.fuel - 1
    state.stats.total_moves = state.stats.total_moves + 1
    return true, nil
end

function M.move(direction, context)
    direct.validate_movement_direction(direction, 3)
    context_builder.run_checks(context, {"state", "facing", "fuel", "depth", "position", "position_x",
                                        "position_y", "position_z", "stats", "total_moves"}, 3)
    direct.validate_facing(context.state.facing, 3)
    return move(direction, context.state)
end
function M.forward(context)
    return M.move(direct.MOVEMENT_DIRECTIONS.FORWARD, context)
end
function M.back(context)
    return M.move(direct.MOVEMENT_DIRECTIONS.BACK, context)
end
function M.up(context)
    return M.move(direct.MOVEMENT_DIRECTIONS.UP, context)
end
function M.down(context)
    return M.move(direct.MOVEMENT_DIRECTIONS.DOWN, context)
end
----------------------------------------------TURNING------------------------------------------------------------------------------------------------
--[[
-- When turtle turns:
    -- change state.facing direction
]]
local function turn(direction, state) --> boolean Whether the turtle could succesfully turn, string | nil The reason the turtle could not turn
    local success, reason = turn_functions[direction]()
    if not success then
        return false, reason
    else
        state.facing =
        ((direction == direct.TURN_DIRECTIONS.LEFT) and direct.LEFT_TURN[state.facing]) or direct.RIGHT_TURN[state.facing]
    end
    return true, nil
end
function M.turn(direction, context)
    direct.validate_turn_direction(direction)
    context_builder.run_checks(context, {"state", "facing"}, 3)
    return turn(direction, context.state)
end
function M.turn_opposite(direction, context)
    return M.turn((direction == "left" and "right" or "left"), context.state)
end
function M.turnLeft(context)
    return M.turn(direct.TURN_DIRECTIONS.LEFT, context)
end
function M.turnRight(context)
    return M.turn(direct.TURN_DIRECTIONS.RIGHT, context)
end

return M