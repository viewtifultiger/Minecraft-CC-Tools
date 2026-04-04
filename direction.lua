
local M = {}

M.FACINGS = {
    NORTH = "north",
    EAST = "east",
    SOUTH = "south",
    WEST = "west"
}
M.VALID_FACINGS = {
    north = true,
    east = true,
    south = true,
    west = true
}
M.DIRECTIONS = {
    FORWARD = "forward",
    BACK = "back",
    UP = "up",
    DOWN = "down"
}
M.VALID_DIRECTIONS = {
    forward = true,
    back = true,
    up = true,
    down = true
}
M.TURN_DIRECTIONS = {
    LEFT = "left",
    RIGHT = "right"
}
M.VALID_TURN_DIRECTIONS = {
    left = true,
    right = true
}
M.VERTICAL_DIRECTIONS = {
    FORWARD = "forward",
    UP = "up",
    DOWN = "down"
}
M.VALID_VERTICAL_DIRECTIONS = {
    forward = true,
    up = true,
    down = true
}
M.LEFT_TURN = {
    north = "west",
    west = "south",
    south = "east",
    east = "north"
}
M.RIGHT_TURN = {
    north = "east",
    east = "south",
    south = "west",
    west = "north"
}
M.VECTORS = {
    north = {x = 0, z = -1},
    east = {x = 1, z = 0},
    south = {x = 0, z = 1},
    west = {x = -1, z = 0},
    up = {y = 1},
    down = {y = -1}
}

function M.vertical_direction_checker(direction, level)
    if not M.VALID_VERTICAL_DIRECTIONS[direction] then
        error('invalid dig direction, expected "forward", "up", or "down"; received "' .. tostring(direction) .. '"', level or 2)
    end
end
function M.turn_direction_checker(direction, level)
    if not M.VALID_TURN_DIRECTIONS[direction] then
        error('invalid turn direction, expected "left" or "right"; received "' .. tostring(direction) .. '"', level or 2)
    end
end

return M