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
-- change fuel expense prompt to dig depth

local startingFuel = turtle.getFuelLevel()
print("Fuel Level:", startingFuel)
print("Enter Depth: ")
local depth = tonumber(io.read())
local fuelCost = (depth * 2) + 1

if not ct.hasFuelExpense(fuelCost) then
	error("Cannot run dig_3x2_tunnel because there is not enough fuel")

turtle.select(1)
tunnel.dig(depth, placeTorches)

turtle.turnRight()
turtle.dig()
turtle.forward() -- +1 fuel cost
turtle.turnRight()

tunnel.dig(depth)

print("Complete!")
print("Fuel Remaining:", turtle.getFuelLevel())
print("Total Fuel Used:", startingFuel - turtle.getFuelLevel())