local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")

G2L["ScreenGui_1"] = Instance.new("ScreenGui", game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"))
G2L["ScreenGui_1"]["ZIndexBehavior"] = Enum.ZIndexBehavior.Sibling
G2L["ScreenGui_1"]["IgnoreGuiInset"] = true
CollectionService:AddTag(G2L["ScreenGui_1"], "main")

local DarkBG = Instance.new("Frame", G2L["ScreenGui_1"])
DarkBG.Name = "DarkBackground"
DarkBG.Size = UDim2.new(1, 0, 1, 0)
DarkBG.Position = UDim2.new(0, 0, 0, 0)
DarkBG.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
DarkBG.BackgroundTransparency = 0.5  -- Semi-transparent dark overlay
DarkBG.BorderSizePixel = 0
DarkBG.ZIndex = 1

G2L["Frame_2"] = Instance.new("Frame", G2L["ScreenGui_1"])
G2L["Frame_2"]["BorderSizePixel"] = 0
G2L["Frame_2"]["BackgroundColor3"] = Color3.fromRGB(15, 15, 15)
G2L["Frame_2"]["Size"] = UDim2.new(0, 350, 0, 450)
G2L["Frame_2"]["Position"] = UDim2.new(0.5, -175, 0.5, -225)
G2L["Frame_2"]["AnchorPoint"] = Vector2.new(0.5, 0.5)
G2L["Frame_2"]["BackgroundTransparency"] = 0.1
G2L["Frame_2"]["ZIndex"] = 2

G2L["UICorner_3"] = Instance.new("UICorner", G2L["Frame_2"])
G2L["UICorner_3"].CornerRadius = UDim.new(0, 20)

local UIGradient = Instance.new("UIGradient", G2L["Frame_2"])
UIGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 35)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 20))
})
UIGradient.Rotation = 45

local Glow = Instance.new("ImageLabel", G2L["Frame_2"])
Glow["BackgroundTransparency"] = 1
Glow["Size"] = UDim2.new(1, 60, 1, 60)
Glow["Position"] = UDim2.new(0.5, -30, 0.5, -30)
Glow["AnchorPoint"] = Vector2.new(0.5, 0.5)
Glow["Image"] = "rbxassetid://5028857084"
Glow["ImageColor3"] = Color3.fromRGB(46, 205, 255)
Glow["ImageTransparency"] = 0.7
Glow["ZIndex"] = 1

