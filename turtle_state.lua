local M = {}

function M.create_state()
    return {
        position = { x = 0, y = 0, z = 0},
        facing = "north",
        fuel = 0,
        stats = {
            blocks_mined = 0,
            moves = 0,
        },
        next_hole_direction = "left",
    }
end

return M