os.loadAPI("codetools.lua")
local ct = codetools

-- Fuel check
if ct.hasEnoughFuel(600) == false then
    return
end

-- Dig Down
depth = 0
-- if block == false then
--     print("no block")
-- ende
while true do
    block, tabl = turtle.inspectDown()
    if block == true then
        if tabl.name ~= "minecraft:bedrock" then
            turtle.digDown()
        else
            print("mmmhm, it's pretty deep...")
            break
        end
    end
    turtle.down()
    depth = ct.inc(depth)
end

-- Return to surface
for moves = 1,depth do
    turtle.up()
end

-- Summary
print("Depth:", depth)
print("Fuel Level:", turtle.getFuelLevel())

turtle.refuel()


-- print(textutils.serialize(tabl)) 



