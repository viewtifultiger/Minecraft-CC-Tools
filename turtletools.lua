--[[
- Allow isInFront() to accept a table
]]
local DEFAULT_BLACKLIST = require("_block_list_blocks")
local turtle_states = require("turtle_states")

local M = {}

-- LOCAL FUNCTIONS --

-- BASICS--
-----------------------------------------------------------------------------
M.turn_functions = {
	left = turtle.turnLeft,
	right = turtle.turnRight,
}
-----------------------------------------------------------------------------
M.inspect_functions = {
	forward = turtle.inspect,
	up = turtle.inspectUp,
	down = turtle.inspectDown
}
-----------------------------------------------------------------------------
M.dig_functions = {
	forward = turtle.dig,
	up = turtle.digUp,
	down = turtle.digDown
}
-----------------------------------------------------------------------------

local function record_mined_block(state, block_name)
		state.stats.blocks_mined_by_name[block_name] = (state.stats.blocks_mined_by_name[block_name] or 0) + 1
end


-----------------------------------------------------------------------------
local function inspect_validity(direction, blacklist) --> bool: is block is valid; table (block data): nil if no block data
	blacklist = blacklist or DEFAULT_BLACKLIST
	local block_present, tabl = M.inspect_functions[direction]()

	if not block_present then
		return true, nil
	end

	return not blacklist[tabl.name], tabl
end

function M.inspect_validity(direction, blacklist)
	return inspect_validity(direction, blacklist)
end
-----------------------------------------------------------------------------
function M.inspect_and_dig(direction, blacklist, state) --> bool: is block is valid; table (block data): nil if no block data
	blacklist = blacklist or DEFAULT_BLACKLIST
	--------------------------
	local block_is_valid, block_data = inspect_validity(direction, blacklist)

	if not block_data then	-- if empty space, skip digging and return true
		return false, block_data
	end

	if block_is_valid then	-- dig if valid block
		M.dig_functions[direction]()
		if state then
			record_mined_block(state, block_data.name)
		end
	end

	return block_is_valid, block_data-- return validity and block data
end
-----------------------------------------------------------------------------

-- direction: place - turtle place direction
local function _placeTorch(place) --> bool : torch placed
	local selected = M.selectItem("torch")
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
function M.back(int)
	for i=1,int do turtle.back() end
end
function M.turn180()
	for i=1,2 do turtle.turnLeft() end
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
function M.selectEmptySlot()
	for slot = 1,16 do
		if turtle.getItemCount(slot) == 0 then
			turtle.select(slot)
			return true
		end
	end
end

-- DIG FUNCTIONS --

-- TO DO --
-- make sure dig() can handle bedrock


function M.repeatDig(block)
	while true do
		local _, data = turtle.inspect()
		if data.name == "minecraft:" .. block then
			turtle.dig()
		else
			return
		end
	end
end
function M.digUTurnRight()
	turtle.turnRight()
	if not M.isInFront("gravel") then
		turtle.dig()
		turtle.forward()
		turtle.turnRight()
	else
		M.repeatDig("gravel")
	end
end
function M.digUTurnLeft()
	turtle.turnLeft()
	if not M.isInFront("gravel") then
		turtle.dig()
		turtle.forward()
		turtle.turnLeft()
		return true
	else
		M.repeatDig("gravel")
	end

	return false
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

-- Check Functions
-- TO DO:
--  


function M.isInFront(block_name)
	block, tabl = turtle.inspect()
	if block then
		if tabl.name == ("minecraft:" .. block_name) then
			return true
		end
	end
	return false
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
