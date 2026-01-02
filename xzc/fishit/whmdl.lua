local WebhookModule = {}

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Player = Players.LocalPlayer

_G.httpRequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

_G.WebhookFlags = _G.WebhookFlags or {
    FishCaught = {
        Enabled = false,
        URL = ""
    },
    Stats = {
        Enabled = false,
        URL = "",
        Delay = 5
    },
    Disconnect = {
        Enabled = false,
        URL = ""
    }
}

_G.WebhookCustomName = _G.WebhookCustomName or ""
_G.DiscordPingID = _G.DiscordPingID or ""
_G.DisconnectCustomName = _G.DisconnectCustomName or ""
_G.WebhookRarities = _G.WebhookRarities or {}
_G.WebhookFishNames = _G.WebhookFishNames or {}

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

local FishDatabase = {}

function WebhookModule.SendWebhook(url, data)
    if not _G.httpRequest then
        return false
    end
    
    if not url or url == "" then
        return false
    end
    
    _G._WebhookLock = _G._WebhookLock or {}
    if _G._WebhookLock[url] then
        return false
    end
    
    _G._WebhookLock[url] = true
    task.delay(1, function()
        _G._WebhookLock[url] = nil
    end)
    
    local success, err = pcall(function()
        _G.httpRequest({
            Url = url,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = HttpService:JSONEncode(data)
        })
    end)
    
    if not success then
        return false
    end
    
    return true
end

function WebhookModule.BuildFishDatabase()
    local itemsFolder = ReplicatedStorage:FindFirstChild("Items")
    if not itemsFolder then
        return 0
    end
    
    local count = 0
    for _, item in ipairs(itemsFolder:GetChildren()) do
        if item:IsA("ModuleScript") then
            local success, data = pcall(require, item)
            if success and type(data) == "table" and data.Data then
                local fishData = data.Data
                if fishData.Type == "Fish" or fishData.Type == "Fishes" then
                    if fishData.Id and fishData.Name then
                        FishDatabase[fishData.Id] = {
                            Name = fishData.Name,
                            Tier = fishData.Tier or 0,
                            Icon = fishData.Icon or "",
                            SellPrice = data.SellPrice or 0
                        }
                        count = count + 1
                    end
                end
            end
        end
    end
    
    return count
end

function WebhookModule.GetThumbnailURL(assetId)
    if not assetId or assetId == "" then return nil end
    
    local id = assetId:match("rbxassetid://(%d+)") or assetId:match("(%d+)")
    
    if not id then return nil end
    
    return string.format("https://www.roblox.com/Thumbs/Asset.ashx?width=420&height=420&assetId=%s", id)
end

function WebhookModule.GetTierName(tier)
    if type(tier) == "string" then
        return TierNames[tier] or tier
    elseif type(tier) == "number" then
        return TierNames[tier] or "Unknown"
    else
        return "Unknown"
    end
end

function WebhookModule.GetVariantName(fishId, metadata, data)
    local variant = "None"
    
    if data and data.InventoryItem and data.InventoryItem.Metadata then
        local variantId = data.InventoryItem.Metadata.VariantId
        
        if variantId and type(variantId) == "string" and variantId ~= "" then
            variant = variantId
        end
    elseif metadata and metadata.VariantId then
        local variantId = metadata.VariantId
        if variantId and type(variantId) == "string" and variantId ~= "" then
            variant = variantId
        end
    end
    
    return variant
end

