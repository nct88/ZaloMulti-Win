# 🚀 ZalỏMulti - Quản lý đa tài khoản Zalo Desktop

<p align="center">
  <img src="Assets/zalo_01_Do.ico" width="64" height="64" alt="ZaloMulti" />
</p>

<p align="center">
  <strong>Nguyễn Công Trường</strong><br>
  Digital Marketing Specialist · Retail Operations · Open Source Developer
</p>

<p align="center">
  <a href="https://nct88.github.io/portfolio/">🌐 Portfolio</a> ·
  <a href="https://d.truong.it/donate">❤️ Ủng hộ</a> ·
  <a href="https://t.me/congtruongit">💬 Telegram</a> ·
  <a href="https://fb.me/congtruongit">📘 Facebook</a>
</p>

---

**ZalỏMulti** là một công cụ mạnh mẽ, gọn nhẹ và thẩm mỹ dành cho người dùng Windows, giúp quản lý và chạy đồng thời nhiều tài khoản Zalo Desktop trên cùng một máy tính một cách dễ dàng.



## ✨ Tính năng nổi bật

- **Quản lý không giới hạn**: Thêm, xóa và đặt tên cho từng tài khoản Zalo riêng biệt.
- **Dữ liệu độc lập**: Mỗi tài khoản hoạt động trong một môi trường (Profile) riêng, không lo bị đăng xuất hoặc chồng chéo dữ liệu.
- **Giao diện hiện đại (Modern UI)**: Thiết kế chuẩn Glassmorphism, hỗ trợ Chế độ Sáng (Light) và Tối (Dark).
- **Shortcut tiện lợi**: Tự động tạo biểu tượng ngoài Desktop cho từng tài khoản để truy cập nhanh.
- **Cập nhật tự động**: Tự kiểm tra và thông báo khi có phiên bản mới từ GitHub.
- **Đóng nhanh**: Chức năng đóng tất cả các phiên làm việc Zalo chỉ với 1 cú click.

## 🛠 Yêu cầu hệ thống

- **Hệ điều hành**: Windows 10/11.
- **Zalo Desktop**: Đã cài đặt phiên bản chính thức từ [Zalo.me](https://zalo.me/pc).
- **PowerShell**: Phiên bản 5.1 trở lên (có sẵn trên Windows).

## 🚀 Hướng dẫn sử dụng

1. **Tải về**: Tải toàn bộ thư mục từ [GitHub](https://github.com/nct88/ZaloMulti-Win/archive/refs/heads/main.zip).
2. **Khởi chạy**: Nhấn đúp vào file `ZaloMulti.exe`.
3. **Thêm tài khoản**: Nhấn "Thêm tài khoản", nhập tên và bắt đầu sử dụng.
4. **Mở Zalo**: Nhấn "MỞ TÀI KHOẢN" trên thẻ tương ứng.

## 📂 Cấu trúc dự án

- **`ZaloMulti.ps1`**: Mã nguồn chính (PowerShell)
- **`ZaloMulti.xaml`**: Giao diện người dùng (WPF)
- **`ZaloMulti.exe`**: File khởi động nhanh
- **`CHANGELOG.md`**: Nhật ký phiên bản
- **`docs/`**: Trang giới thiệu (GitHub Pages)
- **`Assets/`**: Tài nguyên (Font, Icon, Images)

## ❓ Xử lý sự cố

- **Lỗi ký tự lạ / cú pháp**: Mở `ZaloMulti.ps1` → Save As → Encoding **UTF-8 with BOM**.
- **Không chạy được**: Chuột phải vào file `.zip` tải về → Properties → tick **Unblock** → OK.
- **Lỗi quyền thực thi**: Chạy lệnh `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser` trong cửa sổ PowerShell.
- **Không gõ được tiếng Việt**: Khởi động lại Unikey hoặc chuyển sang phần mềm EVKey.
- **Đồng bộ tin nhắn chậm**: Đợi 5–10 phút sau đăng nhập, không tắt Zalo giữa chừng.

## 📋 Nhật ký phiên bản

Xem chi tiết tất cả các thay đổi qua từng phiên bản:

👉 **[CHANGELOG.md](CHANGELOG.md)** · **[Xem trên trang giới thiệu](https://nct88.github.io/ZaloMulti-Win/#changelog)**

## 🤝 Đóng góp & Liên hệ

Nếu bạn thấy công cụ này hữu ích, hãy để lại một **Star** ⭐ trên GitHub!

- 🌐 **Website**: [truong.it](https://truong.it)
- 💬 **Telegram**: [@congtruongit](https://t.me/congtruongit)
- 📘 **Facebook**: [congtruongit](https://fb.me/congtruongit)
- 🐙 **GitHub**: [nct88](https://github.com/nct88)

---

### ❤️ Ủng hộ

Nếu bạn thấy dự án hữu ích, hãy cân nhắc [ủng hộ truong.it](https://d.truong.it/donate) để tôi tiếp tục tạo ra những sản phẩm giá trị cho cộng đồng.

---

*Bản quyền © 2026 bởi truong.it. Phát triển với đam mê.*
