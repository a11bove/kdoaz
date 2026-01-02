local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local MiscModule = {}

-- HIDE IDENTITY FUNCTIONS
MiscModule.Identity = {
    NameLabel = nil,
    LevelLabel = nil,
    OriginalName = "Player",
    OriginalLevel = "1",
    OriginalNameColor = Color3.new(1, 1, 1),
    HideIdentityEnabled = true,
    overheadConnection = nil,
    rainbowThread = nil
}

function MiscModule.Identity:getOverheadElements()
    local character = LocalPlayer.Character
    if not character then return nil, nil end

    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil, nil end

    local overhead = hrp:FindFirstChild("Overhead")
    if not overhead then return nil, nil end

    local nameLabel = overhead:FindFirstChild("Content") and overhead.Content:FindFirstChild("Header")
    local levelLabel = overhead:FindFirstChild("LevelContainer") and overhead.LevelContainer:FindFirstChild("Label")

    return nameLabel, levelLabel
end

function MiscModule.Identity:updateIdentityDisplay()
    local nameLabel, levelLabel = self:getOverheadElements()

    if nameLabel and levelLabel then
        if self.HideIdentityEnabled then
            nameLabel.Text = "@aikoware [PROTECTED]"
            levelLabel.Text = "@aikoware [PROTECTED]"
        else
            nameLabel.Text = self.OriginalName
            levelLabel.Text = self.OriginalLevel
        end
    end
end

function MiscModule.Identity:startOverheadMonitoring()
    if self.overheadConnection then
        self.overheadConnection:Disconnect()
    end

    self.overheadConnection = RunService.Heartbeat:Connect(function()
        if self.HideIdentityEnabled then
            self:updateIdentityDisplay()
        end
    end)
end

function MiscModule.Identity:startRainbowEffect()
    if self.rainbowThread then
        task.cancel(self.rainbowThread)
    end

    self.rainbowThread = task.spawn(function()
        local hue = 0
        while true do
            if self.HideIdentityEnabled then
                local nameLabel, _ = self:getOverheadElements()
                if nameLabel then
                    hue = (hue + 0.01) % 1
                    local rainbowColor = Color3.fromHSV(hue, 1, 1)
                    nameLabel.TextColor3 = rainbowColor
                end
            else
                local nameLabel, _ = self:getOverheadElements()
                if nameLabel then
                    nameLabel.TextColor3 = self.OriginalNameColor
                end
            end
            task.wait(0.05)
        end
    end)
end

function MiscModule.Identity:Initialize()
    self.NameLabel, self.LevelLabel = self:getOverheadElements()
    
    if self.NameLabel and self.LevelLabel then
        self.OriginalName = self.NameLabel.Text
        self.OriginalLevel = self.LevelLabel.Text
        self.OriginalNameColor = self.NameLabel.TextColor3
    end

    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(1)
        self.NameLabel, self.LevelLabel = self:getOverheadElements()

        if self.NameLabel and self.LevelLabel then
            self.OriginalName = self.NameLabel.Text
            self.OriginalLevel = self.LevelLabel.Text
        end

        if self.HideIdentityEnabled then
            self:updateIdentityDisplay()
        end
    end)

    self:startRainbowEffect()
end

function MiscModule.Identity:Toggle(enabled)
    self.HideIdentityEnabled = enabled

    if enabled then
        self:startOverheadMonitoring()
        self:updateIdentityDisplay()
    else
        if self.overheadConnection then
            self.overheadConnection:Disconnect()
            self.overheadConnection = nil
        end
        self:updateIdentityDisplay()
    end
end

-- INFINITE JUMP
MiscModule.InfiniteJump = {
    Enabled = false,
    Connection = nil
}

