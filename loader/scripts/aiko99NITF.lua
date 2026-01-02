local AIKO = loadstring(game:HttpGet("https://raw.githubusercontent.com/a11bove/kdoaz/refs/heads/main/src/Library.lua"))()

local Window = AIKO:Window({
    Title   = "Aikoware",
    Footer  = "| made by @aoki!",
    Version = 1,
})

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local player = Players.LocalPlayer
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local Stats = game:GetService("Stats")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local workspace = Workspace
local character = player.Character or player.CharacterAdded:Wait()
local HumanoidRootPart = character:WaitForChild("HumanoidRootPart")
local Character = character
local rs = ReplicatedStorage

-- modular yarn
local FlyModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/a11bove/kdoaz/refs/heads/main/xzc/99nitf/flynitf.lua"))()

local ESPModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/a11bove/kdoaz/refs/heads/main/xzc/99nitf/espmdl.lua"))()

local AutoPlantModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/a11bove/kdoaz/refs/heads/main/xzc/99nitf/autoplantmdl.lua"))()

local AuraModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/a11bove/kdoaz/refs/heads/main/xzc/99nitf/auramdl.lua"))()

local VisionModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/a11bove/kdoaz/refs/heads/main/xzc/99nitf/envmdl.lua"))()

local FunModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/a11bove/kdoaz/refs/heads/main/xzc/99nitf/funmdl.lua"))()

local AntiModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/a11bove/kdoaz/refs/heads/main/xzc/99nitf/antmdl.lua"))()

local TeleportModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/a11bove/kdoaz/refs/heads/main/xzc/99nitf/tpmdl.lua"))()

local BringModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/a11bove/kdoaz/refs/heads/main/xzc/99nitf/bringmdl.lua"))()

local MiscModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/a11bove/kdoaz/refs/heads/main/xzc/99nitf/miscmdl.lua"))()

local ScanModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/a11bove/kdoaz/refs/heads/main/xzc/99nitf/scanmdl.lua"))()

-- start
local currentChests, currentChestNames = TeleportModule.getChests()
local selectedChest = currentChestNames[1] or nil

local currentMobs, currentMobNames = TeleportModule.getMobs()
local selectedMob = currentMobNames[1] or nil

local flyToggle = FlyModule.flyToggle
local flySpeed = FlyModule.flySpeed
local FLYING = FlyModule.FLYING
local sFLY = FlyModule.sFLY
local NOFLY = FlyModule.NOFLY
local MobileFly = FlyModule.MobileFly
local UnMobileFly = FlyModule.UnMobileFly

local alimentos = {
    "Apple",
    "Berry",
    "Carrot",
    "Cake",
    "Chili",
    "Cooked Clownfish",
    "Cooked Swordfish",
    "Cooked Jellyfish",
    "Cooked Char",
    "Cooked Eel",
    "Cooked Shark",
    "Cooked Ribs",
    "Cooked Mackerel",
    "Cooked Salmon",
    "Cooked Morsel",
    "Cooked Steak"
}

local ie = {
    "Bandage", "Bolt", "Broken Fan", "Broken Microwave", "Cake", "Apple", "Carrot", "Chair", "Coal", "Coin Stack",
    "Cooked Morsel", "Cooked Steak", "Fuel Canister", "Iron Body", "Leather Body", "Obsidiron Body", "Log", "MadKit", "Metal Chair",
    "MedKit", "Old Car Engine", "Old Flashlight", "Old Radio", "Revolver", "Revolver Ammo", "Rifle", "Rifle Ammo",
    "Morsel", "Sheet Metal", "Steak", "Tyre", "Washing Machine", "Cultist Gem", "Cultist Staff", "Gem of the Forest Fragment", "Frozen Shuriken",
    "Tactical Shotgun", "Snowball", "Kunai", "Infernal Sword", "Infernal Sack", "Infernal Crossbow", "Crossbow", "Good Axe", "Good Sack",
}

local me = {"Bunny", "Wolf", "Alpha Wolf", "Bear", "Crossbow Cultist", "Alien", "Alien Elite", "Polar Bear", "Arctic Fox", "Meteor Crab", "Mammoth", "Cultist", "Cultist Melee", "Cultist Crossbow", "Cultist Juggernaut"}

local craftableItems = {
    "Map", "Old Bed", "Bunny Trap", "Crafting Bench 2", "Sun Dial",
    "Regular Bed", "Compass", "Freezer", "Farm Plot", "Wood Rain Storage",
    "Shelf", "Log Wall", "Bear Trap", "Crock Pot", "Good Bed", "Radar",
    "Boost Pad", "Biofuel Processor", "Lighting Rod", "Torch", "Ammo Crate",
    "Giant Bed", "Oil Dril", "Teleporter", "Respawn Capsule",
    "Temporal Accelerometer", "Weather Machine"
}

local selectedCraftItems = {}

local campfireFuelItems = {"Log", "Coal", "Chair", "Fuel Canister", "Oil Barrel", "Biofuel"}
local campfireDropPos = Vector3.new(0, 19, 0)
local selectedCampfireItem = nil
local autoUpgradeCampfireEnabled = false

local scrapjunkItems = {"Log", "Chair", "Tyre", "Bolt", "Broken Fan", "Broken Microwave", "Sheet Metal", "Old Radio", "Washing Machine", "Old Car Engine", "Cultist Gem", "Gem of the Forest Fragment"}
local autoScrapPos = Vector3.new(21, 20, -5)
local selectedScrapItem = nil
local autoScrapItemsEnabled = false

local autocookItems = {"Morsel", "Steak", "Ribs", "Salmon", "Mackerel"}
local autoCookEnabledItems = {}
local autoCookEnabled = false

function wiki(nome)
    local c = 0
    for _, i in ipairs(Workspace.Items:GetChildren()) do
        if i.Name == nome then
            c = c + 1
        end
    end
    return c
end

function ghn()
    return math.floor(LocalPlayer.PlayerGui.Interface.StatBars.HungerBar.Bar.Size.X.Scale * 100)
end

function feed(nome)
    for _, item in ipairs(Workspace.Items:GetChildren()) do
        if item.Name == nome then
            ReplicatedStorage.RemoteEvents.RequestConsumeItem:InvokeServer(item)
            break
        end
    end
end

function notifeed(nome)
    AIKO:MakeNotify({
        Title = "Aikoware",
        Description = "| Auto Eat Paused",
        Content = "The food is gone!",
        Color = Color3.fromRGB(255,100,100),
        Delay = 3
    })
end

