local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ContextActionService = game:GetService("ContextActionService")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Knit = require(Shared:WaitForChild("Packages").Knit)
local Utils = require(Shared:WaitForChild("Utils"))
local Ore = require(Shared:WaitForChild("Data"):WaitForChild("Ore"))

local Services = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services")
local ToolService = Services:WaitForChild("ToolService")
local ToolServiceRF = ToolService:WaitForChild("RF")
local StartBlock = ToolServiceRF:WaitForChild("StartBlock")
local StopBlock = ToolServiceRF:WaitForChild("StopBlock")

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Forge = PlayerGui:WaitForChild("Forge")
local MeltMinigame = Forge:WaitForChild("MeltMinigame")
local PourMinigame = Forge:WaitForChild("PourMinigame")
local HammerMinigame = Forge:WaitForChild("HammerMinigame")

local AutoMineEnabled = false
local RockTypes = {}
local MineDistance = 6
local MineTweenSpeed = 70
local AllRockTypes = {}
local RockDropdown = nil
local Tweening = false

local AutoFarmEnemyEnabled = false
local EnemyTypes = {}
local FarmDistance = 6
local FarmTweenSpeed = 70
local AllEnemyTypes = {}
local EnemyDropdown = nil
local CurrentEnemyTween = nil

local antiAfk = {
    enabled = true,
    running = false,
    interval = 60,
    key = Enum.KeyCode.ButtonR3,
    bindName = "PVB_AntiAFK_Sink",
}

local autoForge = {
    enabled = false,
    autoMelt = false,
    autoPour = false,
    autoHammer = false,
    autoMold = false,

    itemType = "Weapon",
    selectedOres = {},
    totalOresPerForge = 3,
}

local autoPotions = {
    enabled = false,
    selected = {},
}

local autoMovement = {
    alwaysRun = false,
    autoDodge = false,
}

local autoSell = {
    enabled = false,
    selectedOres = {},
    selectedInvItems = {},
    interval = 10,
    sellAmount = 100,
}

local UseInstantTPMine = false

local UseInstantTPEnemy = false

local autoParry = {
    enabled = false,
    parryAnimations = {
        ["rbxassetid://106199289601358"] = 0.433,
        ["rbxassetid://97668319966803"] = 0.3,
        ["rbxassetid://89496572417272"] = 0.44,
        ["rbxassetid://82533430458765"] = 0.37,
        ["rbxassetid://98266710251041"] = 0.25,
        ["rbxassetid://73829363877010"] = 0.43,
        ["rbxassetid://131510736644901"] = 0.4,
        ["rbxassetid://89127058244517"] = 0.59,
        ["rbxassetid://107274803323874"] = 0.93,
    }
}

local webhook = {
    enabled = false,
    url = "",
    userId = "",
    selectedOres = {},
}

local currentInvOptions = {"Click Refresh Inventory"}
local InvDropdown
local autoMovementRunning = false

local function getCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function getHumanoidRootPart()
    local char = getCharacter()
    return char:WaitForChild("HumanoidRootPart")
end

local function getHumanoid()
    local char = getCharacter()
    return char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid")
end

local function AA_BindSink()
    pcall(function() ContextActionService:UnbindAction(antiAfk.bindName) end)
    pcall(function()
        ContextActionService:BindAction(antiAfk.bindName, function()
            return Enum.ContextActionResult.Sink
        end, false, antiAfk.key)
    end)
end

local function AA_UnbindSink()
    pcall(function() ContextActionService:UnbindAction(antiAfk.bindName) end)
end

local function AA_Tap()
    pcall(function() VirtualInputManager:SendKeyEvent(true, antiAfk.key, false, game) end)
    task.wait(0.06)
    pcall(function() VirtualInputManager:SendKeyEvent(false, antiAfk.key, false, game) end)
end

local function AA_Start()
    if antiAfk.running then return end
    antiAfk.running = true
    AA_BindSink()
    task.spawn(function()
        while antiAfk.enabled do
            AA_Tap()
            local waitFor = (antiAfk.interval or 60) + math.random(-2, 2)
            if waitFor < 10 then waitFor = 10 end
            for _ = 1, waitFor * 10 do
                if not antiAfk.enabled then break end
                task.wait(0.1)
            end
        end
        antiAfk.running = false
        AA_UnbindSink()
    end)
end

local function GetAllRockTypes()
    AllRockTypes = {}
    local Seen = {}
    local Assets = ReplicatedStorage:FindFirstChild("Assets")
    if not Assets then return AllRockTypes end
    local Rocks = Assets:FindFirstChild("Rocks")
    if not Rocks then return AllRockTypes end
    for _, Desc in ipairs(Rocks:GetDescendants()) do
        if Desc:IsA("Model") then
            local Name = Desc.Name
            if typeof(Name) == "string" and Name ~= "" and not Name:match("^%d+$") and not Seen[Name] then
                Seen[Name] = true
                table.insert(AllRockTypes, Name)
            end
        end
    end
    table.sort(AllRockTypes)
    return AllRockTypes
end

local function GetRockParts(RockName)
    local Parts = {}
    if not RockName or RockName == "" then return Parts end
    local RocksFolder = workspace:FindFirstChild("Rocks")
    if not RocksFolder then return Parts end
    for _, Desc in ipairs(RocksFolder:GetDescendants()) do
        if Desc:IsA("BasePart") then
            local Model = Desc:FindFirstAncestorWhichIsA("Model")
            if Model and Model.Name == RockName then
                table.insert(Parts, Desc)
            end
        end
    end
    return Parts
end

local function GetClosestRock(RockNames)
    if not RockNames or #RockNames == 0 then return nil end
    local Character = Players.LocalPlayer.Character
    if not Character then return nil end
    local RootPart = Character:FindFirstChild("HumanoidRootPart")
    if not RootPart then return nil end
    local IsAll = false
    for _, Name in ipairs(RockNames) do
        if Name == "All" then
            IsAll = true
            break
        end
    end
    if IsAll then
        RockNames = AllRockTypes
    end
    local ClosestDist = math.huge
    local ClosestPart = nil
    for _, RockName in ipairs(RockNames) do
        local Parts = GetRockParts(RockName)
        for _, Part in ipairs(Parts) do
            if Part and Part.Parent then
                local Dist = (RootPart.Position - Part.Position).Magnitude
                if Dist < ClosestDist then
                    ClosestPart = Part
                    ClosestDist = Dist
                end
            end
        end
    end
    return ClosestPart
end

local function TweenToRock(Part)
    local Character = Players.LocalPlayer.Character
    if not Character then return false end
    local RootPart = Character:FindFirstChild("HumanoidRootPart")
    if not (RootPart and Part and Part.Parent) then return false end

    local OffsetY = -(MineDistance or 3)
    local TargetPos = Part.Position + Vector3.new(0, OffsetY, 0)
    local LookAt = Part.Position + Vector3.new(0, 5, 0)

    if UseInstantTPMine then
        RootPart.CFrame = CFrame.new(TargetPos, LookAt)
        RootPart.Velocity = Vector3.new(0, 0, 0)
        task.wait(1)
        return true
    end

    local Dist = (RootPart.Position - TargetPos).Magnitude
    local Time = Dist / MineTweenSpeed
    local Tween = TweenService:Create(RootPart, TweenInfo.new(Time, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
        CFrame = CFrame.new(TargetPos, LookAt)
    })
    Tween:Play()
    Tween.Completed:Wait()
    return true
