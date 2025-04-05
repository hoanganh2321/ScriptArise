local Players = game:GetService("Players")
local DiscordWebhook = require(script.Parent.DiscordWebhook)
local WebhookHandler = require(script.Parent.WebhookHandler)

local RewardService = {}

-- Trao phần thưởng và gửi thông báo
function RewardService.giveReward(player, rewardType, amount)
    -- 1. Logic trao quà trong game
    local leaderstats = player:FindFirstChild("leaderstats")
    if not leaderstats then return false end
    
    local stat = leaderstats:FindFirstChild(rewardType)
    if not stat then return false end
    
    stat.Value += amount
    
    -- 2. Chuẩn bị dữ liệu thông báo
    local rewardData = {
        itemType = rewardType,
        amount = amount,
        newTotal = stat.Value,
        title = "🎉 CHÚC MỪNG!",
        message = string.format("Bạn vừa nhận được %d %s", amount, rewardType),
        color = 65407 -- Màu xanh ngọc
    }
    
    -- 3. Gửi thông báo Discord
    local success = DiscordWebhook.sendPlayerReward(player, rewardData)
    
    if not success then
        warn(`Không thể gửi thông báo cho {player.Name}`)
    end
    
    return true
end

-- Khởi tạo hệ thống
function RewardService.init()
    -- Đảm bảo player có đủ dữ liệu
    Players.PlayerAdded:Connect(function(player)
        player:WaitForChild("Inventory")
        player:WaitForChild("leaderstats")
    end)
    
    -- Kết nối sự kiện nhận quà (ví dụ)
    -- game:GetService("ReplicatedStorage").RewardEvent.OnServerEvent:Connect(function(player, ...)
    --     RewardService.giveReward(player, ...)
    -- end)
end

return RewardService