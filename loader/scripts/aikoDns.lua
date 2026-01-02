local AIKO = loadstring(game:HttpGet("https://raw.githubusercontent.com/a11bove/kdoaz/refs/heads/main/src/Library.lua"))()

local Window = AIKO:Window({
    Title = "@aikoware |",
    Footer = "made by untog!",
    Version = 1
})

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local RunService = game:GetService("RunService")
local LocalPlayer = player
local Character = player.Character or player.CharacterAdded:Wait()

local autoKM_Running = false
local dupe_Running = false
local duplicateCashActive = false
local cashDupeAmount = 1200

local function autoFarmKm(state)
    autoKM_Running = state

    if state then
        task.spawn(function()
            while autoKM_Running and player.Character do
                local hum = player.Character:FindFirstChild("Humanoid")
                if hum and hum.SeatPart then
                    local car = hum.SeatPart.Parent

                    if car:FindFirstChild("Body") and car.Body:FindFirstChild("#Weight") then
                        car.PrimaryPart = car.Body["#Weight"]
                    end

                    local pos1 = Vector3.new(-6205.2983, 100, 8219.8535)
                    local pos2 = Vector3.new(-7594.5410, 100, 5130.9526)

                    repeat
                        task.wait()
                        car.PrimaryPart.Velocity = car.PrimaryPart.CFrame.LookVector * 550
                        car:PivotTo(CFrame.new(car.PrimaryPart.Position, pos1))
                    until not autoKM_Running or (player.Character.PrimaryPart.Position - pos1).Magnitude < 50

                    car.PrimaryPart.Velocity = Vector3.new()

                    repeat
                        task.wait()
                        car.PrimaryPart.Velocity = car.PrimaryPart.CFrame.LookVector * 550
                        car:PivotTo(CFrame.new(car.PrimaryPart.Position, pos2))
                    until not autoKM_Running or (player.Character.PrimaryPart.Position - pos2).Magnitude < 50

                    car.PrimaryPart.Velocity = Vector3.new()
                end

                task.wait(0.1)
            end
        end)
    end
end

local function activateExp()
    pcall(function()
        local ls = player:FindFirstChild("leaderstats")
        if ls and ls:FindFirstChild("Exp") then
            ls.Exp.Value = 82917
        end
    end)
end

local function duplicateCoin(state)
    dupe_Running = state

    local RS = ReplicatedStorage
    local WS = Workspace
    local Remotes = RS:WaitForChild("Remotes")
    local RecieveCoin = Remotes:WaitForChild("RecieveCoin")
    local Jeepnies = WS:WaitForChild("Jeepnies")

    if state then
        task.spawn(function()
            while dupe_Running do
                pcall(function()
                    local Jeep = Jeepnies:FindFirstChild(player.Name)
                    if Jeep then
                        local PV = Jeep:FindFirstChild("PassengerValues")
                        if PV then
                            RecieveCoin:FireServer({
                                PassengerValues = PV,
                                Password = 123456789,
                                Main = true,
                                Value = 300
                            })
                        end
                    end
                end)
                task.wait(0.01)
            end
        end)
    end
end

local function duplicateCash(state)
    duplicateCashActive = state
    local RecieveCash = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("RecieveCash")

    if state then
        task.spawn(function()
            while duplicateCashActive do
                for i = 1, cashDupeAmount do
                    pcall(function()
                        RecieveCash:FireServer({
                            Value = 100,
                            Password = 93828272827
                        })
                    end)
                end
                task.wait(0.3)
            end
        end)
    end
end

local BoostPower = 0
local BoostEnabled = false
local BoostConnection = nil

