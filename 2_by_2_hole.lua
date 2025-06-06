os.loadAPI("codetools.lua")
local ct = codetools

local switch = true

local block, tabl = turtle.detectDown()
if tabl.name ~= "minecraft:bedrock" then
	turtle.digDown()
	turtle.down()
end

_, tabl = turtle.detectDown()

while tabl.name ~= "minecraft:bedrock" do
	turtle.dig()
	turtle.turnRight()
	turtle.dig()
	turtle.forward()
	turtle.turnLeft()
	turtle.dig()
	turtle.digDown()
	turtle.down()
	turtle.dig()
	turtle.turnLeft()
	turtle.dig()
	turtle.forward()
	turtle.turnRight() 
	_, tabl = turtle.detectDown()
end