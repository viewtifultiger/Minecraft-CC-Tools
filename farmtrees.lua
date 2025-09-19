
local tt = require("turtletools")

local blockExists, item
local logCount = 0

if not fs.exists("choptree.lua") then
	error("You must install choptree program first")
end

while true do
	if not tt.selectItem("oak_sapling") then
		error("Out of saplings.")
	end


	tt.forward(3)

	print("Planting...")
	turtle.place()

	while true do
		blockExists, item = turtle.inspect()
		if blockExists and item["name"] == "minecraft:oak_sapling" then
			if tt.selectItem("bone_meal") then
				print("Using bone meal")
				turtle.place()
			else
				tt.back(3)
				print("Sleeping...")
				sleep(300)
				tt.forward(3)
			end
		else
			break
		end
	end

	tt.selectEmptySlot()
	shell.run("choptree")

	tt.back(4)
	turtle.down()
	tt.turn180()

	while tt.selectItem("oak_log") do
		logCount = logCount + turtle.getItemCount()
		print("Total logs: " .. logCount)
		turtle.drop()
	end

	while turtle.suckDown() do
		if tt.selectItem("stick") then
			turtle.drop()
		elseif tt.selectItem("apple") then
			turtle.drop()
		else
			tt.selectItem("oak_sapling")
		end
	end

	turtle.up()
	tt.turn180()
end
