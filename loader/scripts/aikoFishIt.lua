local AIKO = loadstring(game:HttpGet("https://raw.githubusercontent.com/a11bove/kdoaz/refs/heads/main/src/Library.lua"))()

local Window = AIKO:Window({
    Title   = "Aikoware |",
    Footer  = "made by @aoki!",              
    Version = 1,
})

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")

local Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    HttpService = game:GetService("HttpService"),
    RS = game:GetService("ReplicatedStorage"),
    VIM = game:GetService("VirtualInputManager"),
    TeleportService = game:GetService("TeleportService")
}

local Player = Services.Players.LocalPlayer
local PlayerGui = Player.PlayerGui
local Camera = workspace.CurrentCamera

local Net = Services.RS.Packages._Index["sleitnick_net@0.2.0"].net
local NetworkFunctions = {
    UpdateRadar = Net["RF/UpdateFishingRadar"]
}

_G.httpRequest = syn and syn.request or (http and http.request or http_request or (fluxus and fluxus.request or request))

local net = ReplicatedStorage:WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_net@0.2.0")
    :WaitForChild("net")

local rodRemote = net:WaitForChild("RF/ChargeFishingRod")
local miniGameRemote = net:WaitForChild("RF/RequestFishingMinigameStarted")
local finishRemote = net:WaitForChild("RE/FishingCompleted")
local equipRemote = net:WaitForChild("RE/EquipToolFromHotbar")
local REFavoriteItem = net:WaitForChild("RE/FavoriteItem")
local InitiateTrade = net:WaitForChild("RF/InitiateTrade")
local SellAllItems = net:WaitForChild("RF/SellAllItems")
local REObtainedNewFishNotification = net:WaitForChild("RE/ObtainedNewFishNotification")

local NetFolder = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")

local NetIndex = ReplicatedStorage.Packages._Index and ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"]
if NetIndex then
    NetIndex = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net
end

local ChargeFishingRod = NetFolder:WaitForChild("RF/ChargeFishingRod")
local RequestFishingMinigame = NetFolder:WaitForChild("RF/RequestFishingMinigameStarted")
local FishingCompleted = NetFolder:WaitForChild("RE/FishingCompleted")
local EquipToolFromHotbar = NetFolder:WaitForChild("RE/EquipToolFromHotbar")
local SellAllItems = NetFolder:WaitForChild("RF/SellAllItems")
local CancelFishingInputs = NetFolder:WaitForChild("RF/CancelFishingInputs")
local ActivateEnchantingAltar = NetFolder:WaitForChild("RE/ActivateEnchantingAltar")
local UpdateOxygen = NetFolder:WaitForChild("URE/UpdateOxygen")
local FishingController = require(ReplicatedStorage.Controllers.FishingController)
local REFavoriteItem = NetFolder:WaitForChild("RE/FavoriteItem")

