local Module = {}

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

local services = {}

local function getInventoryFromUI()
    local inv = {}
    local pg = services.LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then return inv end
    local menu = pg:FindFirstChild("Menu")
    if not menu then return inv end
    local frame1 = menu:FindFirstChild("Frame")
    if not frame1 then return inv end
    local frame2 = frame1:FindFirstChild("Frame")
    if not frame2 then return inv end
    local menus = frame2:FindFirstChild("Menus")
    if not menus then return inv end
    local stash = menus:FindFirstChild("Stash")
    if not stash then return inv end
    local container = stash:FindFirstChild("Background") or stash
    for _, itemFrame in ipairs(container:GetChildren()) do
        if itemFrame:IsA("GuiObject") then
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
    end
    return inv
end

local function buildForgeOreOptions(rs)
    local names = {}
    local assets = rs:FindFirstChild("Assets")
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

local function startAutoMelt()
    task.spawn(function()
        while autoForge.autoMelt and autoForge.enabled do
            if services.MeltMinigame and services.MeltMinigame.Enabled then
                local frame = services.MeltMinigame:FindFirstChild("Frame")
                local bar = frame and frame:FindFirstChild("Bar")
                local indicator = bar and bar:FindFirstChild("Indicator")
                local button = bar and bar:FindFirstChild("TextButton")
                if indicator and button and indicator.Position then
                    local pos = indicator.Position.X.Scale
                    if pos >= 0.45 and pos <= 0.55 then
                        pcall(function()
                            for i = 1, 15 do
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
            if services.PourMinigame and services.PourMinigame.Enabled then
                local frame = services.PourMinigame:FindFirstChild("Frame")
                local container = frame and frame:FindFirstChild("Container")
                local indicator = container and container:FindFirstChild("Indicator")
                if indicator and indicator.Position then
                    local pos = indicator.Position.Y.Scale
                    pcall(function()
                        if pos < 0.05 then
                            services.StartBlock:InvokeServer()
                        elseif pos > 0.9 then
                            services.StopBlock:InvokeServer()
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
            if services.HammerMinigame and services.HammerMinigame.Enabled then
                local frame = services.HammerMinigame:FindFirstChild("Frame")
                local bar = frame and frame:FindFirstChild("Bar")
                local indicator = bar and bar:FindFirstChild("Indicator")
                local button = bar and bar:FindFirstChild("TextButton")
                if indicator and button and indicator.Position then
                    local pos = indicator.Position.X.Scale
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
            local char = services.LocalPlayer.Character
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
                                        services.Dialogue:InvokeServer("Mold", {ItemType = autoForge.itemType})
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
                local oreBasket = {}
                local totalOres = 0
                for _, oreName in ipairs(autoForge.selectedOres) do
                    if inv[oreName] then
                        local useAmount = math.min(inv[oreName], autoForge.totalOresPerForge - totalOres)
                        if useAmount > 0 then
                            oreBasket[oreName] = useAmount
                            totalOres = totalOres + useAmount
                        end
                        if totalOres >= autoForge.totalOresPerForge then
                            break
                        end
                    end
                end
                if totalOres >= autoForge.totalOresPerForge then
                    pcall(function()
                        services.UseItems:InvokeServer(oreBasket)
                    end)
                    task.wait(2)
                end
            end
            task.wait(2)
        end
    end)
end

function Module.Initialize(svc)
    services = svc
end

function Module.GetOreOptions(rs)
    return buildForgeOreOptions(rs)
end

function Module.SetItemType(itemType)
    autoForge.itemType = itemType
end

function Module.SetSelectedOres(ores)
    autoForge.selectedOres = ores
end

function Module.SetOresPerForge(amount)
    autoForge.totalOresPerForge = amount
end

function Module.EnableAutoMelt(enabled)
    autoForge.autoMelt = enabled
    if enabled then startAutoMelt() end
end

function Module.EnableAutoPour(enabled)
    autoForge.autoPour = enabled
    if enabled then startAutoPour() end
end

function Module.EnableAutoHammer(enabled)
    autoForge.autoHammer = enabled
    if enabled then startAutoHammer() end
end

function Module.EnableAutoMold(enabled)
    autoForge.autoMold = enabled
    if enabled then startAutoMold() end
end

function Module.EnableAutoForge(enabled)
    autoForge.enabled = enabled
    if enabled then startAutoForge() end
end

return Module
