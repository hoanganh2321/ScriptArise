# Roblox Discord Webhook System

Hệ thống tích hợp webhook Discord cho Roblox game với đầy đủ tính năng:

## Tính năng chính
- UI nhập webhook thân thiện
- Lưu trữ webhook vào DataStore
- Kiểm tra kết nối trước khi lưu
- Xóa webhook đã lưu
- Gửi thông báo phần thưởng tự động

## Cài đặt
1. Đặt tất cả server scripts vào `ServerScriptService`
2. Đặt client script vào `StarterPlayerScripts`
3. Cấu hình bot name/avatar trong `DiscordWebhook.server.lua`

## Sử dụng
- Nhấn `F7` để mở UI cấu hình
- Dán URL webhook Discord vào ô nhập
- Kiểm tra kết nối trước khi lưu
- Xóa webhook khi cần thiết

## DataStore
Hệ thống tự động lưu webhook vào DataStore với:
- Retry khi gặp lỗi
- Rate limiting (60 giây/1 lần lưu)
- Xử lý đồng thời an toàn