function MiscModule.InfiniteJump:Toggle(enabled)
    self.Enabled = enabled
    _G.InfiniteJump = enabled
    
    if not self.Connection then
        local UserInputService = game:GetService("UserInputService")
        self.Connection = UserInputService.JumpRequest:Connect(function()
            if _G.InfiniteJump then
                local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
    end
end

-- PERFORMANCE FUNCTIONS
MiscModule.Performance = {
    hidePlayersEnabled = false,
    playerAddedConnection = nil,
    characterConnections = {}
}

function MiscModule.Performance:setCharacterVisibility(character, visible)
    if character then
        for _, descendant in ipairs(character:GetDescendants()) do
            if descendant:IsA("BasePart") then
                pcall(function()
                    descendant.LocalTransparencyModifier = visible and 0 or 1
                    descendant.CanCollide = visible
                end)
            elseif descendant:IsA("Decal") then
                pcall(function()
                    descendant.Transparency = visible and 0 or 1
                end)
            end
        end
    end
end

function MiscModule.Performance:hideAllPlayers()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            self:setCharacterVisibility(player.Character, false)
        end
    end
end

function MiscModule.Performance:showAllPlayers()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            self:setCharacterVisibility(player.Character, true)
        end
    end
end

function MiscModule.Performance:EnableHidePlayers()
    if not self.hidePlayersEnabled then
        self.hidePlayersEnabled = true
        self:hideAllPlayers()

        self.playerAddedConnection = Players.PlayerAdded:Connect(function(player)
            self.characterConnections[player] = player.CharacterAdded:Connect(function(character)
                task.wait(0.5)
                self:setCharacterVisibility(character, false)
            end)

            if player.Character then
                task.wait(0.1)
                self:setCharacterVisibility(player.Character, false)
            end
        end)

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and not self.characterConnections[player] then
                self.characterConnections[player] = player.CharacterAdded:Connect(function(character)
                    task.wait(0.5)
                    self:setCharacterVisibility(character, false)
                end)
            end
        end
    end
end

function MiscModule.Performance:DisableHidePlayers()
    if self.hidePlayersEnabled then
        self.hidePlayersEnabled = false
        self:showAllPlayers()

        if self.playerAddedConnection then
            self.playerAddedConnection:Disconnect()
            self.playerAddedConnection = nil
        end

        for player, connection in pairs(self.characterConnections) do
            if connection then
                connection:Disconnect()
            end
            self.characterConnections[player] = nil
        end
    end
end

function MiscModule.Performance:LowGFX()
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Material = Enum.Material.SmoothPlastic
            v.Reflectance = 0
            v.CastShadow = false
        elseif v:IsA("Decal") or v:IsA("Texture") then
            v.Transparency = 1
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
            v.Enabled = false
        end
    end

    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    Lighting.Brightness = 1
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
end

function MiscModule.Performance:RemoveShadows(enabled)
    pcall(function()
        Lighting.GlobalShadows = not enabled
    end)
end

function MiscModule.Performance:RemoveWaterReflections(enabled)
    pcall(function()
        Lighting.EnvironmentSpecularScale = enabled and 0 or 1
    end)
end

function MiscModule.Performance:RemoveParticles(enabled)
    for _, descendant in ipairs(workspace:GetDescendants()) do
        if descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") or descendant:IsA("Beam") then
            pcall(function()
                descendant.Enabled = not enabled
            end)
        end
    end
end

function MiscModule.Performance:RemoveTerrainDecorations(enabled)
    local terrain = workspace:FindFirstChildOfClass("Terrain")
    if terrain then
        pcall(function()
            terrain.Decoration = not enabled
        end)
    end
end

-- FREEZE CHARACTER

MiscModule.FreezeCharacter = {
    Enabled = false,
    originalCFrame = nil,
    freezeConnection = nil
}

function MiscModule.FreezeCharacter:Toggle(enabled)
    self.Enabled = enabled
    _G.FreezeCharacter = enabled

    if enabled then
        local character = LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")

        if hrp then
            self.originalCFrame = hrp.CFrame

            if self.freezeConnection then
                self.freezeConnection:Disconnect()
            end

            self.freezeConnection = RunService.Heartbeat:Connect(function()
                if self.Enabled and hrp and hrp.Parent then
                    hrp.CFrame = self.originalCFrame
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    hrp.AssemblyAngularVelocity = Vector3.zero
                end
            end)
        end
    else
        if self.freezeConnection then
            self.freezeConnection:Disconnect()
            self.freezeConnection = nil
        end
    end
end

-- XP BAR
MiscModule.XPBar = {}

function MiscModule.XPBar:Toggle(state)
    local XPBar = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("XP")
    if XPBar then
        XPBar.Enabled = state
    end
end

-- ANTI DROWN

MiscModule.AntiDrown = {
    Enabled = false
}

function MiscModule.AntiDrown:Initialize()
    local rawmt = getrawmetatable(game)
    setreadonly(rawmt, false)
    local oldNamecall = rawmt.__namecall

    rawmt.__namecall = newcclosure(function(self, ...)
        local args = { ... }
        local method = getnamecallmethod()

        if tostring(self) == "URE/UpdateOxygen" and method == "FireServer" and MiscModule.AntiDrown.Enabled then
            return nil
        end

        return oldNamecall(self, ...)
    end)
end

function MiscModule.AntiDrown:Toggle(state)
    self.Enabled = state
end

-- FISHING RADAR
MiscModule.FishingRadar = {}

function MiscModule.FishingRadar:Toggle(state)
    local Replion = require(ReplicatedStorage.Packages.Replion)
    local Net = require(ReplicatedStorage.Packages.Net)
    local SPR = require(ReplicatedStorage.Packages.spr)
    local Soundbook = require(ReplicatedStorage.Shared.Soundbook)
    local ClientTime = require(ReplicatedStorage.Controllers.ClientTimeController)
    local TextNotification = require(ReplicatedStorage.Controllers.TextNotificationController)

    local UpdateFishingRadar = Net:RemoteFunction("UpdateFishingRadar")

    local function SetRadar(enable)
        local clientData = Replion.Client:GetReplion("Data")
        if not clientData then return end

        if clientData:Get("RegionsVisible") ~= enable then
            if UpdateFishingRadar:InvokeServer(enable) then
                Soundbook.Sounds.RadarToggle:Play().PlaybackSpeed = 1 + math.random() * 0.3

                if enable then
                    local ccEffect = Lighting:FindFirstChildWhichIsA("ColorCorrectionEffect")
                    if ccEffect then
                        SPR.stop(ccEffect)
                        local lightingProfile = ClientTime:_getLightingProfile()
                        local targetSettings = (lightingProfile and lightingProfile.ColorCorrection) or {}
                        targetSettings.Brightness = targetSettings.Brightness or 0.04
                        targetSettings.TintColor = targetSettings.TintColor or Color3.fromRGB(255, 255, 255)

                        ccEffect.TintColor = Color3.fromRGB(42, 226, 118)
                        ccEffect.Brightness = 0.4
                        SPR.target(ccEffect, 1, 1, targetSettings)
                    end

                    SPR.stop(Lighting)
                    Lighting.ExposureCompensation = 1
                    SPR.target(Lighting, 1, 2, {ExposureCompensation = 0})
                end

                TextNotification:DeliverNotification({
                    Type = "Text",
                    Text = "Radar: "..(enable and "Enabled" or "Disabled"),
                    TextColor = enable and {R = 9, G = 255, B = 0} or {R = 255, G = 0, B = 0}
                })
            end
        end
    end

    SetRadar(state)
end

-- INITIALIZATION
function MiscModule:Initialize()
    self.Identity:Initialize()
    self.AntiDrown:Initialize()
    
    LocalPlayer.CharacterAdded:Connect(function()
        if self.FreezeCharacter.freezeConnection then
            self.FreezeCharacter.freezeConnection:Disconnect()
            self.FreezeCharacter.freezeConnection = nil
        end
        self.FreezeCharacter.Enabled = false
        _G.FreezeCharacter = false
    end)
end

return MiscModule