local function BoostLogic(dt)
    local success, err = pcall(function()
        if BoostPower <= 0 then return end
        local char = LocalPlayer.Character
        if not char then return end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end
        local seat = humanoid.SeatPart
        if not seat or not seat:IsA("VehicleSeat") then return end
        
        local velocity = seat.AssemblyLinearVelocity
        if velocity and velocity.Magnitude > 0.5 then
            seat.AssemblyLinearVelocity = velocity + (velocity.Unit * BoostPower * dt)
        end
    end)
    
    if not success then
        warn("Booster Error:", err)
    end
end

local function EnableBoost()
    if BoostEnabled then return end
    BoostEnabled = true
    BoostConnection = RunService.Heartbeat:Connect(BoostLogic)
end

local function DisableBoost()
    if not BoostEnabled then return end
    BoostEnabled = false
    if BoostConnection then
        BoostConnection:Disconnect()
        BoostConnection = nil
    end
end

local function SetBoostPower(value)
    BoostPower = value
end

local function ResetBoostPower()
    BoostPower = 0
end

local main = Window:AddTab({
    Name = "Main",
    Icon = "star"
})

local expsec = main:AddSection("Exploit")

expsec:AddParagraph({
    Title = "Tip",
    Icon = "idea",
    Content = "Sobrahan niyo ng sukli para dalawang beses mag duplicate."
})

expsec:AddInput({
    Title = "Duplicate Cash Multiplier",
    Default = "1200",
    Placeholder = "Default: 1200",
    Content = "1 - 6000",
    Callback = function(value)
        local num = tonumber(value)
        if num and num > 0 then
            cashDupeAmount = num
            aiko("Multiplier set to: " .. value)
        end
    end
})

expsec:AddToggle({
    Title = "Manual Duplicate Cash",
    Default = false,
    Callback = function(v)
        duplicateCash(v)
    end
})

expsec:AddToggle({
    Title = "Manual Duplicate Coins",
    Content = "",
    Default = false,
    Callback = function(value)
        duplicateCoin(value)
    end
})

expsec:AddToggle({
    Title = "Auto Farm KM",
    Content = "",
    Default = false,
    Callback = function(value)
        autoFarmKm(value)
    end
})

--[[ local jep = main:AddSection("Jeepney")

jep:AddToggle({
    Title = "Booster",
    Content = "",
    Default = false,
    Callback = function(value)
        if value then
            EnableBoost()
        else
            DisableBoost()
        end
    end
})

jep:AddSlider({
    Title = "Booster Power",
    Content = "Adjust booster strength",
    Min = 0,
    Max = 300,
    Default = 0,
    Callback = function(value)
        SetBoostPower(value)
    end
})

jep:AddButton({
    Title = "Reset Booster",
    Content = "Reset booster power to 0",
    Callback = function()
        ResetBoostPower()
    end
}) ]]

local visec = main:AddSection("Visual")

visec:AddParagraph({
    Title = "Recommend:",
    Content = "Use the add exp if you're only going to buy something in talyer, then rejoin so your exp wont get reset if you bump into other jeeps or walls."
})

visec:AddButton({
    Title = "Add Exp",
    Callback = function()
        activateExp()
        AIKO:MakeNotify({
            Title = "@aikoware",
            Description = "",
            Content = "Exp Added!"
        })
    end
})

local info = Window:AddTab({
    Name = "Information",
    Icon = "alert"
})

local infosec = info:AddSection("Info", true)

infosec:AddParagraph({
    Title = "Warning:",
    Icon = "alert",
    Content = "I made this script for testing purposes only, I am not responsible for any bans or any other consequences."
})

infosec:AddParagraph({
    Title = "Discord",
    Content = "Join to our discord server for more updates and information.",
    Icon = "discord",
    ButtonText = "Copy Discord Link",
    ButtonCallback = function()
        local link = "https://discord.gg/JccfFGpDNV"
        if setclipboard then
            setclipboard(link)
            aiko("Successfully Copied!")
        end
    end
})

AIKO:MakeNotify({
    Title = "@aikoware",
    Description = "| Script Loaded",
    Content = "Game: Diesel 'N Steel",
    Delay = 5
})
