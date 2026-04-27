# 🚀 ZalỏMulti - Quản lý đa tài khoản Zalo Desktop (v1.0.1)

**ZalỏMulti** là một công cụ mạnh mẽ, gọn nhẹ và thẩm mỹ dành cho người dùng Windows, giúp quản lý và chạy đồng thời nhiều tài khoản Zalo Desktop trên cùng một máy tính một cách dễ dàng.

<p align="center">
  <img src="Assets/zalo_01_Do.ico" width="48" height="48" />
  <img src="Assets/zalo_02_XanhLa.ico" width="48" height="48" />
  <img src="Assets/zalo_03_Cam.ico" width="48" height="48" />
  <img src="Assets/zalo_04_Vang.ico" width="48" height="48" />
  <img src="Assets/zalo_05_Tim.ico" width="48" height="48" />
  <img src="Assets/zalo_06_Hong.ico" width="48" height="48" />
  <img src="Assets/zalo_07_XanhDuongDam.ico" width="48" height="48" />
  <img src="Assets/zalo_08_XanhNgoc.ico" width="48" height="48" />
  <img src="Assets/zalo_09_Nau.ico" width="48" height="48" />
  <img src="Assets/zalo_10_XamBac.ico" width="48" height="48" />
</p>

## ✨ Tính năng mới (Cập nhật 28/04/2026 - v1.0.2)
- **Sửa lỗi Shortcut tiếng Việt**: Khắc phục hoàn toàn lỗi không tạo được lối tắt khi tên tài khoản có dấu tiếng Việt.
- **Sửa lỗi khởi chạy**: Đảm bảo Shortcut mở đúng profile tương ứng.
- **Tối ưu hóa mã hóa**: Chuyển đổi toàn bộ hệ thống sang UTF-8 để hỗ trợ tiếng Việt tốt nhất.

## ✨ Tính năng mới (Cập nhật 28/04/2026 - v1.0.1)
- **Cập nhật tự động (Auto-Update)**: Hệ thống tự động kiểm tra và thông báo khi có bản vá lỗi hoặc tính năng mới từ GitHub.
- **Sửa lỗi "Không phản hồi"**: Khắc phục triệt để lỗi nhấn nút "Mở tài khoản" nhưng không có hiện tượng gì xảy ra.
- **Cải tiến giao diện**: Đưa nút **Tạo lối tắt (🔗)** lên thanh tiêu đề thẻ tài khoản để gọn gàng và dễ thao tác hơn.
- **GitHub Page**: Đã có trang giới thiệu chuyên nghiệp tại [congtruongitvn.github.io/ZaloMulti-Win](https://congtruongitvn.github.io/ZaloMulti-Win/).

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
1. **Tải về**: Tải toàn bộ thư mục này từ GitHub của [congtruongitvn](https://github.com/congtruongitvn/ZaloMulti-Win).
2. **Khởi chạy**: Nhấn đúp chuột vào file `ZaloMulti.bat` để mở ứng dụng.
3. **Thêm tài khoản**: Nhấn "Thêm tài khoản", nhập tên và bắt đầu sử dụng.
4. **Mở Zalo**: Nhấn "MỞ TÀI KHOẢN" trên thẻ tương ứng để bắt đầu đăng nhập.

## 📂 Cấu trúc thư mục dự án
- `ZaloMulti.ps1`: Mã nguồn chính xử lý logic (PowerShell).
- `ZaloMulti.xaml`: Định nghĩa giao diện người dùng (WPF).
- `ZaloMulti.bat`: File thực thi để khởi động ứng dụng nhanh.
- `docs/`: Thư mục chứa mã nguồn trang giới thiệu (GitHub Pages).
- `Assets/`: Thư mục chứa tài nguyên (Font, Icon, Images).
- `.gitignore`: Cấu hình loại trừ các dữ liệu cá nhân khi đẩy lên GitHub.

## 📝 Lưu ý quan trọng
- **Vị trí lưu dữ liệu**: Mặc định là `C:\Zalo_Clone_Profiles`. Nếu bạn không có quyền ghi vào ổ C, ứng dụng sẽ tự động lưu tại thư mục người dùng của bạn (`C:\Users\Tên_Bạn\Zalo_Clone_Profiles`).
- **Tính an toàn**: Ứng dụng không yêu cầu quyền Admin.
- **Tính bảo mật**: Mọi tin nhắn và dữ liệu cá nhân nằm trong máy tính của bạn. ZalỏMulti không gửi bất kỳ dữ liệu nào ra bên ngoài.
- **Dọn dẹp**: Nếu bạn xóa ứng dụng, hãy nhớ xóa thư mục dữ liệu thủ công nếu muốn giải phóng dung lượng ổ cứng.

## 💾 Hướng dẫn chọn nơi lưu trữ
- **Lần đầu khởi chạy**: Ứng dụng sẽ tự động hiển thị thông báo hỏi bạn muốn lưu dữ liệu ở đâu. Bạn có thể nhấn **Yes** để chọn ổ D, E hoặc thư mục bất kỳ, hoặc nhấn **No** để sử dụng mặc định (ổ C).
- **Thay đổi sau này**: Nếu muốn đổi nơi lưu trữ khác, bạn chỉ cần xóa file `custom_path.txt` trong thư mục ứng dụng và mở lại, ứng dụng sẽ hỏi lại từ đầu.

## ❓ Giải quyết sự cố (Troubleshooting)
Nếu bạn gặp lỗi trong quá trình sử dụng, hãy thử các cách sau:
1. **Lỗi ký tự lạ hoặc lỗi cú pháp (Encoding)**: 
    - Hiện tượng: Script hiện lỗi "Missing closing '}'" hoặc các ký tự `Ã`, `Ä`.
    - Cách sửa: Mở file `ZaloMulti.ps1` bằng Notepad -> Save As -> Chọn Encoding là **UTF-8 with BOM** -> Lưu đè lên.
2. **Unblock file**: Click chuột phải vào file `.zip` vừa tải về (hoặc thư mục đã giải nén), chọn **Properties**, tick vào ô **Unblock** ở dưới cùng rồi nhấn **OK**.
3. **Quyền thực thi**: Mở PowerShell với quyền Admin và chạy lệnh: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser` sau đó chọn `Y`.
4. **Zalo Desktop**: Đảm bảo bạn đã cài đặt bản Zalo Desktop chính thức từ trang chủ.

## 🤝 Đóng góp & Liên hệ
Nếu bạn thấy công cụ này hữu ích, hãy để lại một **Star** ⭐ trên GitHub hoặc liên hệ với tôi qua:
- **Facebook**: [congtruongit](https://fb.me/congtruongit)
- **Telegram**: [@congtruongit](https://t.me/congtruongit)
- **GitHub**: [congtruongitvn/ZaloMulti-Win](https://github.com/congtruongitvn/ZaloMulti-Win)
- **Website**: [truong.it](https://truong.it)

---
*Bản quyền © 2026 bởi truong.it. Phát triển với đam mê.*
