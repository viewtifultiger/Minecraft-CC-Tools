os.loadAPI("tunnel_3x1.lua")
os.loadAPI("codetools.lua")
os.loadAPI("turtletools.lua")
local tunnel = tunnel_3x1
local ct = codetools
local tt = turtletools

-- settings
local placeTorches = ct.verifyTorchDownSetting(false)

-- TO DO --
-- have tt.digUTurn functions check blocks (especially gravel)
-- handle finding bedrock
-- make code more efficient
-- find a way to dig tunnel going left rather than to the right
-- investigate two incomplete stacks found in 2 different slots
	-- refer to notes

-- NOTES --
-- Thinking of reworking the tunnel_3x1 loop to generalize 3byX 
	-- tunnel sizes
-- Source of the incomplete stacks in turtle inventory is produced 
	-- because turtle stores items in the first empty space rather
	-- then where the incomplete stack of the item is located. 

local startingFuel = turtle.getFuelLevel()
print("Fuel Level:", startingFuel)
print("Enter Distance: ")
local distance = tonumber(io.read())
print("Enter number of iterations: ")
local iterations = tonumber(io.read())
-- + 2 accounts for 2 extra movements made to repeat tunnels (separated for readability)
local fuelCost = ((distance * 2) + 2) * iterations

if not ct.hasFuelExpense(fuelCost) then
	error("Cannot run dig_3x2_tunnel because there is not enough fuel")
end

for i=1, iterations do
	turtle.select(1)
	tunnel.dig(distance, placeTorches)

	tt.digUTurnRight()

	tunnel.dig(distance)

	tt.digUTurnLeft()

	placeTorches = false
end

print("Complete!")
print("Fuel Remaining:", turtle.getFuelLevel())
print("Total Fuel Used:", startingFuel - turtle.getFuelLevel())