UserInputService.JumpRequest:Connect(function()
    local shouldJump = _G.InfiniteJump and (LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()):FindFirstChildOfClass("Humanoid")
    if shouldJump then
        shouldJump:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

local Replion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Replion"))
local Data = Replion.Client:WaitReplion("Data", LocalPlayer)

local lockPositionState = {
    enabled = false,
    position = nil
}

local playerAddedConnection
local characterConnections = {}

local Home = Window:AddTab({
    Name = "Home",
    Icon = "info"
})

local Fishing = Window:AddTab({
    Name = "Fishing",
    Icon = "rbxassetid://100067447000453"
})

local Shop = Window:AddTab({
    Name = "Shop",
    Icon = "piggy-bank"
})

local Favo = Window:AddTab({
    Name = "Auto Favorite",
    Icon = "heart"
})

local Teleport = Window:AddTab({
    Name = "Teleport",
    Icon = "map-pin"
})

local Trade = Window:AddTab({
    Name = "Trade",
    Icon = "repeat"
})

local Webhook = Window:AddTab({
    Name = "Webhook",
    Icon = "rbxassetid://137601480983962"
})

local Misc = Window:AddTab({
    Name = "Misc",
    Icon = "snowflake"
})

local dcsec = Home:AddSection("Support", true)

dcsec:AddParagraph({
    Title = "Discord",
    Content = "Join our discord for more information.",
    Icon = "discord",
    ButtonText = "Copy Server Link",
    ButtonCallback = function()
        local link = "https://discord.gg/JccfFGpDNV"
        if setclipboard then
            setclipboard(link)
            aiko("Successfully Copied!")
        end
    end
})

local srv = Home:AddSection("Server")

local antiIDLE = srv:AddToggle({
    Title = "Anti AFK",
    Content = "Anti kick when idle for 20 mins.",
    Default = false,
    Callback = function(enabled)
        _G.AntiAFK = enabled
        local VirtualUser = game:GetService("VirtualUser")
        task.spawn(function()
            while _G.AntiAFK do
                task.wait(60)
                pcall(function()
                    VirtualUser:CaptureController()

                    VirtualUser:ClickButton2(Vector2.new())
                end)
            end
        end)
    end
})

local autoRECON = srv:AddToggle({
    Title = "Auto Reconnect",
    Content = "",
    Default = false,
    Callback = function(enabled)
        _G.AutoReconnect = enabled
        if enabled then
            task.spawn(function()
                while _G.AutoReconnect do
                    task.wait(2)
                    local promptGui = game:GetService("CoreGui"):FindFirstChild("RobloxPromptGui")
                    local promptOverlay = promptGui and promptGui:FindFirstChild("promptOverlay")
                    if promptOverlay then
                        local reconnectButton = promptOverlay:FindFirstChild("ButtonPrimary")
                        if reconnectButton and reconnectButton.Visible then
                            firesignal(reconnectButton.MouseButton1Click)
                        end
                    end
                end
            end)
        end
    end
})

function RejoinServer()
    local TeleportService = game:GetService("TeleportService")
    local Player = game:GetService("Players").LocalPlayer
    TeleportService:Teleport(game.PlaceId, Player)
end

srv:AddButton({
    Title = "Rejoin Server",
    Content = "Teleport back to the same game",
    Callback = function()
        task.wait(0.5)
        local TeleportService = game:GetService("TeleportService")
        local Player = game:GetService("Players").LocalPlayer
        TeleportService:Teleport(game.PlaceId, Player)
    end
})

local fsh = Fishing:AddSection("Legit (Auto Perfect)")

local MouseReleaseCallback = nil
local LegitShakeDelay = 0.05
local DefaultLegitDelay = 0.1

_G.FishMiniData = _G.FishMiniData or {}

local InputControl = require(ReplicatedStorage.Modules.InputControl)
local OldRegisterMouseReleased = InputControl.RegisterMouseReleased

function InputControl.RegisterMouseReleased(self, param2, callback)
    MouseReleaseCallback = callback
    return OldRegisterMouseReleased(self, param2, callback)
end

function castWithBarRelease()
    local PlayerGui = LocalPlayer.PlayerGui
    local Camera = workspace.CurrentCamera
    local CenterPosition = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    pcall(function()
        CancelFishingInputs:InvokeServer()
    end)

    pcall(function()
        FishingController:RequestChargeFishingRod(CenterPosition, false)
    end)

    local ChargeBar = PlayerGui:WaitForChild("Charge"):WaitForChild("Main"):WaitForChild("CanvasGroup"):WaitForChild("Bar")

    repeat
        task.wait()
    until ChargeBar.Size.Y.Scale > 0

    local StartTime = tick()

    while ChargeBar:IsDescendantOf(PlayerGui) and ChargeBar.Size.Y.Scale < 0.93 do
        task.wait()
        if tick() - StartTime > 2 then
            break
        end
    end

    if MouseReleaseCallback then
        pcall(MouseReleaseCallback)
    end
end

function StartLegitFishing(enabled)
    FishingController._autoLoop = enabled
    FishingController._autoShake = enabled

    if enabled then
        task.spawn(function()
            pcall(function()
                EquipToolFromHotbar:FireServer(1)
            end)
            task.wait(0.5)
        end)

        task.spawn(function()
            local UserId = tostring(LocalPlayer.UserId)
            local CosmeticFolder = workspace:WaitForChild("CosmeticFolder")

            while FishingController._autoLoop do
                if not CosmeticFolder:FindFirstChild(UserId) then
                    castWithBarRelease()
                    task.wait(0.2)
                end

                while CosmeticFolder:FindFirstChild(UserId) and FishingController._autoLoop do
                    task.wait(0.2)
                end

                task.wait(0.2)
            end
        end)

        local ClickEffect = LocalPlayer.PlayerGui:FindFirstChild("!!! Click Effect")
        if ClickEffect then
            ClickEffect.Enabled = false
        end

        task.spawn(function()
            while FishingController._autoShake do
                pcall(function()
                    FishingController:RequestFishingMinigameClick()
                end)
                task.wait(LegitShakeDelay)
            end
        end)
    else
        local ClickEffect = LocalPlayer.PlayerGui:FindFirstChild("!!! Click Effect")
        if ClickEffect then
            ClickEffect.Enabled = true
        end
    end
end

fsh:AddToggle({
    Title = "Legit Fishing",
    Content = "",
    Default = false,
    Callback = function(enabled)
        if enabled then
            task.spawn(function()
                pcall(function()
                    EquipToolFromHotbar:FireServer(1)
                end)
                task.wait(0.3)
                StartLegitFishing(enabled)
            end)
        else
            StartLegitFishing(enabled)
        end

        local playerGui = LocalPlayer:WaitForChild("PlayerGui")
        local fishingGui = playerGui:WaitForChild("Fishing"):WaitForChild("Main")

        if enabled then
            fishingGui.Visible = false
        else
            fishingGui.Visible = true
        end
    end
})

fsh:AddButton({
    Title = "Manual Fix Stuck",
    Content = "",
    Callback = function()
        StartLegitFishing(false)

        AIKO:MakeNotify({
            Title = "Aikoware",
            Description = "| Manual Fix Stuck",
            Content = "Stuck Fixed",
            Delay = 2
        })
    end
})

local fin = Fishing:AddSection("Instant")

local InstantFishEnabled = false
local InstantDelayComplete = 0.1
_G.FishMiniData = _G.FishMiniData or {}

local MiniEvent = net:WaitForChild("RE/FishingMinigameChanged")
if MiniEvent then
    if _G._MiniEventConn then
        _G._MiniEventConn:Disconnect()
    end

    _G._MiniEventConn = MiniEvent.OnClientEvent:Connect(function(param1, param2)
        if param1 and param2 then
            _G.FishMiniData = param2
        end
    end)
end

local function StartInstantFishing(enabled)
    InstantFishEnabled = enabled

    if enabled then
        task.spawn(function()
            pcall(function()
                EquipToolFromHotbar:FireServer(1)
            end)
            task.wait(0.5)
        end)

        task.spawn(function()
            task.wait(0.5)

            while InstantFishEnabled do
                pcall(function()
                    local success, _, rodGUID = pcall(function()
                        return ChargeFishingRod:InvokeServer(workspace:GetServerTimeNow())
                    end)

                    if success and typeof(rodGUID) == "number" then
                        local ProgressValue = -1
                        local SuccessRate = 0.999

                        task.wait(0.3)

                        pcall(function()
                            RequestFishingMinigame:InvokeServer(ProgressValue, SuccessRate, rodGUID)
                        end)

                        local WaitStart = tick()
                        repeat
                            task.wait()
                        until _G.FishMiniData and _G.FishMiniData.LastShift or tick() - WaitStart > 1

                        task.wait(InstantDelayComplete)

                        pcall(function()
                            FishingCompleted:FireServer()
                        end)

                        local CurrentCount = getFishCount()
                        local CountWaitStart = tick()
                        repeat
                            task.wait()
                        until CurrentCount < getFishCount() or tick() - CountWaitStart > 1

                        pcall(function()
                            CancelFishingInputs:InvokeServer()
                        end)
                    end
                end)
                task.wait()
            end
        end)
    end
end

function getFishCount()
    local BagSizeLabel = LocalPlayer.PlayerGui:WaitForChild("Inventory"):WaitForChild("Main"):WaitForChild("Top"):WaitForChild("Options"):WaitForChild("Fish"):WaitForChild("Label"):WaitForChild("BagSize")
    return tonumber((BagSizeLabel.Text or "0/???"):match("(%d+)/")) or 0
end

fin:AddToggle({
    Title = "Instant Fishing",
    Content = "",
    Default = false,
    Callback = function(enabled)
        if enabled then
            pcall(function()
                EquipToolFromHotbar:FireServer(1)
            end)
            task.wait(0.5)
            StartInstantFishing(true)
        else
            StartInstantFishing(false)
        end
    end
})

fin:AddInput({
    Title = "Complete Delay",
    Placeholder = "0.1",
    Callback = function(value)
        local delay = tonumber(value)
        if delay and delay >= 0 then
            InstantDelayComplete = delay
        end
    end
})

local bts = Fishing:AddSection("Blatant")

_G.FishingDelay = _G.FishingDelay or 1.1
_G.Reel = _G.Reel or 1.9
_G.FBlatant = _G.FBlatant or false

function FastestFishing()
    task.spawn(function()
        pcall(function()
            CancelFishingInputs:InvokeServer()
        end)

        local serverTime = workspace:GetServerTimeNow()

        pcall(function()
            ChargeFishingRod:InvokeServer(serverTime)
        end)

        pcall(function()
            RequestFishingMinigame:InvokeServer(-1, 0.999)
        end)

        task.wait(_G.FishingDelay)

        pcall(function()
            FishingCompleted:FireServer()
        end)
    end)
end

function StartBlatantFishing()
    _G.FBlatant = true

    pcall(function()
        EquipToolFromHotbar:FireServer(1)
    end)

    LocalPlayer:SetAttribute("Loading", nil)

    task.spawn(function()
        task.wait(0.5) -- Wait for rod to equip

        while _G.FBlatant do
            FastestFishing()
            task.wait(_G.Reel)
        end
    end)
end

function StopBlatantFishing()
    _G.FBlatant = false
    LocalPlayer:SetAttribute("Loading", false)
end

function RecoveryFishing()
    task.spawn(function()
        pcall(function()
            CancelFishingInputs:InvokeServer()
        end)

        LocalPlayer:SetAttribute("Loading", nil)
        task.wait(0.05)
        LocalPlayer:SetAttribute("Loading", false)
    end)
end

function SetFishingDelay(delay)
    local num = tonumber(delay)
    if num and num > 0 then
        _G.FishingDelay = num
    end
end

function SetReelDelay(delay)
    local num = tonumber(delay)
    if num and num > 0 then
        _G.Reel = num
    end
end

bts:AddToggle({
    Title = "Blatant Fishing",
    Content = "",
    Default = false,
    Callback = function(enabled)
        if enabled then
            StartBlatantFishing()
        else
            StopBlatantFishing()
        end
    end
})

bts:AddInput({
    Title = "Fishing Delay",
    Placeholder = "1.1",
    Callback = function(value)
        SetFishingDelay(value)
    end
})

bts:AddInput({
    Title = "Reel Delay",
    Placeholder = "1.9",
    Callback = function(value)
        SetReelDelay(value)
    end
})

bts:AddButton({
    Title = "Manual Fix Stuck",
    Callback = function()
        RecoveryFishing()
        AIKO:MakeNotify({
            Title = "Aikoware",
            Description = "| Manual Fix",
            Content = "Stuck Fixed",
            Delay = 2
        })
    end
})

local ench = Fishing:AddSection("Enchant")

ench:AddToggle({
    Title = "Auto Enchant Rod",
    Content = "Automatically enchants your equipped rod.",
    Default = false,
    Callback = function()
        local enchantPosition = Vector3.new(3231, -1303, 1402)
        local character = workspace:WaitForChild("Characters"):FindFirstChild(LocalPlayer.Name)
        local hrp = character and character:FindFirstChild("HumanoidRootPart")

        if hrp then
            task.wait(3)

            local slot5 = LocalPlayer.PlayerGui.Backpack.Display:GetChildren()[10]
            local itemName = slot5 and slot5:FindFirstChild("Inner") and slot5.Inner:FindFirstChild("Tags") and slot5.Inner.Tags:FindFirstChild("ItemName")

            if itemName and itemName.Text:lower():find("enchant") then
                local originalPosition = hrp.Position
                task.wait(1)
                hrp.CFrame = CFrame.new(enchantPosition + Vector3.new(0, 5, 0))
                task.wait(1.2)

                pcall(function()
                    EquipToolFromHotbar:FireServer(5)
                    task.wait(0.5)
                    ActivateEnchantingAltar:FireServer()
                    task.wait(7)
                end)

                task.wait(0.9)
                hrp.CFrame = CFrame.new(originalPosition + Vector3.new(0, 3, 0))
            end
        end
    end
})

local ntf = Fishing:AddSection("Auto Fish Misc")

local function ToggleCaughtNotifications(visible)
    local notificationGui = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("Small Notification")
    if notificationGui then
        local display = notificationGui:FindFirstChild("Display")
        if display then
            for _, child in ipairs(display:GetChildren()) do
                if child:IsA("GuiObject") then
                    child.Visible = visible
                end
            end
        end
    end
end

local noNOTIF = ntf:AddToggle({
    Title = "Disable Fish Notification",
    Content = "",
    Default = false,
    Callback = function(enabled)
        ToggleCaughtNotifications(not enabled)
    end
})

local stopAnimConnections = {}

local function setGameAnimationsEnabled(state)
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    for _, conn in pairs(stopAnimConnections) do
        pcall(function() conn:Disconnect() end)
    end
    stopAnimConnections = {}

    if state then
        local animator = humanoid:FindFirstChildOfClass("Animator")
        if animator then
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                pcall(function() track:Stop(0) end)
            end

            local conn = animator.AnimationPlayed:Connect(function(track)
                task.defer(function()
                    pcall(function() track:Stop(0) end)
                end)
            end)
            table.insert(stopAnimConnections, conn)
        end
    end
end

local noANIMS = ntf:AddToggle({
    Title = "Disable Animations",
    Content = "",
    Default = false,
    Callback = function(state)
        setGameAnimationsEnabled(state)
    end
})

local originalCFrame = nil
local freezeConnection = nil

local freezeCHAR = ntf:AddToggle({
    Title = "Freeze Character",
    Content = "",
    Default = false,
    Callback = function(enabled)
        _G.FreezeCharacter = enabled

        if enabled then
            local character = LocalPlayer.Character
            local hrp = character and character:FindFirstChild("HumanoidRootPart")

            if hrp then
                originalCFrame = hrp.CFrame

                if freezeConnection then
                    freezeConnection:Disconnect()
                    freezeConnection = nil
                end

                freezeConnection = RunService.Heartbeat:Connect(function()
                    if _G.FreezeCharacter and hrp and hrp.Parent then
                        hrp.CFrame = originalCFrame
                        hrp.AssemblyLinearVelocity = Vector3.zero
                        hrp.AssemblyAngularVelocity = Vector3.zero
                    end
                end)
            end
        else
            if freezeConnection then
                freezeConnection:Disconnect()
                freezeConnection = nil
            end
        end
    end
})

local rds = Shop:AddSection("Rod Shop")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RFPurchaseFishingRod = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/PurchaseFishingRod"]

local rods = {
    ["Luck Rod"] = 79,
    ["Carbon Rod"] = 76,
    ["Grass Rod"] = 85,
    ["Demascus Rod"] = 77,
    ["Ice Rod"] = 78,
    ["Lucky Rod"] = 4,
    ["Midnight Rod"] = 80,
    ["Steampunk Rod"] = 6,
    ["Chrome Rod"] = 7,
    ["Astral Rod"] = 5,
    ["Ares Rod"] = 126,
    ["Angler Rod"] = 168
}

local rodNames = {
    "Luck Rod", "Carbon Rod", "Grass Rod", "Demascus Rod",
    "Ice Rod", "Lucky Rod", "Midnight Rod", "Steampunk Rod",
    "Chrome Rod", "Astral Rod", "Ares Rod", "Angler Rod"
}

local rodKeyMap = {
    ["Luck Rod"]="Luck Rod",
    ["Carbon Rod"]="Carbon Rod",
    ["Grass Rod"]="Grass Rod",
    ["Demascus Rod"]="Demascus Rod",
    ["Ice Rod"]="Ice Rod",
    ["Lucky Rod"]="Lucky Rod",
    ["Midnight Rod"]="Midnight Rod",
    ["Steampunk Rod"]="Steampunk Rod",
    ["Chrome Rod"]="Chrome Rod",
    ["Astral Rod"]="Astral Rod",
    ["Ares Rod"]="Ares Rod",
    ["Angler Rod"]="Angler Rod"
}

local selectedRod = rodNames[1]

local selectROS = rds:AddDropdown({
    Title = "Select Rod",
    Content = "",
    Options = rodNames,
    Multi = false,
    Default = selectedRod,
    Callback = function(value)
        if type(value) == "table" then
            selectedRod = value[1] or rodNames[1]
        else
            selectedRod = value
        end
    end
})

rds:AddButton({
    Title = "Buy Rod",
    Content = "",
    Callback = function()
        local key = rodKeyMap[selectedRod]

        if key and rods[key] then
            local rodId = rods[key]

            local success, err = pcall(function()
                RFPurchaseFishingRod:InvokeServer(rodId)
            end)

            if success then
                    AIKO:MakeNotify({
                    Title = "Aikoware",
                    Description = "| Rod Purchase", 
                    Content = "Purchased " .. selectedRod, 
                    Delay = 3
                })
            else
                    AIKO:MakeNotify({
                    Title = "Aikoware",
                    Description = "| Rod Purchase Error", 
                    Content = tostring(err), 
                    Delay = 5
                })
            end
        else
                AIKO:MakeNotify({
                Title = "Aikoware",
                Description = "| Error", 
                Content = "Invalid rod selection", 
                Delay = 3
            })
        end
    end
})

local bs = Shop:AddSection("Bait Shop")

local RFPurchaseBait = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/PurchaseBait"]

local baits = {
    ["TopWater Bait"] = 10,
    ["Lucky Bait"] = 2,
    ["Midnight Bait"] = 3,
    ["Chroma Bait"] = 6,
    ["Dark Mater Bait"] = 8,
    ["Corrupt Bait"] = 15,
    ["Aether Bait"] = 16
}

local baitNames = {
    "TopWater Bait",
    "Lucky Bait",
    "Midnight Bait",
    "Chroma Bait",
    "Dark Mater Bait",
    "Corrupt Bait",
    "Aether Bait"
}

local baitKeyMap = {
    ["TopWater Bait"] = "TopWater Bait",
    ["Lucky Bait"] = "Lucky Bait",
    ["Midnight Bait"] = "Midnight Bait",
    ["Chroma Bait"] = "Chroma Bait",
    ["Dark Mater Bait"] = "Dark Mater Bait",
    ["Corrupt Bait"] = "Corrupt Bait",
    ["Aether Bait"] = "Aether Bait"
}

local selectedBait = baitNames[1]

local selectBAIT = bs:AddDropdown({
    Title = "Select Bait",
    Content = "",
    Options = baitNames,
    Default = selectedBait,
    Multi = false,
    Callback = function(value)
        if type(value) == "table" then
            selectedBait = value[1] or baitNames[1]
        else
            selectedBait = value
        end
    end
})

bs:AddButton({
    Title = "Buy Bait",
    Content = "",
    Callback = function()
        local key = baitKeyMap[selectedBait]

        if key and baits[key] then
            local baitId = baits[key]

            local success, err = pcall(function()
                RFPurchaseBait:InvokeServer(baitId)
            end)

            if success then
                    AIKO:MakeNotify({
                    Title = "Aikoware",
                    Description = "| Bait Purchase",
                    Content = "Purchased " .. selectedBait,
                    Delay = 3
                })
            else
                    AIKO:MakeNotify({
                    Title = "Aikoware",
                    Description = "| Bait Purchase Error",
                    Content = tostring(err),
                    Delay = 5
                })
            end
        else
                AIKO:MakeNotify({
                Title = "Aikoware",
                Description = "| Error",
                Content = "Invalid bait selection",
                Delay = 3
            })
        end
    end
})

local bos = Shop:AddSection("Boat Shop")

local RFPurchaseBoat = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/PurchaseBoat"]

local boatOrder = {
    "Small Boat",
    "Kayak",
    "Jetski",
    "Highfield",
    "Speed Boat",
    "Fishing Boat",
    "Mini Yacht",
    "Hyper Boat",
    "Frozen Boat",
    "Cruiser Boat"
}

local boats = {
    ["Small Boat"] = {Id = 1, Price = 300},
    ["Kayak"] = {Id = 2, Price = 1100},
    ["Jetski"] = {Id = 3, Price = 7500},
    ["Highfield"] = {Id = 4, Price = 25000},
    ["Speed Boat"] = {Id = 5, Price = 70000},
    ["Fishing Boat"] = {Id = 6, Price = 180000},
    ["Mini Yacht"] = {Id = 14, Price = 1200000},
    ["Hyper Boat"] = {Id = 7, Price = 999000},
    ["Frozen Boat"] = {Id = 11, Price = 0},
    ["Cruiser Boat"] = {Id = 13, Price = 0}
}

local boatNames = {}
for _, name in ipairs(boatOrder) do
    local data = boats[name]
    local priceStr
    if data.Price >= 1000000 then
        priceStr = string.format("%.2fM Coins", data.Price/1000000)
    elseif data.Price >= 1000 then
        priceStr = string.format("%.0fk Coins", data.Price/1000)
    else
        priceStr = data.Price.." Coins"
    end
    table.insert(boatNames, name.." ("..priceStr..")")
end

local boatKeyMap = {}
for _, displayName in ipairs(boatNames) do
    local nameOnly = displayName:match("^(.-) %(")
    boatKeyMap[displayName] = nameOnly
end

local selectedBoat = boatNames[1]

local selectBOAT = bos:AddDropdown({
    Title = "Select Boat",
    Content = "",
    Options = boatNames,
    Default = selectedBoat,
    Multi = false,
    Callback = function(value)
        if type(value) == "table" then
            selectedBoat = value[1] or boatNames[1]
        else
            selectedBoat = value
        end
    end
})

bos:AddButton({
    Title = "Buy Boat",
    Content = "",
    Callback = function()
        local key = boatKeyMap[selectedBoat]

        if key and boats[key] then
            local boatId = boats[key].Id

            local success, err = pcall(function()
                RFPurchaseBoat:InvokeServer(boatId)
            end)

            if success then
                    AIKO:MakeNotify({
                    Title = "Aikoware",
                    Description = "| Boat Purchase",
                    Content = "Purchased " .. selectedBoat,
                    Delay = 3
                })
            else
                    AIKO:MakeNotify({
                    Title = "Aikoware",
                    Description = "| Boat Purchase Error",
                    Content = tostring(err),
                    Delay = 5
                })
            end
        else
                AIKO:MakeNotify({
                Title = "Aikoware",
                Description = "| Error",
                Content = "Invalid boat selection",
                Delay = 3
            })
        end
    end
})

local ws = Shop:AddSection("Weather Shop")

local weathers = {
    ["Wind"] = 10000,
    ["Snow"] = 15000,
    ["Cloudy"] = 20000,
    ["Storm"] = 35000,
    ["Radiant"] = 50000,
    ["Shark Hunt"] = 300000
}

local weatherNames = {
    "Wind", "Snow", "Cloudy", "Storm",
    "Radiant", "Shark Hunt"
}

local weatherKeyMap = {
    ["Wind"] = "Wind",
    ["Snow"] = "Snow",
    ["Cloudy"] = "Cloudy",
    ["Storm"] = "Storm",
    ["Radiant"] = "Radiant",
    ["Shark Hunt"] = "Shark Hunt"
}

local selectedWeathers = {}

local selectWEATHER = ws:AddDropdown({
    Title = "Select Weather(s)",
    Content = "",
    Options = weatherNames,
    Default = {},
    Multi = true,
    Callback = function(values)
        selectedWeathers = values
    end
})

local autoBuyEnabled = false
local buyDelay = 0.

local function startAutoBuy()
    task.spawn(function()
        while autoBuyEnabled do
            for _, displayName in ipairs(selectedWeathers) do
                local key = weatherKeyMap[displayName]
                if key and weathers[key] then
                    local success, err = pcall(function()
                        RFPurchaseWeatherEvent:InvokeServer(key)
                    end)
                    if not success then
                        aiko("Error buying weather:", err)
                    end
                    task.wait(buyDelay)
                end
            end
            task.wait(0.1)
        end
    end)
end

local autobuyweather = ws:AddToggle({
    Title = "Auto Buy Weather",
    Content = "Automatically purchase selected weather(s).",
    Default = false,
    Callback = function(state)
        autoBuyEnabled = state
        if state then
            startAutoBuy()
        end
    end
})

local merch = Shop:AddSection("Merchant")

local MerchantUI = {
    Main = PlayerGui.Merchant,
    ItemsFrame = PlayerGui.Merchant.Main.Background.Items.ScrollingFrame,
    RefreshLabel = PlayerGui.Merchant.Main.Background.RefreshLabel
}

ShopParagraph = merch:AddParagraph({
    Title = "Merchant Stock:",
    Icon = "shop",
    Content = "Loading..."
})

merch:AddButton({
    Title = "Toggle Merchant UI",
    Callback = function()
        local merchant = PlayerGui:FindFirstChild("Merchant")
        if merchant then
            merchant.Enabled = not merchant.Enabled
        end
    end
})

function UPX()
    local items = {}
    
    for _, child in ipairs(MerchantUI.ItemsFrame:GetChildren()) do
        if child:IsA("ImageLabel") and child.Name ~= "Frame" then
            local frame = child:FindFirstChild("Frame")
            if frame and frame:FindFirstChild("ItemName") then
                local itemName = frame.ItemName.Text
                if not string.find(itemName, "Mystery") then
                    table.insert(items, "- " .. itemName)
                end
            end
        end
    end
    
    if #items > 0 then
        ShopParagraph:SetContent(table.concat(items, "<br/>") .. "<br/><br/>" .. MerchantUI.RefreshLabel.Text)
    else
        ShopParagraph:SetContent("No items found\n" .. MerchantUI.RefreshLabel.Text)
    end
end

task.spawn(function()
    while task.wait(1) do
        pcall(UPX)
    end
end)

local sell = Shop:AddSection("Sell")

local sellThreshold = 30
local autoSellEnabled = false

local sellDELAY = sell:AddInput({
    Title = "Auto Sell Delay",
    Content = "",
    Placeholder = "30",
    Callback = function(value)
        local num = tonumber(value)
        if num and num > 0 then
            sellThreshold = num
        end
    end
})

local autoSELL = sell:AddToggle({
    Title = "Auto Sell",
    Content = "Sell when threshold reached.",
    Default = false,
    Callback = function(state)
        autoSellEnabled = state

        if state then
            task.spawn(function()
                while autoSellEnabled do
                    task.wait(5)

                    local Replion = require(ReplicatedStorage.Packages.Replion)
                    local Data = Replion.Client:WaitReplion("Data")
                    local inventoryData = Data:Get("Inventory")

                    if inventoryData and inventoryData.Items then
                        local count = 0
                        for _ in pairs(inventoryData.Items) do
                            count = count + 1
                        end

                        if count >= sellThreshold then
                            SellAllItems:InvokeServer()
                        end
                    end
                end
            end)
        end
    end
})

sell:AddButton({
    Title = "Sell All Fish",
    Content = "Instanly sells non-favorite fish.",
    Callback = function()
        local RFSellAllItems = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/SellAllItems"]

        pcall(function()
            RFSellAllItems:InvokeServer()
        end)

    end
})

_G.AutoFavoriteRarities = _G.AutoFavoriteRarities or {}

local fav = Favo:AddSection("Auto Favorite")

local GlobalFav = {
    REObtainedNewFishNotification = net:WaitForChild("RE/ObtainedNewFishNotification"),
    REFavoriteItem = net:WaitForChild("RE/FavoriteItem"),

    FishIdToName = {},
    FishNameToId = {},
    FishIdToTier = {},
    FishNames = {},
    Variants = {},
    VariantIdToName = {},
    VariantNameToId = {},

    SelectedFishIds = {},
    SelectedVariants = {},
    SelectedRarities = {},
    AutoFavoriteEnabled = false
}

for _, item in pairs(ReplicatedStorage.Items:GetChildren()) do
    local ok, data = pcall(require, item)
    if ok and data.Data and data.Data.Type == "Fish" then
        local id = data.Data.Id
        local name = data.Data.Name
        local tier = data.Data.Tier
        GlobalFav.FishIdToName[id] = name
        GlobalFav.FishNameToId[name] = id
        GlobalFav.FishIdToTier[id] = tier
        table.insert(GlobalFav.FishNames, name)
    end
end

for _, variantModule in pairs(ReplicatedStorage.Variants:GetChildren()) do
    local ok, variantData = pcall(require, variantModule)
    if ok and variantData.Data then
        local id = variantData.Data.Id
        local name = variantData.Data.Name
        if id and name then
            GlobalFav.VariantIdToName[id] = name
            GlobalFav.VariantNameToId[name] = id
            table.insert(GlobalFav.Variants, name)
        end
    end
end

table.sort(GlobalFav.FishNames)
table.sort(GlobalFav.Variants)

local TierNames = {
    ["Common"] = "Common",
    ["Uncommon"] = "Uncommon", 
    ["Rare"] = "Rare",
    ["Epic"] = "Epic",
    ["Legendary"] = "Legendary",
    ["Mythic"] = "Mythic",
    ["Secret"] = "Secret",
    [1] = "Common",
    [2] = "Uncommon",
    [3] = "Rare",
    [4] = "Epic",
    [5] = "Legendary",
    [6] = "Mythic",
    [7] = "Secret",
    [0] = "Common"
}

local function GetTierName(tier)
    if type(tier) == "string" then
        return TierNames[tier] or tier
    elseif type(tier) == "number" then
        return TierNames[tier] or "Unknown"
    else
        return "Unknown"
    end
end

local autoFAV = fav:AddToggle({
    Title = "Enable Auto Favorite",
    Content = "",
    Default = false,
    Callback = function(state)
        GlobalFav.AutoFavoriteEnabled = state
    end
})

local selectFishes = fav:AddDropdown({
    Title = "Select Fish",
    Content = "",
    Options = GlobalFav.FishNames,
    Multi = true,
    Default = {},
    Callback = function(selectedNames)
        GlobalFav.SelectedFishIds = {}
        for _, name in ipairs(selectedNames) do
            local id = GlobalFav.FishNameToId[name]
            if id then
                GlobalFav.SelectedFishIds[id] = true
            end
        end
    end
})

local selectRarities = fav:AddDropdown({
    Title = "Rarity",
    Content = "",
    Options = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Secret"},
    Multi = true,
    Default = {},
    Callback = function(selectedRarities)
        _G.AutoFavoriteRarities = {}
        GlobalFav.SelectedRarities = {}
        
        for _, rarity in ipairs(selectedRarities) do
            _G.AutoFavoriteRarities[rarity] = true
            GlobalFav.SelectedRarities[rarity] = true
        end
        
        local count = 0
        for _ in pairs(_G.AutoFavoriteRarities) do
            count = count + 1
        end
    end
})

local selectMutations = fav:AddDropdown({
    Title = "Select Mutation",
    Content = "",
    Options = GlobalFav.Variants,
    Multi = true,
    Default = {},
    Callback = function(selectedNames)
        GlobalFav.SelectedVariants = {}
        for _, name in ipairs(selectedNames) do
            local id = GlobalFav.VariantNameToId[name]
            if id then
                GlobalFav.SelectedVariants[id] = true
            end
        end
    end
})

GlobalFav.REObtainedNewFishNotification.OnClientEvent:Connect(function(itemId, _, data)
    if not GlobalFav.AutoFavoriteEnabled then return end

    local uuid = data.InventoryItem and data.InventoryItem.UUID
    if not uuid then return end

    local fishName = GlobalFav.FishIdToName[itemId] or "Unknown"
    local fishTier = GlobalFav.FishIdToTier[itemId]
    local tierName = GetTierName(fishTier)
    local variantId = data.InventoryItem.Metadata and data.InventoryItem.Metadata.VariantId

    local shouldFavorite = false
    local reason = ""

    local isFishSelected = GlobalFav.SelectedFishIds[itemId]
    
    local isRaritySelected = GlobalFav.SelectedRarities[tierName] == true
    
    local isVariantSelected = variantId and GlobalFav.SelectedVariants[variantId]

    if isFishSelected then
        shouldFavorite = true
        reason = "Fish: " .. fishName
    end

    if isRaritySelected then
        shouldFavorite = true
        reason = reason .. (reason ~= "" and " + " or "") .. "Rarity: " .. tierName
    end

    if isVariantSelected then
        shouldFavorite = true
        local variantName = GlobalFav.VariantIdToName[variantId] or "Unknown Variant"
        reason = reason .. (reason ~= "" and " + " or "") .. "Variant: " .. variantName
    end

    if shouldFavorite then
        pcall(function()
            GlobalFav.REFavoriteItem:FireServer(uuid)
        end)
    end
end)

fav:AddButton({
    Title = "Clear Rarity Selection",
    Content = "Clear all selected rarities",
    Callback = function()
        _G.AutoFavoriteRarities = {}
        GlobalFav.SelectedRarities = {}
        AIKO:MakeNotify({
            Title = "Aikoware",
            Description = "| Cleared",
            Content = "Rarity selection cleared",
            Delay = 2
        })
    end
})

fav:AddButton({
    Title = "Clear Variant Selection",
    Content = "Clear all selected variants",
    Callback = function()
        GlobalFav.SelectedVariants = {}
        AIKO:MakeNotify({
            Title = "Aikoware",
            Description = "| Cleared",
            Content = "Variant selection cleared",
            Delay = 2
        })
    end
})

local TeleportData = loadstring(game:HttpGet("https://raw.githubusercontent.com/a11bove/kdoaz/refs/heads/main/xzc/fishit/tpmdl.lua"))()

local loc = Teleport:AddSection("Location")

local locationNames = {}
for name, _ in pairs(TeleportData.Locations) do
    table.insert(locationNames, name)
end
table.sort(locationNames)

local selectedLocation = nil

local locationDropdown = loc:AddDropdown({
    Title = "Select Location",
    Content = "",
    Multi = false,
    Options = locationNames,
    Default = {},
    Callback = function(value)
        if type(value) == "table" and #value > 0 then
            selectedLocation = value[1]
        elseif type(value) == "string" then
            selectedLocation = value
        else
            selectedLocation = nil
        end
    end
})

loc:AddButton({
    Title = "Teleport to Location",
    Content = "",
    Callback = function()
        if selectedLocation and TeleportData.Locations[selectedLocation] then
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(TeleportData.Locations[selectedLocation])
                    AIKO:MakeNotify({
                    Title = "Aikoware",
                    Description = "| Teleported",
                    Content = "Teleported to " .. selectedLocation,
                    Delay = 3
                })
            end
        else
                AIKO:MakeNotify({
                Title = "Aikoware",
                Description = "| Error",
                Content = "No location selected",
                Delay = 3
            })
        end
    end
})

local npcl = Teleport:AddSection("NPC")

local npcNames = {}
for name, _ in pairs(TeleportData.NPCs) do
    table.insert(npcNames, name)
end
table.sort(npcNames)

local selectedNPC = nil

local npcDropdown = npcl:AddDropdown({
    Title = "Select NPC",
    Content = "",
    Options = npcNames,
    Default = {},
    Multi = false,
    Callback = function(value)
        if type(value) == "table" and #value > 0 then
            selectedNPC = value[1]
        elseif type(value) == "string" then
            selectedNPC = value
        else
            selectedNPC = nil
        end
    end
})

npcl:AddButton({
    Title = "Teleport to NPC",
    Content = "",
    Callback = function()
        if selectedNPC and TeleportData.NPCs[selectedNPC] then
            local targetCFrame = TeleportData.NPCs[selectedNPC]
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                character:PivotTo(targetCFrame)
                    AIKO:MakeNotify({
                    Title = "Aikoware",
                    Description = "| Teleported",
                    Content = "Teleported to " .. selectedNPC,
                    Delay = 3
                })
            end
        else
                AIKO:MakeNotify({
                Title = "Aikoware",
                Description = "| Error",
                Content = "No NPC selected",
                Delay = 3
            })
        end
    end
})

local mach = Teleport:AddSection("Machines")

local machineNames = {}
for name, _ in pairs(TeleportData.Machines) do
    table.insert(machineNames, name)
end
table.sort(machineNames)

local selectedMachine = nil

local machineDropdown = mach:AddDropdown({
    Title = "Select Machine",
    Content = "",
    Options = machineNames,
    Default = {},
    Multi = false,
    Callback = function(value)
        if type(value) == "table" and #value > 0 then
            selectedMachine = value[1]
        elseif type(value) == "string" then
            selectedMachine = value
        else
            selectedMachine = nil
        end
    end
})

mach:AddButton({
    Title = "Teleport to Machine",
    Content = "",
    Callback = function()
        if selectedMachine and TeleportData.Machines[selectedMachine] then
            local targetCFrame = TeleportData.Machines[selectedMachine]
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                character:PivotTo(targetCFrame)
                    AIKO:MakeNotify({
                    Title = "Aikoware",
                    Description = "| Teleported",
                    Content = "Teleported to " .. selectedMachine,
                    Delay = 3
                })
            end
        else
                AIKO:MakeNotify({
                Title = "Aikoware",
                Description = "| Error",
                Content = "No machine selected",
                Delay = 3
            })
        end
    end
})

local EventSettings = {
    autoEventActive = false,
    selectedEvents = {},
    priorityEvent = nil,
    currentCFrame = nil,
    originalCFrame = nil,
    floatingEnabled = false,
    floatingConnection = nil,
    lastState = nil,
    offsets = {
        ["Worm Hunt"] = 25
    }
}

local IgnoredEvents = {
    Cloudy = true,
    Day = true,
    ["Increased Luck"] = true,
    Mutated = true,
    Night = true,
    Snow = true,
    ["Sparkling Cove"] = true,
    Storm = true,
    Wind = true,
    UIListLayout = true,
    ["Admin - Shocked"] = true,
    ["Admin - Super Mutated"] = true,
    Radiant = true
}

local function getCharacterRoot(character)
    if character then
        return character:FindFirstChild("HumanoidRootPart") or 
               character:FindFirstChildWhichIsA("BasePart")
    end
    return nil
end

local function setupWaterWalking(character, rootPart, enabled)
    if EventSettings.floatingEnabled and EventSettings.floatingConnection then
        EventSettings.floatingConnection:Disconnect()
    end
    
    EventSettings.floatingEnabled = enabled or false
    
    if enabled then
        local waterPart = Workspace:FindFirstChild("WW_Part") or Instance.new("Part")
        waterPart.Name = "WW_Part"
        waterPart.Size = Vector3.new(15, 1, 15)
        waterPart.Anchored = true
        waterPart.CanCollide = false
        waterPart.Transparency = 1
        waterPart.Material = Enum.Material.SmoothPlastic
        waterPart.Parent = Workspace
        
        local waterLevel = -1.8
        
        EventSettings.floatingConnection = RunService.Heartbeat:Connect(function()
            if character and rootPart and waterPart then
                waterPart.Position = Vector3.new(rootPart.Position.X, waterLevel, rootPart.Position.Z)
                waterPart.CanCollide = waterLevel < rootPart.Position.Y
            end
        end)
    else
        local existingPart = Workspace:FindFirstChild("WW_Part")
        if existingPart then
            existingPart:Destroy()
        end
    end
end

local function getAvailableEvents()
    local events = {}
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    local eventsGui = playerGui:FindFirstChild("Events")
    
    if not eventsGui then return events end
    
    local frame = eventsGui:FindFirstChild("Frame")
    if frame then
        frame = frame:FindFirstChild("Events")
    end
    
    if frame then
        for _, child in ipairs(frame:GetChildren()) do
            local displayName = nil
            
            if child:IsA("Frame") then
                local displayLabel = child:FindFirstChild("DisplayName")
                if displayLabel and displayLabel:IsA("TextLabel") then
                    displayName = displayLabel.Text
                end
            end
            
            if not displayName or displayName == "" then
                displayName = child.Name
            end
            
            if typeof(displayName) == "string" and 
               displayName ~= "" and 
               displayName ~= "UIListLayout" and
               not IgnoredEvents[displayName] then
                local cleanName = displayName:gsub("^Admin %- ", "")
                table.insert(events, cleanName)
            end
        end
    end
    
    return events
end

local function findEventLocation(eventName)
    if not eventName then return nil end
    
    if eventName == "Megalodon Hunt" then
        local menuRings = Workspace:FindFirstChild("!!! MENU RINGS")
        if menuRings then
            for _, ring in ipairs(menuRings:GetChildren()) do
                local megalodonEvent = ring:FindFirstChild("Megalodon Hunt")
                if megalodonEvent then
                    megalodonEvent = megalodonEvent:FindFirstChild("Megalodon Hunt")
                end
                
                if megalodonEvent and megalodonEvent:IsA("BasePart") then
                    return megalodonEvent
                end
            end
        end
    else
        local propsLocations = {Workspace:FindFirstChild("Props")}
        local menuRings = Workspace:FindFirstChild("!!! MENU RINGS")
        
        if menuRings then
            for _, ring in ipairs(menuRings:GetChildren()) do
                if ring.Name:match("^Props") then
                    table.insert(propsLocations, ring)
                end
            end
        end
        
        for _, propsFolder in ipairs(propsLocations) do
            if propsFolder then
                for _, model in ipairs(propsFolder:GetChildren()) do
                    for _, descendant in ipairs(model:GetDescendants()) do
                        if descendant:IsA("TextLabel") and 
                           descendant.Name == "DisplayName" then
                            local text = (descendant.ContentText ~= "" and 
                                        descendant.ContentText) or descendant.Text
                            
                            if text:lower() == eventName:lower() then
                                local parentModel = descendant:FindFirstAncestorOfClass("Model")
                                local part = parentModel and 
                                           parentModel:FindFirstChild("Part") or 
                                           model:FindFirstChild("Part")
                                
                                if part and part:IsA("BasePart") then
                                    return part
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    return nil
end

local function updateEventStatus(message)
    if EventSettings.lastState ~= message then
        EventSettings.lastState = message
    end
end

function EventSettings.loop()
    while EventSettings.autoEventActive do
        local targetEvent = nil
        local targetLocation = nil
        
        if EventSettings.priorityEvent then
            targetLocation = findEventLocation(EventSettings.priorityEvent)
            if targetLocation then
                targetEvent = EventSettings.priorityEvent
            end
        end
        
        if not targetLocation and #EventSettings.selectedEvents > 0 then
            for _, eventName in ipairs(EventSettings.selectedEvents) do
                targetLocation = findEventLocation(eventName)
                if targetLocation then
                    targetEvent = eventName
                    break
                end
            end
        end
        
        local rootPart = getCharacterRoot(LocalPlayer.Character)
        
        if targetLocation and rootPart then
            if not EventSettings.originalCFrame then
                EventSettings.originalCFrame = rootPart.CFrame
            end
            
            if (rootPart.Position - targetLocation.Position).Magnitude > 40 then
                local offset = EventSettings.offsets[targetEvent] or 7
                EventSettings.currentCFrame = targetLocation.CFrame + Vector3.new(0, offset, 0)
                LocalPlayer.Character:PivotTo(EventSettings.currentCFrame)
                setupWaterWalking(LocalPlayer.Character, rootPart, true)
                task.wait(1)
                updateEventStatus("Event! " .. targetEvent)
            end
        elseif not targetLocation and EventSettings.currentCFrame and rootPart then
            setupWaterWalking(LocalPlayer.Character, nil, false)
            if EventSettings.originalCFrame then
                LocalPlayer.Character:PivotTo(EventSettings.originalCFrame)
                updateEventStatus("Event ended - Returned")
                EventSettings.originalCFrame = nil
            end
            EventSettings.currentCFrame = nil
        elseif not EventSettings.currentCFrame then
            updateEventStatus("Waiting for event...")
        end
        
        task.wait(0.2)
    end
    
    setupWaterWalking(LocalPlayer.Character, nil, false)
    if EventSettings.originalCFrame and LocalPlayer.Character then
        LocalPlayer.Character:PivotTo(EventSettings.originalCFrame)
        updateEventStatus("Auto Event disabled")
    end
    EventSettings.currentCFrame = nil
    EventSettings.originalCFrame = nil
end

LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    if EventSettings.autoEventActive then
        task.spawn(function()
            local rootPart = newCharacter:WaitForChild("HumanoidRootPart", 5)
            task.wait(0.3)
            
            if rootPart then
                if EventSettings.currentCFrame then
                    newCharacter:PivotTo(EventSettings.currentCFrame)
                    setupWaterWalking(newCharacter, rootPart, true)
                    task.wait(0.5)
                    updateEventStatus("Respawned at event")
                elseif EventSettings.originalCFrame then
                    newCharacter:PivotTo(EventSettings.originalCFrame)
                    setupWaterWalking(newCharacter, rootPart, true)
                    updateEventStatus("Returned to farm location")
                end
            end
        end)
    end
end)