function WebhookModule.SendFishWebhook(fishId, metadata, data)
    if not _G.WebhookFlags.FishCaught.Enabled then return end
    
    local webhookUrl = _G.WebhookFlags.FishCaught.URL
    if not webhookUrl or webhookUrl == "" then
        return
    end

    local fishData = FishDatabase[fishId]
    if not fishData then 
        return 
    end
    
    local tierName = WebhookModule.GetTierName(fishData.Tier)
    
    if _G.WebhookRarities and #_G.WebhookRarities > 0 then
        local found = false
        for _, rarity in ipairs(_G.WebhookRarities) do
            if rarity == tierName then
                found = true
                break
            end
        end
        if not found then
            return
        end
    end
    
    if _G.WebhookFishNames and #_G.WebhookFishNames > 0 then
        if not table.find(_G.WebhookFishNames, fishData.Name) then
            return
        end
    end
    
    local weight = "N/A"
    if metadata and metadata.Weight then
        weight = string.format("%.2f Kg", metadata.Weight)
    elseif data and data.InventoryItem and data.InventoryItem.Metadata and data.InventoryItem.Metadata.Weight then
        weight = string.format("%.2f Kg", data.InventoryItem.Metadata.Weight)
    end
    
    local variant = WebhookModule.GetVariantName(fishId, metadata, data)
    
    local playerName = _G.WebhookCustomName ~= "" and _G.WebhookCustomName or Player.Name
    
    local payload = {
        embeds = {{
            title = "🎣 FISH CAUGHT",
            description = string.format("**%s** caught a **%s** fish!", playerName, tierName),
            color = 5708687,
            fields = {
                {name = "**Fish:**", value = "`` ❯ " .. fishData.Name .. " ``", inline = false},
                {name = "**Tier:**", value = "`` ❯ " .. tierName .. " ``", inline = false},
                {name = "**Weight:**", value = "`` ❯ " .. weight .. " ``", inline = true},
                {name = "**Variant:**", value = "`` ❯ " .. variant .. " ``", inline = true}
            },
            thumbnail = {
                url = WebhookModule.GetThumbnailURL(fishData.Icon) or "https://cdn.discordapp.com/attachments/1387681189502124042/1449753201044750336/banners_pinterest_654429389618926022.jpg"
            },
            image = {
                url = "https://cdn.discordapp.com/attachments/1387681189502124042/1454161899238457571/New_Project.jpg?ex=6950154d&is=694ec3cd&hm=d3d22f3aa93d26b2f80b0b8a136d61269ece8c665a033947c71ae9fc1a7ddfa6&"
            },
            footer = {
                text = "Aikoware Webhook"
            },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }},
        username = "AIKO",
        avatar_url = "https://cdn.discordapp.com/attachments/1387681189502124042/1453911584874168340/IMG_1130.png"
    }
    
    WebhookModule.SendWebhook(webhookUrl, payload)
end

--[[function WebhookModule.SendFishWebhook(fishId, metadata, data)
    if not _G.WebhookFlags.FishCaught.Enabled then return end
    
    local webhookUrl = _G.WebhookFlags.FishCaught.URL
    if not webhookUrl or webhookUrl == "" then
        return
    end
    
    local fishData = FishDatabase[fishId]
    if not fishData then 
        return 
    end
    
    local tierName = WebhookModule.GetTierName(fishData.Tier)
    
    if _G.WebhookRarities and #_G.WebhookRarities > 0 then
        local found = false
        for _, rarity in ipairs(_G.WebhookRarities) do
            if rarity == tierName then
                found = true
                break
            end
        end
        if not found then
            return
        end
    end
    
    if _G.WebhookFishNames and #_G.WebhookFishNames > 0 then
        if not table.find(_G.WebhookFishNames, fishData.Name) then
            return
        end
    end
    
    local weight = "N/A"
    if metadata and metadata.Weight then
        weight = string.format("%.2f Kg", metadata.Weight)
    elseif data and data.InventoryItem and data.InventoryItem.Metadata and data.InventoryItem.Metadata.Weight then
        weight = string.format("%.2f Kg", data.InventoryItem.Metadata.Weight)
    end
    
    local variant = WebhookModule.GetVariantName(fishId, metadata, data)
    
    local playerName = _G.WebhookCustomName ~= "" and _G.WebhookCustomName or Player.Name
    
    local payload = {
        embeds = {{
            title = "🎣 FISH CAUGHT",
            description = string.format("**%s** caught a **%s** fish!", playerName, tierName),
            color = 5708687,
            fields = {
                {name = "**Fish:**", value = "`` ❯ " .. fishData.Name .. " ``", inline = false},
                {name = "**Tier:**", value = "`` ❯ " .. tierName .. " ``", inline = false},
                {name = "**Weight:**", value = "`` ❯ " .. weight .. " ``", inline = true},
                {name = "**Variant:**", value = "`` ❯ " .. variant .. " ``", inline = true}
            },
            thumbnail = {
                url = WebhookModule.GetThumbnailURL(fishData.Icon) or "https://cdn.discordapp.com/attachments/1387681189502124042/1449753201044750336/banners_pinterest_654429389618926022.jpg"
            },
            image = {
                url = "https://cdn.discordapp.com/attachments/1387681189502124042/1454161899238457571/New_Project.jpg?ex=6950154d&is=694ec3cd&hm=d3d22f3aa93d26b2f80b0b8a136d61269ece8c665a033947c71ae9fc1a7ddfa6&"
            },
            footer = {
                text = "@aikoware Webhook",
            },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }},
        username = "AIKO",
        avatar_url = "https://cdn.discordapp.com/attachments/1387681189502124042/1453911584874168340/IMG_1130.png"
    }
    
    WebhookModule.SendWebhook(webhookUrl, payload)
end]]