end

local function MineRock(Part, RockName)
    if Part and RockName and RockName ~= "" then
        local Model = Part:FindFirstAncestorWhichIsA("Model")
        if Model and Model.Name == RockName then
            local Args = {"Pickaxe"}
            local ToolRemote = ReplicatedStorage.Shared.Packages.Knit.Services.ToolService.RF.ToolActivated
            local Character = Players.LocalPlayer.Character
            if Character then
                local RootPart = Character:FindFirstChild("HumanoidRootPart")
                if RootPart then
                    local OriginalChar = Character
                    local OriginalAngular = RootPart.AssemblyAngularVelocity
                    RootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                    local BodyVel = RootPart:FindFirstChild("BodyVelocity")
                    if not BodyVel then
                        BodyVel = Instance.new("BodyVelocity")
                        BodyVel.MaxForce = Vector3.new(4000, 4000, 4000)
                        BodyVel.Velocity = Vector3.new(0, 0, 0)
                        BodyVel.Parent = RootPart
                    end
                    local Connection
                    Connection = RunService.Heartbeat:Connect(function()
                        if AutoMineEnabled and Model and Model.Parent and Players.LocalPlayer.Character == OriginalChar and RootPart and RootPart.Parent and not Tweening then
                            local TargetY = -(MineDistance or 3)
                            local TargetPos = Part.Position + Vector3.new(0, TargetY, 0)
                            local LookAt = Part.Position + Vector3.new(0, 5, 0)
                            RootPart.CFrame = CFrame.new(TargetPos, LookAt)
                            if BodyVel then
                                BodyVel.Velocity = Vector3.new(0, 0, 0)
                            end
                        else
                            if Connection then Connection:Disconnect() end
                        end
                    end)
                    while AutoMineEnabled and Players.LocalPlayer.Character == OriginalChar and RootPart and RootPart.Parent and not Tweening and Model and Model.Parent do
                        pcall(function()
                            ToolRemote:InvokeServer(unpack(Args))
                        end)
                        task.wait(0.15)
                    end
                    if Connection then Connection:Disconnect() end
                    if BodyVel and BodyVel.Parent then BodyVel:Destroy() end
                    if RootPart and RootPart.Parent then
                        RootPart.AssemblyAngularVelocity = OriginalAngular
                    end
                end
            end
        end
    end
end

local function GetBaseMobName(MobName)
    if MobName and MobName ~= "" then
        local Base = MobName:gsub("%d+$", "")
        if Base == "" then return nil end
        return Base:gsub("%s+$", "")
    end
    return nil
end

local function GetAllEnemyTypes()
    AllEnemyTypes = {}
    local Seen = {}
    local Assets = ReplicatedStorage:FindFirstChild("Assets")
    if not Assets then return AllEnemyTypes end
    local Mobs = Assets:FindFirstChild("Mobs")
    if not Mobs then return AllEnemyTypes end
    for _, Desc in ipairs(Mobs:GetDescendants()) do
        if Desc:IsA("Model") and Desc.Name ~= "Model" then
            local BaseName = GetBaseMobName(Desc.Name)
            if BaseName and BaseName ~= "" and not Seen[BaseName] then
                Seen[BaseName] = true
                table.insert(AllEnemyTypes, BaseName)
            end
        end
    end
    table.sort(AllEnemyTypes)
    return AllEnemyTypes
end

local function GetMobModels(MobBaseName)
    local Models = {}
    if not MobBaseName or MobBaseName == "" then return Models end
    local Living = workspace:FindFirstChild("Living")
    if not Living then return Models end
    for _, Child in ipairs(Living:GetChildren()) do
        if Child:IsA("Model") and GetBaseMobName(Child.Name) == MobBaseName then
            table.insert(Models, Child)
        end
    end
    return Models
end

local function IsMobDead(Mob)
    if not (Mob and Mob.Parent) then return true end
    local Status = Mob:FindFirstChild("Status")
    return Status and Status:FindFirstChild("Dead") or false
end

local function GetClosestEnemy(EnemyBaseNames)
    local Character = Players.LocalPlayer.Character
    if not Character then return nil end
    local RootPart = Character:FindFirstChild("HumanoidRootPart")
    if not RootPart then return nil end
    local IsAll = false
    for _, Name in ipairs(EnemyBaseNames) do
        if Name == "All" then
            IsAll = true
            break
        end
    end
    if IsAll then
        EnemyBaseNames = AllEnemyTypes
    end
    local Models = {}
    for _, BaseName in ipairs(EnemyBaseNames) do
        local TheseModels = GetMobModels(BaseName)
        for _, Model in ipairs(TheseModels) do
            table.insert(Models, Model)
        end
    end
    local ClosestDist = math.huge
    local ClosestMob = nil
    for _, Mob in ipairs(Models) do
        if not IsMobDead(Mob) and Mob and Mob.Parent then
            local MobRoot = Mob:FindFirstChild("HumanoidRootPart") or Mob.PrimaryPart or Mob:FindFirstChildWhichIsA("BasePart", true)
            if MobRoot then
                local Dist = (RootPart.Position - MobRoot.Position).Magnitude
                if Dist < ClosestDist then
                    ClosestMob = Mob
                    ClosestDist = Dist
                end
            end
        end
    end
    return ClosestMob
end

local function TweenToEnemy(Mob, OffsetY)
    local Character = Players.LocalPlayer.Character
    if not Character then return false end
    local RootPart = Character:FindFirstChild("HumanoidRootPart")
    if not (RootPart and Mob and Mob.Parent) then return false end
    local MobRoot = Mob:FindFirstChild("HumanoidRootPart") or Mob.PrimaryPart or Mob:FindFirstChildWhichIsA("BasePart", true)
    if not MobRoot then return false end
    if CurrentEnemyTween then
        pcall(function() CurrentEnemyTween:Cancel() end)
    end
    local TargetPos = MobRoot.Position + Vector3.new(0, OffsetY, 0)

    if UseInstantTPEnemy then
        RootPart.CFrame = CFrame.new(TargetPos, MobRoot.Position)
        RootPart.Velocity = Vector3.new(0, 0, 0)
        task.wait(1)
        return true
    end

    local Dist = (RootPart.Position - TargetPos).Magnitude
    local Time = Dist / FarmTweenSpeed
    CurrentEnemyTween = TweenService:Create(RootPart, TweenInfo.new(Time, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
        CFrame = CFrame.new(TargetPos, MobRoot.Position)
    })
    CurrentEnemyTween:Play()
    return true
end

