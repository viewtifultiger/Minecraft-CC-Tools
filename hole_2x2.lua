os.loadAPI("codetools.lua")
os.loadAPI("turtletools.lua")
local ct = codetools
local tt = turtletools

-- TO DO --

-- create dig_2x2_hole
-- ? check all digging blocks for bedrock (only check at bottom)
-- ? find an algorithm to mine everthing around bedrock
function dig(placeTorches) --> str: left or right
	local block, tabl
	local turn = turtle.turnRight
	local opp_turn = turtle.turnLeft
	local depth = 0
	local side_moves = 0

	turtle.select(1)

	while true do
		-- Clean Inventory
		if placeTorches and depth % 8 == 0 then
			placeTorches = tt.torch()
		end
		if depth % 12 == 0 then
			tt.cleanInventory()
		end

		block, tabl = turtle.inspectDown()
		if block then
			if tabl.name ~= "minecraft:bedrock" then
				turtle.digDown()
				turtle.down()
			else
				break
			end
		else
			turtle.down()
		end
		depth = ct.inc(depth)

		block, tabl = turtle.inspect()
		if tabl.name ~= "minecraft:bedrock" then
			turtle.dig()
			turn()
			turtle.dig()
			turtle.forward()
			side_moves = ct.inc(side_moves)
			opp_turn()
			turtle.dig()
		else
			break
		end

		temp = turn
		turn = opp_turn
		opp_turn = temp
	end

	tt.cleanInventory()
	tt.returnToSurface(depth)
	if side_moves % 2 == 0 then
		return "left"
	else
		return "right"
	end
end