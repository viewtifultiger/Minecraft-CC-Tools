
function selectItem(item)
	for slot=1,16 do
		local selectedItem = turtle.getItemDetail(slot)

		if selectedItem ~= nil and selectedItem.name == "minecraft:".. item then
			turtle.select(slot)
			return true
		end
	end
	return false
end

function torchDown()
	local selectedItem = turtle.getItemDetail()
		local selected = true

	if selectedItem == nil or selectedItem.name ~= "minecraft:torch" then
		selected = selectItem("torch")
	end
	
	if not selected then
		return false
	end
	
	turtle.placeDown()
	return selected
end

function cleanInventory(overrides)
	local discardList = dofile("discardlist_config.lua")
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
end

if not ... then
	torchDown()
end