local disconnectHandled = false

function WebhookModule.SendDisconnectWebhook(reason)
    if disconnectHandled then return end
    disconnectHandled = true
    
    local webhookUrl = _G.WebhookFlags.Disconnect.URL
    if not webhookUrl or webhookUrl == "" then 
        return 
    end
    
    local playerName = _G.DisconnectCustomName ~= "" and _G.DisconnectCustomName or Player.Name
    local dateTime = os.date("%m/%d/%Y %I:%M %p")
    local pingText = _G.DiscordPingID or ""
    
    local payload = {
        content = pingText ~= "" and (pingText .. " Your account got disconnected!") or "Your account got disconnected!",
        embeds = {{
            title = "⚠️ Disconnected Alert!",
            description = string.format("**%s** got disconnected from the server", playerName),
            color = 5708687,
            fields = {
                {name = "**Username:**", value = "`` ❯ " .. playerName .. " ``", inline = false},
                {name = "**Time:**", value = "`` ❯ " .. dateTime .. " ``", inline = false},
                {name = "**Reason:**", value = "`` ❯ " .. (reason or "Unknown") .. " ``", inline = false}
            },
            image = {
                url = "https://cdn.discordapp.com/attachments/1387681189502124042/1454161899238457571/New_Project.jpg?ex=6950154d&is=694ec3cd&hm=d3d22f3aa93d26b2f80b0b8a136d61269ece8c665a033947c71ae9fc1a7ddfa6&"
            },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }},
        username = "AIKO",
        avatar_url = "https://cdn.discordapp.com/attachments/1387681189502124042/1453911584874168340/IMG_1130.png"
    }
    
    WebhookModule.SendWebhook(webhookUrl, payload)
    
    task.wait(3)
    game:GetService("TeleportService"):Teleport(game.PlaceId, Player)
end

function WebhookModule.SetupFishListener()
    if _G.FishWebhookConnected then return end
    _G.FishWebhookConnected = true
    
    local NetFolder = ReplicatedStorage:WaitForChild("Packages")
        :WaitForChild("_Index")
        :WaitForChild("sleitnick_net@0.2.0")
        :WaitForChild("net")
    
    local REObtainedNewFishNotification = NetFolder:WaitForChild("RE/ObtainedNewFishNotification")
    
    REObtainedNewFishNotification.OnClientEvent:Connect(function(fishId, _, data)
        task.spawn(function()
            pcall(function()
                local metadata = data and data.InventoryItem and data.InventoryItem.Metadata
                WebhookModule.SendFishWebhook(fishId, metadata, data)
            end)
        end)
    end)
end

