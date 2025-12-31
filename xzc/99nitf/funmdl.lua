local FunModule = {}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

-- Get LocalPlayer
local LocalPlayer = Players.LocalPlayer
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local hum = character:FindFirstChildOfClass("Humanoid")

FunModule.GodModeEnabled = false
FunModule.GodModeToggle = false
FunModule.GodModeHumConnection = nil
FunModule.GodModeHeartbeat = nil

-- Apply God Mode (No Health Bar)
function FunModule.ApplyGodMode(state)
    local currentCharacter = LocalPlayer.Character
    if currentCharacter then
        for i, part in ipairs(currentCharacter:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = not state
            end
        end

        local currentHum = currentCharacter:FindFirstChildOfClass("Humanoid")
        if state and currentHum then
            if FunModule.GodModeHumConnection then 
                FunModule.GodModeHumConnection:Disconnect() 
                FunModule.GodModeHumConnection = nil 
            end
            if FunModule.GodModeHeartbeat then 
                FunModule.GodModeHeartbeat:Disconnect() 
                FunModule.GodModeHeartbeat = nil 
            end

            FunModule.GodModeHumConnection = currentHum.HealthChanged:Connect(function(hp)
                if FunModule.GodModeEnabled and currentHum and currentHum.Health < currentHum.MaxHealth then
                    currentHum.Health = currentHum.MaxHealth
                end
            end)

            FunModule.GodModeHeartbeat = RunService.Heartbeat:Connect(function()
                if FunModule.GodModeEnabled and currentHum and currentHum.Health < currentHum.MaxHealth then
                    currentHum.Health = currentHum.MaxHealth
                end
            end)
        else
            if FunModule.GodModeHumConnection then 
                FunModule.GodModeHumConnection:Disconnect() 
                FunModule.GodModeHumConnection = nil 
            end
            if FunModule.GodModeHeartbeat then 
                FunModule.GodModeHeartbeat:Disconnect() 
                FunModule.GodModeHeartbeat = nil 
            end
        end
    end
end

-- Toggle No Health Bar
function FunModule.ToggleNoHealthBar(state, notifyCallback)
    FunModule.GodModeEnabled = state
    FunModule.ApplyGodMode(state)
    
    if notifyCallback then
        if state then
            notifyCallback("Disabled", "Health Bar")
        else
            notifyCallback("Enabled", "Health Bar")
        end
    end
end

-- Character Added Connection
local characterAddedConnection
function FunModule.SetupCharacterConnection()
    if characterAddedConnection then
        characterAddedConnection:Disconnect()
    end
    
    characterAddedConnection = LocalPlayer.CharacterAdded:Connect(function(char)
        character = char
        wait(0.1)
        if FunModule.GodModeEnabled then
            FunModule.ApplyGodMode(true)
        end
    end)
end

-- God Mode (Immune to damage)
local godModeLoop
function FunModule.ToggleGodMode(state, notifyCallback)
    FunModule.GodModeToggle = state
    
    if state then
        godModeLoop = task.spawn(function()
            while FunModule.GodModeToggle do
                local dmgEvent = ReplicatedStorage:FindFirstChild("RemoteEvents") 
                    and ReplicatedStorage.RemoteEvents:FindFirstChild("DamagePlayer")
                
                if dmgEvent then
                    pcall(function()
                        dmgEvent:FireServer(-9999)
                    end)
                else
                    if notifyCallback then
                        notifyCallback("Failed, rejoin and try again.", "God Mode")
                    end
                    break
                end
                RunService.Stepped:Wait()
            end
        end)
    else
        if godModeLoop then
            task.cancel(godModeLoop)
            godModeLoop = nil
        end
    end
end

-- Load Auto Days Farm
function FunModule.LoadAutoDaysFarm()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/a11bove/kdoaz/refs/heads/main/xzc/99nitf/daysfrm.lua", true))()
    end)
end

-- Cleanup Function
function FunModule.Cleanup()
    FunModule.ToggleNoHealthBar(false)
    FunModule.ToggleGodMode(false)
    
    if FunModule.GodModeHumConnection then
        FunModule.GodModeHumConnection:Disconnect()
        FunModule.GodModeHumConnection = nil
    end
    if FunModule.GodModeHeartbeat then
        FunModule.GodModeHeartbeat:Disconnect()
        FunModule.GodModeHeartbeat = nil
    end
    if characterAddedConnection then
        characterAddedConnection:Disconnect()
        characterAddedConnection = nil
    end
end

-- Initialize
FunModule.SetupCharacterConnection()

return FunModule