local evt = Teleport:AddSection("Auto Event Teleport")

evt:AddParagraph({
    Title = "Event TP Info",
    Icon = "info",
    Content = "Make sure to select one option in Prioritize dropdown first. Otherwise, it will not work even if you selected one in Select Events dropdown.",
})

local priorityEventDropdown = evt:AddDropdown({
    Title = "Prioritize Event",
    Options = getAvailableEvents(),
    Multi = false,
    Default = {},
    Callback = function(selected)
        if type(selected) == "table" and #selected > 0 then
            EventSettings.priorityEvent = selected[1]
        elseif type(selected) == "string" then
            EventSettings.priorityEvent = selected
        else
            EventSettings.priorityEvent = nil
        end
    end
})

local selectedEventsDropdown = evt:AddDropdown({
    Title = "Select Events",
    Options = getAvailableEvents(),
    Multi = true,
    Default = {},
    Callback = function(selected)
        EventSettings.selectedEvents = {}
        for _, eventName in ipairs(selected) do
            table.insert(EventSettings.selectedEvents, eventName)
        end
    end
})

local autoEventToggle = evt:AddToggle({
    Title = "Auto Teleport to Event",
    Default = false,
    Callback = function(enabled)
        EventSettings.autoEventActive = enabled
        
        if enabled then
            if #EventSettings.selectedEvents == 0 and not EventSettings.priorityEvent then
                EventSettings.autoEventActive = false
                return
            end
            
            EventSettings.originalCFrame = EventSettings.originalCFrame or 
                                          getCharacterRoot(LocalPlayer.Character).CFrame
            task.spawn(EventSettings.loop)
        end
    end
})