function WebhookModule.SetupDisconnectDetection()
    if _G.DisconnectDetectionSetup then return end
    _G.DisconnectDetectionSetup = true
    
    pcall(function()
        game:GetService("GuiService").ErrorMessageChanged:Connect(function(msg)
            if msg and msg ~= "" and _G.WebhookFlags.Disconnect.Enabled then
                WebhookModule.SendDisconnectWebhook(msg)
            end
        end)
    end)
    
    pcall(function()
        local coreGui = game:GetService("CoreGui")
        local promptGui = coreGui:FindFirstChild("RobloxPromptGui")
        if promptGui then
            local promptOverlay = promptGui:FindFirstChild("promptOverlay")
            if promptOverlay then
                promptOverlay.ChildAdded:Connect(function(prompt)
                    if prompt.Name == "ErrorPrompt" and _G.WebhookFlags.Disconnect.Enabled then
                        task.wait(0.5)
                        local label = prompt:FindFirstChildWhichIsA("TextLabel", true)
                        local reason = label and label.Text or "Disconnected"
                        WebhookModule.SendDisconnectWebhook(reason)
                    end
                end)
            end
        end
    end)
end

function WebhookModule.SendTestWebhook()
    local webhookUrl = _G.WebhookFlags.FishCaught.URL
    if not webhookUrl or webhookUrl == "" then
        return false, "No webhook URL set"
    end
    
    local payload = {
        embeds = {{
            color = 5708687,
            title = "✅ Webhook Connection Test!",
            description = "If you see this message, it means your webhook is working!",
            image = {
                url = "https://cdn.discordapp.com/attachments/1387681189502124042/1454161899238457571/New_Project.jpg?ex=6950154d&is=694ec3cd&hm=d3d22f3aa93d26b2f80b0b8a136d61269ece8c665a033947c71ae9fc1a7ddfa6&"
            },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }},
        username = "AIKO",
        avatar_url = "https://cdn.discordapp.com/attachments/1387681189502124042/1453911584874168340/IMG_1130.png"
    }
    
    if WebhookModule.SendWebhook(webhookUrl, payload) then
        return true, "Test sent successfully!"
    else
        return false, "Failed to send test!"
    end
end

function WebhookModule.SendTestDisconnectWebhook()
    local webhookUrl = _G.WebhookFlags.Disconnect.URL
    if not webhookUrl or webhookUrl == "" then
        return false, "No webhook URL set"
    end
    
    local payload = {
        embeds = {{
            title = "✅ Webhook Disconnect Test!",
            color = 5708687,
            fields = {
                {name = "Status", value = "Webhook working!", inline = false},
                {name = "Action", value = "Rejoining server now...", inline = false}
            },
            image = {
                url = "https://cdn.discordapp.com/attachments/1387681189502124042/1454161899238457571/New_Project.jpg?ex=6950154d&is=694ec3cd&hm=d3d22f3aa93d26b2f80b0b8a136d61269ece8c665a033947c71ae9fc1a7ddfa6&"
            },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }},
        username = "AIKO",
        avatar_url = "https://cdn.discordapp.com/attachments/1387681189502124042/1453911584874168340/IMG_1130.png"
    }
    
    WebhookModule.SendWebhook(webhookUrl, payload)
    task.wait(2)
    game:GetService("TeleportService"):Teleport(game.PlaceId, Player)
    
    return true, "Test webhook sent, rejoining..."
end

function WebhookModule.CleanWebhookURL(url)
    if url and url:match("discord.com/api/webhooks") then
        return url:gsub("discordapp%.com", "discord.com")
                  :gsub("canary%.discord%.com", "discord.com")
                  :gsub("ptb%.discord%.com", "discord.com")
    end
    return url
end

function WebhookModule.GetRarityList()
    return {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Secret"}
end

function WebhookModule.Initialize()
    local fishCount = WebhookModule.BuildFishDatabase()
    WebhookModule.SetupFishListener()
    WebhookModule.SetupDisconnectDetection()
    return WebhookModule
end

function WebhookModule.GetFishDatabase()
    return FishDatabase
end

function WebhookModule.GetTierColors()
    return TierColors
end

function WebhookModule.GetTierNames()
    return TierNames
end

return WebhookModule
