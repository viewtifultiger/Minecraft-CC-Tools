local context_builder = require("context_builder")
local direct = require("direction")

---@class MovementModule
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

local function move(direction, state) --> boolean Whether the turtle could successfully move, string | nil The reason the turtle could not turn
    local movement = move_functions[direction]
    local position = state.position
    local vectors = direct.VECTORS
    local directions = direct.MOVEMENT_DIRECTIONS
    local success, reason = movement()

    if success then
        if direction == directions.UP or direction == directions.DOWN then
            position.y = position.y + vectors[direction].y
            state.depth = state.depth + (-1 * vectors[direction].y)
        else
            position.x = position.x + (direction == directions.FORWARD and vectors[state.facing].x or -1 * (vectors[state.facing].x))
            position.z = position.z + (direction == directions.FORWARD and vectors[state.facing].z or -1 * (vectors[state.facing].z))
        end
        state.fuel = state.fuel - 1
        state.stats.total_moves = state.stats.total_moves + 1
    end
    return success, reason
end

local function turn(direction, state) --> boolean Whether the turtle could succesfully turn, string | nil The reason the turtle could not turn
    local success, reason = turn_functions[direction]()
    if success then
        state.facing =
        ((direction == direct.TURN_DIRECTIONS.LEFT) and direct.LEFT_TURN[state.facing]) or direct.RIGHT_TURN[state.facing]
    end
    return success, reason
end

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
function M.move(direction, context)
    direct.validate_movement_direction(direction, 3)
    context_builder.run_checks(context, {"full_movement"}, 3)
    direct.validate_facing_direction(context.state.facing, 3)
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

function M.turn(direction, context)
    direct.validate_turn_direction(direction, 3)
    context_builder.run_checks(context, {"state", "facing"}, 3)
    return turn(direction, context.state)
end
function M.turn_opposite(direction, context)
    direct.validate_turn_direction(direction, 3)
    return M.turn(direct.OPPOSITE_TURN_DIRECTIONS[direction], context)
end
function M.turn_left(context)
    return M.turn(direct.TURN_DIRECTIONS.LEFT, context)
end
function M.turn_right(context)
    return M.turn(direct.TURN_DIRECTIONS.RIGHT, context)
end

return M