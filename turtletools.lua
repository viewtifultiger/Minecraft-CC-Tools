--[[

]]
local DEFAULT_BLACKLIST = require("_black_list_blocks")

local M = {}

local DIG_REASONS = {
	DUG = "dug",
	EMPTY = "empty",
	BLACKLISTED = "blacklisted",
	DIG_FAILED = "dig failed",
	LIQUID = "liquid",
}
local LIQUID_BLOCKS = {
	["minecraft:water"] = true,
	["minecraft:lava"] = true
}

M.DIG_REASONS = DIG_REASONS

-----------------------------------------------------------------------------
M.turn_functions = {
	left = turtle.turnLeft,
	right = turtle.turnRight,
}
-----------------------------------------------------------------------------
local inspect_functions = {
	forward = turtle.inspect,
	up = turtle.inspectUp,
	down = turtle.inspectDown
}
-----------------------------------------------------------------------------
local dig_functions = {
	forward = turtle.dig,
	up = turtle.digUp,
	down = turtle.digDown
}

----------------LOCAL-FUNCTIONS------------------------------------------------------------------------------------------------------------------------
local function record_mined_block(state, block_name)
	local stats = state.stats
	stats.blocks_mined_by_name[block_name] =
		(stats.blocks_mined_by_name[block_name] or 0) + 1
	stats.blocks_mined = stats.blocks_mined + 1

end

---checks block validity by refering to the blacklist from the context
local function inspect_validity(direction, blacklist) --> bool: is block is valid; table (block data): nil if no block data
	blacklist = blacklist or DEFAULT_BLACKLIST
	local block_is_present, block_data = inspect_functions[direction]()

	return not blacklist[block_data.name], type(block_data) == "table" and block_data or nil
end
----------------MAIN-FUNCTIONS-------------------------------------------------------------------------------------------------------------------------
function M.inspect_validity(direction, blacklist)
	return inspect_validity(direction, blacklist)
end

---checks if block is valid and digs, returns boolean if something was dug, block data regardless of validity (maybe nil), reason for boolean result
function M.try_dig(direction, context) --> bool: is block is valid; table (block data): nil if no block data; string dig reason
	local blacklist = context
		and context.dig_config
		and context.dig_config.blacklist
	local block_not_blacklisted, block_data = inspect_validity(direction, blacklist)

	if block_not_blacklisted and block_data then
		if LIQUID_BLOCKS[block_data.name] then
			return false, block_data, DIG_REASONS.LIQUID
		end

		local success, err = dig_functions[direction]()

		if success then -- block is valid, block has data, something was dug
			if context then
				record_mined_block(context.state, block_data.name)
			end
			return true, block_data, DIG_REASONS.DUG
		else
			return false, block_data, DIG_REASONS.DIG_FAILED
		end
	elseif block_not_blacklisted then	-- empty
		return false, nil, DIG_REASONS.EMPTY
	else
		return false, block_data, DIG_REASONS.BLACKLISTED
	end
end



------------ ITS A MESS DOWN THERE ---------------------------------
-- direction: place - turtle place direction
local function _placeTorch(place) --> bool : torch placed
	local selected = M.selectItem("torch")
	if not selected then
		return selected
	end
	place()
	return selected
end


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
	turtle.select(1)
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
