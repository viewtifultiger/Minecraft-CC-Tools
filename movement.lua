local context_builder = require("context_builder")
local direct = require("direction")
local movement_core = require("movement_core")

---@class MovementModule
M = {}


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
    return movement_core.move(direction, context.state)
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
    return movement_core.turn(direction, context.state)
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