local function FarmEnemy(Mob, MobBaseName)
    if Mob and MobBaseName and MobBaseName ~= "" then
        if Mob and Mob.Parent then
            local Args = {"Weapon"}
            local ToolRemote = ReplicatedStorage.Shared.Packages.Knit.Services.ToolService.RF.ToolActivated
            local Character = Players.LocalPlayer.Character
            if Character then
                local RootPart = Character:FindFirstChild("HumanoidRootPart")
                if RootPart then
                    local OriginalChar = Character
                    local OriginalAngular = RootPart.AssemblyAngularVelocity
                    RootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                    local BodyVel = RootPart:FindFirstChild("BodyVelocity")
                    if not BodyVel then
                        BodyVel = Instance.new("BodyVelocity")
                        BodyVel.MaxForce = Vector3.new(4000, 4000, 4000)
                        BodyVel.Velocity = Vector3.new(0, 0, 0)
                        BodyVel.Parent = RootPart
                    end
                    local TweenCompleted = false
                    if CurrentEnemyTween then
                        task.spawn(function()
                            pcall(function()
                                CurrentEnemyTween.Completed:Wait()
                            end)
                            TweenCompleted = true
                        end)
                    else
                        TweenCompleted = true
                    end
                    local Connection
                    Connection = RunService.Heartbeat:Connect(function()
                        if TweenCompleted then
                            if AutoFarmEnemyEnabled and Mob and Mob.Parent and not IsMobDead(Mob) and Players.LocalPlayer.Character == OriginalChar and RootPart and RootPart.Parent and not Tweening then
                                local MobRoot = Mob:FindFirstChild("HumanoidRootPart") or Mob.PrimaryPart or Mob:FindFirstChildWhichIsA("BasePart", true)
                                if MobRoot and RootPart and RootPart.Parent then
                                    local TargetPos = MobRoot.Position + Vector3.new(0, FarmDistance, 0)
                                    RootPart.CFrame = CFrame.new(TargetPos, MobRoot.Position)
                                    if BodyVel then BodyVel.Velocity = Vector3.new(0, 0, 0) end
                                end
                            else
                                if Connection then Connection:Disconnect() end
                            end
                        end
                    end)
                    while AutoFarmEnemyEnabled and Players.LocalPlayer.Character == OriginalChar and RootPart and RootPart.Parent and not Tweening and not IsMobDead(Mob) and Mob and Mob.Parent do
                        pcall(function()
                            ToolRemote:InvokeServer(unpack(Args))
                        end)
                        task.wait(0.15)
                    end
                    if CurrentEnemyTween then
                        pcall(function() CurrentEnemyTween:Cancel() end)
                        CurrentEnemyTween = nil
                    end
                    if Connection then Connection:Disconnect() end
                    if BodyVel and BodyVel.Parent then BodyVel:Destroy() end
                    if RootPart and RootPart.Parent then
                        RootPart.AssemblyAngularVelocity = OriginalAngular
                    end
                end
            end
        end
    end
end

local function buildOreOptions()
    local assets = ReplicatedStorage:FindFirstChild("Assets")
    local oresFolder = assets and assets:FindFirstChild("Ores")
    local options = {}
    if oresFolder then
        for _, ore in ipairs(oresFolder:GetChildren()) do
            if ore.Name and ore.Name ~= "" then
                table.insert(options, ore.Name)
            end
        end
    end
    table.sort(options)
    return options
end

local function listToSet(list)
    local set = {}
    for _, v in ipairs(list) do
        set[tostring(v)] = true
    end
    return set
end

local function buildMobOptions()
    local assets = ReplicatedStorage:FindFirstChild("Assets")
    local mobsFolder = assets and assets:FindFirstChild("Mobs")
    local options = {}
    if mobsFolder then
        for _, mob in ipairs(mobsFolder:GetChildren()) do
            if mob.Name and mob.Name ~= "" then
                table.insert(options, mob.Name)
            end
        end
    end
    table.sort(options)
    return options
end

local function normalizeMobName(name)
    return (tostring(name):gsub("%d+$", ""))
end

local function ensureWeaponEquipped()
    local char = getCharacter()
    local hum = getHumanoid()
    for _, t in ipairs(char:GetChildren()) do
        if t:IsA("Tool") and t.Name == "Weapon" then
            return t
        end
    end
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return nil end
    local weapon = backpack:FindFirstChild("Weapon")
    if not (weapon and weapon:IsA("Tool")) then return nil end
    pcall(function()
        if hum then
            hum:EquipTool(weapon)
        else
            weapon.Parent = char
        end
    end)
    task.wait(0.1)
    return weapon
end

local function runCharacter()
    pcall(function()
        local CharacterService = Knit.GetService("CharacterService")
        CharacterService:Run()
    end)
end

local function stopRunCharacter()
    pcall(function()
        local CharacterService = Knit.GetService("CharacterService")
        CharacterService:StopRun()
    end)
end

local function dashAwayFromTarget(humanoid, hrp, targetPart)
    if not (humanoid and hrp and targetPart) then return end
    pcall(function()
        local CharacterService = Knit.GetService("CharacterService")
        local toEnemy = (targetPart.Position - hrp.Position)
        local flat = Vector3.new(toEnemy.X, 0, toEnemy.Z)
        if flat.Magnitude < 0.1 then return end
        local away = -flat.Unit
        local rootCF = hrp.CFrame
        local look = rootCF.LookVector
        local right = rootCF.RightVector
        look = Vector3.new(look.X, 0, look.Z).Unit
        right = Vector3.new(right.X, 0, right.Z).Unit
        local dotL = look:Dot(away)
        local dotR = right:Dot(away)
        local dir, sign
        if math.abs(dotL) >= math.abs(dotR) then
            if dotL >= 0 then
                dir, sign = "LookVector", "+"
            else
                dir, sign = "LookVector", "-"
            end
        else
            if dotR >= 0 then
                dir, sign = "RightVector", "+"
            else
                dir, sign = "RightVector", "-"
            end
        end
        CharacterService:Dash(dir, sign)
    end)
end

local SelectedNPC = nil
local AllNPCs = {}
local NPCDropdown = nil
local SelectedShop = nil
local AllShops = {}
local ShopDropdown = nil

local function GetAllNPCs()
    AllNPCs = {}
    local Proximity = workspace:FindFirstChild("Proximity")
    if not Proximity then return AllNPCs end
    for _, Child in ipairs(Proximity:GetChildren()) do
        if Child:IsA("Model") and not Child.Name:lower():find("potion") then
            table.insert(AllNPCs, Child.Name)
        end
    end
    table.sort(AllNPCs)
    return AllNPCs
end

local function GetAllShops()
    AllShops = {}
    local Shops = workspace:FindFirstChild("Shops")
    if not Shops then return AllShops end
    for _, Child in ipairs(Shops:GetChildren()) do
        if Child:IsA("Model") then
            table.insert(AllShops, Child.Name)
        end
    end
    table.sort(AllShops)
    return AllShops
end

