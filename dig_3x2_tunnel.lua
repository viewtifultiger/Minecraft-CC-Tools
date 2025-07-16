os.loadAPI("tunnel_3x1.lua")
os.loadAPI("codetools.lua")
local tunnel = tunnel_3x1
local ct = codetools

-- settings
local placeTorches = ct.verifyTorchDownSetting(false)

-- TO DO --
-- handle finding bedrock during first half
-- make it continuously loop
-- make code more efficient
-- make hasFuelExpense() return a bool
-- separate asking fuel cost from fuel comparison from hasFuelExpense()
-- change fuel expense prompt to dig distance
-- find a way to dig tunnel going left rather than to the right
-- investigate two incomplete stacks found in 2 different slots
	-- after cobble was in slot 1 and it was discarded, coal was mined,
	-- which was previously sloted elsewhere, was stashed in slot 1, therefore
	-- separating the stacks. However, previous observations showed duplicated
	-- incomplete stacks found elsewhere other than slot 1. 

local startingFuel = turtle.getFuelLevel()
print("Fuel Level:", startingFuel)
print("Enter distance: ")
local distance = tonumber(io.read())
local fuelCost = (distance * 2) + 1

if not ct.hasFuelExpense(fuelCost) then
	error("Cannot run dig_3x2_tunnel because there is not enough fuel")
end

turtle.select(1)
tunnel.dig(distance, placeTorches)

turtle.turnRight()
turtle.dig()
turtle.forward() -- +1 fuel cost
turtle.turnRight()

tunnel.dig(distance)

print("Complete!")
print("Fuel Remaining:", turtle.getFuelLevel())
print("Total Fuel Used:", startingFuel - turtle.getFuelLevel())