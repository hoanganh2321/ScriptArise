local HttpService = game:GetService("HttpService")
local WebhookHandler = require(script.Parent.WebhookHandler)

local DiscordWebhook = {}

-- Cấu hình bot
local BOT_CONFIG = {
    NAME = "Reward Bot",
    AVATAR = "https://i.imgur.com/1Lf5QJy.png",
    COLORS = {
        SUCCESS = 65280,    -- Xanh lá
        WARNING = 16753920, -- Cam
        ERROR = 16711680,   -- Đỏ
        INFO = 3447003      -- Xanh dương
    }
}

-- Tạo embed thông báo phần thưởng
function DiscordWebhook.createRewardEmbed(player, rewardData)
    local inventory = player:FindFirstChild("Inventory")
    local inventoryItems = {}
    
    if inventory then
        for _, item in ipairs(inventory:GetChildren()) do
            if item:IsA("IntValue") and item.Value > 0 then
                table.insert(inventoryItems, string.format("%s: %d", item.Name, item.Value))
            end
        end
    end

    return {
        title = rewardData.title or "🎁 PHẦN THƯỞNG MỚI",
        description = rewardData.description or string.format("Người chơi **%s** vừa nhận quà", player.Name),
        color = rewardData.color or BOT_CONFIG.COLORS.SUCCESS,
        fields = {
            {
                name = "Phần thưởng",
                value = rewardData.rewardDetails or "Không có thông tin",
                inline = true
            },
            {
                name = "Tổng cộng",
                value = rewardData.total or "0",
                inline = true
            },
            {
                name = "📦 Inventory",
                value = #inventoryItems > 0 and table.concat(inventoryItems, "\n") or "Trống",
                inline = false
            },
            {
                name = "⏰ Thời gian",
                value = os.date("%d/%m/%Y %H:%M:%S"),
                inline = true
            }
        },
        footer = {
            text = rewardData.footer or "Roblox Reward System"
        }
    }
end

-- Gửi embed đến webhook cụ thể
function DiscordWebhook.sendEmbed(webhookUrl, embedData)
    if not WebhookHandler.validateWebhook(webhookUrl) then
        warn("[Webhook] Invalid URL provided")
        return false
    end

    local payload = {
        embeds = {embedData},
        username = BOT_CONFIG.NAME,
        avatar_url = BOT_CONFIG.AVATAR
    }

    local success, response = pcall(function()
        HttpService:PostAsync(
            webhookUrl,
            HttpService:JSONEncode(payload),
            Enum.HttpContentType.ApplicationJson
        )
        return true
    end)

    if not success then
        warn("[Webhook Error]", response)
        return false, response
    end
    return true
end

-- Gửi thông báo phần thưởng cho người chơi
function DiscordWebhook.sendPlayerReward(player, rewardInfo)
    local webhookUrl = WebhookHandler.getPlayerWebhook(player)
    if not webhookUrl then return false end
    
    local embed = DiscordWebhook.createRewardEmbed(player, {
        title = rewardInfo.title or "🎁 NHẬN PHẦN THƯỞNG",
        description = rewardInfo.message or "Bạn vừa nhận được phần thưởng mới!",
        rewardDetails = string.format("%s x%d", rewardInfo.itemType, rewardInfo.amount),
        total = tostring(rewardInfo.newTotal),
        color = rewardInfo.color or BOT_CONFIG.COLORS.SUCCESS
    })
    
    return DiscordWebhook.sendEmbed(webhookUrl, embed)
end

return DiscordWebhook