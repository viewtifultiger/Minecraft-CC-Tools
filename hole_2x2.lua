local ct = require("codetools")
local tt = require("turtletools")
local DEFAULT_BLACKLIST = require("_black_list_blocks")

local M = {}

--[[
	Notes:
		When it comes to the positioning of the turtle after digging the 2x2 square, there would be no need to return the position of the
		turtle of where it is on the grid. It's position would just be the opposite of the direction it's given to mine. The position 
		can be handled in the upper level program. The real question is, what do we return?
]]

-- TO DO --
-- 1 find an algorithm to "clean up" after finding all blocks to be invalid (mine blocks not checked)
-- 2 have the dig function accept a dictionary of dig options including placeTorches, clean inventory frequency, and more
-- 5 let the M.dig() function accept a table of options


--[[
	-- WORKING ON --

]]

local function dig_2x2_square(direction, blacklist) -- direction: string
	blacklist = blacklist or DEFAULT_BLACKLIST
	local block, tabl
	local turn, opposite_turn
	local horizontal_position = direction == "left" and "right" or "left"
	local dig = tt.inspect_and_dig

	turn = tt.turn_functions[direction]
	opposite_turn = tt.turn_functions[direction == "left" and "right" or "left"]

	local valid_block, tabl = dig("forward", blacklist) -- 1st block

	if not valid_block then
		return false, horizontal_position
	end

	turn()

	valid_block, tabl = dig("forward", blacklist) -- 2nd block

	if not valid_block then
		opposite_turn()
		return false, horizontal_position
	end

	turtle.forward()
	horizontal_position = horizontal_position == "left" and "right" or "left"
	opposite_turn()

	valid_block, tabl = dig("forward", blacklist)	-- 3rd block

	if not valid_block then
		return false, horizontal_position
	end	

	return true, horizontal_position
end
-------------------------------------------------------------------------------------------------------------------------------------------------------
function M.dig_2x2_square(direction, blacklist)
	return dig_2x2_square(direction, blacklist)
end

--@param next_hole_direction string: determines the direction of the next hole
--@param placeTorches boolean: determines whether the turtle should place torches 
-------------------------------------------------------------------------------------------------------------------------------------------------------
function M.dig(next_hole_direction, options)
	local valid, tabl -- valid_block: bool; tabl: table block data
	local horizontal_position = next_hole_direction == "left" and "right" or "left" -- turtle starts at the opposite end of where it intends to mine
	local dig = tt.inspect_and_dig
	local dig_square = dig_2x2_square
	local depth = 0

	tt.selectEmptySlot()

	while true do
		-- Place torches every 8 blocks
		if options.placeTorches and depth % 8 == 0 then
			tt.torch()
		end

		-- Clean Invetory every 12 block
		if depth % 12 == 0 then
			tt.cleanInventory()
		end
	
------------------------MAIN DIG LOOP-------------------------------------------------
		valid, tabl = dig("down", DEFAULT_BLACKLIST)

		if not valid then
			break
		end

		turtle.down()
		depth = ct.inc(depth)

		valid, horizontal_position = M.dig_2x2_square(next_hole_direction)

		if not valid then
			break
		end

		next_hole_direction = next_hole_direction == "left" and "right" or "left"

	end
--------------------------------------------------------------------------------------------------
	tt.cleanInventory()
	tt.returnToSurface(depth)
	return horizontal_position

end

return M