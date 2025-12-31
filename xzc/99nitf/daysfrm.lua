repeat task.wait() until game.Players.LocalPlayer.Character
local CollectionService = game:GetService("CollectionService")
local lp = game:GetService("Players").LocalPlayer
local Vim = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local rs = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = game:GetService("Players").LocalPlayer
local player = LocalPlayer

local G2L = {}

local Items = workspace.Items
local Tree = workspace.Map.Landmarks
local Mobs = workspace.Characters
local killAuraToggle = true
local chopAuraToggle = true
local auraRadius = 100
local currentammount = 0
local campfireFuelItems = {"Log", "Coal", "Chair", "Fuel Canister", "Oil Barrel", "Biofuel"}
local campfireDropPos = Vector3.new(0, 19, 0)
local selectedCampfireItem = nil
local selectedCampfireItems = {}
_G.GodModeToggle = false
local autocookItems = {"Morsel", "Steak", "Ribs", "Salmon", "Mackerel"}
local autoCookEnabled = false

for _, itemName in ipairs(campfireFuelItems) do
    table.insert(selectedCampfireItems, itemName)
end

local Day = game.Players.LocalPlayer.PlayerGui.Interface.DayCounter

local toolsDamageIDs = {
    ["Old Axe"] = "3_7367831688",
    ["Good Axe"] = "112_7367831688",
    ["Strong Axe"] = "116_7367831688",
    ["Ice Axe"] = "116_7367831688",
    ["Admin Axe"] = "116_7367831688",
    ["Morningstar"] = "116_7367831688",
    ["Laser Sword"] = "116_7367831688",
    ["Ice Sword"] = "116_7367831688",
    ["Infernal Sword"] = "6_7461591369",
    ["Katana"] = "116_7367831688",
    ["Trident"] = "116_7367831688",
    ["Poison Spear"] = "116_7367831688",
    ["Chainsaw"] = "647_8992824875",
    ["Spear"] = "196_8999010016",
    ["Rifle"] = "22_6180169035"
}

local alimentos = {
    "Apple", "Berry", "Carrot", "Cake", "Chili",
    "Cooked Clownfish", "Cooked Swordfish", "Cooked Jellyfish",
    "Cooked Char", "Cooked Eel", "Cooked Shark", "Cooked Ribs",
    "Cooked Mackerel", "Cooked Salmon", "Cooked Morsel", "Cooked Steak"
}

local selectedFood = {}
local hungerThreshold = 75
local autoFeedToggle = false

local function SetFoodList(foodList)
    selectedFood = {}
    for _, foodName in ipairs(foodList) do
        table.insert(selectedFood, foodName)
    end
end

G2L["ScreenGui_1"] = Instance.new("ScreenGui", game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"))
G2L["ScreenGui_1"]["ZIndexBehavior"] = Enum.ZIndexBehavior.Sibling
CollectionService:AddTag(G2L["ScreenGui_1"], "main")

-- Main Frame
G2L["Frame_2"] = Instance.new("Frame", G2L["ScreenGui_1"])
G2L["Frame_2"]["BorderSizePixel"] = 0
G2L["Frame_2"]["BackgroundColor3"] = Color3.fromRGB(15, 15, 15)
G2L["Frame_2"]["Size"] = UDim2.new(0, 280, 0, 320)
G2L["Frame_2"]["Position"] = UDim2.new(0.5, -140, 0.5, -160)
G2L["Frame_2"]["BackgroundTransparency"] = 0.05

G2L["UICorner_3"] = Instance.new("UICorner", G2L["Frame_2"])
G2L["UICorner_3"].CornerRadius = UDim.new(0, 16)

-- Gradient Background
local UIGradient = Instance.new("UIGradient", G2L["Frame_2"])
UIGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 30)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 15))
})
UIGradient.Rotation = 45

