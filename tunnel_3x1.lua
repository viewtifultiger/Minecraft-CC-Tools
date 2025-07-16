os.loadAPI("codetools.lua")
os.loadAPI("turtletools.lua")
local tt = turtletools
local ct = codetools

-- TO DO --

-- fix handling of bedrock
-- test to see if turtle always come back to starting position
-- check for sand/gravel after digging the block in front

-- NOTES --
-- removed sleep function to test if gravel falling from above non
    -- gravel block that was mined in front is the real problem.
-- turtle might not being going to full depth when a non-gravel
    -- block is broken but there is a gravel above that blocks it from
    -- moving forward properly, hence skipping a depth.

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
        -- keeps mining until no block is inspected
            -- (prevents falling blocks from preventing movement)
        while block == true do
            turtle.dig()
            block, data = turtle.inspect()
        end

        turtle.forward()
        turtle.digUp()
        turtle.digDown()
        currentDepth = ct.inc(currentDepth)
    end
    return currentDepth -- might need this when an invalid block
                            -- is found (bedrock or other)
end