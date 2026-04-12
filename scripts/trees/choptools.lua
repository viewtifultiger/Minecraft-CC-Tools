local M = {}

function M.selectItem(name)
	local itme
	for slot = 1, 16 do
		item = turtle.getItemDetail(slot)
		if item ~= nil and item["name"] == name then
			turtle.select(slot)
			return true
		end
	end
	return false
end

function M.selectEmptySlot()
	for slot = 1, 16 do
		if turtle.getItemCount(slot) == 0 then
			turtle.select(slot)
			return true
		end
	end
	return false
end

return M