evt:AddButton({
    Title = "Refresh Event List",
    Callback = function()
        local events = getAvailableEvents()
        priorityEventDropdown:Refresh(events)
        selectedEventsDropdown:Refresh(events)
        AIKO:MakeNotify({
            Title = "Aikoware",
            Description = "| Event List",
            Content = "Refreshed! Found " .. #events .. " events",
            Delay = 3
        })
    end
})

evt:AddButton({
    Title = "Teleport to Event",
    Callback = function()
        if EventSettings.priorityEvent then
            local eventPart = findEventLocation(EventSettings.priorityEvent)
            if eventPart then
                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local offset = EventSettings.offsets[EventSettings.priorityEvent] or 7
                    hrp.CFrame = eventPart.CFrame + Vector3.new(0, offset, 0)
                    AIKO:MakeNotify({
                        Title = "Aikoware",
                        Description = "| Teleported",
                        Content = "Teleported to " .. EventSettings.priorityEvent,
                        Delay = 3
                    })
                end
            else
                AIKO:MakeNotify({
                    Title = "Aikoware",
                    Description = "| Error",
                    Content = "Event not found or not active",
                    Delay = 3
                })
            end
        else
            AIKO:MakeNotify({
                Title = "Aikoware",
                Description = "| Error",
                Content = "No priority event selected",
                Delay = 3
            })
        end
    end
})

