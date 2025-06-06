os.loadAPI("codetools.lua")
os.loadAPI("turtletools.lua")
local tt = turtletools
local ct = codetools

-- TO DO --

-- fix handling of bedrock
-- dig setting for placing torches
-- dig setting for clearing inventory

function dig(fuel, placeTorches)
    local placeTorches = placeTorches or false
    halfFuel = math.floor(fuel / 2)
    depth = 0

    turtle.digUp()
    turtle.digDown()
    for moves = 1,halfFuel do
        -- Torches
        if placeTorches and moves % 8 == 0 then
            placeTorches = tt.torchDown()
        end
        -- Clean Inventory
        if moves % 16 == 0 then
            tt.cleanInventory()
        end
        block, tabl = turtle.inspect()
        if block == true then
            if tabl.name == "minecraft:gravel" then
                repeat
                    turtle.dig()
                    _, tabl = turtle.inspect()
                until tabl.name ~= "minecraft:gravel"
            else
                turtle.dig()
            end
        end
        turtle.forward()
        turtle.digUp()
        turtle.digDown()
        depth = ct.inc(depth)
    end
    return depth
end

