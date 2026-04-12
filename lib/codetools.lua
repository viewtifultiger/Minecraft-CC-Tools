--[[
TO DO:

- verifyTorchSettings
    * have Enter key also pass pullEvent
]]

local M = {}


function M.verifyTorchDownSetting(placeTorches) --> bool : placeTorches
    if placeTorches == true then
        print("\nplaceTorches: ON\n")
        print("!!! Make sure " .. os.getComputerLabel() .. " has torches !!!\n")
        print("To turn off, press 'n',")
        print("Otherwise press any other key...")
    else
        print("\nplaceTorches: OFF\n")
        print("If you would like placeTorches ON,")
        print("Make sure " .. os.getComputerLabel() .. " has torches!!\n")
        print("And press 'y' to turn on")

        print("Otherwise press any other key...")
    end

    local scrap_event = {os.pullEvent("key_up")} -- enter key_up after running program
    while true do
        local eventData = {os.pullEvent("key_up")}
        local key = eventData[2]

        if (placeTorches == true and key == 78) or (placeTorches == false and key == 89) then
                placeTorches = not placeTorches
        end
        break
    end

    if placeTorches then
        print("\nplaceTorches: ON")
    else
        print("\nplaceTorches: OFF")
    end
    return placeTorches
end


if not pcall(debug.getlocal, 4, 1) then -- checks if stack has 4 levels
    print("Running codetools.lua")
end

return M