local ply = Teleport:AddSection("Player")

local selectedPlayer = nil

local playerDropdown = ply:AddDropdown({
    Title = "Select Player",
    Content = "",
    Options = TeleportData.GetPlayerNames(Players, LocalPlayer),
    Default = {},
    Multi = false,
    Callback = function(value)
        if type(value) == "table" and #value > 0 then
            selectedPlayer = value[1]
        elseif type(value) == "string" then
            selectedPlayer = value
        else
            selectedPlayer = nil
        end
    end
})

ply:AddButton({
    Title = "Teleport To Player",
    Content = "",
    Callback = function()
        if selectedPlayer then
            local targetPlayer = Players:FindFirstChild(selectedPlayer)
            local myChar = LocalPlayer.Character
            local hrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
            local targetChar = targetPlayer and targetPlayer.Character
            local targetHRP = targetChar and targetChar:FindFirstChild("HumanoidRootPart")

            if hrp and targetHRP then
                hrp.CFrame = targetHRP.CFrame + Vector3.new(0,5,0)
                    AIKO:MakeNotify({
                    Title = "Aikoware",
                    Description = "| Teleported", 
                    Content = "Teleported to " .. selectedPlayer, 
                    Delay = 3
                })
            else
                    AIKO:MakeNotify({
                    Title = "Aikoware",
                    Description = "| Error", 
                    Content = "Player not found or not loaded", 
                    Delay = 3
                })
            end
        else
                AIKO:MakeNotify({
                Title = "Aikoware",
                Description = "| Error", 
                Content = "No player selected", 
                Delay = 3
            })
        end
    end
})

