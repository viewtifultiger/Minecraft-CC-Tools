os.loadAPI("tunnel_3x1.lua")
os.loadAPI("codetools.lua")
local tunnel = tunnel_3x1
local ct = codetools

-- settings
local placeTorches = ct.verifyTorchDownSetting(false)
if placeTorches then
	print("\nplaceTorches: ON")
else
	print("\nplaceTorches: OFF")
end
-- TO DO --
-- handle finding bedrock during first half
-- make it continuously loop
-- place dig settings into a different file (rename files)

startingFuel, fuelCost = ct.hasFuelExpense()

if startingFuel == nil and fuelCost == nil then
	return
elseif fuelCost % 2 == 0 then
	fuelCost = ct.dec(fuelCost)
end

turtle.select(1)
local depth = tunnel.dig(fuelCost, placeTorches)

turtle.turnRight()
turtle.dig()
turtle.forward() -- +1 fuel cost
turtle.turnRight()

local fuelCurrentlyExpended = startingFuel - turtle.getFuelLevel()

if fuelCurrentlyExpended ~= (math.floor(fuelCost/2) + 1) then
	tunnel.dig((fuelCurrentlyExpended-1) * 2)
else
	tunnel.dig(fuelCost)
end

print("Complete!")
print("Fuel Remaining:", turtle.getFuelLevel())
print("Total Fuel Used:", startingFuel - turtle.getFuelLevel())