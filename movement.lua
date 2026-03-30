
M = {}

local move_functions = {
    forward = turtle.forward,
    back = turtle.back,
    up = turtle.up,
    down = turtle.down,
}

--[[
    NOTES:
        -- When the turtle moves:
            -- changes state.position by 1 (x, y, or z)
            -- changes state.fuel by 1 **********************
            --------------------------------
            -- changes stats.total_moves *******************************8

        
        when it comes to x and y position changes, it all depends on which direction the turtle is facing:
        -- North (back)   : + Z --
        -- North (forward): - Z --
        -- South (forward): + Z --
        -- South (back)   : - Z --
        -- West  (back)   : + X
        -- West  (forward): - X
        -- East  (forward): + X --
        -- East  (back)   : - X --

            -- Y IS UP/DOWN ( for some reason why is the 3d plane all messed up?)

            WARNING: WE NEED TO GUARANTEE THAT DIRECTION IS VALID 
            WE NEED TO GUARANTEE THAT THE STATE.FACING IS VALID
]]

function M.move(direction, state)
    local move = move_functions[direction]

    state.fuel = state.fuel + 1
    state.total_moves = state.stats.total_moves + 1

    if move == turtle.up or move == turtle.down then
        state.position['y'] = state.position['y'] + ((move == turtle.up) and 1 or -1)
    elseif move == turtle.forward or move == turtle.back then
        if state.facing == "north" then
            state.position['z'] = state.position['z'] + ((move == turtle.forward) and -1 or 1)
        elseif state.facing == "east" then
            state.position['x'] = state.position['x'] + ((move == turtle.forward) and 1 or -1)
        elseif state.facing == "south" then
            state.position['z'] = state.position['z'] + ((move == turtle.forward) and 1 or -1)
        elseif state.facing == "west" then
            state.position['x'] = state.position['x'] + ((move == turtle.forward) and -1 or 1)
        else
            error("invalid facing state: " .. '"' .. tostring(state.facing) .. '"', 2)
        end
    else
        error("invalid direction: " .. '"' ..tostring(direction) .. '"', 2)
    end

    move()

end


return M