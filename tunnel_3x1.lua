os.loadAPI("codetools.lua")
os.loadAPI("turtletools.lua")
local tt = turtletools
local ct = codetools

-- TO DO --

-- fix handling of bedrock
-- test to see if turtle always come back to starting position

function dig(depth, placeTorches)
    local placeTorches = placeTorches or false
    local currentDepth = 0

    turtle.digUp()
    turtle.digDown()
    for moves = 1, depth do
        -- Torches
        if placeTorches and moves % 8 == 0 then
            placeTorches = tt.torchDown()
        end
        -- Clean Inventory
        if moves % 16 == 0 then
            tt.cleanInventory()
        end
        block, tabl = turtle.inspect()
        -- Stop to mine gravel
        if block == true then
            if tabl.name == "minecraft:gravel" then
                repeat
                    turtle.dig()
                    sleep(3)
                    _, tabl = turtle.inspect()
                until tabl.name ~= "minecraft:gravel"
            else
                turtle.dig()
            end
        end
        turtle.forward()
        turtle.digUp()
        turtle.digDown()
        currentDepth = ct.inc(currentDepth)
    end
    return currentDepth -- might need this when an invalid block
                            -- is found (bedrock or other)
end