G2L["TextLabel_6"] = Instance.new("TextLabel", G2L["Frame_2"])
G2L["TextLabel_6"]["BorderSizePixel"] = 0
G2L["TextLabel_6"]["TextSize"] = 40
G2L["TextLabel_6"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
G2L["TextLabel_6"]["FontFace"] = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
G2L["TextLabel_6"]["TextColor3"] = Color3.fromRGB(46, 205, 255)
G2L["TextLabel_6"]["BackgroundTransparency"] = 1
G2L["TextLabel_6"]["Size"] = UDim2.new(1, 0, 0, 40)
G2L["TextLabel_6"]["Text"] = "@aikoware"
G2L["TextLabel_6"]["Position"] = UDim2.new(0, 0, 0, 30)
G2L["TextLabel_6"]["TextXAlignment"] = Enum.TextXAlignment.Center
G2L["TextLabel_6"]["ZIndex"] = 3

local DiscordLink = Instance.new("TextButton", G2L["Frame_2"])
DiscordLink["BorderSizePixel"] = 0
DiscordLink["TextSize"] = 35
DiscordLink["BackgroundColor3"] = Color3.fromRGB(88, 101, 242)
DiscordLink["FontFace"] = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
DiscordLink["TextColor3"] = Color3.fromRGB(255, 255, 255)
DiscordLink["BackgroundTransparency"] = 0.2
DiscordLink["Size"] = UDim2.new(0, 200, 0, 32)
DiscordLink["Text"] = "discord.gg/JccfFGpDNV"
DiscordLink["Position"] = UDim2.new(0.5, -100, 0, 80)
DiscordLink["Name"] = "DiscordLink"
DiscordLink["ZIndex"] = 3
DiscordLink["AutoButtonColor"] = false

local DiscordCorner = Instance.new("UICorner", DiscordLink)
DiscordCorner.CornerRadius = UDim.new(0, 8)

local DiscordIcon = Instance.new("ImageLabel", DiscordLink)
DiscordIcon["BackgroundTransparency"] = 1
DiscordIcon["Size"] = UDim2.new(0, 20, 0, 20)
DiscordIcon["Position"] = UDim2.new(0, 10, 0.5, -10)
DiscordIcon["Image"] = "rbxassetid://15310731934"
DiscordIcon["ImageColor3"] = Color3.fromRGB(255, 255, 255)
DiscordIcon["ZIndex"] = 4

DiscordLink.MouseButton1Click:Connect(function()
    local link = "https://discord.gg/JccfFGpDNV"
    if setclipboard then
        setclipboard(link)
        DiscordLink.Text = "Copied!"
        task.wait(1)
        DiscordLink.Text = "discord.gg/JccfFGpDNV"
    end
end)

DiscordLink.MouseButton1Down:Connect(function()
    TweenService:Create(DiscordLink, TweenInfo.new(0.1), {
        BackgroundTransparency = 0
    }):Play()
end)

DiscordLink.MouseButton1Up:Connect(function()
    TweenService:Create(DiscordLink, TweenInfo.new(0.1), {
        BackgroundTransparency = 0.2
    }):Play()
end)

local LogoFrame = Instance.new("Frame", G2L["Frame_2"])
LogoFrame["BackgroundTransparency"] = 1
LogoFrame["Size"] = UDim2.new(0, 140, 0, 140)
LogoFrame["Position"] = UDim2.new(0.5, -70, 0, 130)
LogoFrame["Name"] = "LogoFrame"
LogoFrame["ZIndex"] = 3

local LogoImage = Instance.new("ImageLabel", LogoFrame)
LogoImage["BackgroundTransparency"] = 1
LogoImage["Size"] = UDim2.new(1, 0, 1, 0)
LogoImage["Image"] = "rbxassetid://105338847670181"  -- Replace with your logo
LogoImage["ScaleType"] = Enum.ScaleType.Fit
LogoImage["Name"] = "LogoImage"
LogoImage["ZIndex"] = 3

local LogoCorner = Instance.new("UICorner", LogoImage)
LogoCorner.CornerRadius = UDim.new(0, 0)

local PlaceholderLogo = Instance.new("Frame", LogoFrame)
PlaceholderLogo["BackgroundColor3"] = Color3.fromRGB(46, 205, 255)
PlaceholderLogo["BackgroundTransparency"] = 0.2
PlaceholderLogo["Size"] = UDim2.new(1, 0, 1, 0)
PlaceholderLogo["Name"] = "PlaceholderLogo"
PlaceholderLogo["Visible"] = true
PlaceholderLogo["ZIndex"] = 3

local PlaceholderCorner = Instance.new("UICorner", PlaceholderLogo)
PlaceholderCorner.CornerRadius = UDim.new(0, 20)

local PlaceholderText = Instance.new("TextLabel", PlaceholderLogo)
PlaceholderText["TextSize"] = 64
PlaceholderText["FontFace"] = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
PlaceholderText["TextColor3"] = Color3.fromRGB(255, 255, 255)
PlaceholderText["BackgroundTransparency"] = 1
PlaceholderText["Size"] = UDim2.new(1, 0, 1, 0)
PlaceholderText["Text"] = "AK"
PlaceholderText["TextXAlignment"] = Enum.TextXAlignment.Center
PlaceholderText["TextYAlignment"] = Enum.TextYAlignment.Center
PlaceholderText["ZIndex"] = 4

task.spawn(function()
    while true do
        TweenService:Create(PlaceholderLogo, TweenInfo.new(3, Enum.EasingStyle.Linear), {
            Rotation = 360
        }):Play()
        task.wait(3)
        PlaceholderLogo.Rotation = 0
    end
end)

G2L["TextLabel_8"] = Instance.new("TextLabel", G2L["Frame_2"])
G2L["TextLabel_8"]["BorderSizePixel"] = 0
G2L["TextLabel_8"]["TextSize"] = 15
G2L["TextLabel_8"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
G2L["TextLabel_8"]["FontFace"] = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
G2L["TextLabel_8"]["TextColor3"] = Color3.fromRGB(180, 180, 180)
G2L["TextLabel_8"]["BackgroundTransparency"] = 1
G2L["TextLabel_8"]["Size"] = UDim2.new(1, -40, 0, 60)
G2L["TextLabel_8"]["Text"] = "Do not do anything,\nauto farm days enabled!"
G2L["TextLabel_8"]["Position"] = UDim2.new(0, 20, 0, 285)
G2L["TextLabel_8"]["TextXAlignment"] = Enum.TextXAlignment.Center
G2L["TextLabel_8"]["TextWrapped"] = true
G2L["TextLabel_8"]["TextYAlignment"] = Enum.TextYAlignment.Top
G2L["TextLabel_8"]["ZIndex"] = 3

G2L["TextLabel2_7"] = Instance.new("TextLabel", G2L["Frame_2"])
G2L["TextLabel2_7"]["BorderSizePixel"] = 0
G2L["TextLabel2_7"]["TextSize"] = 13
G2L["TextLabel2_7"]["BackgroundColor3"] = Color3.fromRGB(46, 205, 255)
G2L["TextLabel2_7"]["FontFace"] = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
G2L["TextLabel2_7"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
G2L["TextLabel2_7"]["BackgroundTransparency"] = 0.3
G2L["TextLabel2_7"]["Size"] = UDim2.new(0, 120, 0, 30)
G2L["TextLabel2_7"]["Text"] = Day.Text
G2L["TextLabel2_7"]["Name"] = "TextLabel2"
G2L["TextLabel2_7"]["Position"] = UDim2.new(0.5, -60, 1, -120)
G2L["TextLabel2_7"]["TextXAlignment"] = Enum.TextXAlignment.Center
G2L["TextLabel2_7"]["ZIndex"] = 3

local DayCorner = Instance.new("UICorner", G2L["TextLabel2_7"])
DayCorner.CornerRadius = UDim.new(0, 8)

G2L["TextLabel3_4"] = Instance.new("TextLabel", G2L["Frame_2"])
G2L["TextLabel3_4"]["BorderSizePixel"] = 0
G2L["TextLabel3_4"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
G2L["TextLabel3_4"]["TextColor3"] = Color3.fromRGB(46, 205, 255)
G2L["TextLabel3_4"]["BackgroundTransparency"] = 1
G2L["TextLabel3_4"]["Size"] = UDim2.new(0, 80, 0, 30)
G2L["TextLabel3_4"]["Text"] = "0s" 
G2L["TextLabel3_4"]["Name"] = "TextLabel3"
G2L["TextLabel3_4"]["FontFace"] = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
G2L["TextLabel3_4"]["TextSize"] = 16
G2L["TextLabel3_4"]["Position"] = UDim2.new(0, 20, 1, -80)
G2L["TextLabel3_4"]["TextXAlignment"] = Enum.TextXAlignment.Left
G2L["TextLabel3_4"]["ZIndex"] = 3

G2L["TextLabel4_5"] = Instance.new("TextLabel", G2L["Frame_2"])
G2L["TextLabel4_5"]["BorderSizePixel"] = 0
G2L["TextLabel4_5"]["TextSize"] = 12
G2L["TextLabel4_5"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
G2L["TextLabel4_5"]["FontFace"] = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
G2L["TextLabel4_5"]["TextColor3"] = Color3.fromRGB(100, 100, 100)
G2L["TextLabel4_5"]["BackgroundTransparency"] = 1
G2L["TextLabel4_5"]["Size"] = UDim2.new(0, 60, 0, 30)
G2L["TextLabel4_5"]["Text"] = "v3.0"
G2L["TextLabel4_5"]["Name"] = "TextLabel4"
G2L["TextLabel4_5"]["Position"] = UDim2.new(1, -80, 1, -80)
G2L["TextLabel4_5"]["TextXAlignment"] = Enum.TextXAlignment.Right
G2L["TextLabel4_5"]["ZIndex"] = 3

G2L["UnloadButton"] = Instance.new("TextButton", G2L["Frame_2"])
G2L["UnloadButton"]["BorderSizePixel"] = 0
G2L["UnloadButton"]["TextSize"] = 16
G2L["UnloadButton"]["BackgroundColor3"] = Color3.fromRGB(255, 69, 58)
G2L["UnloadButton"]["FontFace"] = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
G2L["UnloadButton"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
G2L["UnloadButton"]["Size"] = UDim2.new(0, 200, 0, 45)
G2L["UnloadButton"]["Text"] = "Unload Script"
G2L["UnloadButton"]["Position"] = UDim2.new(0.5, -100, 1, -60)
G2L["UnloadButton"]["AutoButtonColor"] = false
G2L["UnloadButton"]["ZIndex"] = 3

local buttonCorner = Instance.new("UICorner", G2L["UnloadButton"])
buttonCorner.CornerRadius = UDim.new(0, 12)

G2L["UnloadButton"].MouseButton1Down:Connect(function()
    TweenService:Create(G2L["UnloadButton"], TweenInfo.new(0.1), {
        Size = UDim2.new(0, 190, 0, 43),
        BackgroundColor3 = Color3.fromRGB(200, 50, 45)
    }):Play()
end)

G2L["UnloadButton"].MouseButton1Up:Connect(function()
    TweenService:Create(G2L["UnloadButton"], TweenInfo.new(0.1), {
        Size = UDim2.new(0, 200, 0, 45),
        BackgroundColor3 = Color3.fromRGB(255, 69, 58)
    }):Play()
end)

task.spawn(function()
    while true do
        TweenService:Create(Glow, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            ImageTransparency = 0.5
        }):Play()
        task.wait(2)
        TweenService:Create(Glow, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            ImageTransparency = 0.8
        }):Play()
        task.wait(2)
    end
end)

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

local function updateText()
    G2L["TextLabel2_7"].Text = Day.Text
end
updateText()
Day:GetPropertyChangedSignal("Text"):Connect(updateText)
