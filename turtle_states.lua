local M = {}

function M.create_state()
    return {
        facing = "north",
        fuel = 0,
        horizontal_position = "right",
        position = { x = 0, y = 0, z = 0},
        inventory = {
            used_slots = 0,
            free_slots = 16,
            items = {}
        },
        stats = {
            holes_dug = 0,
            moves = 0,
            blocks_mined = 0,
            blocks_mined_by_name = {},

        },
    }
end

return M