local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

-- RemoteEvents
local SetWebhookEvent = ReplicatedStorage:WaitForChild("SetWebhook")
local TestWebhookEvent = ReplicatedStorage:WaitForChild("TestWebhook")
local DeleteWebhookEvent = ReplicatedStorage:WaitForChild("DeleteWebhook")
local GetSavedWebhookEvent = ReplicatedStorage:WaitForChild("GetSavedWebhook")

-- Tạo UI chính
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WebhookConfigUI"
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 400, 0, 350) -- Tăng chiều cao để chứa thêm nút
frame.Position = UDim2.new(0.5, -200, 0.5, -175)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BackgroundColor3 = Color3.fromRGB(36, 36, 36)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = frame

-- Header
local title = Instance.new("TextLabel")
title.Text = "🔗 CẤU HÌNH DISCORD WEBHOOK"
title.Size = UDim2.new(1, 0, 0, 50)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.Parent = frame

local closeButton = Instance.new("TextButton")
closeButton.Text = "✕"
closeButton.Size = UDim2.new(0, 40, 0, 40)
closeButton.Position = UDim2.new(1, -40, 0, 0)
closeButton.BackgroundTransparency = 1
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 20
closeButton.Parent = frame

-- Nội dung chính
local inputContainer = Instance.new("Frame")
inputContainer.Size = UDim2.new(0.9, 0, 0, 120)
inputContainer.Position = UDim2.new(0.05, 0, 0.2, 0)
inputContainer.BackgroundTransparency = 1
inputContainer.Parent = frame

local inputLabel = Instance.new("TextLabel")
inputLabel.Text = "Dán Discord Webhook URL của bạn:"
inputLabel.Size = UDim2.new(1, 0, 0, 20)
inputLabel.Position = UDim2.new(0, 0, 0, 0)
inputLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
inputLabel.Font = Enum.Font.Gotham
inputLabel.TextSize = 14
inputLabel.TextXAlignment = Enum.TextXAlignment.Left
inputLabel.BackgroundTransparency = 1
inputLabel.Parent = inputContainer

local inputBox = Instance.new("TextBox")
inputBox.PlaceholderText = "https://discord.com/api/webhooks/..."
inputBox.Size = UDim2.new(1, 0, 0, 40)
inputBox.Position = UDim2.new(0, 0, 0, 25)
inputBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
inputBox.ClearTextOnFocus = false
inputBox.Font = Enum.Font.Gotham
inputBox.TextSize = 14
inputBox.Parent = inputContainer

-- Các nút chức năng
local buttonContainer = Instance.new("Frame")
buttonContainer.Size = UDim2.new(1, 0, 0, 150)
buttonContainer.Position = UDim2.new(0, 0, 0.5, 0)
buttonContainer.BackgroundTransparency = 1
buttonContainer.Parent = frame

local testButton = Instance.new("TextButton")
testButton.Text = "KIỂM TRA KẾT NỐI"
testButton.Size = UDim2.new(0.9, 0, 0, 40)
testButton.Position = UDim2.new(0.05, 0, 0, 0)
testButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
testButton.TextColor3 = Color3.fromRGB(255, 255, 255)
testButton.Font = Enum.Font.GothamBold
testButton.TextSize = 16
testButton.Parent = buttonContainer

local saveButton = Instance.new("TextButton")
saveButton.Text = "LƯU CẤU HÌNH"
saveButton.Size = UDim2.new(0.9, 0, 0, 40)
saveButton.Position = UDim2.new(0.05, 0, 0, 50)
saveButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
saveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
saveButton.Font = Enum.Font.GothamBold
saveButton.TextSize = 16
saveButton.Parent = buttonContainer

local deleteButton = Instance.new("TextButton")
deleteButton.Text = "XÓA WEBHOOK ĐÃ LƯU"
deleteButton.Size = UDim2.new(0.9, 0, 0, 40)
deleteButton.Position = UDim2.new(0.05, 0, 0, 100)
deleteButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
deleteButton.TextColor3 = Color3.fromRGB(255, 255, 255)
deleteButton.Font = Enum.Font.GothamBold
deleteButton.TextSize = 16
deleteButton.Parent = buttonContainer

-- Thông báo trạng thái
local statusLabel = Instance.new("TextLabel")
statusLabel.Text = ""
statusLabel.Size = UDim2.new(0.9, 0, 0, 30)
statusLabel.Position = UDim2.new(0.05, 0, 0.9, 0)
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 14
statusLabel.TextWrapped = true
statusLabel.BackgroundTransparency = 1
statusLabel.Parent = frame

-- Hiệu ứng hover cho nút
local function setupButtonHover(button, hoverColor, originalColor)
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = hoverColor
    end)
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = originalColor
    end)
end

setupButtonHover(testButton, Color3.fromRGB(90, 90, 90), Color3.fromRGB(70, 70, 70))
setupButtonHover(saveButton, Color3.fromRGB(0, 140, 255), Color3.fromRGB(0, 120, 215))
setupButtonHover(deleteButton, Color3.fromRGB(200, 0, 0), Color3.fromRGB(170, 0, 0))

