--[[

]]
local DEFAULT_BLACKLIST = require("_black_list_blocks")
local context_builder = require("context_builder")
local dig_core = require("dig_core")

local movement = require("movement")
local direct = require("direction")

local M = {}

----------------PUBLIC-FUNCTIONS-----------------------------------------------------------------------------------------------------------------------
--[[
	vertical_direction string (must be "forward", "up", or "down"): ; context table: context_builder.create() or similar and must have a blacklist
]]
function M.inspect_if_blacklisted(vertical_direction, context) --> --> success boolean: if block present and not blacklisted; table block_data | nil (empty block)
	direct.vertical_direction_checker(vertical_direction, 3)
	context = context or context_builder.create()
	context_builder.run_checks(context, {"dig_config", "blacklist"}, 3)
	return dig_core.inspect_if_blacklisted(vertical_direction, context.dig_config.blacklist)
end
--[[
	vertical_direction string (must be "forward", "up", or "down"): ; context table: context_builder.create() or similar and must have a blacklist 
		and must have stats
]]
function M.try_dig(vertical_direction, context) --> boolean: if block was dug; table | nil (if empty block); string reason for the returned boolean
	direct.vertical_direction_checker(vertical_direction, 3)
	context = context
	context_builder.run_checks(context, {"basic_structure", "stats", "blocks_mined",
											"blocks_mined_by_name", "blacklist"}, 3) --check state, dig_config, blacklist, stats, blocks_mined, blocks_mined by name
	return dig_core.try_dig(vertical_direction, context)
end


----------------SANDBOX-FUNCTIONS----------------------------------------------------------------------------------------------------------------------
--[[ !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!THIS FUNCTION NEEDS TO BE PROPERLY IMPLEMENTED OR REFACTORED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	vertical_direction string (must be "forward", "up", or "down"): ; blacklist table

	WARNING: NEEDS A VALIDATE_BLACKLIST FUNCTION OR ELSE ANY TABLE WILL PASS (can check for proper keys and type(values) == "boolean"
]]
-- function M.inspect_if_blacklisted_with_blacklist(vertical_direction, blacklist) --> success boolean: if block present and not blacklisted; table block_data | nil (empty block)
-- 	direct.vertical_direction_checker(vertical_direction, 3)
-- 	blacklist = blacklist or DEFAULT_BLACKLIST
-- 	context_builder.blacklist_checker(blacklist, 3)	--!!!!!!!!!!!!!!!!!!!!WARNING!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- 	return dig_core.inspect_if_blacklisted(vertical_direction, blacklist)
-- end





----OUTDATED FUNCTIONS ----------------------------
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

function M.returnToSurface(depth, context)
	for i=1,depth do
		movement.up(context)
	end
end

if not pcall(debug.getlocal, 4, 1) then
	print("Running turtletools.lua")
end

return M
