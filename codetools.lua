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

-- Check if current fuel is sufficient for user's desired expense
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

-- TO DO -- 
-- have Enter key also pass pullEvent
function verifyTorchDownSetting(bool) --> bool : placeTorches
    if bool == true then
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

    while true do
        local eventData = {os.pullEvent()}
        local event = eventData[1]
        local key = eventData[2]

        if event == "key" then
            os.pullEvent("char")
            print(eventData[2])
            if (bool == true and key == 78) or (bool == false and key == 89) then
                return not bool
            end
            return bool
        end
    end
end

if not pcall(debug.getlocal, 4, 1) then -- checks if stack has 4 levels
    print("Running codetools.lua")
end