# 🚀 ZalỏMulti - Quản lý đa tài khoản Zalo Desktop

**ZalỏMulti** là một công cụ mạnh mẽ, gọn nhẹ và thẩm mỹ dành cho người dùng Windows, giúp quản lý và chạy đồng thời nhiều tài khoản Zalo Desktop trên cùng một máy tính một cách dễ dàng.

![ZaloMulti UI](Assets/zalo.png)

## ✨ Tính năng nổi bật
- **Quản lý không giới hạn**: Thêm, xóa và đặt tên cho từng tài khoản Zalo riêng biệt.
- **Dữ liệu độc lập**: Mỗi tài khoản hoạt động trong một môi trường (Profile) riêng, không lo bị đăng xuất hoặc chồng chéo dữ liệu.
- **Giao diện hiện đại (Modern UI)**: Thiết kế chuẩn Glassmorphism, hỗ trợ Chế độ Sáng (Light) và Tối (Dark).
- **Cá nhân hóa**: Tùy chỉnh màu sắc chủ đạo theo ý thích với bảng màu Pastel mịn mắt.
- **Shortcut tiện lợi**: Tự động tạo biểu tượng ngoài Desktop cho từng tài khoản để truy cập nhanh.
- **Đóng nhanh**: Chức năng đóng tất cả các phiên làm việc Zalo chỉ với 1 cú click.

## ⚙️ Cơ chế hoạt động kỹ thuật
Ứng dụng hoạt động dựa trên cơ chế **Điều hướng biến môi trường (Environment Variables Redirection)**. Thay vì can thiệp vào mã nguồn của Zalo, ZalỏMulti đánh lừa Zalo Desktop bằng cách chỉ định các đường dẫn lưu trữ dữ liệu khác nhau cho mỗi phiên làm việc.

### 1. Vị trí lưu trữ dữ liệu
Mọi dữ liệu của các tài khoản "Clone" sẽ được tập trung tại:
- **Đường dẫn**: `C:\Zalo_Clone_Profiles`
- **Cấu trúc bên trong mỗi Profile**:
    - `\AppData\Roaming`: Chứa tin nhắn, cơ sở dữ liệu và cấu hình tài khoản.
    - `\AppData\Local`: Chứa các file tạm và dữ liệu thực thi cục bộ.
    - `phone.txt`: File văn bản nhỏ lưu số điện thoại hiển thị trên giao diện.

### 2. Cách thức tạo tài khoản Clone
Khi bạn nhấn "Mở tài khoản", ứng dụng sẽ thực hiện:
- Thiết lập biến `$env:USERPROFILE` về thư mục Profile riêng.
- Thiết lập biến `$env:APPDATA` và `$env:LOCALAPPDATA` trỏ vào các thư mục con tương ứng bên trong Profile đó.
- Khởi chạy `Zalo.exe` với các biến môi trường đã được cô lập. Nhờ đó, Zalo sẽ nghĩ rằng nó đang chạy trên một người dùng Windows hoàn toàn mới.

### 3. Tự động hóa Desktop
- Ứng dụng tự động tạo các file `.lnk` (Shortcut) ngoài Desktop với tham số `-LaunchInstance`.
- Khi bạn nhấn vào biểu tượng ngoài Desktop, PowerShell sẽ chạy ngầm để thiết lập môi trường và mở đúng tài khoản đó mà không cần mở giao diện chính của ZalỏMulti.

## 🛠 Yêu cầu hệ thống
- **Hệ điều hành**: Windows 10/11.
- **Zalo Desktop**: Đã cài đặt phiên bản chính thức từ Zalo.me.
- **PowerShell**: Phiên bản 5.1 trở lên (có sẵn trên Windows).

## 🚀 Hướng dẫn cài đặt & Sử dụng
1. **Tải về**: Tải toàn bộ thư mục này về máy tính của bạn.
2. **Khởi chạy**: Nhấn đúp chuột vào file `ZaloMulti.bat` để mở ứng dụng.
3. **Thêm tài khoản**: Nhấn "Thêm tài khoản", nhập tên và bắt đầu sử dụng.
4. **Mở Zalo**: Nhấn "MỞ TÀI KHOẢN" trên thẻ tương ứng để bắt đầu đăng nhập.

## 📂 Cấu trúc thư mục dự án
- `ZaloMulti.ps1`: Mã nguồn chính xử lý logic (PowerShell).
- `ZaloMulti.xaml`: Định nghĩa giao diện người dùng (WPF).
- `ZaloMulti.bat`: File thực thi để khởi động ứng dụng nhanh.
- `Assets/`: Thư mục chứa tài nguyên (Font, Icon, Images).
- `.gitignore`: Cấu hình loại trừ các dữ liệu cá nhân khi đẩy lên GitHub.

## 📝 Lưu ý quan trọng
- **Tính an toàn**: Ứng dụng không yêu cầu quyền Admin (trừ khi thư mục `C:\` của bạn bị khóa).
- **Tính bảo mật**: Mọi tin nhắn và dữ liệu cá nhân nằm trong máy tính của bạn (`C:\Zalo_Clone_Profiles`). ZalỏMulti không gửi bất kỳ dữ liệu nào ra bên ngoài.
- **Dọn dẹp**: Nếu bạn xóa ứng dụng, hãy nhớ xóa thư mục `C:\Zalo_Clone_Profiles` thủ công nếu muốn giải phóng dung lượng ổ cứng.

## 🤝 Đóng góp & Liên hệ
Nếu bạn thấy công cụ này hữu ích, hãy để lại một **Star** ⭐ trên GitHub hoặc liên hệ với tôi qua:
- **Facebook**: [congtruongit](https://fb.me/congtruongit)
- **Telegram**: [@congtruongit](https://t.me/congtruongit)
- **Website**: [truong.it](https://truong.it)

---
*Bản quyền © 2024 bởi Truong.it. Phát triển với đam mê.*