ply:AddButton({
    Title = "Refresh Player List",
    Content = "",
    Callback = function()
        playerDropdown:Refresh(TeleportData.GetPlayerNames(Players, LocalPlayer))
            AIKO:MakeNotify({
            Title = "Aikoware",
            Description = "Refreshed", 
            Content = "Player list updated", 
            Delay = 3
        })
    end
})

local autotrade = Trade:AddSection("Auto Trade")

local TradeModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/a11bove/kdoaz/refs/heads/main/xzc/fishit/autotrademdl.lua"))()
local Trade = TradeModule(Players, LocalPlayer, ReplicatedStorage, Library)

local selectedTradePlayer = nil

local tradePlayerDropdown = autotrade:AddDropdown({
    Title = "Select Player",
    Content = "",
    Options = Trade.GetPlayerNames(),
    Default = {},
    Multi = false,
    Callback = function(value)
        if type(value) == "table" and #value > 0 then
            selectedTradePlayer = value[1]
        elseif type(value) == "string" then
            selectedTradePlayer = value
        else
            selectedTradePlayer = nil
        end
    end
})

autotrade:AddButton({
    Title = "Give Item",
    Content = "",
    Callback = function()
        if selectedTradePlayer then
            Trade.SendTradeRequest(selectedTradePlayer)
        else
                AIKO:MakeNotify({
                Title = "Aikoware",
                Description = "| Error",
                Content = "No player selected",
                Delay = 3
            })
        end
    end
})

