local ScanModule = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local scanPlayer = Players.LocalPlayer
local scanHumanoidRootPart = nil
local scanCenterPosition = Vector3.new(13.287, 100, 0.362)
local scanMaxRadius = 1380
local scanAngleStep = math.rad(10)
local scanRadiusStep = 15
local scanSpeed = 100
local mapMinX = -1386.61
local mapMaxX = 1385.55
local mapMinZ = -1396.19
local mapMaxZ = 1376.45
local mapArea = (mapMaxX - mapMinX) * (mapMaxZ - mapMinZ)

local scanEnabled = false
local scanRunning = false
local scanAngle = 0
local scanRadius = 0

local scanScreenGui = nil
local explorationLabel = nil
local progressBarFrame = nil
local progressBar = nil
local scanBodyVelocity = nil

local function initializeUI()
    if scanScreenGui then return end
    
    local scanPlayerGui = scanPlayer:WaitForChild("PlayerGui")
    scanScreenGui = Instance.new("ScreenGui")
    scanScreenGui.Name = "ScanMapUI"
    scanScreenGui.Parent = scanPlayerGui

    explorationLabel = Instance.new("TextLabel")
    explorationLabel.Parent = scanScreenGui
    explorationLabel.Size = UDim2.new(0, 250, 0, 40)
    explorationLabel.Position = UDim2.new(0.5, -125, 0.08, 0)
    explorationLabel.Text = "Exploration: 0%"
    explorationLabel.BackgroundTransparency = 0.3
    explorationLabel.TextScaled = true
    explorationLabel.TextColor3 = Color3.new(1, 1, 1)
    explorationLabel.BackgroundColor3 = Color3.new(0, 0, 0)
    explorationLabel.BorderSizePixel = 0
    explorationLabel.Visible = false

    progressBarFrame = Instance.new("Frame")
    progressBarFrame.Parent = scanScreenGui
    progressBarFrame.Size = UDim2.new(0, 250, 0, 25)
    progressBarFrame.Position = UDim2.new(0.5, -125, 0.15, 0)
    progressBarFrame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    progressBarFrame.BackgroundTransparency = 0.3
    progressBarFrame.BorderSizePixel = 0
    progressBarFrame.Visible = false

    progressBar = Instance.new("Frame")
    progressBar.Parent = progressBarFrame
    progressBar.Size = UDim2.new(0, 0, 1, 0)
    progressBar.BackgroundColor3 = Color3.new(0, 1, 0)
    progressBar.BorderSizePixel = 0

    local labelCorner = Instance.new("UICorner")
    labelCorner.CornerRadius = UDim.new(0, 8)
    labelCorner.Parent = explorationLabel

    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 8)
    frameCorner.Parent = progressBarFrame

    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(0, 8)
    barCorner.Parent = progressBar

    scanBodyVelocity = Instance.new("BodyVelocity")
    scanBodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    scanBodyVelocity.P = 5000
    scanBodyVelocity.Velocity = Vector3.zero
end

local function calculateOverlapArea(centerX, centerZ, radius, minX, minZ, maxX, maxZ)
    local sampleCount = 10000
    local insideCount = 0
    for _ = 1, sampleCount do
        local angle = math.random() * 2 * math.pi
        local distance = math.sqrt(math.random()) * radius
        local pointX = centerX + distance * math.cos(angle)
        local pointZ = centerZ + distance * math.sin(angle)
        if minX <= pointX and pointX <= maxX and minZ <= pointZ and pointZ <= maxZ then
            insideCount = insideCount + 1
        end
    end
    return insideCount / sampleCount * math.pi * radius * radius
end

local function attachBodyVelocity()
    if not scanHumanoidRootPart then return end
    if scanBodyVelocity.Parent ~= scanHumanoidRootPart then
        scanBodyVelocity.Parent = scanHumanoidRootPart
    end
end

local function detachBodyVelocity()
    if scanBodyVelocity and scanBodyVelocity.Parent then
        scanBodyVelocity.Parent = nil
    end
end

local function moveToPosition(targetPosition)
    if not scanHumanoidRootPart then return end
    while scanEnabled and (scanHumanoidRootPart.Position - targetPosition).Magnitude > 5 do
        local direction = targetPosition - scanHumanoidRootPart.Position
        if direction.Magnitude == 0 then
            break
        end
        scanBodyVelocity.Velocity = direction.Unit * scanSpeed
        task.wait()
    end
end

local function runScanLoop()
    if scanRunning then return end
    
    local character = scanPlayer.Character or scanPlayer.CharacterAdded:Wait()
    scanHumanoidRootPart = character:WaitForChild("HumanoidRootPart")
    
    scanRunning = true
    explorationLabel.Visible = true
    progressBarFrame.Visible = true
    attachBodyVelocity()
    
    while scanEnabled and scanRadius < scanMaxRadius do
        local posX = scanCenterPosition.X + math.cos(scanAngle) * scanRadius
        local posZ = scanCenterPosition.Z + math.sin(scanAngle) * scanRadius
        moveToPosition(Vector3.new(posX, scanCenterPosition.Y, posZ))
        scanAngle = scanAngle + scanAngleStep
        scanRadius = scanRadius + scanRadiusStep * (scanAngleStep / (2 * math.pi))
        
        local overlapArea = calculateOverlapArea(
            scanCenterPosition.X, scanCenterPosition.Z, scanRadius,
            mapMinX, mapMinZ, mapMaxX, mapMaxZ
        )
        local percentage = math.floor(overlapArea / mapArea * 100)
        local clampedPercentage = math.min(percentage, 100)
        
        explorationLabel.Text = "Exploration: " .. clampedPercentage .. "%"
        progressBar.Size = UDim2.new(clampedPercentage / 100, 0, 1, 0)
        task.wait()
    end
    
    scanBodyVelocity.Velocity = Vector3.zero
    detachBodyVelocity()
    explorationLabel.Visible = false
    progressBarFrame.Visible = false
    scanRunning = false
end

local function stopScan()
    scanEnabled = false
    if scanBodyVelocity then
        scanBodyVelocity.Velocity = Vector3.zero
    end
    detachBodyVelocity()
    if explorationLabel then
        explorationLabel.Text = "Exploration: 0%"
        explorationLabel.Visible = false
    end
    if progressBar then
        progressBar.Size = UDim2.new(0, 0, 1, 0)
    end
    if progressBarFrame then
        progressBarFrame.Visible = false
    end
    scanRadius = 0
    scanAngle = 0
end

function ScanModule.ToggleScan(enabled)
    initializeUI()
    if enabled then
        scanEnabled = true
        task.spawn(runScanLoop)
    else
        stopScan()
    end
end

function ScanModule.SetScanSpeed(speed)
    scanSpeed = speed
end

function ScanModule.SetScanRadius(radius)
    scanRadiusStep = radius
end

function ScanModule.SetScanAngle(angle)
    scanAngleStep = math.rad(angle)
end

function ScanModule.Cleanup()
    stopScan()
    if scanScreenGui then
        scanScreenGui:Destroy()
        scanScreenGui = nil
    end
    if scanBodyVelocity then
        scanBodyVelocity:Destroy()
        scanBodyVelocity = nil
    end
end

return ScanModule
