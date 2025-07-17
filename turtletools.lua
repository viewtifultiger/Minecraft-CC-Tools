local M = {}

-- PRIVATE FUNCTIONS --

-- direction: place - turtle place direction
local function _placeTorch(place) --> bool : torch placed
	selected = selectItem("torch")
	if not selected then
		return selected
	end
	place()
	return selected
end

-- END OF PRIVATE FUNCTIONS --

-- FUNCTIONS --
function M.forward(int)
	for i=1,int do turtle.forward() end
end

function M.selectItem(item)
	for slot=1,16 do
		local selectedItem = turtle.getItemDetail(slot)

		if selectedItem ~= nil and selectedItem.name == "minecraft:".. item then
			turtle.select(slot)
			return true
		end
	end
	return false
end


-- DIG FUNCTIONS --

-- TO DO --
-- make sure dig() can handle bedrock
function M.dig()
	block, tabl = turtle.inspect()
    while block == true do
        turtle.dig()
        block, data = turtle.inspect()
    end	
end
function M.compareAndDig(blockAvoiding)
	_, data = turtle.inspect()
	if data.name ~= blockAvoiding then
		turtle.dig()
		return true
	else
		return false
	end
end
function M.digUTurnRight()
	turtle.turnRight()
	turtle.dig()
	turtle.forward()
	turtle.turtRight()
end
function M.digUTurnLeft()
	turtle.turnLeft()
	turtle.dig()
	turtle.forward()
	turtle.turnLeft()
end

-- TORCH FUNCTIONS --> bool - if torch was avaiable and placed
function M.torch()
	return _placeTorch(turtle.place)
end
function M.torchUp()
	return _placeTorch(turtle.placeUp)
end
function M.torchDown()
	return _placeTorch(turtle.placeDown)
end



function M.cleanInventory(overrides)
	local discardList = dofile("_config_cleanInventory.lua")
	-- table: name, count
	if overrides ~= nil then	
		for key, value in pairs(overrides) do
			discardList[key] = value
		end
	end

	for slot=1,16 do
		local item = turtle.getItemDetail(slot)
		if item ~= nil and discardList[item.name] then
			turtle.select(slot)
			turtle.drop()
		end
	end
	for slot=1, 16 do
		local item = turtle.getItemDetail(slot)
		if item ~= nil then
			turtle.select(slot)
			break
		else
			turtle.select(1)
		end
	end
end

function M.returnToSurface(depth)
	for i=1,depth do
		turtle.up()
	end
end

if not pcall(debug.getlocal, 4, 1) then
	print("Running turtletools.lua")
end

return M