local function TweenToTarget(TargetName, IsNPC)
    local Character = Players.LocalPlayer.Character
    if not Character then
        aiko("Character not found!")
        return false
    end
    local RootPart = Character:FindFirstChild("HumanoidRootPart")
    if not RootPart then
        aiko("HumanoidRootPart not found!")
        return false
    end
    local Folder = IsNPC and workspace:FindFirstChild("Proximity") or workspace:FindFirstChild("Shops")
    if not Folder then
        aiko("Folder not found!")
        return false
    end
    local Target = Folder:FindFirstChild(TargetName)
    if not Target then
        aiko("Target not found: " .. TargetName)
        return false
    end
    local TargetRoot = Target:FindFirstChild("HumanoidRootPart") or Target.PrimaryPart or Target:FindFirstChildWhichIsA("BasePart", true)
    if not TargetRoot then
        aiko("Target part not found!")
        return false
    end
    local TargetPos = TargetRoot.Position + Vector3.new(0, 3, 0)
    local Dist = (RootPart.Position - TargetPos).Magnitude
    local Time = math.clamp(Dist / 100, 1.5, 8)
    local Tween = TweenService:Create(RootPart, TweenInfo.new(Time, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
        CFrame = CFrame.new(TargetPos, TargetRoot.Position)
    })
    Tween:Play()
    Tween.Completed:Wait()
    aiko("Teleported to " .. TargetName)
    return true
end

local function sendWebhookNotification(title, description, color, fields)
    if not webhook.enabled or webhook.url == "" then return end

    local embed = {
        ["title"] = title,
        ["description"] = description,
        ["color"] = color or 15158332,
        ["fields"] = fields or {},
        ["timestamp"] = DateTime.now():ToIsoDate(),
        ["footer"] = {
            ["text"] = "@aikoware - The Forge"
        }
    }

    local data = {
        ["embeds"] = {embed}
    }

    if webhook.userId ~= "" then
        data["content"] = "<@" .. webhook.userId .. ">"
    end

    local success, response = pcall(function()
        return HttpService:JSONEncode(data)
    end)

    if success then
        pcall(function()
            local httpRequest = (syn and syn.request) or http_request or request
            if httpRequest then
                httpRequest({
                    Url = webhook.url,
                    Method = "POST",
                    Headers = {
                        ["Content-Type"] = "application/json"
                    },
                    Body = response
                })
            end
        end)
    end
end

local function setupAutoParry(npcModel)
    if not autoParry.enabled then return end

    task.spawn(function()
        local hrp = npcModel:WaitForChild("HumanoidRootPart", 5)
        if not hrp then return end

        local infoFrame = hrp:WaitForChild("infoFrame", 5)
        if not infoFrame then return end

        local frame = infoFrame:WaitForChild("Frame", 5)
        if not frame then return end

        local rockName = frame:WaitForChild("rockName", 5)
        if not rockName or not rockName:IsA("TextLabel") then return end

        if not string.find(rockName.Text, "Slime") then return end

        local status = npcModel:WaitForChild("Status", 5)
        if not status then return end

        status.ChildAdded:Connect(function(child)
            if not autoParry.enabled then return end

            if child:IsA("BoolValue") and child.Name == "Attacking" then
                task.wait(0.1)
                local char = getCharacter()
                if char then
                    local tool = char:FindFirstChildOfClass("Tool")
                    if tool then
                        pcall(function()
                            local toolRF = ReplicatedStorage.Shared.Packages.Knit.Services.ToolService.RF.ToolActivated
                            toolRF:InvokeServer("Parry")
                        end)
                    end
                end
            end
        end)
    end)
end

local function initializeAutoParry()
    local Living = workspace:FindFirstChild("Living")
    if not Living then return end

    for _, npc in ipairs(Living:GetChildren()) do
        if npc:IsA("Model") then
            setupAutoParry(npc)
        end
    end

    Living.ChildAdded:Connect(function(npc)
        if npc:IsA("Model") then
            setupAutoParry(npc)
        end
    end)
end

local function getInventoryFromUI()
    local inv = {}
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then return inv end

    local menu = pg:FindFirstChild("Menu")
    local frame1 = menu and menu:FindFirstChild("Frame")
    local frame2 = frame1 and frame1:FindFirstChild("Frame")
    local menus = frame2 and frame2:FindFirstChild("Menus")
    local stash = menus and menus:FindFirstChild("Stash")
    local container = stash and stash:FindFirstChild("Background")

    if not container then 
        container = stash 
    end

    if not container then
        return inv 
    end

    for _, itemFrame in ipairs(container:GetChildren()) do
        local main = itemFrame:FindFirstChild("Main")
        if main then
            local nameLbl = main:FindFirstChild("ItemName")
            local qtyLbl = main:FindFirstChild("Quantity")
            if nameLbl and qtyLbl and nameLbl:IsA("TextLabel") and qtyLbl:IsA("TextLabel") then
                local name = nameLbl.Text
                local qtyStr = qtyLbl.Text
                local qty = tonumber(qtyStr:match("%d+")) or 0
                if name and name ~= "" and qty > 0 then
                    inv[name] = qty
                end
            end
        end
    end

    return inv
end

local function startAutoMelt()
    task.spawn(function()
        while autoForge.autoMelt and autoForge.enabled do
            local visible = MeltMinigame and MeltMinigame.Enabled
            if visible then
                local frame = MeltMinigame:FindFirstChild("Frame")
                local bar = frame and frame:FindFirstChild("Bar")
                local indicator = bar and bar:FindFirstChild("Indicator")
                local button = bar and bar:FindFirstChild("TextButton")

                if indicator and button then
                    local pos = indicator.Position.X.Scale
                    local speed = 15

                    if pos >= 0.45 and pos <= 0.55 then
                        pcall(function()
                            for i = 1, speed do
                                button.MouseButton1Click:Fire()
                            end
                        end)
                    end
                end
            end
            task.wait(0.01)
        end
    end)
end

local function startAutoPour()
    task.spawn(function()
        while autoForge.autoPour and autoForge.enabled do
            local visible = PourMinigame and PourMinigame.Enabled
            if visible then
                local frame = PourMinigame:FindFirstChild("Frame")
                local container = frame and frame:FindFirstChild("Container")
                local indicator = container and container:FindFirstChild("Indicator")

                if indicator then
                    local pos = indicator.Position.Y.Scale
                    local min = 0.05
                    local max = 0.9

                    pcall(function()
                        if pos < min then
                            StartBlock:InvokeServer()
                        elseif pos > max then
                            StopBlock:InvokeServer()
                        end
                    end)
                end
            end
            task.wait(0.01)
        end
    end)
end

local function startAutoHammer()
    task.spawn(function()
        while autoForge.autoHammer and autoForge.enabled do
            local visible = HammerMinigame and HammerMinigame.Enabled
            if visible then
                local frame = HammerMinigame:FindFirstChild("Frame")
                local bar = frame and frame:FindFirstChild("Bar")
                local indicator = bar and bar:FindFirstChild("Indicator")
                local button = bar and bar:FindFirstChild("TextButton")

                if indicator and button then
                    local pos = indicator.Position.X.Scale

                    -- Click when indicator is in optimal range
                    if pos >= 0.45 and pos <= 0.55 then
                        pcall(function()
                            button.MouseButton1Click:Fire()
                        end)
                    end
                end
            end
            task.wait(0.01)
        end
    end)