local function moveItemToPos(item, position)
    if not item or not item:IsDescendantOf(workspace) or not item:IsA("BasePart") and not item:IsA("Model") then return end
    local part = item:IsA("Model") and (item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart") or item:FindFirstChild("Handle")) or item
    if not part or not part:IsA("BasePart") then return end

    if item:IsA("Model") and not item.PrimaryPart then
        pcall(function() item.PrimaryPart = part end)
    end

    pcall(function()
        game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents").RequestStartDraggingItem:FireServer(item)
        if item:IsA("Model") then
            item:SetPrimaryPartCFrame(CFrame.new(position))
        else
            part.CFrame = CFrame.new(position)
        end
        game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents").StopDraggingItem:FireServer(item)
    end)
end

_G.playerBillboards = {}
_G.EspPlayerOn = false
_G.EspSize = 18

function createPlayerNameBillboard(player)
    if not player or not player.Character then
        return nil
    end

    local character = player.Character
    local head = character:FindFirstChild("Head")

    if not head then
        return nil
    end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "PlayerNameBillboard"
    billboard.Size = UDim2.new(0, 100, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.Parent = head

    local label = Instance.new("TextLabel")
    label.Name = "NameLabel"
    label.Size = UDim2.new(1, 0, 1, 0)  
    label.BackgroundTransparency = 1
    label.Text = player.Name
    label.TextColor3 = Color3.new(1, 1, 1) 
    label.TextSize = _G.EspSize  
    label.TextScaled = false  
    label.Font = Enum.Font.Cartoon
    label.Parent = billboard

    _G.playerBillboards[player.Name] = billboard

    return billboard
end

for _, player in pairs(game:GetService("Players"):GetPlayers()) do
    if player ~= game:GetService("Players").LocalPlayer then
        createPlayerNameBillboard(player)
    end
end

game:GetService("Players").PlayerAdded:Connect(function(player)
    if player ~= game:GetService("Players").LocalPlayer then
        player.CharacterAdded:Connect(function()
            createPlayerNameBillboard(player)
        end)
    end
end)

local showFPS, showPing, showPlayers = true, true, false
local fpsCounter, fpsLastUpdate, fpsValue = 0, tick(), 0

local function createText(yOffset)
    local textObj = Drawing.new("Text")
    textObj.Size = 16
    textObj.Position = Vector2.new(Camera.ViewportSize.X - 110, yOffset)
    textObj.Color = Color3.fromRGB(0, 255, 0)
    textObj.Center = false
    textObj.Outline = true
    textObj.Visible = true
    return textObj
end

local fpsText = createText(10)
local msText = createText(30)
local playersText = createText(50)

Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    fpsText.Position = Vector2.new(Camera.ViewportSize.X - 110, 10)
    msText.Position = Vector2.new(Camera.ViewportSize.X - 110, 30)
    playersText.Position = Vector2.new(Camera.ViewportSize.X - 110, 50)
end)

RunService.RenderStepped:Connect(function()
    fpsCounter += 1

    if tick() - fpsLastUpdate >= 1 then
        fpsValue = fpsCounter
        fpsCounter = 0
        fpsLastUpdate = tick()

        if showFPS then
            fpsText.Text = string.format("Fps: %d", fpsValue)
            fpsText.Color = fpsValue >= 50 and Color3.fromRGB(0, 255, 0)
                or fpsValue >= 30 and Color3.fromRGB(255, 165, 0)
                or Color3.fromRGB(255, 0, 0)
            fpsText.Visible = true
        else
            fpsText.Visible = false
        end

        if showPing then
            local pingStat = Stats.Network.ServerStatsItem["Data Ping"]
            local ping = pingStat and math.floor(pingStat:GetValue()) or 0
            local color, label = Color3.fromRGB(0, 255, 0), "Ping: "

            if ping > 120 then
                color, label = Color3.fromRGB(255, 0, 0), "Ping: "
            elseif ping > 60 then
                color = Color3.fromRGB(255, 165, 0)
            end

            msText.Text = string.format("%s%d ms", label, ping)
            msText.Color = color
            msText.Visible = true
        else
            msText.Visible = false
        end

        if showPlayers then
            local currentPlayers = #Players:GetPlayers()
            local maxPlayers = Players.MaxPlayers
            local color = Color3.fromRGB(0, 255, 0) 

            if currentPlayers >= maxPlayers - 1 then
                color = Color3.fromRGB(255, 0, 0) 
            elseif currentPlayers >= maxPlayers - 4 then
                color = Color3.fromRGB(255, 165, 0) 
            elseif currentPlayers <= 4 then
                color = Color3.fromRGB(135, 206, 235) 
            end

            playersText.Text = string.format("Players: %d/%d", currentPlayers, maxPlayers)
            playersText.Color = color
            playersText.Visible = true
        else
            playersText.Visible = false
        end
    end
end)

local AutoPlantToggle = false

local function autoplant()
    while AutoPlantToggle do
        local args = {
            Instance.new("Model"),
            Vector3.new(-41.2053, 1.0633, 29.2236)
        }
        game:GetService("ReplicatedStorage")
            :WaitForChild("RemoteEvents")
            :WaitForChild("RequestPlantItem")
            :InvokeServer(unpack(args))
        task.wait(1)
    end
end

local MobsFolder = workspace.Characters
local ToolDamageEvent = game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("ToolDamageObject")

local MobsList = {"Cultist", "Crossbow Cultist", "Cultist Juggernaut", "Bunny", "Wolf", "Alpha Wolf", "Bear", "Snow Bear", "Meteor Crab", "Deer", "Owl", "Ram"}
local SelectedMobs = {}
local HitBoxSize = 50
local HitboxesActive = false

local function OnHitConnect(hit, mobModel)
    if hit and hit.Parent then
        local player = game.Players:GetPlayerFromCharacter(hit.Parent)
        if player then
            ToolDamageEvent:FireServer(mobModel) 
        end
    end
end

local function CreateHitboxForMob(mob)
    local primary = mob:FindFirstChild("HumanoidRootPart") or mob.PrimaryPart
    if not primary then return end

    local old = mob:FindFirstChild("HitBoxForMob")
    if old then
        old:Destroy()
    end

    local hitbox = Instance.new("Part")
    hitbox.Name = "HitBoxForMob"
    hitbox.Size = Vector3.new(HitBoxSize, HitBoxSize, HitBoxSize)
    hitbox.Shape = Enum.PartType.Ball
    hitbox.Color = Color3.fromRGB(138, 43, 226)
    hitbox.Transparency = 1
    hitbox.CanCollide = false
    hitbox.Anchored = false
    hitbox.Massless = true
    hitbox.CFrame = primary.CFrame
    hitbox.Parent = mob

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = hitbox
    weld.Part1 = primary
    weld.Parent = hitbox

    hitbox.Touched:Connect(function(hit)
        OnHitConnect(hit, mob)
    end)
end

local function RemoveHitboxFromMob(mob)
    local hitbox = mob:FindFirstChild("HitBoxForMob")
    if hitbox then
        hitbox:Destroy()
    end
end

local function UpdateHitboxes()
    if not HitboxesActive then return end

    for _, mob in ipairs(MobsFolder:GetChildren()) do
        if mob:IsA("Model") then
            local shouldHaveHitbox = table.find(SelectedMobs, mob.Name)
            local hasHitbox = mob:FindFirstChild("HitBoxForMob")

            if shouldHaveHitbox and not hasHitbox then
                CreateHitboxForMob(mob)
            elseif not shouldHaveHitbox and hasHitbox then
                RemoveHitboxFromMob(mob)
            elseif shouldHaveHitbox and hasHitbox then
                local hitbox = mob:FindFirstChild("HitBoxForMob")
                if hitbox and hitbox.Size.X ~= HitBoxSize then
                    hitbox.Size = Vector3.new(HitBoxSize, HitBoxSize, HitBoxSize)
                end
            end
        end
    end
end

local function AddAllHitboxes()
    HitboxesActive = true
    for _, mob in ipairs(MobsFolder:GetChildren()) do
        if mob:IsA("Model") and table.find(SelectedMobs, mob.Name) then
            CreateHitboxForMob(mob)
        end
    end
end

local function RemoveAllHitboxes()
    HitboxesActive = false
    for _, mob in ipairs(MobsFolder:GetChildren()) do
        if mob:IsA("Model") then
            RemoveHitboxFromMob(mob)
        end
    end
end

MobsFolder.ChildAdded:Connect(function(child)
    if HitboxesActive and child:IsA("Model") and table.find(SelectedMobs, child.Name) then
        wait(0.1)
        CreateHitboxForMob(child)
    end
end)

local TreeFold = workspace.Map.Landmarks
local TreeTypes = {"Tree Small"} 
local SelectedTrees = {}
local TreeHitBoxSize = 30
local TreeHitboxesActive = false

local function OnTreeHitConnect(hit, treeModel)
    if hit and hit.Parent then
        local player = game.Players:GetPlayerFromCharacter(hit.Parent)
        if player then
            ToolDamageEvent:FireServer(treeModel) 
        end
    end
end

local function CreateHitboxForTree(tree)
    local primary = tree:FindFirstChild("Trunk") or tree.PrimaryPart or tree:FindFirstChildOfClass("Part")
    if not primary then return end

    local old = tree:FindFirstChild("HitBoxForTree")
    if old then
        old:Destroy()
    end

    local hitbox = Instance.new("Part")
    hitbox.Name = "HitBoxForTree"
    hitbox.Size = Vector3.new(TreeHitBoxSize, TreeHitBoxSize, TreeHitBoxSize)
    hitbox.Shape = Enum.PartType.Ball
    hitbox.Color = Color3.fromRGB(34, 139, 34)
    hitbox.Transparency = 0.6
    hitbox.CanCollide = false
    hitbox.Anchored = false
    hitbox.Massless = true
    hitbox.CFrame = primary.CFrame
    hitbox.Parent = tree

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = hitbox
    weld.Part1 = primary
    weld.Parent = hitbox

    hitbox.Touched:Connect(function(hit)
        OnTreeHitConnect(hit, tree)
    end)
end

local function RemoveHitboxFromTree(tree)
    local hitbox = tree:FindFirstChild("HitBoxForTree")
    if hitbox then
        hitbox:Destroy()
    end
end

local function UpdateTreeHitboxes()
    if not TreeHitboxesActive then return end

    for _, tree in ipairs(TreeFold:GetChildren()) do
        local isCorrectType = tree:IsA("Model") or tree:IsA("BasePart")
        local isSelected = table.find(SelectedTrees, tree.Name)

        if isCorrectType and isSelected then
            local hasHitbox = tree:FindFirstChild("HitBoxForTree")

            if hasHitbox then
                local hitbox = tree:FindFirstChild("HitBoxForTree")
                if hitbox and hitbox.Size.X ~= TreeHitBoxSize then
                    hitbox.Size = Vector3.new(TreeHitBoxSize, TreeHitBoxSize, TreeHitBoxSize)
                end
            else
                CreateHitboxForTree(tree)
            end
        elseif tree:FindFirstChild("HitBoxForTree") and not isSelected then
            RemoveHitboxFromTree(tree)
        end
    end
end 

local function AddAllTreeHitboxes()
    TreeHitboxesActive = true
    for _, tree in ipairs(TreeFold:GetChildren()) do
        local isCorrectType = tree:IsA("Model") or tree:IsA("BasePart")
        local isSelected = table.find(SelectedTrees, tree.Name)

        if isCorrectType and isSelected then
            CreateHitboxForTree(tree)
        end
    end
end

local function RemoveAllTreeHitboxes()
    TreeHitboxesActive = false
    for _, tree in ipairs(TreeFold:GetChildren()) do
        if tree:IsA("Model") or tree:IsA("BasePart") then
            RemoveHitboxFromTree(tree)
        end
    end
end

TreeFold.ChildAdded:Connect(function(child)
    local isCorrectType = child:IsA("Model") or child:IsA("BasePart")
    local isSelected = table.find(SelectedTrees, child.Name)

    if TreeHitboxesActive and isCorrectType and isSelected then
        wait(0.1)
        CreateHitboxForTree(child)
    end
end)

local Home = Window:AddTab({
    Name = "Home",
    Icon = "rbxassetid://10723407389"
})

local Combat = Window:AddTab({
    Name = "Combat",
    Icon = "rbxassetid://10734975692"
})

local Camp = Window:AddTab({
    Name = "Auto",
    Icon = "rbxassetid://10734933826"
})

local br = Window:AddTab({
    Name = "Bring",
    Icon = "rbxassetid://10734909540"
})

local Fly = Window:AddTab({
    Name = "Player",
    Icon = "rbxassetid://10747373176"
})

local esp = Window:AddTab({
    Name = "Esp",
    Icon = "rbxassetid://10723346959"
})

local Tp = Window:AddTab({
    Name = "Teleport",
    Icon = "rbxassetid://10734886004"
})

local Vision = Window:AddTab({
    Name = "Graphics",
    Icon = "rbxassetid://10723425539"
})

local Fun = Window:AddTab({
    Name = "Fun",
    Icon = "rbxassetid://10734966248"
})

local Misc = Window:AddTab({
    Name = "Others",
    Icon = "rbxassetid://10734954538"
})

local infosec = Home:AddSection("Information", true)

infosec:AddParagraph({
    Title = "Discord",
    Content = "Join to our discord server for more updates and information.",
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

local infO = Home:AddSection("Anti Afk")

local antiafk = infO:AddToggle({
    Title = "Enable Anti Afk",
    Content = "Anti kick when idle for 20 mins.",
    Default = false,
    Callback = function(state)
            if state then
                    task.spawn(function()
                        while state do
                            if not LocalPlayer then
                                return
                            end;
                            VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                            VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                            task.wait(40)
                        end
                    end)
                else
                end
            end
})

local vissettings = Home:AddSection("Visual Settings")

ShowFps = vissettings:AddToggle({
    Title = "Show Fps",
    Content = "",
    Default = true,
    Callback = function(val)
        showFPS = val
        fpsText.Visible = val
    end
})

ShowPing = vissettings:AddToggle({
    Title = "Show Ping",
    Content = "",
    Default = true,
    Callback = function(val)
        showPing = val
        msText.Visible = val
    end
})

ShowPlayers = vissettings:AddToggle({
    Title = "Show Players",
    Content = "",
    Default = false,
    Callback = function(val)
        showPlayers = val
        playersText.Visible = val
    end
})

local Grapics = Home:AddSection("Performance")

Grapics:AddButton({
    Title = "Boost Fps",
    Content = "",
    Callback = function()
        pcall(function()
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            local lighting = game:GetService("Lighting")
            lighting.Brightness = 1
            lighting.FogEnd = 1000000
            lighting.GlobalShadows = false
            lighting.EnvironmentDiffuseScale = 0
            lighting.EnvironmentSpecularScale = 0
            lighting.ClockTime = 14
            lighting.OutdoorAmbient = Color3.new(0, 0, 0)
            local terrain = workspace:FindFirstChildOfClass("Terrain")
            if terrain then
                terrain.WaterWaveSize = 0
                terrain.WaterWaveSpeed = 0
                terrain.WaterReflectance = 0
                terrain.WaterTransparency = 1
            end
            for _, obj in ipairs(lighting:GetDescendants()) do
                if obj:IsA("PostEffect") or obj:IsA("BloomEffect") or obj:IsA("ColorCorrectionEffect") or obj:IsA("SunRaysEffect") or obj:IsA("BlurEffect") then
                    obj.Enabled = false
                end
            end
            for _, obj in ipairs(game:GetDescendants()) do
                if obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                    obj.Enabled = false
                elseif obj:IsA("Texture") or obj:IsA("Decal") then
                    obj.Transparency = 1
                end
            end
            for _, part in ipairs(workspace:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CastShadow = false
                end
            end
        end)
    end
})

Grapics:AddButton({
    Title = "Low GFX",
    Content = "",
    Callback = function()
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/a11bove/kdoaz/refs/heads/main/xzc/lowgfx.lua"))()
        end)
    end
})

local aur = Combat:AddSection("Aura")

local killaura = aur:AddToggle({
    Title = "Kill Aura",
    Content = "",
    Default = false,
    Callback = function(state)
        if state then
            AuraModule.StartKillAura()
        else
            AuraModule.StopKillAura()
        end
    end
})

local chopaura = aur:AddToggle({
    Title = "Chop Aura",
    Content = "",
    Default = false,
    Callback = function(state)
        if state then
            AuraModule.StartChopAura()
        else
            AuraModule.StopChopAura()
        end
    end
})

local auraradius = aur:AddSlider({
    Title = "Aura Radius",
    Content = "",
    Min = 1,
    Max = 200,
    Default = 50,
    Callback = function(value)
        AuraModule.SetAuraRadius(value)
    end
})

local hbmob = Combat:AddSection("Hitbox Mobs")

local SelectedMobs = {}

local selmob = hbmob:AddDropdown({
    Title = "Select Mobs",
    Content = "Select mobs to add hitbox.",
    Multi = true,
    Options = MobsList,
    Default = {},
    Callback = function(options)
        if type(options) == "table" then
            SelectedMobs = options
        else
            SelectedMobs = {}
        end
        UpdateHitboxes()
    end
})

local hbsze = hbmob:AddSlider({
    Title = "Hitbox Size",
    Content = "",
    Min = 20,
    Max = 100,
    Default = 50,
    Callback = function(value)
            HitBoxSize = value
                if HitboxesActive then
                    for _, mob in ipairs(MobsFolder:GetChildren()) do
                        if mob:IsA("Model") and table.find(SelectedMobs, mob.Name) then
                            local hitbox = mob:FindFirstChild("HitBoxForMob")
                            if hitbox then
                                hitbox.Size = Vector3.new(HitBoxSize, HitBoxSize, HitBoxSize)
                            end
                        end
                    end
                end
            end
})

local exphb = hbmob:AddToggle({
    Title = "Expand Hitbox",
    Content = "",
    Default = false,
    Callback = function(state) 
        if state then
            pcall(function()
                AddAllHitboxes()
            end)
        else
                RemoveAllHitboxes()
        end
    end
})

local apln = Camp:AddSection("Auto Plant")

local autopl = apln:AddToggle({
    Title = "Auto Plant",
    Content = "Plant saplings around base",
    Default = false,
    Callback = function(state) 
        if state then
            pcall(function()
                AutoPlantModule.StartAutoPlant(notifyNoSapling)
            end)
        else
            AutoPlantModule.StopAutoPlant()
        end
    end
})

local plradius = apln:AddSlider({
    Title = "Plant Radius",
    Content = "",
    Min = 50,
    Max = 100,
    Default = 50,
    Callback = function(value)
        AutoPlantModule.SetPlantRadius(value)
    end
})

local aucf = Camp:AddSection("Auto Upgrade Campfire")

local selectedCampfireItems = {}

local selitem = aucf:AddDropdown({
    Title = "Select Item",
    Content = "Select an item to upgrade campfire.",
    Multi = true,
    Options = campfireFuelItems,
    Default = {},
    Callback = function(options)
        if type(options) == "table" then
            selectedCampfireItems = options
        else
            selectedCampfireItems = {}
        end
    end
})

local autoupgcf = aucf:AddToggle({
    Title = "Enable Auto Upgrade Campfire",
    Content = "",
    Default = false,
    Callback = function(checked)
        autoUpgradeCampfireEnabled = checked
        if checked then
            task.spawn(function()
                while autoUpgradeCampfireEnabled do
                    if #selectedCampfireItems > 0 then
                        for _, selectedItem in ipairs(selectedCampfireItems) do
                            local items = {}

                            for _, item in ipairs(workspace:WaitForChild("Items"):GetChildren()) do
                                if item.Name == selectedItem then
                                    table.insert(items, item)
                                end
                            end

                            local count = math.min(10, #items)
                            for i = 1, count do
                                moveItemToPos(items[i], campfireDropPos)
                            end
                        end
                    end
                    task.wait(1)
                end
            end)
        end
    end
})

local acok = Camp:AddSection("Auto Cook")

local selfood = acok:AddDropdown({
    Title = "Select Food",
    Content = "Select a food to cook.",
    Multi = true,
    Options = autocookItems,
    Default = {},
    Callback = function(options)
        for _, itemName in ipairs(autocookItems) do
            autoCookEnabledItems[itemName] = false
        end

        if type(options) == "table" then
            for _, itemName in ipairs(options) do
                autoCookEnabledItems[itemName] = true
            end
        end
    end
})

local autocook = acok:AddToggle({
    Title = "Enable Auto Cook",
    Content = "",
    Default = false,
    Callback = function(state)
        autoCookEnabled = state
    end
})

coroutine.wrap(function()
    while true do
        if autoCookEnabled then
            for itemName, enabled in pairs(autoCookEnabledItems) do
                if enabled then
                    for _, item in ipairs(Workspace:WaitForChild("Items"):GetChildren()) do
                        if item.Name == itemName then
                            moveItemToPos(item, campfireDropPos)
                        end
                    end
                end
            end
        end
        task.wait(0.5)
    end
end)()

local acft = Camp:AddSection("Auto Craft")

local selitem2 = acft:AddDropdown({
    Title = "Select Item",
    Content = "Select an items to craft.",
    Multi = true,
    Options = craftableItems,
    Default = {},
    Callback = function(options)
        if type(options) == "table" then
            selectedCraftItems = options
        else
            selectedCraftItems = {}
        end
    end
})

local autocraft = acft:AddToggle({
    Title = "Enable Auto Craft",
    Content = "",
    Default = false,
    Callback = function(checked)
        autoCraftEnabled = checked
        if checked then
            task.spawn(function()
                while autoCraftEnabled do
                    if #selectedCraftItems > 0 then
                        for _, itemName in ipairs(selectedCraftItems) do
                            local args = { itemName }
                            game:GetService("ReplicatedStorage")
                                :WaitForChild("RemoteEvents")
                                :WaitForChild("CraftItem")
                                :InvokeServer(unpack(args))
                        end
                    end
                    task.wait(0.5)
                end
            end)
        end
    end
})

local bpr = br:AddSection("Blueprint")

local selblueprint = bpr:AddDropdown({
    Title = "Select Blueprint",
    Content = "Select blueprints to bring.",
    Multi = true,
    Options = BringModule.BlueprintItems,
    Default = {},
    Callback = function(options)
        if type(options) == "table" then
            BringModule.selectedBlueprintItems = options
        else
            BringModule.selectedBlueprintItems = {}
        end
    end
})

local bringbp = bpr:AddToggle({
    Title = "Bring Blueprints",
    Content = "",
    Default = false,
    Callback = function(value)
        BringModule.BlueprintToggleEnabled = value

        if value then
            if #BringModule.selectedBlueprintItems > 0 then
                spawn(function()
                    while BringModule.BlueprintToggleEnabled do
                        if #BringModule.selectedBlueprintItems > 0 and BringModule.BlueprintToggleEnabled then
                            BringModule.bypassBringSystem(BringModule.selectedBlueprintItems, function() 
                                return BringModule.BlueprintToggleEnabled 
                            end)
                        end

                        local waitTime = 0
                        while waitTime < 3 and BringModule.BlueprintToggleEnabled do
                            wait(0.1)
                            waitTime = waitTime + 0.1
                        end
                    end
                end)
            end
        end
    end
})

local plt = br:AddSection("Pelts")

local selpelt = plt:AddDropdown({
    Title = "Select Pelt",
    Content = "Select pelts to bring.",
    Multi = true,
    Options = BringModule.PeltsItems,
    Default = {},
    Callback = function(options)
        if type(options) == "table" then
            BringModule.selectedPeltsItems = options
        else
            BringModule.selectedPeltsItems = {}
        end
    end
})

local bringpelt = plt:AddToggle({
    Title = "Bring Pelts",
    Content = "",
    Default = false,
    Callback = function(value)
        BringModule.PeltsToggleEnabled = value

        if value then
            if #BringModule.selectedPeltsItems > 0 then
                spawn(function()
                    while BringModule.PeltsToggleEnabled do
                        if #BringModule.selectedPeltsItems > 0 and BringModule.PeltsToggleEnabled then
                            BringModule.bypassBringSystem(BringModule.selectedPeltsItems, function() 
                                return BringModule.PeltsToggleEnabled 
                            end)
                        end

                        local waitTime = 0
                        while waitTime < 3 and BringModule.PeltsToggleEnabled do
                            wait(0.1)
                            waitTime = waitTime + 0.1
                        end
                    end
                end)
            end
        end
    end
})

local scr = br:AddSection("Scrap")

local selscrap = scr:AddDropdown({
    Title = "Select Scrap",
    Content = "Select scraps to bring",
    Multi = true,
    Options = BringModule.junkItems,
    Default = {},
    Callback = function(options)
        if type(options) == "table" then
            BringModule.selectedJunkItems = options
        else
            BringModule.selectedJunkItems = {}
        end
    end
})

local bringscrap = scr:AddToggle({
    Title = "Bring Scraps",
    Content = "",
    Default = false,
    Callback = function(value)
        BringModule.junkToggleEnabled = value

        if value then
            if #BringModule.selectedJunkItems > 0 then
                spawn(function()
                    while BringModule.junkToggleEnabled do
                        if #BringModule.selectedJunkItems > 0 and BringModule.junkToggleEnabled then
                            BringModule.bypassBringSystem(BringModule.selectedJunkItems, function() 
                                return BringModule.junkToggleEnabled 
                            end)
                        end

                        local waitTime = 0
                        while waitTime < 3 and BringModule.junkToggleEnabled do
                            wait(0.1)
                            waitTime = waitTime + 0.1
                        end
                    end
                end)
            end
        end
    end
})

local ful = br:AddSection("Fuel")

local selfuel = ful:AddDropdown({
    Title = "Select Fuel",
    Content = "Select fuel to bring.",
    Multi = true,
    Options = BringModule.fuelItems,
    Default = {},
    Callback = function(options)
        if type(options) == "table" then
            BringModule.selectedFuelItems = options
        else
            BringModule.selectedFuelItems = {}
        end
    end
})

local bringfuel = ful:AddToggle({
    Title = "Bring Fuels",
    Content = "",
    Default = false,
    Callback = function(value)
        BringModule.fuelToggleEnabled = value

        if value then
            if #BringModule.selectedFuelItems > 0 then
                spawn(function()
                    while BringModule.fuelToggleEnabled do
                        if #BringModule.selectedFuelItems > 0 and BringModule.fuelToggleEnabled then
                            BringModule.bypassBringSystem(BringModule.selectedFuelItems, function() 
                                return BringModule.fuelToggleEnabled 
                            end)
                        end

                        local waitTime = 0
                        while waitTime < 3 and BringModule.fuelToggleEnabled do
                            wait(0.1)
                            waitTime = waitTime + 0.1
                        end
                    end
                end)
            end
        end
    end
})

local fod = br:AddSection("Food")

local selfood = fod:AddDropdown({
    Title = "Select Food",
    Content = "Select food to bring.",
    Multi = true,
    Options = BringModule.foodItems,
    Default = {},
    Callback = function(options)
        if type(options) == "table" then
            BringModule.selectedFoodItems = options
        else
            BringModule.selectedFoodItems = {}
        end
    end
})

local bringfood = fod:AddToggle({
    Title = "Bring Foods",
    Content = "",
    Default = false,
    Callback = function(value)
        BringModule.foodToggleEnabled = value

        if value then
            if #BringModule.selectedFoodItems > 0 then
                spawn(function()
                    while BringModule.foodToggleEnabled do
                        if #BringModule.selectedFoodItems > 0 and BringModule.foodToggleEnabled then
                            BringModule.bypassBringSystem(BringModule.selectedFoodItems, function() 
                                return BringModule.foodToggleEnabled 
                            end)
                        end

                        local waitTime = 0
                        while waitTime < 3 and BringModule.foodToggleEnabled do
                            wait(0.1)
                            waitTime = waitTime + 0.1
                        end
                    end
                end)
            end
        end
    end
})

local med = br:AddSection("Medical Items")

local selmed = med:AddDropdown({
    Title = "Select Medical Items",
    Content = "Select medical items to bring.",
    Multi = true,
    Options = BringModule.medicalItems,
    Default = {},
    Callback = function(options)
        if type(options) == "table" then
            BringModule.selectedMedicalItems = options
        else
            BringModule.selectedMedicalItems = {}
        end
    end
})

local bringmed = med:AddToggle({
    Title = "Bring Medical Items",
    Content = "",
    Default = false,
    Callback = function(value)
        BringModule.medicalToggleEnabled = value

        if value then
            if #BringModule.selectedMedicalItems > 0 then
                spawn(function()
                    while BringModule.medicalToggleEnabled do
                        if #BringModule.selectedMedicalItems > 0 and BringModule.medicalToggleEnabled then
                            BringModule.bypassBringSystem(BringModule.selectedMedicalItems, function() 
                                return BringModule.medicalToggleEnabled 
                            end)
                        end

                        local waitTime = 0
                        while waitTime < 3 and BringModule.medicalToggleEnabled do
                            wait(0.1)
                            waitTime = waitTime + 0.1
                        end
                    end
                end)
            end
        end
    end
})

local mobz = br:AddSection("Mobs")

local selmobz = mobz:AddDropdown({
    Title = "Select Mobs",
    Content = "Select mobs to bring.",
    Multi = true,
    Options = BringModule.cultistItems,
    Default = {},
    Callback = function(options)
        if type(options) == "table" then
            BringModule.selectedCultistItems = options
        else
            BringModule.selectedCultistItems = {}
        end
    end
})

local bringmobz = mobz:AddToggle({
    Title = "Bring Mobs",
    Content = "",
    Default = false,
    Callback = function(value)
        BringModule.cultistToggleEnabled = value

        if value then
            if #BringModule.selectedCultistItems > 0 then
                spawn(function()
                    while BringModule.cultistToggleEnabled do
                        if #BringModule.selectedCultistItems > 0 and BringModule.cultistToggleEnabled then
                            BringModule.bypassBringSystem(BringModule.selectedCultistItems, function() 
                                return BringModule.cultistToggleEnabled 
                            end)
                        end

                        local waitTime = 0
                        while waitTime < 3 and BringModule.cultistToggleEnabled do
                            wait(0.1)
                            waitTime = waitTime + 0.1
                        end
                    end
                end)
            end
        end
    end
})

local eqp = br:AddSection("Equipment")

local seleqp = eqp:AddDropdown({
    Title = "Select Equipments",
    Content = "Select an equipments to bring.",
    Multi = true,
    Options = BringModule.equipmentItems,
    Default = {},
    Callback = function(options)
        if type(options) == "table" then
            BringModule.selectedEquipmentItems = options
        else
            BringModule.selectedEquipmentItems = {}
        end
    end
})

local bringeqp = eqp:AddToggle({
    Title = "Bring Equipments",
    Content = "",
    Default = false,
    Callback = function(value)
        BringModule.equipmentToggleEnabled = value

        if value then
            if #BringModule.selectedEquipmentItems > 0 then
                spawn(function()
                    while BringModule.equipmentToggleEnabled do
                        if #BringModule.selectedEquipmentItems > 0 and BringModule.equipmentToggleEnabled then
                            BringModule.bypassBringSystem(BringModule.selectedEquipmentItems, function() 
                                return BringModule.equipmentToggleEnabled 
                            end)
                        end

                        local waitTime = 0
                        while waitTime < 3 and BringModule.equipmentToggleEnabled do
                            wait(0.1)
                            waitTime = waitTime + 0.1
                        end
                    end
                end)
            end
        end
    end
})

local saps = br:AddSection("Sapling")

local bringsap = saps:AddToggle({
    Title = "Bring Saplings",
    Content = "",
    Default = false,
    Callback = function(value)
        BringModule.ToggleSaplingBring(value)
    end
})

local vis = esp:AddSection("Players")

local esppl = vis:AddToggle({
    Title = "Enable Esp Players",
    Content = "",
    Default = false,
    Callback = function(enable)
        ESPModule.EspPlayerOn = enable
        if enable then
            pcall(function()
                createPlayerNameBillboard(player)
            end)
        else
            ESPModule.EspPlayerOn = false
        end
    end
})

--[[ local trevis = esp:AddSection("Tree Health")

trevis:AddToggle({
    Title = "Enable Esp Tree Health",
    Content = "",
    Default = false,
    Callback = function(enable)
        if enable then
            ESPModule.enableTreeESP()
        else
            ESPModule.disableTreeESP()
        end
    end
}) ]]

local itemvis = esp:AddSection("Items")

local selitems3 = itemvis:AddDropdown({
    Title = "Select Items",
    Content = "",
    Multi = true,
    Options = ie,
    Default = {},
    Callback = function(options)
        ESPModule.selectedItems = options
        ESPModule.UpdateItemsESP(ie)
    end
})

local espitem = itemvis:AddToggle({
    Title = "Enable Esp Items",
    Content = "",
    Default = false,
    Callback = function(state)
        ESPModule.ToggleItemsESP(state, ie)
    end
})

local envis = esp:AddSection("Entity")

local selentity = envis:AddDropdown({
    Title = "Select Entity",
    Content = "",
    Multi = true,
    Options = me,
    Default = {},
    Callback = function(options)
        ESPModule.selectedMobs = options
        ESPModule.UpdateMobsESP(me)
    end
})

local espentite = envis:AddToggle({
    Title = "Enable Esp Entity",
    Content = "",
    Default = false,
    Callback = function(state)
        ESPModule.ToggleMobsESP(state, me)
    end
})

local smp = Tp:AddSection("Map")

smp:AddButton({
    Title = "Reveal Whole Map",
    Content = "",
    Callback = function()
        TeleportModule.RevealWholeMap()
    end
})

smp:AddSubSection("Scan Map")
smp:AddDivider()

smp:AddToggle({
    Title = "Scan Map",
    Default = false,
    Callback = function(enabled)
        ScanModule.ToggleScan(enabled)
    end
})

smp:AddSlider({
    Title = "Scan Speed",
    Increment = 10,
    Min = 50,
    Max = 500,
    Default = 100,
    Callback = function(value)
        ScanModule.SetScanSpeed(value)
    end
})

smp:AddSlider({
    Title = "Scan Radius",
    Increment = 1,
    Min = 1,
    Max = 100,
    Default = 15,
    Callback = function(value)
        ScanModule.SetScanRadius(value)
    end
})

smp:AddSlider({
    Title = "Scan Angle",
    Increment = 1,
    Min = 1,
    Max = 90,
    Default = 10,
    Callback = function(value)
        ScanModule.SetScanAngle(value)
    end
})

--[[smp:AddToggle({
    Title = "Scan Map",
    Content = "Might not work for some executors.",
    Default = false,
    Callback = function(state)
        TeleportModule.ToggleScanMap(state)
    end
})]]

local tpt = Tp:AddSection("Teleport to")

tpt:AddButton({
    Title = "Teleport to Campfire",
    Content = "",
    Callback = function()
        TeleportModule.TeleportToCampfire()
    end
})

tpt:AddButton({
    Title = "Teleport to Stronghold",
    Content = "",
    Callback = function()
        TeleportModule.TeleportToStronghold()
    end
})

tpt:AddButton({
    Title = "Teleport to Safe Zone",
    Content = "",
    Callback = function()
        TeleportModule.TeleportToSafeZone()
    end
})

tpt:AddButton({
    Title = "Teleport to Trader",
    Content = "",
    Callback = function()
        TeleportModule.TeleportToTrader()
    end
})

tpt:AddButton({
    Title = "Teleport to Random Tree",
    Content = "",
    Callback = function()
        TeleportModule.TeleportToRandomTree()
    end
})

local tpc = Tp:AddSection("Children")

local MobDropdown = tpc:AddDropdown({
    Title = "Select Child",
    Content = "",
    Multi = false,
    Options = currentMobNames,
    Default = {},
    Callback = function(options)
        selectedMob = options[#options] or currentMobNames[1] or nil
    end
})

tpc:AddButton({
    Title = "Refresh List",
    Content = "",
    Callback = function()
        currentMobs, currentMobNames = TeleportModule.getMobs()
        if #currentMobNames > 0 then
            selectedMob = currentMobNames[1]
            MobDropdown:Refresh(currentMobNames)
        else
            selectedMob = nil
            MobDropdown:Refresh({ "No child found" })
        end
    end
})

tpc:AddButton({
    Title = "Teleport to Child",
    Content = "",
    Callback = function()
        if selectedMob and currentMobs then
            for i, name in ipairs(currentMobNames) do
                if name == selectedMob then
                    TeleportModule.TeleportToMob(currentMobs[i])
                    break
                end
            end
        end
    end
})

local tpch = Tp:AddSection("Chest")

local ChestDropdown = tpch:AddDropdown({
    Title = "Select Chest",
    Content = "",
    Multi = false,
    Options = currentChestNames,
    Default = {},
    Callback = function(options)
        selectedChest = options[#options] or currentChestNames[1] or nil
    end
})

tpch:AddButton({
    Title = "Refresh List",
    Content = "",
    Callback = function()
        currentChests, currentChestNames = TeleportModule.getChests()
        if #currentChestNames > 0 then
            selectedChest = currentChestNames[1]
            ChestDropdown:Refresh(currentChestNames)
        else
            selectedChest = nil
            ChestDropdown:Refresh({ "No chests found" })
        end
    end
})

tpch:AddButton({
    Title = "Teleport to Chest",
    Content = "",
    Callback = function()
        if selectedChest and currentChests then
            local chestIndex = 1
            for i, name in ipairs(currentChestNames) do
                if name == selectedChest then
                    chestIndex = i
                    break
                end
            end
            TeleportModule.TeleportToChest(currentChests[chestIndex])
        end
    end
})

local chs = Misc:AddSection("Chest")

local autoopench = chs:AddToggle({
    Title = "Auto Open Chests",
    Content = "",
    Default = false,
    Callback = function(v)
        MiscModule.ToggleAutoOpenChests(v)
    end
})

local afed = Misc:AddSection("Auto Eat")

local selfoodsz = afed:AddDropdown({
    Title = "Select Food",
    Content = "Select food to eat.",
    Multi = false,
    Options = alimentos,
    Default = {},
    Callback = function(value)
        MiscModule.SetSelectedFood(value)
    end
})

local eatamount = afed:AddInput({
    Title = "Eat Amount",
    Content = "Eat when hunger reaches this %",
    Placeholder = "ex: 20 (numbers)",
    Callback = function(value)
        local n = tonumber(value)
        if n then
            MiscModule.SetHungerThreshold(n)
        end
    end
})

local autoeat = afed:AddToggle({
    Title = "Enable Auto Eat",
    Content = "",
    Default = false,
    Callback = function(state)
        MiscModule.ToggleAutoEat(state)
    end
})

local hh = Fly:AddSection("User Settings")

local walkspeedValue = 16

local wsvl = hh:AddSlider({
    Title = "Walkspeed",
    Content = "",
    Min = 16,
    Max = 200,
    Default = 16,
    Callback = function(value)
        walkspeedValue = value
        local player = game.Players.LocalPlayer
        local char = player.Character
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = value
            end
        end
    end
})

task.spawn(function()
    while task.wait(0.1) do
        local player = game.Players.LocalPlayer
        local char = player.Character
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.WalkSpeed ~= walkspeedValue then
                humanoid.WalkSpeed = walkspeedValue
            end
        end
    end
end)

hh:AddButton({
    Title = "Reset Walkspeed",
    Content = "Returns to default speed.",
    Callback = function()
        walkspeedValue = 16
        local player = game.Players.LocalPlayer
        local char = player.Character
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = 16
            end
        end
        AIKO:MakeNotify({
            Title = "@aikoware",
            Description = "Walkspeed Reset",
            Content = "Walkspeed back to default.",
            Delay = 2,
        })
    end
})

local humanoid = character:FindFirstChildOfClass("Humanoid")
if humanoid then
    humanoid.HipHeight = 2
end

local hiph = hh:AddSlider({
    Title = "Hip Height",
    Content = "",
    Min = 1,
    Max = 50,
    Default = 2,
    Callback = function(v)
        _G.HipHeight = v
        if _G.HipHeightOn then
            game.Players.LocalPlayer.Character.Humanoid.HipHeight = v
        end
    end
})

local enablehiph = hh:AddToggle({
    Title = "Enable HipHeight",
    Content = "",
    Default = false,
    Callback = function(PH)
        _G.HipHeightOn = PH
        local humanoid = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")

        if PH then
            if humanoid then
                humanoid.HipHeight = _G.HipHeight or 2
            end
        else
            if humanoid then
                humanoid.HipHeight = 2  -- Reset to default
            end
        end
    end
})

local flypseed = hh:AddSlider({
    Title = "Fly Speed",
    Content = "",
    Min = 1,
    Max = 20,
    Default = 1,
    Callback = function(value)
        FlyModule.flySpeed = value
        if FlyModule.FLYING then
            task.spawn(function()
                while FlyModule.FLYING do
                    task.wait(0.1)
                    if game:GetService("UserInputService").TouchEnabled then
                        local root = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if root and root:FindFirstChild("BodyVelocity") then
                            local bv = root:FindFirstChild("BodyVelocity")
                            bv.Velocity = bv.Velocity.Unit * (FlyModule.flySpeed * 50)
                        end
                    end
                end
            end)
        end
    end
})

local enablefly = hh:AddToggle({
    Title = "Enable Fly",
    Content = "",
    Default = false,
    Callback = function(state)
        FlyModule.flyToggle = state
        if FlyModule.flyToggle then
            if game:GetService("UserInputService").TouchEnabled then
                FlyModule.MobileFly()
            else
                FlyModule.sFLY()
            end
        else
            FlyModule.NOFLY()
            FlyModule.UnMobileFly()
        end
    end
})

local infJumpConnection
local infJ = hh:AddToggle({
    Title = "Inf Jump",
    Content = "",
    Default = false,
    Callback = function(state)
        if state then
            infJumpConnection = UserInputService.JumpRequest:Connect(function()
                local char = Players.LocalPlayer.Character
                local humanoid = char and char:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        else
            if infJumpConnection then
                infJumpConnection:Disconnect()
                infJumpConnection = nil
            end
        end
    end
})

local mxc = Misc:AddSection("Misc")

local instinte = mxc:AddToggle({
    Title = "Instant Interact",
    Content = "Instantly open chests, gates, etc.",
    Default = false,
    Callback = function(state)
        MiscModule.ToggleInstantInteract(state)
    end
})

local autocollectocoins = mxc:AddToggle({
    Title = "Auto Collect Coin Stacks",
    Content = "Automatically collects all Coin Stacks",
    Default = false,
    Callback = function(value)
        MiscModule.ToggleAutoCollectCoins(value)
    end
})

local ant = Misc:AddSection("Anti's")

local stundeerr = ant:AddToggle({
    Title = "Auto Stun Deer",
    Content = "Need Flashlight",
    Default = false,
    Callback = function(state)
        AntiModule.ToggleAutoStunDeer(state)
    end
})

local escapeowl = ant:AddToggle({
    Title = "Auto Escape From Owl",
    Content = "",
    Default = false,
    Callback = function(state)
        AntiModule.ToggleAutoEscapeOwl(state)
    end
})

local escapedeer = ant:AddToggle({
    Title = "Auto Escape From Deer",
    Content = "",
    Default = false,
    Callback = function(state)
        AntiModule.ToggleAutoEscapeDeer(state)
    end
})

local escaperam = ant:AddToggle({
    Title = "Auto Escape From Ram",
    Content = "",
    Default = false,
    Callback = function(state)
        AntiModule.ToggleAutoEscapeRam(state)
    end
})

local fun = Fun:AddSection("Fun")

local healthbar = fun:AddToggle({
    Title = "No Health Bar",
    Content = "Invisible health bar",
    Default = false,
    Callback = function(state)
        FunModule.ToggleNoHealthBar(state, notify)
    end
})

local godmodez = fun:AddToggle({
    Title = "God Mode",
    Content = "Immune to physical and hunger damage",
    Default = false,
    Callback = function(value)
        FunModule.ToggleGodMode(value, notify)
    end
})

local env = Vision:AddSection("Graphics")

local disablenight = env:AddToggle({
    Title = "Disable Night Campfire Effect",
    Content = "",
    Default = false,
    Callback = function(state)
        VisionModule.ToggleDisableNightCampfire(state)
    end
})

local nightvision = env:AddToggle({
    Title = "Full Bright",
    Content = "",
    Default = false,
    Callback = function(state)
        VisionModule.ToggleFullBright(state)
    end
})

local nofogg = env:AddToggle({
    Title = "No Fog",
    Content = "",
    Default = false,
    Callback = function(state)
        VisionModule.ToggleNoFog(state)
    end
})

local brightcolor = env:AddToggle({
    Title = "Vibrant Colors",
    Content = "",
    Default = false,
    Callback = function(state)
        VisionModule.ToggleVibrantColors(state)
    end
})

env:AddButton({
    Title = "Remove Gameplay Paused",
    Content = "",
    Callback = function()
        VisionModule.RemoveGameplayPaused()
    end
})

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end

    if input.KeyCode == Enum.KeyCode.V then
        showPlayers = not showPlayers
        playersText.Visible = showPlayers
    end
end)

AIKO:MakeNotify({
    Title = "Aikoware",
    Description = "Script Loaded",
    Content = "Game: 99 Nights in The Forest",
    Delay = 5
})
