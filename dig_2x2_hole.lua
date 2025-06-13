os.loadAPI("hole_2x2.lua")
os.loadAPI("codetools.lua")
os.loadAPI("turtletools.lua")
local hole = hole_2x2
local ct = codetools
local tt = turtletools

print("Enter your Y level: ")
local y = tonumber(io.read())
print("Enter number of iterations: ")
local iterations = tonumber(io.read())

local max_y = y + 64
local cost = ((max_y * 2) + 1 + max_y) * iterations + (2 * iterations)
-- max_y * 2 -> cost to mine down
-- + 1 -> first dig down
-- + may_y -> cost to return to surface from bedrock
-- * iterations -> number of times to loop
-- + (2 * iterations) max number of moves to move to next section
local startingFuel = turtle.getFuelLevel()

if startingFuel < cost then
	print("You don't have enough fuel")
	return
else
	print("Maximum cost: " .. cost)
end

local placeTorches = ct.verifyTorchDownSetting(false)

-- TO DO --
-- check for bedrock before every dig
-- create a prompt to choose starting left or right
-- make this continuous
-- find a way to determine position once bedrock is found
-- ? create a prompt to get y level to know how much fuel is to be expended

-- if iterations == 1 then
-- 	hole.dig(placeTorches)
-- else
-- 	for i=1,iterations do
-- 		hole.dig(placeTorches)
-- 		-- figure out if turtle end on left or right side
-- 		-- turn right and move forward depending on left or right
-- 		--- turn left and start dig again
-- 	end
-- end

for i=1,iterations do
	local placement = hole.dig(placeTorches)
	turtle.turnRight()
	if placement == "left" then
		tt.forward(2)
	else
		tt.forward(1)
	end
	turtle.turnLeft()
end

turtle.turnLeft()
turtle.turnLeft()
tt.forward(3)

local fuelCurrentlyExpended = startingFuel - turtle.getFuelLevel()
print("Complete!")
print("Fuel Remaining:", turtle.getFuelLevel())
print("Total Fuel Used:", startingFuel - turtle.getFuelLevel())