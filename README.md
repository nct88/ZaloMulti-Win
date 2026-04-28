# 🚀 ZalỏMulti - Quản lý đa tài khoản Zalo Desktop (v2.0.2)

**ZalỏMulti** là một công cụ mạnh mẽ, gọn nhẹ và thẩm mỹ dành cho người dùng Windows, giúp quản lý và chạy đồng thời nhiều tài khoản Zalo Desktop trên cùng một máy tính một cách dễ dàng.

<p align="center">
  <img src="Assets/zalo_01_Do.ico" width="48" height="48" alt="Đỏ" />
  <img src="Assets/zalo_02_XanhLa.ico" width="48" height="48" alt="Xanh lá" />
  <img src="Assets/zalo_03_Cam.ico" width="48" height="48" alt="Cam" />
  <img src="Assets/zalo_04_Vang.ico" width="48" height="48" alt="Vàng" />
  <img src="Assets/zalo_05_Tim.ico" width="48" height="48" alt="Tím" />
  <img src="Assets/zalo_06_Hong.ico" width="48" height="48" alt="Hồng" />
  <img src="Assets/zalo_07_XanhDuongDam.ico" width="48" height="48" alt="Xanh dương" />
  <img src="Assets/zalo_08_XanhNgoc.ico" width="48" height="48" alt="Xanh ngọc" />
  <img src="Assets/zalo_09_Nau.ico" width="48" height="48" alt="Nâu" />
  <img src="Assets/zalo_10_XamBac.ico" width="48" height="48" alt="Xám bạc" />
</p>

## ✨ Tính năng mới (Cập nhật 28/04/2026 - v2.0.2)

- **Khởi chạy từ Shortcut cực nhanh**: Khi mở Zalo từ Desktop, script không load giao diện XAML nữa mà chạy trực tiếp → mở Zalo gần như tức thì.
- **Sửa lỗi con trỏ xoay xoay**: Khắc phục hiện tượng con trỏ chuột nhấp nháy liên tục khi mở Zalo từ Shortcut Desktop.
- **Tối ưu hiệu suất**: Script thoát ngay sau khi mở Zalo, không chạy ngầm chiếm tài nguyên.

## ✨ Tính năng mới (Cập nhật 28/04/2026 - v2.0.1)

- **Sửa lỗi Shortcut tiếng Việt (triệt để)**: Khắc phục hoàn toàn lỗi `Unable to save shortcut` khi tên tài khoản có dấu tiếng Việt (ả, ạ, ồ, ể...). File Shortcut giờ dùng tên không dấu để tương thích mọi Windows locale.
- **Tối ưu encoding**: Thêm `chcp 65001` vào file `.bat` trung gian và dùng `UTF-8 no BOM` cho file `.bat`, `UTF-8 BOM` cho file `.ps1`.
- **Tự động sửa Shortcut cũ**: Ứng dụng tự phát hiện và sửa các file `.bat` cũ thiếu encoding UTF-8 khi khởi động.
- **Dọn dẹp thông minh**: Khi xóa/đổi tên tài khoản, tự dọn cả file Shortcut cũ (tên có dấu từ bản trước).

## ✨ Tính năng mới (Cập nhật 28/04/2026 - v2.0.0)

- **Tự động làm mới trạng thái**: Giao diện tự cập nhật mỗi 5 giây, hiển thị 🟢/⚫ chính xác theo thời gian thực.
- **Bộ đếm tài khoản**: Hiển số lượng tài khoản đang mở ngay trên thanh phiên bản (ví dụ: "2/5 đang mở").
- **Xóa thông minh**: Khi xóa tài khoản, chỉ đóng đúng phiên Zalo của tài khoản đó, không ảnh hưởng đến các tài khoản khác.
- **Dọn dẹp**: Loại bỏ `ZaloTransfer.ps1` (chức năng đã tích hợp sẵn trong ứng dụng chính).

## ✨ Tính năng mới (Cập nhật 28/04/2026 - v1.1.0)

- **Trạng thái tài khoản (🟢/⚫)**: Hiển thị trực quan trên mỗi thẻ xem Zalo đang mở hay đã đóng.
- **Cập nhật toàn diện (ZIP-based)**: Hệ thống cập nhật mới có thể tải và thay thế toàn bộ file (XAML, Assets, Script) thay vì chỉ 1 file duy nhất.
- **Hiện Changelog khi cập nhật**: Hộp thoại cập nhật giờ hiển thị danh sách thay đổi để người dùng biết có gì mới trước khi đồng ý.
- **Đồng bộ Shortcut khi đổi/xóa tên**: Khi đổi tên hoặc xóa tài khoản, Shortcut trên Desktop và file `.bat` trung gian sẽ tự động được cập nhật theo.

## ✨ Tính năng mới (Cập nhật 28/04/2026 - v1.0.3)