-- Xử lý sự kiện nút đóng
closeButton.MouseButton1Click:Connect(function()
    screenGui.Enabled = false
end)

-- Hàm hiển thị hộp thoại xác nhận
local function showConfirmation(message, callback)
    local dialog = Instance.new("Frame")
    dialog.Size = UDim2.new(1, 0, 1, 0)
    dialog.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    dialog.BackgroundTransparency = 0.5
    dialog.Parent = screenGui

    local dialogFrame = Instance.new("Frame")
    dialogFrame.Size = UDim2.new(0, 300, 0, 150)
    dialogFrame.Position = UDim2.new(0.5, -150, 0.5, -75)
    dialogFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    dialogFrame.BackgroundColor3 = Color3.fromRGB(36, 36, 36)
    dialogFrame.Parent = dialog

    local messageLabel = Instance.new("TextLabel")
    messageLabel.Text = message
    messageLabel.Size = UDim2.new(0.9, 0, 0, 60)
    messageLabel.Position = UDim2.new(0.05, 0, 0.1, 0)
    messageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    messageLabel.TextWrapped = true
    messageLabel.Parent = dialogFrame

    local yesButton = Instance.new("TextButton")
    yesButton.Text = "XÁC NHẬN"
    yesButton.Size = UDim2.new(0.4, 0, 0, 40)
    yesButton.Position = UDim2.new(0.05, 0, 0.7, 0)
    yesButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
    yesButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    yesButton.Parent = dialogFrame

    local noButton = Instance.new("TextButton")
    noButton.Text = "HỦY BỎ"
    noButton.Size = UDim2.new(0.4, 0, 0, 40)
    noButton.Position = UDim2.new(0.55, 0, 0.7, 0)
    noButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    noButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    noButton.Parent = dialogFrame

    yesButton.MouseButton1Click:Connect(function()
        callback(true)
        dialog:Destroy()
    end)

    noButton.MouseButton1Click:Connect(function()
        callback(false)
        dialog:Destroy()
    end)
end

-- Xử lý kiểm tra kết nối
testButton.MouseButton1Click:Connect(function()
    local webhookUrl = inputBox.Text
    
    if not string.find(webhookUrl, "^https://discord%.com/api/webhooks/") then
        statusLabel.Text = "❌ URL không hợp lệ! Vui lòng kiểm tra lại"
        statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        return
    end
    
    statusLabel.Text = "🔄 Đang kiểm tra kết nối..."
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    TestWebhookEvent:InvokeServer(webhookUrl):andThen(function(success, message)
        if success then
            statusLabel.Text = "✅ Kết nối thành công! "..message
            statusLabel.TextColor3 = Color3.fromRGB(80, 255, 80)
        else
            statusLabel.Text = "❌ Lỗi kết nối: "..message
            statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        end
    end)
end)

-- Xử lý lưu cấu hình
saveButton.MouseButton1Click:Connect(function()
    local webhookUrl = inputBox.Text
    
    if not string.find(webhookUrl, "^https://discord%.com/api/webhooks/") then
        statusLabel.Text = "❌ URL không hợp lệ! Vui lòng kiểm tra trước khi lưu"
        statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        return
    end
    
    SetWebhookEvent:FireServer(webhookUrl)
    statusLabel.Text = "✅ Đã lưu cấu hình webhook!"
    statusLabel.TextColor3 = Color3.fromRGB(80, 255, 80)
    
    task.delay(2, function()
        screenGui.Enabled = false
    end)
end)

-- Xử lý xóa webhook
deleteButton.MouseButton1Click:Connect(function()
    showConfirmation("Bạn có chắc muốn xóa webhook đã lưu?\nSau khi xóa sẽ không nhận được thông báo tự động.", function(confirmed)
        if confirmed then
            DeleteWebhookEvent:FireServer()
            inputBox.Text = ""
            statusLabel.Text = "✅ Đã xóa webhook đã lưu!"
            statusLabel.TextColor3 = Color3.fromRGB(80, 255, 80)
            task.delay(2, function()
                screenGui.Enabled = false
            end)
        end
    end)
end)

-- Tự động tải webhook đã lưu khi khởi động
local function initUI()
    GetSavedWebhookEvent:InvokeServer():andThen(function(savedWebhook)
        if savedWebhook and string.find(savedWebhook, "^https://discord%.com/api/webhooks/") then
            inputBox.Text = savedWebhook
            statusLabel.Text = "🔄 Đã tải webhook đã lưu từ trước"
            statusLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
        end
    end)
end

initUI()

-- Cho phép mở UI bằng phím F7
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.F7 then
        screenGui.Enabled = not screenGui.Enabled
    end
end)

-- Tắt UI mặc định (có thể bật khi cần)
screenGui.Enabled = false