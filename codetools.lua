function inc(num)
    return num + 1
end

function dec(num)
    return num - 1
end

function hasEnoughFuel(level)
    -- Fuel check
    local fuel = turtle.getFuelLevel()
    if fuel < level then
        print("Fuel level: ", fuel)
        print("Are you sure you want to proceed? (y/n)")
        local inp = io.read()
        if string.lower(inp) ~= "y" then
          print("Program Terminated")
          return false
        end
        return true
    end
end

function hasFuelExpense()
    local startingFuel = turtle.getFuelLevel()

    print("Fuel Level:", startingFuel)
    print("Enter fuel to expend: ")
    local fuelCost = tonumber(io.read())

    if fuelCost > startingFuel then
        print("Insufficient Fuel...")
        return nil, nil
    end
    return startingFuel, fuelCost
end

function verifyTorchDownSetting(bool) --> bool : placeTorches
    if bool == true then
        print("\nYou have the placeTorches setting on.\n")
        print("Make sure " .. os.getComputerLabel() .. " has torches!!\n")
        print("To turn off, press 'n',")
        print("Otherwise press any other key...")

        while true do
            local eventData = {os.pullEvent()}
            local event = eventData[1]

            if event == "key" then
                print(eventData[2])
                os.pullEvent("char")
                if eventData[2] == 78 then
                    return false
                else
                    return true
                end
            end
        end
    end
    return false
end

-- if not ... then
--     verifyTorchDownSetting(true)
-- end

if not pcall(debug.getlocal, 4, 1) then -- checks if stack has 4 levels
    print("Running codetools.lua")
end