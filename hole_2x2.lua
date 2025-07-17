local ct = require("codetools")
local tt = require("turtletools")

local M = {}

-- TO DO --
-- make code more efficient
-- ? find an algorithm to mine everthing around bedrock
function M.dig(direction, placeTorches) --> str: left or right
	local block, tabl

	if direction == "right" then
		local turn = turtle.turnRight
		local opp_turn = turtle.turnLeft
	else
		local turn = turtle.turnLeft
		local opp_turn = turtle.turnRight
	end
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


		if not tt.compareAndDig("minecraft:bedrock") then
			break
		end
		turn()
		if not tt.compareAndDig("minecraft:bedrock") then
			opp_turn()
			break
		end
		turtle.forward()
		side_moves = ct.inc(side_moves)
		opp_turn()
		if not tt.compareAndDig("minecraft:bedrock") then
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

return M