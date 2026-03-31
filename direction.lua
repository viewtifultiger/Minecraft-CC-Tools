
M = {}

M.FACINGS = {
    NORTH = "north",
    EAST = "east",
    SOUTH = "south",
    WEST = "west"
}

M.DIRECTIONS = {
    FORWARD = "forward",
    BACK = "back",
    UP = "up",
    DOWN = "down"
}

M.VALID_FACINGS = {
    north = true,
    east = true,
    south = true,
    west = true
}

M.VALID_DIRECTIONS = {
    forward = true,
    back = true,
    up = true,
    down = true
}

M.VECTORS = {
    north = {x = 0, z = -1},
    east = {x = 1, z = 0},
    south = {x = 0, z = 1},
    west = {x = -1, z = 0},
    up = {y = 1},
    down = {y = -1}
}


return M