end

local function startAutoMold()
    task.spawn(function()
        while autoForge.autoMold and autoForge.enabled do
            local char = LocalPlayer.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local proximity = workspace:FindFirstChild("Proximity")
                    if proximity then
                        local mold = proximity:FindFirstChild("Mold")
                        if mold then
                            local moldRoot = mold:FindFirstChild("HumanoidRootPart") or mold.PrimaryPart
                            if moldRoot then
                                local dist = (hrp.Position - moldRoot.Position).Magnitude
                                if dist < 10 then
                                    pcall(function()
                                        local ProximityService = Services:WaitForChild("ProximityService")
                                        local ProximityRF = ProximityService:WaitForChild("RF")
                                        local Dialogue = ProximityRF:FindFirstChild("Dialogue")
                                        if Dialogue then
                                            Dialogue:InvokeServer("Mold", {ItemType = autoForge.itemType})
                                        end
                                    end)
                                end
                            end
                        end
                    end
                end
            end
            task.wait(1)
        end
    end)
end

local function startAutoForge()
    task.spawn(function()
        while autoForge.enabled do
            if #autoForge.selectedOres > 0 then
                local inv = getInventoryFromUI()
                local hasOres = false

                for _, oreName in ipairs(autoForge.selectedOres) do
                    if inv[oreName] and inv[oreName] >= autoForge.totalOresPerForge then
                        hasOres = true
                        break
                    end
                end

                if hasOres then
                    pcall(function()
                        local InventoryService = Services:WaitForChild("InventoryService")
                        local InventoryRF = InventoryService:WaitForChild("RF")
                        local UseItems = InventoryRF:WaitForChild("UseItems")

                        -- Use the ores
                        local oreBasket = {}
                        for _, oreName in ipairs(autoForge.selectedOres) do
                            if inv[oreName] then
                                oreBasket[oreName] = math.min(inv[oreName], autoForge.totalOresPerForge)
                            end
                        end

                        UseItems:InvokeServer(oreBasket)
                    end)
                end
            end

            task.wait(2)
        end
    end)
end

local function buildForgeOreOptions()
    local names = {}
    local assets = ReplicatedStorage:FindFirstChild("Assets")
    local oresFolder = assets and assets:FindFirstChild("Ores")

    if oresFolder then
        for _, ore in ipairs(oresFolder:GetChildren()) do
            if ore.Name and ore.Name ~= "" then
                table.insert(names, ore.Name)
            end
        end
    end

    table.sort(names)
    return names
end

local forgeOreOptions = buildForgeOreOptions()
if #autoForge.selectedOres == 0 and #forgeOreOptions > 0 then
    autoForge.selectedOres = { forgeOreOptions[1] }
end

local AIKO = loadstring(game:HttpGet("https://raw.githubusercontent.com/a11bove/kdoaz/refs/heads/main/src/Library.lua"))()

local Window = AIKO:Window({
    Title = "@aikoware |",
    Footer = "made by untog",
    Version = 1,
})

local Tabs = {
    Info = Window:AddTab({ Name = "Home", Icon = "home" }),
    MainFarm = Window:AddTab({ Name = "Main", Icon = "sword" }),
    AutoForge = Window:AddTab({ Name = "Forge", Icon = "hammer" }),
    Auto = Window:AddTab({ Name = "Auto", Icon = "loop" }),
    AutoSell = Window:AddTab({ Name = "Sell", Icon = "shop" }),
    Webhook = Window:AddTab({ Name = "Webhook", Icon = "bell" }),
    Teleport = Window:AddTab({ Name = "Teleport", Icon = "map-pin" }),
}

local InfoSection = Tabs.Info:AddSection("Support", true)

InfoSection:AddParagraph({
    Title = "Note",
    Content = "Script is still in beta, so expect some bugs.",
    Icon = "idea",
})

InfoSection:AddParagraph({
    Title = "Discord",
    Content = "Join to our discord for more info!",
    Icon = "discord",
    ButtonText = "Copy Server Link",
    ButtonCallback = function()
        local link = "https://discord.gg/JccfFGpDNV"
        if setclipboard then
            setclipboard(link)
            aiko("Discord link copied!")
        end
    end
})

local SettingsSection = Tabs.Info:AddSection("Anti AFK")

SettingsSection:AddToggle({
    Title = "Anti-AFK",
    Content = "Anti kick if idle for 20 mins.",
    Default = true,
    Callback = function(v)
        antiAfk.enabled = v and true or false
        if v then 
            AA_Start()
            aiko("Anti-AFK enabled!")
        else
            aiko("Anti-AFK disabled")
        end
    end
})

SettingsSection:AddSlider({
    Title = "AFK Tap Interval (sec)",
    Min = 30,
    Max = 180,
    Increment = 5,
    Default = 60,
    Callback = function(v)
        local n = tonumber(v)
        if n and n >= 10 then antiAfk.interval = n end
    end
})

if antiAfk.enabled then AA_Start() end

AllRockTypes = GetAllRockTypes()
local RockOptions = {"All"}
for _, Rock in ipairs(AllRockTypes) do
    table.insert(RockOptions, Rock)
end

local TeleportInfo = Tabs.MainFarm:AddSection("Info", true)

TeleportInfo:AddParagraph({
    Title = "Teleport Info",
    Icon = "info",
    Content = "If you got kicked because of anti tp, just adjust the teleport speed to a lower value."
})

local OreFarmSection = Tabs.MainFarm:AddSection("Ore Farming")

RockDropdown = OreFarmSection:AddDropdown({
    Title = "Select Rock",
    Content = "Select rocks to mine",
    Multi = true,
    Options = RockOptions,
    Default = RockTypes,
    Callback = function(opts)
        if type(opts) == "table" then
            RockTypes = {}
            local HasAll = false
            for _, name in ipairs(opts) do
                if name == "All" then
                    HasAll = true
                else
                    table.insert(RockTypes, name)
                end
            end
            if HasAll then
                RockTypes = {}
                for _, Rock in ipairs(AllRockTypes) do
                    table.insert(RockTypes, Rock)
                end
            end
        end
    end
})

OreFarmSection:AddButton({
    Title = "Refresh Rock List",
    Callback = function()
        AllRockTypes = GetAllRockTypes()
        local NewOptions = {"All"}
        for _, Rock in ipairs(AllRockTypes) do
            table.insert(NewOptions, Rock)
        end
        if RockDropdown then
            RockDropdown:SetValues(NewOptions, RockTypes)
        end
        aiko("Rock list refreshed!")
    end
})

OreFarmSection:AddSlider({
    Title = "Mine Distance",
    Content = "Distance from rock",
    Min = 1,
    Max = 10,
    Increment = 1,
    Default = 6,
    Callback = function(value)
        MineDistance = value
    end
})