local autoAccept = autotrade:AddToggle({
    Title = "Auto Accept Trade Requests",
    Content = "",
    Default = false,
    Callback = function(state)
        Trade.SetAutoAccept(state)
    end
})

autotrade:AddButton({
    Title = "Refresh Player List",
    Icon = "refresh-cw",
    Content = "",
    Callback = function()
        tradePlayerDropdown:Refresh(Trade.GetPlayerNames())
            AIKO:MakeNotify({
            Title = "Aikoware",
            Description = "| Refreshed", 
            Content = "Player list updated", 
            Delay = 3
        })
    end
})

local WebhookModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/a11bove/kdoaz/refs/heads/main/xzc/fishit/whmdl.lua"))()
WebhookModule.Initialize()

_G.WebhookRarities = _G.WebhookRarities or {}

local webhookSection = Webhook:AddSection("Webhook Settings")

local whurl = webhookSection:AddInput({
    Title = "Webhook URL",
    Default = _G.WebhookFlags.FishCaught.URL,
    Placeholder = "Paste discord webhook...",
    Callback = function(url)
        local cleanUrl = WebhookModule.CleanWebhookURL(url)
        if cleanUrl then
            _G.WebhookFlags.FishCaught.URL = cleanUrl
        end
    end
})

local whfish = webhookSection:AddToggle({
    Title = "Webhook Send",
    Default = _G.WebhookFlags.FishCaught.Enabled,
    Callback = function(enabled)
        _G.WebhookFlags.FishCaught.Enabled = enabled
    end
})

