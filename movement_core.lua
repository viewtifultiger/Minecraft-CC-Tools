local direct = require("direction")

---@class MovementCoreModule
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

function M.move(direction, state) --> boolean Whether the turtle could successfully move, string | nil The reason the turtle could not turn
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

function M.turn(direction, state) --> boolean Whether the turtle could succesfully turn, string | nil The reason the turtle could not turn
    local success, reason = turn_functions[direction]()
    if not success then
        return false, reason
    else
        state.facing =
        ((direction == direct.TURN_DIRECTIONS.LEFT) and direct.LEFT_TURN[state.facing]) or direct.RIGHT_TURN[state.facing]
    end
    return true, nil
end

return M