G2L["TextLabel_6"] = Instance.new("TextLabel", G2L["Frame_2"])
G2L["TextLabel_6"]["BorderSizePixel"] = 0
G2L["TextLabel_6"]["TextSize"] = 24
G2L["TextLabel_6"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
G2L["TextLabel_6"]["FontFace"] = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
G2L["TextLabel_6"]["TextColor3"] = Color3.fromRGB(46, 205, 255)
G2L["TextLabel_6"]["BackgroundTransparency"] = 1
G2L["TextLabel_6"]["Size"] = UDim2.new(1, 0, 0, 30)
G2L["TextLabel_6"]["Text"] = "@aikoware"
G2L["TextLabel_6"]["Position"] = UDim2.new(0, 0, 0, 20)
G2L["TextLabel_6"]["TextXAlignment"] = Enum.TextXAlignment.Center

local DiscordLink = Instance.new("TextLabel", G2L["Frame_2"])
DiscordLink["BorderSizePixel"] = 0
DiscordLink["TextSize"] = 12
DiscordLink["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
DiscordLink["FontFace"] = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
DiscordLink["TextColor3"] = Color3.fromRGB(88, 166, 255)
DiscordLink["BackgroundTransparency"] = 1
DiscordLink["Size"] = UDim2.new(1, 0, 0, 20)
DiscordLink["Text"] = "discord.gg/JccfFGpDNV"
DiscordLink["Position"] = UDim2.new(0, 0, 0, 55)
DiscordLink["TextXAlignment"] = Enum.TextXAlignment.Center
DiscordLink["Name"] = "DiscordLink"

local LogoFrame = Instance.new("Frame", G2L["Frame_2"])
LogoFrame["BackgroundTransparency"] = 1
LogoFrame["Size"] = UDim2.new(0, 120, 0, 120)
LogoFrame["Position"] = UDim2.new(0.5, -60, 0, 85)
LogoFrame["Name"] = "LogoFrame"

local LogoImage = Instance.new("ImageLabel", LogoFrame)
LogoImage["BackgroundTransparency"] = 1
LogoImage["Size"] = UDim2.new(1, 0, 1, 0)
LogoImage["Image"] = "rbxassetid://105338847670181"
LogoImage["ScaleType"] = Enum.ScaleType.Fit
LogoImage["Name"] = "LogoImage"

local PlaceholderLogo = Instance.new("Frame", LogoFrame)
PlaceholderLogo["BackgroundColor3"] = Color3.fromRGB(46, 205, 255)
PlaceholderLogo["BackgroundTransparency"] = 0.3
PlaceholderLogo["Size"] = UDim2.new(1, 0, 1, 0)
PlaceholderLogo["Name"] = "PlaceholderLogo"
PlaceholderLogo["Visible"] = false

local PlaceholderCorner = Instance.new("UICorner", PlaceholderLogo)
PlaceholderCorner.CornerRadius = UDim.new(0, 20)

local PlaceholderText = Instance.new("TextLabel", PlaceholderLogo)
PlaceholderText["TextSize"] = 48
PlaceholderText["FontFace"] = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
PlaceholderText["TextColor3"] = Color3.fromRGB(255, 255, 255)
PlaceholderText["BackgroundTransparency"] = 1
PlaceholderText["Size"] = UDim2.new(1, 0, 1, 0)
PlaceholderText["Text"] = "AK"
PlaceholderText["TextXAlignment"] = Enum.TextXAlignment.Center
PlaceholderText["TextYAlignment"] = Enum.TextYAlignment.Center

-- Status Text (Below Logo - iPhone SF Pro style)
G2L["TextLabel_8"] = Instance.new("TextLabel", G2L["Frame_2"])
G2L["TextLabel_8"]["BorderSizePixel"] = 0
G2L["TextLabel_8"]["TextSize"] = 13
G2L["TextLabel_8"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
G2L["TextLabel_8"]["FontFace"] = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
G2L["TextLabel_8"]["TextColor3"] = Color3.fromRGB(180, 180, 180)
G2L["TextLabel_8"]["BackgroundTransparency"] = 1
G2L["TextLabel_8"]["Size"] = UDim2.new(1, -30, 0, 50)
G2L["TextLabel_8"]["Text"] = "Do not do anything,\nauto farm days enabled!"
G2L["TextLabel_8"]["Position"] = UDim2.new(0, 15, 0, 215)
G2L["TextLabel_8"]["TextXAlignment"] = Enum.TextXAlignment.Center
G2L["TextLabel_8"]["TextWrapped"] = true
G2L["TextLabel_8"]["TextYAlignment"] = Enum.TextYAlignment.Top

-- Day Counter (Top Right)
G2L["TextLabel2_7"] = Instance.new("TextLabel", G2L["Frame_2"])
G2L["TextLabel2_7"]["BorderSizePixel"] = 0
G2L["TextLabel2_7"]["TextSize"] = 11
G2L["TextLabel2_7"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
G2L["TextLabel2_7"]["FontFace"] = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
G2L["TextLabel2_7"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
G2L["TextLabel2_7"]["BackgroundTransparency"] = 1
G2L["TextLabel2_7"]["Size"] = UDim2.new(0, 100, 0, 25)
G2L["TextLabel2_7"]["Text"] = Day.Text
G2L["TextLabel2_7"]["Name"] = "TextLabel2"
G2L["TextLabel2_7"]["Position"] = UDim2.new(1, -110, 0, 15)
G2L["TextLabel2_7"]["TextXAlignment"] = Enum.TextXAlignment.Right

-- Timer Display (Bottom Left)
G2L["TextLabel3_4"] = Instance.new("TextLabel", G2L["Frame_2"])
G2L["TextLabel3_4"]["BorderSizePixel"] = 0
G2L["TextLabel3_4"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
G2L["TextLabel3_4"]["TextColor3"] = Color3.fromRGB(46, 205, 255)
G2L["TextLabel3_4"]["BackgroundTransparency"] = 1
G2L["TextLabel3_4"]["Size"] = UDim2.new(0, 60, 0, 30)
G2L["TextLabel3_4"]["Text"] = "0s" 
G2L["TextLabel3_4"]["Name"] = "TextLabel3"
G2L["TextLabel3_4"]["FontFace"] = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
G2L["TextLabel3_4"]["TextSize"] = 14
G2L["TextLabel3_4"]["Position"] = UDim2.new(0, 15, 1, -35)
G2L["TextLabel3_4"]["TextXAlignment"] = Enum.TextXAlignment.Left

-- Version Label (Bottom Right)
G2L["TextLabel4_5"] = Instance.new("TextLabel", G2L["Frame_2"])
G2L["TextLabel4_5"]["BorderSizePixel"] = 0
G2L["TextLabel4_5"]["TextSize"] = 11
G2L["TextLabel4_5"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
G2L["TextLabel4_5"]["FontFace"] = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
G2L["TextLabel4_5"]["TextColor3"] = Color3.fromRGB(100, 100, 100)
G2L["TextLabel4_5"]["BackgroundTransparency"] = 1
G2L["TextLabel4_5"]["Size"] = UDim2.new(0, 60, 0, 30)
G2L["TextLabel4_5"]["Text"] = "v3.0"
G2L["TextLabel4_5"]["Name"] = "TextLabel4"
G2L["TextLabel4_5"]["Position"] = UDim2.new(1, -70, 1, -35)
G2L["TextLabel4_5"]["TextXAlignment"] = Enum.TextXAlignment.Right

-- Unload Button
G2L["UnloadButton"] = Instance.new("TextButton", G2L["Frame_2"])
G2L["UnloadButton"]["BorderSizePixel"] = 0
G2L["UnloadButton"]["TextSize"] = 15
G2L["UnloadButton"]["BackgroundColor3"] = Color3.fromRGB(255, 69, 58)
G2L["UnloadButton"]["FontFace"] = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
G2L["UnloadButton"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
G2L["UnloadButton"]["Size"] = UDim2.new(0, 120, 0, 36)
G2L["UnloadButton"]["Text"] = "Unload"
G2L["UnloadButton"]["Position"] = UDim2.new(0.5, -60, 1, -80)
G2L["UnloadButton"]["AutoButtonColor"] = false

local buttonCorner = Instance.new("UICorner", G2L["UnloadButton"])
buttonCorner.CornerRadius = UDim.new(0, 10)

-- Button Press Animation
G2L["UnloadButton"].MouseButton1Down:Connect(function()
    TweenService:Create(G2L["UnloadButton"], TweenInfo.new(0.1), {
        BackgroundColor3 = Color3.fromRGB(200, 50, 45)
    }):Play()
end)

G2L["UnloadButton"].MouseButton1Up:Connect(function()
    TweenService:Create(G2L["UnloadButton"], TweenInfo.new(0.1), {
        BackgroundColor3 = Color3.fromRGB(255, 69, 58)
    }):Play()
end)

-- Glow Effect
local Glow = Instance.new("ImageLabel", G2L["Frame_2"])
Glow["BackgroundTransparency"] = 1
Glow["Size"] = UDim2.new(1, 40, 1, 40)
Glow["Position"] = UDim2.new(0.5, -20, 0.5, -20)
Glow["AnchorPoint"] = Vector2.new(0.5, 0.5)
Glow["Image"] = "rbxassetid://5028857084"
Glow["ImageColor3"] = Color3.fromRGB(46, 205, 255)
Glow["ImageTransparency"] = 0.8
Glow["ZIndex"] = 0

-- Update timer display format
local count = 0
task.spawn(function()
    while task.wait(1) do
        count = count + 1
        local hours = math.floor(count / 3600)
        local minutes = math.floor((count % 3600) / 60)
        local seconds = count % 60
        
        if hours > 0 then
            G2L["TextLabel3_4"].Text = string.format("%dh %dm", hours, minutes)
        elseif minutes > 0 then
            G2L["TextLabel3_4"].Text = string.format("%dm %ds", minutes, seconds)
        else
            G2L["TextLabel3_4"].Text = string.format("%ds", seconds)
        end
    end
end)

local frame = G2L["Frame_2"]
local dragging, dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

local textLabel = G2L["TextLabel_8"]
local speedX, speedY = 1, 1
local posX, posY = 38, 74
local frameWidth, frameHeight = 214, 238
local textWidth, textHeight = 138, 60

RunService.RenderStepped:Connect(function()
    posX, posY = posX + speedX, posY + speedY
    if posX <= 0 or posX + textWidth >= frameWidth then speedX = -speedX end
    if posY <= 0 or posY + textHeight >= frameHeight then speedY = -speedY end
    textLabel.Position = UDim2.new(0, posX, 0, posY)
end)

local count = 0
task.spawn(function()
    while task.wait(1) do
        count = count + 1
        G2L["TextLabel3_4"].Text = tostring(count)
    end
end)

local function updateText()
    G2L["TextLabel2_7"].Text = Day.Text
end
updateText()
Day:GetPropertyChangedSignal("Text"):Connect(updateText)

local function RemoveGamePlayPaused()
    pcall(function()
        game:GetService("CoreGui").RobloxGui["CoreScripts/NetworkPause"]:Destroy()
    end)
end
RemoveGamePlayPaused()

Vim:SendKeyEvent(true, Enum.KeyCode.Two, false, game)  
task.wait(0.1)  
Vim:SendKeyEvent(false, Enum.KeyCode.Two, false, game) 

local function moveItemToPos(item, position)
    if not item or not item:IsDescendantOf(workspace) then return end
    local part = item:IsA("Model") and (item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")) or item
    if not part or not part:IsA("BasePart") then return end
    
    pcall(function()
        ReplicatedStorage.RemoteEvents.RequestStartDraggingItem:FireServer(item)
        if item:IsA("Model") then
            item:SetPrimaryPartCFrame(CFrame.new(position))
        else
            part.CFrame = CFrame.new(position)
        end
        ReplicatedStorage.RemoteEvents.StopDraggingItem:FireServer(item)
    end)
end

local function getAnyToolWithDamageID(isChopAura)
    for toolName, damageID in pairs(toolsDamageIDs) do
        if isChopAura and not (toolName:find("Axe") or toolName == "Chainsaw") then
            continue
        end
        local tool = lp.Inventory and lp.Inventory:FindFirstChild(toolName)
        if tool then return tool, damageID end
    end
    return nil, nil
end

local function equipTool(tool)
    if tool then
        pcall(function()
            ReplicatedStorage.RemoteEvents.EquipItemHandle:FireServer("FireAllClients", tool)
        end)
    end
end

local function unequipTool(tool)
    if tool then
        pcall(function()
            ReplicatedStorage.RemoteEvents.UnequipItemHandle:FireServer("FireAllClients", tool)
        end)
    end
end

local function killAuraLoop()
    while true do
        task.wait(0.01)
        if not killAuraToggle then continue end
        
        local character = lp.Character
        if not character then continue end
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        
        local tool, damageID = getAnyToolWithDamageID(false)
        if not tool or not damageID then continue end
        equipTool(tool)
        
        local chars = workspace:FindFirstChild("Characters")
        if chars then
            for _, mob in ipairs(chars:GetChildren()) do
                if mob:IsA("Model") and mob ~= character then
                    local mobHrp = mob:FindFirstChild("HumanoidRootPart") or mob:FindFirstChildWhichIsA("BasePart")
                    if mobHrp and (mobHrp.Position - hrp.Position).Magnitude <= auraRadius then
                        for i = 1, 3 do
                            pcall(function()
                                ReplicatedStorage.RemoteEvents.ToolDamageObject:InvokeServer(
                                    mob, tool, damageID, CFrame.new(mobHrp.Position)
                                )
                            end)
                        end
                    end
                end
            end
        end
    end
end

local function chopAuraLoop()
    while true do
        if not chopAuraToggle then 
            task.wait(0.1) 
            continue 
        end
        
        local character = lp.Character
        if not character then 
            task.wait(0.1) 
            continue 
        end
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then 
            task.wait(0.1) 
            continue 
        end
        
        local tool, baseDamageID = getAnyToolWithDamageID(true)
        if not tool or not baseDamageID then 
            task.wait(0.1) 
            continue 
        end
        equipTool(tool)
        
        local trees = {}
        local map = workspace:FindFirstChild("Map")
        if map then
            for _, folder in ipairs({map:FindFirstChild("Foliage"), map:FindFirstChild("Landmarks")}) do
                if folder then
                    for _, obj in ipairs(folder:GetChildren()) do
                        if obj:IsA("Model") and obj.Name:find("Small Tree") then
                            local trunk = obj:FindFirstChild("Trunk")
                            if trunk and (trunk.Position - hrp.Position).Magnitude <= auraRadius then
                                table.insert(trees, {tree = obj, trunk = trunk})
                            end
                        end
                    end
                end
            end
        end
        
        for _, treeData in ipairs(trees) do
            if treeData.tree and treeData.tree.Parent and treeData.trunk and treeData.trunk.Parent then
                currentammount = currentammount + 1
                pcall(function()
                    ReplicatedStorage.RemoteEvents.ToolDamageObject:InvokeServer(
                        treeData.tree, tool, tostring(currentammount) .. "_7367831688", treeData.trunk.CFrame
                    )
                end)
            end
        end
        task.wait(0.08)
    end
end

task.spawn(chopAuraLoop)
task.spawn(killAuraLoop)

local function God()
    _G.GodModeToggle = true
    task.spawn(function()
        while _G.GodModeToggle do
            pcall(function()
                local dmgEvent = rs.RemoteEvents and rs.RemoteEvents:FindFirstChild("DamagePlayer")
                if dmgEvent then dmgEvent:FireServer(-math.huge) end
            end)
            RunService.Stepped:Wait()
        end
    end)
end
God()

local itemsMoved = 0
local maxItemsAtCampfire = 20
local lastMoveTime = {}

local function getItemsNearCampfire()
    local count = 0
    local itemsFolder = workspace:FindFirstChild("Items")
    if itemsFolder then
        for _, item in ipairs(itemsFolder:GetChildren()) do
            local pos
            if item:IsA("Model") then
                local primaryPart = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
                if primaryPart then
                    pos = primaryPart.Position
                end
            elseif item:IsA("BasePart") then
                pos = item.Position
            end
            
            if pos and (pos - campfireDropPos).Magnitude < 25 then
                count = count + 1
            end
        end
    end
    return count
end

task.spawn(function()
    while task.wait(1) do
        if #selectedCampfireItems > 0 then
            local nearbyItems = getItemsNearCampfire()
            
            if nearbyItems < maxItemsAtCampfire then
                for _, selectedItem in ipairs(selectedCampfireItems) do
                    local currentTime = tick()
                    if lastMoveTime[selectedItem] and currentTime - lastMoveTime[selectedItem] < 1.5 then
                        continue
                    end
                    
                    local items = {}
                    local itemsFolder = workspace:FindFirstChild("Items")
                    if not itemsFolder then continue end
                    
                    for _, item in ipairs(itemsFolder:GetChildren()) do
                        if item.Name == selectedItem then
                            local pos
                            if item:IsA("Model") then
                                local primaryPart = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
                                if primaryPart then
                                    pos = primaryPart.Position
                                end
                            elseif item:IsA("BasePart") then
                                pos = item.Position
                            end
                            
                            if pos and (pos - campfireDropPos).Magnitude > 30 then
                                table.insert(items, item)
                            end
                        end
                    end
                    
                    local itemsToMove = math.min(5, #items, maxItemsAtCampfire - nearbyItems)
                    for i = 1, itemsToMove do
                        moveItemToPos(items[i], campfireDropPos)
                        itemsMoved = itemsMoved + 1
                        task.wait(0.15)
                    end
                    
                    lastMoveTime[selectedItem] = currentTime
                    nearbyItems = getItemsNearCampfire()
                    
                    if nearbyItems >= maxItemsAtCampfire then
                        break
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.5)
        if autoCookEnabled then
            for _, itemName in ipairs(autocookItems) do
                for _, item in ipairs(Items:GetChildren()) do
                    if item.Name == itemName and item.Parent then
                        pcall(function() moveItemToPos(item, campfireDropPos) end)
                    end
                end
            end
        end
    end
end)

autoCookEnabled = true
SetFoodList(alimentos)

local function getHunger()
    local success, result = pcall(function()
        local hungerBar = LocalPlayer.PlayerGui.Interface.StatBars.HungerBar
        return math.floor(hungerBar.Bar.Size.X.Scale * 100)
    end)
    return success and result or 100
end

task.spawn(function()
    autoFeedToggle = true
    while true do
        task.wait(0.5)
        if not autoFeedToggle or #selectedFood == 0 then continue end
        
        local currentHunger = getHunger()
        if currentHunger < hungerThreshold then
            while currentHunger < 100 and autoFeedToggle do
                local foundFood = false
                for _, foodName in ipairs(selectedFood) do
                    if currentHunger >= 100 then break end
                    for _, item in ipairs(Items:GetChildren()) do
                        if item.Name == foodName and item:IsDescendantOf(workspace) then
                            pcall(function()
                                ReplicatedStorage.RemoteEvents.RequestConsumeItem:InvokeServer(item)
                            end)
                            foundFood = true
                            task.wait(0.5)
                            currentHunger = getHunger()
                            if currentHunger >= 100 then break end
                        end
                    end
                    if currentHunger >= 100 then break end
                end
                if not foundFood then break end
                task.wait(0.1)
            end
        end
    end
end)

local scanning = false
local scanStartTime = 0
local isCollectingChild = false
local scannedTrees = {}
local lastScanReset = tick()

local function CheckChild()
    local childCount = 0
    for _, v in pairs(Mobs:GetChildren()) do
        if v.Name:match("Lost Child") then
            local childPart = v:FindFirstChild("HumanoidRootPart") or v:FindFirstChildWhichIsA("BasePart")
            if childPart then
                local distanceToCampfire = (childPart.Position - campfireDropPos).Magnitude
                if distanceToCampfire > 80 then
                    childCount = childCount + 1
                end
            end
        end
    end
    return childCount >= 1
end

local function AllChildrenCollected()
    local collectedCount = 0
    for _, v in pairs(Mobs:GetChildren()) do
        if v.Name:match("Lost Child") then
            local childPart = v:FindFirstChild("HumanoidRootPart") or v:FindFirstChildWhichIsA("BasePart")
            if childPart then
                local distanceToCampfire = (childPart.Position - campfireDropPos).Magnitude
                if distanceToCampfire <= 80 then
                    collectedCount = collectedCount + 1
                end
            end
        end
    end
    return collectedCount >= 4
end

local function GetChild()
    if isCollectingChild then return end
    isCollectingChild = true
    
    local Character = player.Character or player.CharacterAdded:Wait()
    local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    local inventory = player:WaitForChild("Inventory")
    
    local sack = nil
    for _, item in pairs(inventory:GetChildren()) do
        if item.Name:find("Sack") then
            sack = item
            break
        end
    end
    
    if not sack then 
        isCollectingChild = false
        return 
    end
    
    equipTool(sack)
    task.wait(0.5)
    
    for _, v in pairs(Mobs:GetChildren()) do
        if v.Name:match("Lost Child") and v:FindFirstChild("HumanoidRootPart") then
            local part = v:FindFirstChildWhichIsA("BasePart")
            if part then
                local distanceToCampfire = (part.Position - campfireDropPos).Magnitude
                if distanceToCampfire <= 50 then
                    continue
                end
                
                HumanoidRootPart.CFrame = part.CFrame
                task.wait(0.2)
                
                pcall(function()
                    rs.RemoteEvents.RequestBagStoreItem:InvokeServer(sack, v)
                end)
                task.wait(0.8)
            end
        end
    end
    
    unequipTool(sack)
    task.wait(0.5)
    
    HumanoidRootPart.CFrame = CFrame.new(0, 19, 0)
    task.wait(1)
    
    local itemBag = player:WaitForChild("ItemBag")
    for _, child in pairs(itemBag:GetChildren()) do
        if child.Name:match("Lost Child") then
            pcall(function()
                rs.RemoteEvents.RequestBagDropItem:FireServer(sack, child, true)
            end)
            task.wait(0.5)
        end
    end
    
    task.wait(1)
    isCollectingChild = false
end

function scanMapForTrees()
    if isCollectingChild then return end
    
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")
    local map = workspace:FindFirstChild("Map")
    if not map then return end
    
    if tick() - lastScanReset > 60 then
        scannedTrees = {}
        lastScanReset = tick()
    end
    
    scanStartTime = tick()
    local treesScanned = 0
    local maxTreesPerScan = 50
    
    while scanning and not isCollectingChild do
        if CheckChild() then
            scanning = false
            return
        end
        
        if tick() - scanStartTime >= 180 then break end
        
        local trees = {}
        for _, folderName in ipairs({"Foliage", "Landmarks"}) do
            local folder = map:FindFirstChild(folderName)
            if folder then
                for _, obj in ipairs(folder:GetChildren()) do
                    if obj.Name == "Small Tree" and obj:IsA("Model") then
                        local trunk = obj:FindFirstChild("Trunk") or obj.PrimaryPart
                        if trunk and not scannedTrees[trunk] then
                            table.insert(trees, trunk)
                            if #trees >= maxTreesPerScan then break end
                        end
                    end
                end
            end
            if #trees >= maxTreesPerScan then break end
        end
        
        if #trees == 0 then
            scannedTrees = {}
            lastScanReset = tick()
            task.wait(2)
            continue
        end
        
        for i, trunk in ipairs(trees) do
            if isCollectingChild or CheckChild() then
                scanning = false
                return
            end
            
            if not scanning or tick() - scanStartTime >= 180 then break end
            if not trunk.Parent then continue end
            
            scannedTrees[trunk] = true
            
            local treeCFrame = trunk.CFrame
            local targetPos = treeCFrame.Position + treeCFrame.RightVector * 69 + Vector3.new(0, 15, 69)
            hrp.CFrame = CFrame.new(targetPos)
            
            treesScanned = treesScanned + 1
            task.wait(0.08)
        end
        
        task.wait(0.5)
    end
    
    scanning = false
end

local function TeleportSpinAroundCampfire()
    local Character = player.Character or player.CharacterAdded:Wait()
    local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    
    local radius = 30
    local spinSpeed = 0.08
    local fullCircle = math.pi * 2
    local height = 60
    
    if HumanoidRootPart then
        HumanoidRootPart.Anchored = true
    end
    
    while _G.GodModeToggle do  
        for angle = 0, fullCircle, 0.1 do
            if not _G.GodModeToggle then break end
            
            local x = campfireDropPos.X + radius * math.cos(angle)
            local z = campfireDropPos.Z + radius * math.sin(angle)
            local y = campfireDropPos.Y + height
            
            if HumanoidRootPart and HumanoidRootPart.Parent then
                HumanoidRootPart.CFrame = CFrame.new(x, y, z)
            else
                break
            end
            task.wait(spinSpeed)
        end
    end
end

task.spawn(function()
    task.wait(1)
    if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = lp.Character.HumanoidRootPart
        hrp.CFrame = CFrame.new(-2, 80, 0)
        hrp.Anchored = true
        task.wait(5)
        hrp.Anchored = false
    end
end)

G2L["UnloadButton"].MouseButton1Click:Connect(function()
    _G.GodModeToggle = false
    killAuraToggle = false
    chopAuraToggle = false
    autoCookEnabled = false
    autoFeedToggle = false
    scanning = false
    
    if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
        lp.Character.HumanoidRootPart.Anchored = false
    end
    
    if G2L["ScreenGui_1"] then
        G2L["ScreenGui_1"]:Destroy()
    end
end)

task.spawn(function()
    task.wait(6)
    
    while true do
        task.wait(1)
        
        if AllChildrenCollected() then
            scanning = false
            task.wait(1)
            TeleportSpinAroundCampfire()
            break
        end
    
        if CheckChild() and not isCollectingChild then
            scanning = false
            task.wait(0.5)
            GetChild()
            task.wait(2)
        elseif not scanning and not isCollectingChild then
            scanning = true
            scanMapForTrees()
        end
    end
end)

return G2L["ScreenGui_1"]