local whrarity = webhookSection:AddDropdown({
    Title = "Rarity Filter",
    Content = "Empty = All",
    Options = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Secret"},
    Multi = true,
    Default = {},
    Callback = function(selected)
        _G.WebhookRarities = {}
        for i, rarity in ipairs(selected) do
            _G.WebhookRarities[i] = rarity
        end
        
        local count = #_G.WebhookRarities
    end
})

webhookSection:AddButton({
    Title = "Test Fish Webhook",
    Callback = function()
        local success, message = WebhookModule.SendTestWebhook()
        AIKO:MakeNotify({
            Title = "Aikoware",
            Description = "| Test Webhook",
            Content = message,
            Delay = 3
        })
    end
})

webhookSection:AddDivider()

local whname = webhookSection:AddInput({
    Title = "Custom Name (Optional)",
    Default = _G.WebhookCustomName or "",
    Placeholder = "Leave blank to use Roblox name",
    Callback = function(name)
        _G.WebhookCustomName = name
    end
})

local disconnectSection = Webhook:AddSection("Webhook Disconnect Alert")

local dcurl = disconnectSection:AddInput({
    Title = "Webhook URL",
    Default = _G.WebhookFlags.Disconnect.URL,
    Placeholder = "Paste disconnect webhook...",
    Callback = function(url)
        local cleanUrl = WebhookModule.CleanWebhookURL(url)
        if cleanUrl then
            _G.WebhookFlags.Disconnect.URL = cleanUrl
        end
    end
})

local dcid = disconnectSection:AddInput({
    Title = "Discord ID (Optional)",
    Default = "",
    Placeholder = "Enter your Discord ID for ping...",
    Callback = function(id)
        if id and id ~= "" then
            _G.DiscordPingID = "<@" .. id:gsub("%D", "") .. ">"
        else
            _G.DiscordPingID = ""
        end
    end
})

local dcname = disconnectSection:AddInput({
    Title = "Custom Name (Optional)",
    Default = _G.DisconnectCustomName or "",
    Placeholder = "Custom name (blank = use Roblox name)",
    Callback = function(name)
        _G.DisconnectCustomName = name
    end
})

local dcrj = disconnectSection:AddToggle({
    Title = "Auto Rejoin On Disconnect",
    Content = "Send webhook and rejoin automatically",
    Default = _G.WebhookFlags.Disconnect.Enabled,
    Callback = function(enabled)
        _G.WebhookFlags.Disconnect.Enabled = enabled
    end
})

disconnectSection:AddButton({
    Title = "Test Disconnect Webhook",
    Callback = function()
        local success, message = WebhookModule.SendTestDisconnectWebhook()
    end
})

local MiscModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/a11bove/kdoaz/refs/heads/main/xzc/fishit/miscmdl.lua"))()
MiscModule:Initialize()

local idn = Misc:AddSection("Hide Identity")

local antiSolace = idn:AddToggle({
    Title = "Enable Hide Identity",
    Content = "",
    Default = true,
    Callback = function(enabled)
        MiscModule.Identity:Toggle(enabled)
    end
})

local uset = Misc:AddSection("User Settings")

local WALKSPEED = uset:AddSlider({
    Title = "Walkspeed",
    Content = "",
    Min = 18,
    Max = 200,
    Default = 18,
    Callback = function(value)
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = value
            end
        end
    end
})

uset:AddButton({
    Title = "Reset Walkspeed",
    Content = "Returns to default speed.",
    Callback = function()
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = 18
            end
        end
    end
})

local INFJUMP = uset:AddToggle({
    Title = "Inf Jump",
    Content = "",
    Default = false,
    Callback = function(enabled)
        MiscModule.InfiniteJump:Toggle(enabled)
    end
})

local perf = Misc:AddSection("Performance")

perf:AddButton({
    Title = "Low GFX",
    Content = "Ultra low graphics mode.",
    Callback = function()
        MiscModule.Performance:LowGFX()
    end
})

perf:AddToggle({
    Title = "Hide Players",
    Content = "",
    Default = false,
    Callback = function(enabled)
        if enabled then
            MiscModule.Performance:EnableHidePlayers()
        else
            MiscModule.Performance:DisableHidePlayers()
        end
    end
})

perf:AddToggle({
    Title = "Remove Shadows",
    Content = "",
    Default = false,
    Callback = function(enabled)
        MiscModule.Performance:RemoveShadows(enabled)
    end
})

perf:AddToggle({
    Title = "Remove Water Reflections",
    Content = "",
    Default = false,
    Callback = function(enabled)
        MiscModule.Performance:RemoveWaterReflections(enabled)
    end
})

perf:AddToggle({
    Title = "Remove Particles",
    Content = "",
    Default = false,
    Callback = function(enabled)
        MiscModule.Performance:RemoveParticles(enabled)
    end
})

perf:AddToggle({
    Title = "Remove Terrain Decorations",
    Content = "",
    Default = false,
    Callback = function(enabled)
        MiscModule.Performance:RemoveTerrainDecorations(enabled)
    end
})

local xpb = Misc:AddSection("Level Progress")

local xpProgress = xpb:AddToggle({
    Title = "Show Level Progress Bar",
    Content = "",
    Default = true,
    Callback = function(state)
        MiscModule.XPBar:Toggle(state)
    end
})

local oxy = Misc:AddSection("Infinite Oxygen")

local antiDrown = oxy:AddToggle({
    Title = "Anti Drown",
    Content = "",
    Default = false,
    Callback = function(state)
        MiscModule.AntiDrown:Toggle(state)
    end,
})

local zooom = Misc:AddSection("Max Zoom")

function SetMaxZoom(distance)
    local player = game:GetService("Players").LocalPlayer
    if player then
        player.CameraMaxZoomDistance = distance
        player.CameraMinZoomDistance = distance
    end
end


local maxzoom = zooom:AddInput({
    Title = "Camera Max Zoom",
    Default = "128",
    Placeholder = "Enter zoom distance...",
    Callback = function(value)
        local zoomDistance = tonumber(value)
        if zoomDistance and zoomDistance > 0 then
            Player.CameraMaxZoomDistance = zoomDistance
            Player.CameraMinZoomDistance = 0.5
        end
    end
})

function BypassRadar(enabled)
    pcall(function()
        NetworkFunctions.UpdateRadar:InvokeServer(enabled)
    end)
end

local radsr = Misc:AddSection("Fishing Radar")

local fishrad = radsr:AddToggle({
    Title = "Fishing Radar",
    Default = false,
    Callback = function(enabled)
        pcall(function()
            NetworkFunctions.UpdateRadar:InvokeServer(enabled)
        end)
    end
})

AIKO:MakeNotify({
    Title = "Aikoware",
    Description = "Script Loaded",
    Content = "Game: Fish It",
    Delay = 5
})