OreFarmSection:AddSlider({
    Title = "Teleport Speed",
    Min = 30,
    Max = 200,
    Increment = 10,
    Default = 70,
    Callback = function(value)
        MineTweenSpeed = value
    end
})

OreFarmSection:AddToggle({
    Title = "Use Instant TP",
    Default = false,
    Callback = function(v)
        UseInstantTPMine = v
        if v then
            aiko("Instant TP for mining enabled!")
        else
            aiko("Instant TP for mining disabled")
        end
    end
})

OreFarmSection:AddToggle({
    Title = "Auto Mine",
    Default = false,
    Callback = function(v)
        AutoMineEnabled = v
        if v and (not RockTypes or #RockTypes == 0) then
            aiko("Please select a rock type!")
        elseif v then
            aiko("Auto mine started!")
        else
            aiko("Auto mine stopped")
        end
    end
})

task.spawn(function()
    while task.wait(0.3) do
        if AutoMineEnabled and RockTypes and #RockTypes > 0 and not Tweening then
            local Character = Players.LocalPlayer.Character
            local RootPart = Character and Character:FindFirstChild("HumanoidRootPart")
            local ClosestRockPart = Character and RootPart and GetClosestRock(RockTypes)
            if ClosestRockPart then
                TweenToRock(ClosestRockPart)
                local Model = ClosestRockPart:FindFirstAncestorWhichIsA("Model")
                MineRock(ClosestRockPart, Model and Model.Name or nil)
            end
        end
    end
end)

AllEnemyTypes = GetAllEnemyTypes()
local EnemyOptions = {"All"}
for _, Enemy in ipairs(AllEnemyTypes) do
    table.insert(EnemyOptions, Enemy)
end

local MobFarmSection = Tabs.MainFarm:AddSection("Mob Farming")

EnemyDropdown = MobFarmSection:AddDropdown({
    Title = "Select Enemy",
    Content = "Select mobs to farm",
    Multi = true,
    Options = EnemyOptions,
    Default = EnemyTypes,
    Callback = function(opts)
        if type(opts) == "table" then
            EnemyTypes = {}
            local HasAll = false
            for _, name in ipairs(opts) do
                if name == "All" then
                    HasAll = true
                else
                    table.insert(EnemyTypes, name)
                end
            end
            if HasAll then
                EnemyTypes = {}
                for _, Enemy in ipairs(AllEnemyTypes) do
                    table.insert(EnemyTypes, Enemy)
                end
            end
        end
    end
})

MobFarmSection:AddButton({
    Title = "Refresh Enemy List",
    Callback = function()
        AllEnemyTypes = GetAllEnemyTypes()
        local NewOptions = {"All"}
        for _, Enemy in ipairs(AllEnemyTypes) do
            table.insert(NewOptions, Enemy)
        end
        if EnemyDropdown then
            EnemyDropdown:SetValues(NewOptions, EnemyTypes)
        end
        aiko("Enemy list refreshed!")
    end
})

MobFarmSection:AddSlider({
    Title = "Teleport Speed",
    Min = 30,
    Max = 200,
    Increment = 10,
    Default = 70,
    Callback = function(value)
        FarmTweenSpeed = value
    end
})

MobFarmSection:AddSlider({
    Title = "Farm Distance",
    Content = "Distance from mob",
    Min = 1,
    Max = 10,
    Increment = 1,
    Default = 6,
    Callback = function(value)
        FarmDistance = value
    end
})

MobFarmSection:AddToggle({
    Title = "Use Instant TP",
    Default = false,
    Callback = function(v)
        UseInstantTPEnemy = v
        if v then
            aiko("Instant TP for mob farming enabled!")
        else
            aiko("Instant TP for mob farming disabled")
        end
    end
})

MobFarmSection:AddToggle({
    Title = "Auto Farm Mobs",
    Default = false,
    Callback = function(v)
        AutoFarmEnemyEnabled = v
        if v and (not EnemyTypes or #EnemyTypes == 0) then
            aiko("Please select an enemy type!")
        elseif v then
            aiko("Auto farm mobs started!")
        else
            aiko("Auto farm mobs stopped")
        end
    end
})

task.spawn(function()
    while task.wait(0.3) do
        if AutoFarmEnemyEnabled and EnemyTypes and #EnemyTypes > 0 and not Tweening then
            local ClosestEnemy = GetClosestEnemy(EnemyTypes)
            if ClosestEnemy then
                if IsMobDead(ClosestEnemy) then
                    task.wait(0.1)
                else
                    TweenToEnemy(ClosestEnemy, FarmDistance)
                    local BaseName = GetBaseMobName(ClosestEnemy.Name)
                    FarmEnemy(ClosestEnemy, BaseName)
                end
            else
                task.wait(0.1)
            end
        end
    end
end)

local ForgeSection = Tabs.AutoForge:AddSection("Auto Forge")

ForgeSection:AddDropdown({
    Title = "Item Type",
    Content = "Weapon or Armor",
    Options = { "Weapon", "Armor" },
    Default = "Weapon",
    Callback = function(v)
        if v == "Weapon" or v == "Armor" then
            autoForge.itemType = v
        end
    end
})

ForgeSection:AddDropdown({
    Title = "Select Ore",
    Multi = true,
    Options = forgeOreOptions,
    Default = autoForge.selectedOres,
    Callback = function(opts)
        if type(opts) == "table" and #opts > 0 then
            autoForge.selectedOres = opts
        end
    end
})

ForgeSection:AddSlider({
    Title = "Ores Per Forge",
    Content = "Number of ores to use",
    Min = 3,
    Max = 10,
    Increment = 1,
    Default = 3,
    Callback = function(value)
        autoForge.totalOresPerForge = math.floor(value)
    end
})

local MinigameSection = Tabs.AutoForge:AddSection("Minigame Automation")

MinigameSection:AddToggle({
    Title = "Auto Melt",
    Default = false,
    Callback = function(v)
        autoForge.autoMelt = v
        if v then
            startAutoMelt()
            aiko("Auto melt enabled!")
        else
            aiko("Auto melt disabled")
        end
    end
})

MinigameSection:AddToggle({
    Title = "Auto Pour",
    Default = false,
    Callback = function(v)
        autoForge.autoPour = v
        if v then
            startAutoPour()
            aiko("Auto pour enabled!")
        else
            aiko("Auto pour disabled")
        end
    end
})

MinigameSection:AddToggle({
    Title = "Auto Hammer",
    Default = false,
    Callback = function(v)
        autoForge.autoHammer = v
        if v then
            startAutoHammer()
            aiko("Auto hammer enabled!")
        else
            aiko("Auto hammer disabled")
        end
    end
})

MinigameSection:AddToggle({
    Title = "Auto Mold",
    Default = false,
    Callback = function(v)
        autoForge.autoMold = v
        if v then
            startAutoMold()
            aiko("Auto mold enabled!")
        else
            aiko("Auto mold disabled")
        end
    end
})

ForgeSection:AddDivider()

ForgeSection:AddToggle({
    Title = "Enable Auto Forge",
    Default = false,
    Callback = function(v)
        autoForge.enabled = v
        if v then
            aiko("Auto forge started!")
            startAutoForge()
        else
            aiko("Auto forge stopped")
        end
    end
})

local oreOptions = buildOreOptions()

local mobOptions = buildMobOptions()
if #mobOptions == 0 then
    table.insert(mobOptions, "Zombie")
end

local AutoPotSection = Tabs.Auto:AddSection("Auto Potions")

local function buildPotionOptions()
    local potFolder = ReplicatedStorage:FindFirstChild("Assets")
    potFolder = potFolder and potFolder:FindFirstChild("Extras") or nil
    potFolder = potFolder and potFolder:FindFirstChild("Potion") or nil
    local names = {}
    if potFolder then
        for _, inst in ipairs(potFolder:GetChildren()) do
            if inst.Name and typeof(inst.Name) == "string" then
                table.insert(names, inst.Name)
            end
        end
    end
    table.sort(names)
    return names
end

local potionOptions = buildPotionOptions()

AutoPotSection:AddDropdown({
    Title = "Select Potions",
    Multi = true,
    Options = potionOptions,
    Default = {},
    Callback = function(opts)
        if type(opts) == "table" and #opts > 0 then
            autoPotions.selected = opts
        else
            autoPotions.selected = {}
        end
    end
})

local function autoPotionLoop()
    local toolRF = ReplicatedStorage
        :WaitForChild("Shared")
        :WaitForChild("Packages")
        :WaitForChild("Knit")
        :WaitForChild("Services")
        :WaitForChild("ToolService")
        :WaitForChild("RF")
        :WaitForChild("ToolActivated")

    while autoPotions.enabled do
        if #autoPotions.selected == 0 then
            wait(1)
        else
            local usedSomething = false
            for _, potionName in ipairs(autoPotions.selected) do
                local backpack = LocalPlayer:FindFirstChild("Backpack")
                local tool = backpack and backpack:FindFirstChild(potionName)
                if tool and tool:IsA("Tool") then
                    pcall(function()
                        LocalPlayer.Character.Humanoid:EquipTool(tool)
                    end)
                    pcall(function()
                        toolRF:InvokeServer(potionName)
                    end)
                    usedSomething = true
                end
            end
            wait(1)
        end
    end
end

AutoPotSection:AddToggle({
    Title = "Auto Drink Potions",
    Default = false,
    Callback = function(v)
        autoPotions.enabled = v
        if autoPotions.enabled then
            aiko("Auto potions started!")
            spawn(autoPotionLoop)
        else
            aiko("Auto potions stopped")
        end
    end
})

local AutoMoveSection = Tabs.Auto:AddSection("Auto Movement")

local function autoMovementLoop()
    if autoMovementRunning then return end
    autoMovementRunning = true
    local lastHealth
    local lastDodgeTime = 0
    while autoMovement.alwaysRun or autoMovement.autoDodge do
        local char = LocalPlayer and LocalPlayer.Character or nil
        local humanoid = char and char:FindFirstChildOfClass("Humanoid") or nil
        local hrp = char and char:FindFirstChild("HumanoidRootPart") or nil
        if humanoid and hrp then
            local health = humanoid.Health
            if autoMovement.alwaysRun and humanoid.MoveDirection.Magnitude > 0.1 then
                runCharacter()
            end
            if autoMovement.autoDodge and lastHealth and health < lastHealth - 0.5 and health > 0 then
                if time() - lastDodgeTime > 1 then
                    local nearestPart
                    local nearestDist = math.huge
                    for _, model in ipairs(workspace.Living:GetChildren()) do
                        if model:IsA("Model") and model ~= char then
                            local part = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
                            if part then
                                local d = (part.Position - hrp.Position).Magnitude
                                if d < nearestDist then
                                    nearestDist = d
                                    nearestPart = part
                                end
                            end
                        end
                    end
                    if nearestPart and nearestDist < 60 then
                        dashAwayFromTarget(humanoid, hrp, nearestPart)
                        lastDodgeTime = time()
                    end
                end
            end
            lastHealth = health
        else
            lastHealth = nil
        end
        wait(0.1)
    end
    autoMovementRunning = false
end

AutoMoveSection:AddToggle({
    Title = "Always Run",
    Default = false,
    Callback = function(v)
        autoMovement.alwaysRun = v
        if not v then
            stopRunCharacter()
        end
        if autoMovement.alwaysRun or autoMovement.autoDodge then
            spawn(autoMovementLoop)
        end
        if v then
            aiko("Always run enabled!")
        else
            aiko("Always run disabled")
        end
    end
})

AutoMoveSection:AddToggle({
    Title = "Auto Dodge",
    Content = "Dash away when hit",
    Default = false,
    Callback = function(v)
        autoMovement.autoDodge = v
        if autoMovement.alwaysRun or autoMovement.autoDodge then
            spawn(autoMovementLoop)
        end
        if v then
            aiko("Auto dodge enabled!")
        else
            aiko("Auto dodge disabled")
        end
    end
})

local AutoParrySection = Tabs.Auto:AddSection("Auto Parry")

AutoParrySection:AddToggle({
    Title = "Auto Parry",
    Default = false,
    Callback = function(v)
        autoParry.enabled = v
        if v then
            initializeAutoParry()
            aiko("Auto parry enabled!")
        else
            aiko("Auto parry disabled")
        end
    end
})

local AutoSellSection = Tabs.AutoSell:AddSection("Auto Sell")

local function RefreshInventoryList()
    local inv = getInventoryFromUI()
    local options = {}
    for name, _ in pairs(inv) do
        table.insert(options, name)
    end
    table.sort(options)

    if #options == 0 then
        options = {"No items found (Open Stash)"}
    end

    currentInvOptions = options

    if InvDropdown then
        InvDropdown:SetValues(currentInvOptions, {})
    end
    aiko("Refreshed inventory: " .. #options .. " items")
end

local function performAutoSell()
    local inv = getInventoryFromUI()
    local basket = {}
    local hasItems = false

    local selectedSet = listToSet(autoSell.selectedOres)
    local invSet = listToSet(autoSell.selectedInvItems)

    local function isSelected(name)
        if selectedSet[name] then return true end
        if invSet[name] then return true end
        if selectedSet["Any"] then
            for _, v in ipairs(oreOptions) do
                if v == name then return true end
            end
        end
        return false
    end

    local batchSize = tonumber(autoSell.sellAmount) or 100

    for itemName, amount in pairs(inv) do
        if isSelected(itemName) and amount > 0 then
            local sellQty = math.min(amount, batchSize)
            if sellQty > 0 then
                basket[itemName] = sellQty
                hasItems = true
            end
        end
    end

    if hasItems then
        local args = {
            "SellConfirm",
            {
                Basket = basket
            }
        }

        local rs = game:GetService("ReplicatedStorage")
        local shared = rs:WaitForChild("Shared", 2)
        local packages = shared and shared:WaitForChild("Packages", 2)
        local knit = packages and packages:WaitForChild("Knit", 2)
        local services = knit and knit:WaitForChild("Services", 2)
        local dialogue = services and services:WaitForChild("DialogueService", 2)
        local rf = dialogue and dialogue:WaitForChild("RF", 2)
        local runCmd = rf and rf:WaitForChild("RunCommand", 2)

        if runCmd then
            pcall(function()
                runCmd:InvokeServer(unpack(args))
            end)
        end
    end
end

AutoSellSection:AddParagraph({
    Title = "Auto Sell Info",
    Content = "You need to interact with Greedy Cey first to work.",
    Icon = "info"
})

AutoSellSection:AddDropdown({
    Title = "Ores to Auto Sell",
    Content = "Ores that you get from mining",
    Multi = true,
    Options = oreOptions,
    Default = {},
    Callback = function(opts)
        if type(opts) == "table" then
            autoSell.selectedOres = opts
        end
    end
})

AutoSellSection:AddButton({
    Title = "Refresh Inventory List",
    Callback = function()
        RefreshInventoryList()
    end
})

InvDropdown = AutoSellSection:AddDropdown({
    Title = "Inventory Items to Sell",
    Content = "Ores in your inventory",
    Multi = true,
    Options = currentInvOptions,
    Default = {},
    Callback = function(opts)
        if type(opts) == "table" then
            autoSell.selectedInvItems = opts
        end
    end
})

AutoSellSection:AddSlider({
    Title = "Sell Amount (Batch Size)",
    Content = "Items per sell",
    Min = 1,
    Max = 1000,
    Increment = 1,
    Default = 100,
    Callback = function(v)
        autoSell.sellAmount = v
    end
})

AutoSellSection:AddSlider({
    Title = "Sell Interval (s)",
    Content = "Time between sells",
    Min = 5,
    Max = 120,
    Increment = 5,
    Default = 10,
    Callback = function(v)
        autoSell.interval = v
    end
})

AutoSellSection:AddDivider()

AutoSellSection:AddToggle({
    Title = "Enable Auto Sell",
    Content = "Start auto selling",
    Default = false,
    Callback = function(v)
        autoSell.enabled = v
        if v then
            aiko("Auto sell started!")
            task.spawn(function()
                while autoSell.enabled do
                    performAutoSell()
                    task.wait(autoSell.interval or 10)
                end
            end)
        else
            aiko("Auto sell stopped")
        end
    end
})

local WebhookSection = Tabs.Webhook:AddSection("Webhook Settings")

WebhookSection:AddInput({
    Title = "Webhook URL",
    Placeholder = "https://discord.com/api/webhooks/...",
    Callback = function(v)
        webhook.url = v
        aiko("Webhook URL updated!")
    end
})

WebhookSection:AddInput({
    Title = "User ID (Optional)",
    Placeholder = "123456789012345678",
    Callback = function(v)
        webhook.userId = v
        if v ~= "" then
            aiko("User ID set!")
        end
    end
})

WebhookSection:AddDropdown({
    Title = "Select Ore",
    Content = "Select ores to get notified about",
    Multi = true,
    Options = oreOptions,
    Default = {},
    Callback = function(opts)
        if type(opts) == "table" then
            webhook.selectedOres = opts
            aiko("Webhook ores updated!")
        end
    end
})

WebhookSection:AddButton({
    Title = "Test Webhook",
    Callback = function()
        if webhook.url == "" then
            aiko("Please set webhook URL first!")
            return
        end
        sendWebhookNotification(
            "🔔 Test Notification",
            "Webhook is working correctly!",
            3447003,
            {
                {
                    ["name"] = "Status",
                    ["value"] = "Connected",
                    ["inline"] = true
                }
            }
        )
        aiko("Test notification sent!")
    end
})

WebhookSection:AddToggle({
    Title = "Enable Webhook",
    Default = false,
    Callback = function(v)
        webhook.enabled = v
        if v then
            if webhook.url == "" then
                aiko("Please set webhook URL first!")
                webhook.enabled = false
                return
            end
            aiko("Webhook notifications enabled!")
        else
            aiko("Webhook notifications disabled")
        end
    end
})

local TeleportNPCSection = Tabs.Teleport:AddSection("NPC")

AllNPCs = GetAllNPCs()
NPCDropdown = TeleportNPCSection:AddDropdown({
    Title = "Select NPC",
    Options = AllNPCs,
    Default = nil,
    Callback = function(v)
        SelectedNPC = v
    end
})

TeleportNPCSection:AddButton({
    Title = "Refresh NPC List",
    Callback = function()
        AllNPCs = GetAllNPCs()
        if NPCDropdown then
            NPCDropdown:SetValues(AllNPCs, SelectedNPC)
        end
        aiko("NPC list refreshed!")
    end
})

TeleportNPCSection:AddButton({
    Title = "Teleport to NPC",
    Callback = function()
        if SelectedNPC then
            TweenToTarget(SelectedNPC, true)
        else
            aiko("Please select an NPC!")
        end
    end
})

local TeleportShopSection = Tabs.Teleport:AddSection("Shops")

AllShops = GetAllShops()
ShopDropdown = TeleportShopSection:AddDropdown({
    Title = "Select Shop",
    Options = AllShops,
    Default = nil,
    Callback = function(v)
        SelectedShop = v
    end
})

TeleportShopSection:AddButton({
    Title = "Refresh Shop List",
    Callback = function()
        AllShops = GetAllShops()
        if ShopDropdown then
            ShopDropdown:SetValues(AllShops, SelectedShop)
        end
        aiko("Shop list refreshed!")
    end
})

TeleportShopSection:AddButton({
    Title = "Teleport to Shop",
    Callback = function()
        if SelectedShop then
            TweenToTarget(SelectedShop, false)
        else
            aiko("Please select a shop!")
        end
    end
})

local TeleportWorldSection = Tabs.Teleport:AddSection("World Teleport")

TeleportWorldSection:AddButton({
    Title = "Teleport to World 1",
    Content = "Stonewake's Cross",
    Callback = function()
        local TeleportService = game:GetService("TeleportService")
        local placeId = 129009554587176
        if game.PlaceId == placeId then
            aiko("You are already in World 1!")
            return
        end
        aiko("Teleporting to World 1...")
        pcall(function()
            TeleportService:Teleport(placeId, LocalPlayer)
        end)
    end
})

TeleportWorldSection:AddButton({
    Title = "Teleport to World 2",
    Content = "Forgotten Kindom",
    Callback = function()
        local TeleportService = game:GetService("TeleportService")
        local placeId = 76558904092080
        if game.PlaceId == placeId then
            aiko("You are already in World 2!")
            return
        end
        aiko("Teleporting to World 2...")
        pcall(function()
            TeleportService:Teleport(placeId, LocalPlayer)
        end)
    end
})

AIKO:MakeNotify({
    Title = "@aikoware",
    Description = "Script Loaded",
    Content = "Game: The Forge",
    Delay = 4
})
