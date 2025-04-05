local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Khởi tạo DataStore
local WebhookDataStore = DataStoreService:GetDataStore("PlayerWebhooks")

-- Tạo các RemoteEvents/Functions
local SetWebhookEvent = Instance.new("RemoteEvent")
SetWebhookEvent.Name = "SetWebhook"
SetWebhookEvent.Parent = ReplicatedStorage

local TestWebhookEvent = Instance.new("RemoteFunction")
TestWebhookEvent.Name = "TestWebhook"
TestWebhookEvent.Parent = ReplicatedStorage

local DeleteWebhookEvent = Instance.new("RemoteEvent")
DeleteWebhookEvent.Name = "DeleteWebhook"
DeleteWebhookEvent.Parent = ReplicatedStorage

local GetSavedWebhookEvent = Instance.new("RemoteFunction")
GetSavedWebhookEvent.Name = "GetSavedWebhook"
GetSavedWebhookEvent.Parent = ReplicatedStorage

-- Biến lưu trữ tạm
local playerWebhooks = {}
local lastSaveTimes = {}

-- Hàm kiểm tra webhook hợp lệ
local function validateWebhook(url)
    if type(url) ~= "string" then return false end
    if #url > 250 then return false end
    return string.match(url, "^https://discord%.com/api/webhooks/%w+/%w+$") ~= nil
end

-- Hàm kiểm tra rate limit
local function canSaveToDataStore(player)
    local now = os.time()
    local lastSave = lastSaveTimes[player.UserId] or 0
    local cooldown = 60 -- 60 giây cooldown
    
    if now - lastSave < cooldown then
        return false, cooldown - (now - lastSave)
    end
    
    lastSaveTimes[player.UserId] = now
    return true, 0
end

-- Hàm lưu webhook với retry
local function saveWebhookToDataStore(player, webhookUrl)
    local retries = 3
    local success = false
    
    for i = 1, retries do
        success = pcall(function()
            WebhookDataStore:SetAsync(player.UserId, webhookUrl)
            return true
        end)
        
        if success then break end
        warn(`[DataStore] Lỗi lần {i} khi lưu webhook cho {player.Name}`)
        task.wait(1)
    end
    
    return success
end

-- Hàm tải webhook với retry
local function loadWebhookFromDataStore(player)
    local retries = 3
    local webhookUrl = nil
    
    for i = 1, retries do
        local success, result = pcall(function()
            return WebhookDataStore:GetAsync(player.UserId)
        end)
        
        if success then
            webhookUrl = result
            break
        end
        warn(`[DataStore] Lỗi lần {i} khi tải webhook của {player.Name}`)
        task.wait(1)
    end
    
    return webhookUrl
end

-- Hàm xóa webhook
local function deleteWebhookFromDataStore(player)
    local retries = 3
    local success = false
    
    for i = 1, retries do
        success = pcall(function()
            WebhookDataStore:SetAsync(player.UserId, nil)
            return true
        end)
        
        if success then break end
        warn(`[DataStore] Lỗi lần {i} khi xóa webhook của {player.Name}`)
        task.wait(1)
    end
    
    return success
end

-- Hàm kiểm tra kết nối webhook
local function testWebhookConnection(url)
    local testPayload = {
        embeds = {{
            title = "🔍 KIỂM TRA KẾT NỐI",
            description = "Đây là tin nhắn kiểm tra từ Roblox",
            color = 16753920, -- Màu cam
            fields = {
                {
                    name = "Trạng thái",
                    value = "Kết nối thành công!",
                    inline = true
                },
                {
                    name = "Thời gian",
                    value = os.date("%d/%m/%Y %H:%M:%S"),
                    inline = true
                }
            },
            footer = {
                text = "Roblox Discord Webhook Tester"
            }
        }}
    }

    local success, response = pcall(function()
        HttpService:PostAsync(
            url,
            HttpService:JSONEncode(testPayload),
            Enum.HttpContentType.ApplicationJson
        )
        return true, "Webhook hoạt động bình thường"
    end)

    if not success then
        if string.find(response, "403") then
            return false, "Webhook bị từ chối (403 Forbidden)"
        elseif string.find(response, "404") then
            return false, "Webhook không tồn tại (404 Not Found)"
        else
            return false, "Lỗi không xác định: "..tostring(response)
        end
    end
    return success, response
end

-- Xử lý yêu cầu kiểm tra webhook
TestWebhookEvent.OnServerInvoke = function(player, webhookUrl)
    if not validateWebhook(webhookUrl) then
        return false, "URL webhook không hợp lệ"
    end
    
    return testWebhookConnection(webhookUrl)
end

-- Xử lý lưu webhook
SetWebhookEvent.OnServerEvent:Connect(function(player, webhookUrl)
    if not validateWebhook(webhookUrl) then return end
    
    -- Kiểm tra thay đổi
    local currentWebhook = playerWebhooks[player] or loadWebhookFromDataStore(player)
    if currentWebhook == webhookUrl then return end
    
    -- Kiểm tra rate limit
    local canSave = canSaveToDataStore(player)
    if not canSave then
        warn(`[DataStore] Rate limit reached for {player.Name}`)
        return
    end
    
    -- Lưu webhook
    playerWebhooks[player] = webhookUrl
    saveWebhookToDataStore(player, webhookUrl)
    
    -- Gửi thông báo test
    testWebhookConnection(webhookUrl)
end)

-- Xử lý xóa webhook
DeleteWebhookEvent.OnServerEvent:Connect(function(player)
    local oldWebhook = playerWebhooks[player] or loadWebhookFromDataStore(player)
    
    -- Xóa webhook
    playerWebhooks[player] = nil
    deleteWebhookFromDataStore(player)
    
    -- Gửi thông báo đến webhook cũ (nếu có)
    if oldWebhook and validateWebhook(oldWebhook) then
        local embed = {
            title = "🗑️ WEBHOOK ĐÃ BỊ XÓA",
            description = string.format("Người chơi **%s** đã xóa webhook đã lưu", player.Name),
            color = 16711680, -- Màu đỏ
            fields = {
                {
                    name = "Thời gian",
                    value = os.date("%d/%m/%Y %H:%M:%S"),
                    inline = true
                },
                {
                    name = "Game",
                    value = game.Name,
                    inline = true
                }
            },
            footer = {
                text = "Hệ thống thông báo tự động"
            }
        }
        
        task.spawn(function()
            pcall(HttpService.PostAsync, HttpService,
                oldWebhook,
                HttpService:JSONEncode({embeds = {embed}}),
                Enum.HttpContentType.ApplicationJson
            )
        end)
    end
end)

-- Xử lý yêu cầu lấy webhook đã lưu
GetSavedWebhookEvent.OnServerInvoke = function(player)
    if playerWebhooks[player] then
        return playerWebhooks[player]
    end
    
    local webhookUrl = loadWebhookFromDataStore(player)
    if webhookUrl then
        playerWebhooks[player] = webhookUrl
        return webhookUrl
    end
    
    return ""
end

-- Tự động tải webhook khi người chơi join
Players.PlayerAdded:Connect(function(player)
    local webhookUrl = loadWebhookFromDataStore(player)
    if webhookUrl and validateWebhook(webhookUrl) then
        playerWebhooks[player] = webhookUrl
    end
end)

-- Dọn dẹp khi người chơi rời
Players.PlayerRemoving:Connect(function(player)
    playerWebhooks[player] = nil
end)