- **Sửa lỗi Shortcut không mở được Zalo**: Khắc phục triệt để lỗi file `.bat` chứa sai nội dung khiến Shortcut ngoài Desktop không hoạt động.
- **Tự động dọn dẹp**: Ứng dụng tự phát hiện và xóa các file Shortcut cũ bị lỗi từ phiên bản trước khi khởi động.
- **Hiệu ứng Hover**: Thẻ tài khoản sáng viền màu khi di chuột, tạo cảm giác giao diện sống động hơn.
- **Phản hồi khi mở Zalo**: Nút "MỞ TÀI KHOẢN" đổi thành "Đang mở..." trong 2 giây, tránh nhấn nhiều lần.
- **Dọn dẹp dự án**: Loại bỏ các file không cần thiết, cập nhật `.gitignore` chuẩn.

## ✨ Tính năng mới (Cập nhật 28/04/2026 - v1.0.2)

- **Sửa lỗi Shortcut tiếng Việt**: Khắc phục hoàn toàn lỗi không tạo được lối tắt khi tên tài khoản có dấu tiếng Việt.
- **Sửa lỗi khởi chạy từ Desktop**: Shortcut giờ truyền trực tiếp tên profile thay vì dùng số thứ tự, đảm bảo mở đúng tài khoản ngay cả khi đổi tên.
- **Nâng cấp cơ chế cập nhật tự động**: So sánh phiên bản chính xác bằng `[version]` (tránh lỗi `1.0.9` > `1.0.10`), kiểm tra tính toàn vẹn file tải về trước khi ghi đè để tránh hỏng ứng dụng.
- **Tối ưu hóa mã hóa**: Chuyển toàn bộ file `.bat` trung gian sang UTF-8, hỗ trợ đường dẫn và tên tài khoản tiếng Việt có dấu.

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

1. **Lỗi ký tự lạ hoặc lỗi cú pháp (Encoding)**: Hiện tượng: Script hiện lỗi "Missing closing '}'" hoặc các ký tự `Ã`, `Ä`. Cách sửa: Mở file `ZaloMulti.ps1` bằng Notepad -> Save As -> Chọn Encoding là **UTF-8 with BOM** -> Lưu đè lên.
2. **Unblock file**: Click chuột phải vào file `.zip` vừa tải về (hoặc thư mục đã giải nén), chọn **Properties**, tick vào ô **Unblock** ở dưới cùng rồi nhấn **OK**.
3. **Quyền thực thi**: Mở PowerShell với quyền Admin và chạy lệnh: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser` sau đó chọn `Y`.
4. **Zalo Desktop**: Đảm bảo bạn đã cài đặt bản Zalo Desktop chính thức từ trang chủ.
5. **Zalo đồng bộ tin nhắn thất bại**: Đây là hành vi bình thường. Khi đăng nhập trên profile Clone lần đầu, Zalo coi đó là thiết bị mới nên cần thời gian đồng bộ lại. Hãy **đợi 5–10 phút** sau khi đăng nhập, không tắt Zalo giữa chừng. Nếu vẫn thất bại, hãy đăng xuất rồi đăng nhập lại.
6. **Cơ chế đăng nhập nhiều tài khoản**: ZalỏMulti sử dụng kỹ thuật **Điều hướng biến môi trường** (Environment Variables Redirection). Mỗi tài khoản được tạo một thư mục riêng, khi mở Zalo ứng dụng sẽ trỏ các biến `USERPROFILE`, `APPDATA`, `LOCALAPPDATA` vào thư mục đó. Zalo nghĩ rằng nó đang chạy trên một người dùng Windows mới — hoàn toàn độc lập, không can thiệp hay crack Zalo gốc.
7. **Mở Clone xong không gõ được tiếng Việt (Unikey)**: Đây là xung đột giữa Zalo (Electron) và Unikey, không phải lỗi của ZalỏMulti. Cách khắc phục: Nhấn chuột phải vào icon Unikey ở khay hệ thống → chọn **Khởi động lại**, hoặc tắt Unikey rồi mở lại. Có thể thử chuyển sang **EVKey** (tương thích tốt hơn với Electron).

## 🤝 Đóng góp & Liên hệ

Nếu bạn thấy công cụ này hữu ích, hãy để lại một **Star** ⭐ trên GitHub hoặc liên hệ với tôi qua:

- **Facebook**: [congtruongit](https://fb.me/congtruongit)
- **Telegram**: [@congtruongit](https://t.me/congtruongit)
- **GitHub**: [congtruongitvn/ZaloMulti-Win](https://github.com/congtruongitvn/ZaloMulti-Win)
- **Website**: [truong.it](https://truong.it)

---

*Bản quyền © 2026 bởi truong.it. Phát triển với đam mê.*
