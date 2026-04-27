# ============================================================
# ZALỎMULTI - PHIÊN BẢN HOÀN THIỆN
# BẢN QUYỀN TRUONG.IT
# ============================================================

Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

# Logic ẩn cửa sổ Terminal
$Win32Code = @"
using System;
using System.Runtime.InteropServices;
public class Win32 {
    [DllImport("kernel32.dll")]
    public static extern IntPtr GetConsoleWindow();
    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
}
"@
Add-Type -TypeDefinition $Win32Code -ErrorAction SilentlyContinue
$consolePtr = [Win32]::GetConsoleWindow()
if ($consolePtr -ne [IntPtr]::Zero) {
    [Win32]::ShowWindow($consolePtr, 0)
}

# Cấu hình toàn cầu
$Global:AppPath = $PSScriptRoot
$Global:IconFolder = Join-Path $Global:AppPath "Assets"
$Global:FontPath = "file:///$($Global:AppPath.Replace('\','/'))/Assets/#Pin-Sans-Regular"

# Đường dẫn mặc định
$Global:ProfileRoot = "C:\Zalo_Clone_Profiles"
$CustomPathFile = Join-Path $Global:AppPath "custom_path.txt"
$Global:SettingsFile = Join-Path $Global:AppPath "settings.json"
$Global:CurrentTheme = "Dark"
$Global:CurrentAccent = "#74B9FF"

# Tải hoặc hỏi đường dẫn tùy chỉnh
if (Test-Path $CustomPathFile) {
    $CustomPath = (Get-Content $CustomPathFile -Raw -Encoding UTF8).Trim()
    if ($CustomPath) { $Global:ProfileRoot = $CustomPath }
} else {
    # Lần đầu chạy hoặc thiếu cấu hình: Hỏi người dùng
    $msg = "Chào mừng bạn đến với ZalỏMulti!`n`nMặc định dữ liệu sẽ được lưu tại: C:\Zalo_Clone_Profiles`n`nBạn có muốn chọn một thư mục khác (Ví dụ ổ D, E) để lưu dữ liệu không?"
    $choice = [System.Windows.MessageBox]::Show($msg, "Cấu hình lưu trữ", [System.Windows.MessageBoxButton]::YesNo, [System.Windows.MessageBoxImage]::Question)
    
    if ($choice -eq "Yes") {
        Add-Type -AssemblyName System.Windows.Forms
        $browser = New-Object System.Windows.Forms.FolderBrowserDialog
        $browser.Description = "Chọn thư mục để lưu trữ các tài khoản Zalo Clone"
        $browser.ShowNewFolderButton = $true
        
        if ($browser.ShowDialog() -eq "OK") {
            $Global:ProfileRoot = Join-Path $browser.SelectedPath "Zalo_Clone_Profiles"
            $Global:ProfileRoot | Set-Content $CustomPathFile -Force -Encoding UTF8
        } else {
            # Người dùng hủy, sử dụng mặc định nhưng chưa lưu file để lần sau hỏi lại
        }
    } else {
        # Người dùng chọn mặc định, lưu lại để không hỏi lại lần sau
        $Global:ProfileRoot | Set-Content $CustomPathFile -Force -Encoding UTF8
    }
}

# Phát hiện đường dẫn Zalo thông minh
$CommonZaloPaths = @(
    "C:\Users\$($env:USERNAME)\AppData\Local\Programs\Zalo\Zalo.exe",
    "C:\Program Files (x86)\Zalo\Zalo.exe",
    "C:\Program Files\Zalo\Zalo.exe"
)
$Global:ZaloPath = ""
foreach ($path in $CommonZaloPaths) {
    if (Test-Path $path) {
        $Global:ZaloPath = $path
        break
    }
}

if (-not $Global:ZaloPath) {
    [System.Windows.MessageBox]::Show("Không tìm thấy Zalo.exe trên hệ thống! Vui lòng cài đặt Zalo trước.", "Lỗi Hệ Thống", 0, 16)
    exit
}

try {
    if (-not (Test-Path $Global:ProfileRoot)) { 
        New-Item -ItemType Directory -Path $Global:ProfileRoot -Force -ErrorAction Stop | Out-Null
    }
} catch {
    $Global:ProfileRoot = Join-Path $env:USERPROFILE "Zalo_Clone_Profiles"
    if (-not (Test-Path $Global:ProfileRoot)) { 
        New-Item -ItemType Directory -Path $Global:ProfileRoot -Force | Out-Null
    }
}

# Tải và nạp XAML (Đường dẫn Font động để đảm bảo tính di động)
$xamlRaw = Get-Content (Join-Path $Global:AppPath "ZaloMulti.xaml") -Raw -Encoding UTF8
$xamlRaw = $xamlRaw.Replace("__FONT_PATH__", $Global:FontPath)

[xml]$xamlContent = $xamlRaw
$reader = New-Object System.Xml.XmlNodeReader $xamlContent
$Global:window = [Windows.Markup.XamlReader]::Load($reader)

# Ánh xạ các thành phần UI
$Global:BtnAdd = $Global:window.FindName("BtnAdd")
$Global:BtnExport = $Global:window.FindName("BtnExport")
$Global:BtnImport = $Global:window.FindName("BtnImport")
$Global:BtnKillAll = $Global:window.FindName("BtnKillAll")
$Global:InstanceGrid = $Global:window.FindName("InstanceGrid")
$Global:BtnClose = $Global:window.FindName("BtnClose")
$Global:BtnLight = $Global:window.FindName("BtnLight")
$Global:BtnDark = $Global:window.FindName("BtnDark")
$Global:ThemeIndicator = $Global:window.FindName("ThemeIndicator")
$Global:ImgLogo = $Global:window.FindName("ImgLogo")
$Global:ImgFB = $Global:window.FindName("ImgFB")
$Global:ImgTG = $Global:window.FindName("ImgTG")
$Global:ImgGH = $Global:window.FindName("ImgGH")
$Global:ImgWS = $Global:window.FindName("ImgWS")
$Global:TxtVersion = $Global:window.FindName("TxtVersion")
$Global:MainScroll = $Global:window.FindName("MainScroll")
$Global:BtnToTop = $Global:window.FindName("BtnToTop")

# Hỗ trợ: Tải ảnh Bitmap
function Get-ZaloBitmap {
    param($filename)
    $path = Join-Path $Global:IconFolder $filename
    if (Test-Path $path) {
        return New-Object System.Windows.Media.Imaging.BitmapImage(New-Object Uri($path))
    }
    return $null
}

# Khởi tạo hình ảnh
$Global:ImgLogo.Source = Get-ZaloBitmap "zalo.png"
$Global:ImgFB.Source = Get-ZaloBitmap "facebook.png"
$Global:ImgTG.Source = Get-ZaloBitmap "telegram.png"
$Global:ImgGH.Source = Get-ZaloBitmap "github.png"
$Global:ImgWS.Source = Get-ZaloBitmap "website.png"

# --- LOGIC BẢO VỆ BẢN QUYỀN (OBFUSCATED) ---
function Get-LicenseInfo {
    $enc = "QuG6o24gcXV54buBbiDCqSAyMDI2IGLhu59pIHRydW9uZy5pdC4gUGjDoXQgdHJp4buDbiB24bubaSDEkWFtIG3Dqi4="
    $dec = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($enc))
    return $dec
}

# --- CHỨC NĂNG SAO LƯU (EXPORT) ---
function Export-ProfileUI {
    $profiles = Get-ChildItem $Global:ProfileRoot | Where-Object { $_.PSIsContainer }
    if ($profiles.Count -eq 0) { [System.Windows.MessageBox]::Show("Không tìm thấy profile nào để sao lưu!"); return }

    # Menu chọn nhanh
    $subWin = New-Object System.Windows.Window
    $subWin.Title = "Chọn Profile Sao Lưu"
    $subWin.Width = 300
    $subWin.Height = 400
    $subWin.WindowStartupLocation = "CenterOwner"
    $subWin.Owner = $Global:window

    $sp = New-Object System.Windows.Controls.StackPanel
    $sp.Margin = 10

    $lb = New-Object System.Windows.Controls.ListBox
    $lb.Height = 300
    foreach ($p in $profiles) { $lb.Items.Add($p.Name) }
    $sp.Children.Add($lb)

    $btn = New-Object System.Windows.Controls.Button
    $btn.Content = "BẮT ĐẦU SAO LƯU"
    $btn.Height = 40
    $btn.Margin = "0,10,0,0"
    $btn.Add_Click({ $subWin.DialogResult = $true; $subWin.Close() })
    $sp.Children.Add($btn)

    $subWin.Content = $sp
    if ($subWin.ShowDialog() -and $lb.SelectedItem) {
        $name = $lb.SelectedItem
        $timestamp = Get-Date -Format "HHmmss-ddMMyy"
        $fileNameFriendly = $name.ToLower().Replace(" ", "-")
        
        $save = New-Object Microsoft.Win32.SaveFileDialog
        $save.Filter = "Zalo Profile Package (*.zlp)|*.zlp"
        $save.FileName = "$fileNameFriendly-$timestamp.zlp"
        
        if ($save.ShowDialog()) {
            $destZip = $save.FileName
            Write-Host "Đang sao lưu $name..."
            Compress-Archive -Path "$(Join-Path $Global:ProfileRoot $name)\*" -DestinationPath $destZip -Force
            [System.Windows.MessageBox]::Show("Đã sao lưu thành công!`n$destZip")
        }
    }
}

# --- CHỨC NĂNG NHẬP (IMPORT) ---
function Import-ProfileUI {
    $open = New-Object Microsoft.Win32.OpenFileDialog
    $open.Filter = "Zalo Profile Package (*.zlp)|*.zlp"
    
    if ($open.ShowDialog()) {
        Add-Type -AssemblyName Microsoft.VisualBasic
        $defaultName = [System.IO.Path]::GetFileNameWithoutExtension($open.FileName).Replace("Backup_Zalo_", "")
        $newName = [Microsoft.VisualBasic.Interaction]::InputBox("Nhập tên cho profile mới:", "Nhập dữ liệu", $defaultName)
        
        if ($newName) {
            $destPath = Join-Path $Global:ProfileRoot $newName
            if (Test-Path $destPath) { [System.Windows.MessageBox]::Show("Tên này đã tồn tại!"); return }
            
            New-Item -ItemType Directory -Path $destPath -Force | Out-Null
            Expand-Archive -Path $open.FileName -DestinationPath $destPath -Force
            Update-AppUIList
            [System.Windows.MessageBox]::Show("Nhập dữ liệu thành công!")
        }
    }
}

# Hỗ trợ: Cập nhật tài nguyên Brush
function Set-GlobalBrush {
    param($key, $hex)
    try {
        $brush = [System.Windows.Media.BrushConverter]::new().ConvertFromString($hex)
        $Global:window.Resources[$key] = $brush
    } catch { }
}

function Save-AppSettings {
    $settings = @{
        Theme = $Global:CurrentTheme
        Accent = $Global:CurrentAccent
    }
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($Global:SettingsFile, ($settings | ConvertTo-Json), $utf8NoBom)
}

# Hỗ trợ: Chuyển đổi chủ đề + Animation
function Set-AppTheme {
    param($mode, $isInitial = $false)
    try {
        $Global:CurrentTheme = $mode
        $anim = New-Object System.Windows.Media.Animation.DoubleAnimation
        if ($isInitial) {
            $anim.Duration = [System.Windows.Duration]::new([TimeSpan]::FromMilliseconds(0))
        } else {
            $anim.Duration = [System.Windows.Duration]::new([TimeSpan]::FromMilliseconds(250))
            Save-AppSettings
        }
        $anim.EasingFunction = New-Object System.Windows.Media.Animation.CubicEase
        $anim.EasingFunction.EasingMode = "EaseInOut"

        if ($mode -eq "Dark") {
            Set-GlobalBrush "BgDark" "#0A0A0A"
            Set-GlobalBrush "BgSidebar" "#18191A"
            Set-GlobalBrush "BgCard" "#242526"
            Set-GlobalBrush "BgToggle" "#3A3B3C"
            Set-GlobalBrush "BorderBrush" "#3E4042"
            Set-GlobalBrush "TextMain" "#E4E6EB"
            Set-GlobalBrush "TextSec" "#B0B3B8"
            
            # Animation trượt sang phải (40px)
            $anim.To = 40
            $Global:ThemeIndicator.RenderTransform.BeginAnimation([System.Windows.Media.TranslateTransform]::XProperty, $anim)
            
            $Global:BtnDark.Foreground = [System.Windows.Media.Brushes]::White
            $Global:BtnLight.Foreground = $Global:window.Resources["TextSec"]
        } else {
            Set-GlobalBrush "BgDark" "#F0F2F5"
            Set-GlobalBrush "BgSidebar" "#FFFFFF"
            Set-GlobalBrush "BgCard" "#FFFFFF"
            Set-GlobalBrush "BgToggle" "#E4E6EB"
            Set-GlobalBrush "BorderBrush" "#CED0D4"
            Set-GlobalBrush "TextMain" "#050505"
            Set-GlobalBrush "TextSec" "#65676B"
            
            # Animation trượt sang trái (0px)
            $anim.To = 0
            $Global:ThemeIndicator.RenderTransform.BeginAnimation([System.Windows.Media.TranslateTransform]::XProperty, $anim)
            
            $Global:BtnLight.Foreground = [System.Windows.Media.Brushes]::White
            $Global:BtnDark.Foreground = $Global:window.Resources["TextSec"]
        }
    } catch { }
}

# Hỗ trợ: Cập nhật màu nhấn
function Update-AppAccent {
    param($hex, $isInitial = $false)
    try {
        $Global:CurrentAccent = $hex
        if (-not $isInitial) { Save-AppSettings }
        $c1 = [System.Drawing.ColorTranslator]::FromHtml($hex)
        $c2 = [System.Drawing.Color]::FromArgb(255, [int]($c1.R * 0.7), [int]($c1.G * 0.7), [int]($c1.B * 0.7))
        
        $brush = New-Object System.Windows.Media.LinearGradientBrush
        $brush.StartPoint = "0,0"
        $brush.EndPoint = "1,1"
        $brush.GradientStops.Add((New-Object System.Windows.Media.GradientStop([System.Windows.Media.Color]::FromRgb($c1.R, $c1.G, $c1.B), 0.0)))
        $brush.GradientStops.Add((New-Object System.Windows.Media.GradientStop([System.Windows.Media.Color]::FromRgb($c2.R, $c2.G, $c2.B), 1.0)))
        
        $Global:window.Resources["AccentGradBrush"] = $brush
        Set-GlobalBrush "AccentBlue" $hex
        $Global:BtnAdd.Background = $brush
        
        $lum = (0.299 * $c1.R + 0.587 * $c1.G + 0.114 * $c1.B)
        if ($lum -gt 150) { Set-GlobalBrush "TextOnAccent" "#000000" }
        else { Set-GlobalBrush "TextOnAccent" "#FFFFFF" }
    } catch { }
}

# Hỗ trợ: Tạo lối tắt ngoài Desktop
function New-AppShortcut {
    param($name, $index)
    try {
        $WshShell = New-Object -ComObject WScript.Shell
        $ShortcutPath = Join-Path ([Environment]::GetFolderPath("Desktop")) "$name.lnk"
        $Shortcut = $WshShell.CreateShortcut($ShortcutPath)
        $Shortcut.TargetPath = "powershell.exe"
        $Shortcut.Arguments = "-ExecutionPolicy Bypass -WindowStyle Hidden -File ""$($MyInvocation.MyCommand.Definition)"" -LaunchInstance ""$name"""
        
        if (Test-Path $Global:IconFolder) {
            $icons = Get-ChildItem $Global:IconFolder -Filter *.ico | Sort-Object Name
            if ($icons.Count -gt 0) {
                $iconIndex = $index % $icons.Count
                $Shortcut.IconLocation = $icons[$iconIndex].FullName
            }
        }
        $Shortcut.Save()
    } catch { }
}

# Hỗ trợ: Trình khởi chạy Zalo + Fake Device ID
function Start-ZaloInstance {
    param($name)
    $profilePath = Join-Path $Global:ProfileRoot $name
    $roamingPath = Join-Path $profilePath "AppData\Roaming"
    $localPath = Join-Path $profilePath "AppData\Local"
    $zaloDataPath = Join-Path $roamingPath "ZaloData"
    
    if (-not (Test-Path $roamingPath)) { New-Item -ItemType Directory -Path $roamingPath -Force | Out-Null }
    if (-not (Test-Path $localPath)) { New-Item -ItemType Directory -Path $localPath -Force | Out-Null }
    if (-not (Test-Path $zaloDataPath)) { New-Item -ItemType Directory -Path $zaloDataPath -Force | Out-Null }

    # --- Logic tạo Device ID ngẫu nhiên ---
    # 1. Tạo file z_u.txt (Định danh quan trọng nhất)
    $randomPart1 = -join ((1..19) | ForEach-Object { Get-Random -Minimum 0 -Maximum 10 })
    $timestamp = [DateTimeOffset]::Now.ToUnixTimeMilliseconds()
    $randomHash = [System.Guid]::NewGuid().ToString("n") # 32 ký tự hex (MD5 format)
    $zuContent = "$randomPart1.$timestamp.$randomHash"
    $zuContent | Set-Content (Join-Path $roamingPath "z_u.txt") -Force -Encoding ASCII

    # 2. Tạo file storage.json trong ZaloData (Để dự phòng)
    $storageJsonPath = Join-Path $zaloDataPath "storage.json"
    $deviceId = [System.Guid]::NewGuid().ToString().ToUpper() # UUID format
    $storageContent = '{"deviceId":"' + $deviceId + '"}'
    
    # Sử dụng UTF8 không BOM để tránh lỗi JavaScript parse JSON
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($storageJsonPath, $storageContent, $utf8NoBom)

    # 3. Tạo file config.json cơ bản nếu chưa có để ép Zalo nhận diện mới
    $configPath = Join-Path $zaloDataPath "config.json"
    if (-not (Test-Path $configPath)) {
        $configContent = '{"zalo_installed":' + $timestamp + '}'
        [System.IO.File]::WriteAllText($configPath, $configContent, $utf8NoBom)
    }

    $processInfo = New-Object System.Diagnostics.ProcessStartInfo
    $processInfo.FileName = $Global:ZaloPath
    $processInfo.UseShellExecute = $false
    $processInfo.EnvironmentVariables["USERPROFILE"] = $profilePath
    $processInfo.EnvironmentVariables["APPDATA"] = $roamingPath
    $processInfo.EnvironmentVariables["LOCALAPPDATA"] = $localPath
    [System.Diagnostics.Process]::Start($processInfo) | Out-Null
}

# Làm mới giao diện chính
function Update-AppUIList {
    # 1. Clean all existing Zalo shortcuts from Desktop first
    try {
        $desktopPath = [Environment]::GetFolderPath("Desktop")
        Get-ChildItem $desktopPath -Filter "Zalo *.lnk" | Remove-Item -Force -ErrorAction SilentlyContinue
    } catch {}

    $Global:InstanceGrid.Children.Clear()
    $profiles = Get-ChildItem $Global:ProfileRoot | Where-Object { $_.PSIsContainer } | Sort-Object CreationTime
    $count = 0
    foreach ($p in $profiles) {
        $name = $p.Name
        $count++
        
        $profileDir = $p.FullName
        $phonePath = Join-Path $profileDir "phone.txt"
        $currentPhone = "Nhập số ĐT tài khoản này"
        if (Test-Path $phonePath) { $currentPhone = (Get-Content $phonePath -Raw -Encoding UTF8).Trim() }

        $border = New-Object System.Windows.Controls.Border
        $border.SetResourceReference([System.Windows.Controls.Border]::BackgroundProperty, "BgCard")
        $border.SetResourceReference([System.Windows.Controls.Border]::BorderBrushProperty, "BorderBrush")
        $border.CornerRadius = 15
        $border.Margin = 10
        $border.Padding = 20
        $border.Width = 310
        $border.BorderThickness = 1
        
        $cardStack = New-Object System.Windows.Controls.StackPanel
        
        $headerGrid = New-Object System.Windows.Controls.Grid
        
        $nameBox = New-Object System.Windows.Controls.TextBox
        $nameBox.Text = $name.ToUpper()
        $nameBox.Style = $Global:window.Resources["EditBox"]
        $nameBox.FontSize = 14
        $nameBox.FontWeight = "Bold"
        $nameBox.Margin = "0,0,35,5" 
        $nameBox.Tag = $name
        $nameBox.SetResourceReference([System.Windows.Controls.TextBox]::ForegroundProperty, "TextMain")
        
        $delBorder = New-Object System.Windows.Controls.Border
        $delBorder.Background = [System.Windows.Media.Brushes]::White
        $delBorder.CornerRadius = 12
        $delBorder.Width = 24
        $delBorder.Height = 24
        $delBorder.HorizontalAlignment = "Right"
        $delBorder.VerticalAlignment = "Top"
        $delBorder.Margin = "0,-5,-5,0"
        $delBorder.Cursor = [Windows.Input.Cursors]::Hand
        $delBorder.ToolTip = "Xoá tài khoản này"
        
        $trashIcon = New-Object System.Windows.Controls.TextBlock
        $trashIcon.Text = "🗑"
        $trashIcon.Foreground = [System.Windows.Media.Brushes]::Red
        $trashIcon.FontSize = 12
        $trashIcon.HorizontalAlignment = "Center"
        $trashIcon.VerticalAlignment = "Center"
        $delBorder.Child = $trashIcon

        $delBorder.Add_MouseDown({
            $targetName = $this.Tag
            $msg = "Để xóa tài khoản '$targetName', hệ thống cần đóng tất cả các ứng dụng Zalo đang chạy để tránh lỗi.`n`nBạn có đồng ý đóng tất cả Zalo và xóa vĩnh viễn tài khoản này không?"
            $res = [System.Windows.MessageBox]::Show($msg, "Xác nhận xóa & Đóng Zalo", [System.Windows.MessageBoxButton]::YesNo, [System.Windows.MessageBoxImage]::Warning)
            
            if ($res -eq "Yes") {
                try {
                    # 1. Tự động đóng tất cả Zalo đang chạy
                    Write-Host "Đang đóng các tiến trình Zalo..." -ForegroundColor Yellow
                    Get-Process Zalo -ErrorAction SilentlyContinue | Stop-Process -Force
                    Start-Sleep -Milliseconds 500 # Chờ một chút để giải phóng file

                    # 2. Xóa thư mục profile
                    $delPath = Join-Path $Global:ProfileRoot $targetName
                    if (Test-Path $delPath) {
                        Remove-Item -Path $delPath -Recurse -Force -ErrorAction Stop
                        Update-AppUIList
                        [System.Windows.MessageBox]::Show("Đã đóng Zalo và xóa tài khoản '$targetName' thành công.")
                    }
                } catch {
                    [System.Windows.MessageBox]::Show("Có lỗi xảy ra: $($_.Exception.Message)`n`nHãy thử đóng Zalo thủ công và thực hiện lại.", "Lỗi", 0, 16)
                }
            }
        })
        $delBorder.Tag = $name

        $headerGrid.Children.Add($nameBox)
        $headerGrid.Children.Add($delBorder)

        $nameBox.Add_LostFocus({
            $newName = $this.Text.Trim()
            $oldName = $this.Tag
            if ($newName -and $newName -ne $oldName.ToUpper()) {
                $oldPath = Join-Path $Global:ProfileRoot $oldName
                $newPath = Join-Path $Global:ProfileRoot $newName
                if (-not (Test-Path $newPath)) {
                    Rename-Item -Path $oldPath -NewName $newName -Force | Out-Null
                    Update-AppUIList
                }
            }
        })

        $grid = New-Object System.Windows.Controls.Grid
        $col1 = New-Object System.Windows.Controls.ColumnDefinition
        $col1.Width = New-Object System.Windows.GridLength(40)
        $grid.ColumnDefinitions.Add($col1)
        $col2 = New-Object System.Windows.Controls.ColumnDefinition
        $col2.Width = New-Object System.Windows.GridLength(1, [System.Windows.GridUnitType]::Star)
        $grid.ColumnDefinitions.Add($col2)
        $grid.Margin = "0,0,0,15"

        $phonePrefix = New-Object System.Windows.Controls.TextBlock
        $phonePrefix.Text = "SĐT:"
        $phonePrefix.SetResourceReference([System.Windows.Controls.TextBlock]::ForegroundProperty, "AccentBlue")
        $phonePrefix.FontSize = 11
        $phonePrefix.FontWeight = "Bold"
        $phonePrefix.VerticalAlignment = "Center"
        [System.Windows.Controls.Grid]::SetColumn($phonePrefix, 0)

        $phoneBox = New-Object System.Windows.Controls.TextBox
        $phoneBox.Text = $currentPhone
        $phoneBox.Style = $Global:window.Resources["EditBox"]
        $phoneBox.FontSize = 11
        $phoneBox.Tag = $profileDir
        $phoneBox.VerticalAlignment = "Center"
        $phoneBox.SetResourceReference([System.Windows.Controls.TextBox]::ForegroundProperty, "TextSec")
        [System.Windows.Controls.Grid]::SetColumn($phoneBox, 1)
        $phoneBox.Add_LostFocus({
            $val = $this.Text.Trim()
            $path = Join-Path $this.Tag "phone.txt"
            $val | Set-Content $path -Force -Encoding UTF8 | Out-Null
        })
        
        $grid.Children.Add($phonePrefix)
        $grid.Children.Add($phoneBox)

        $launchBtn = New-Object System.Windows.Controls.Button
        $launchBtn.Content = "MỞ TÀI KHOẢN"
        $launchBtn.Style = $Global:window.Resources["RoundBtn"]
        $launchBtn.Tag = $name
        $launchBtn.Add_Click({ Start-ZaloInstance $this.Tag })

        $cardStack.Children.Add($headerGrid)
        $cardStack.Children.Add($grid)
        $cardStack.Children.Add($launchBtn)
        $border.Child = $cardStack
        $Global:InstanceGrid.Children.Add($border)

        New-AppShortcut -name "Zalo $count" -index ($count - 1)
    }
}

# Trình xử lý sự kiện
# Khôi phục cài đặt từ file
if (Test-Path $Global:SettingsFile) {
    try {
        $saved = Get-Content $Global:SettingsFile -Raw | ConvertFrom-Json
        $Global:CurrentTheme = $saved.Theme
        $Global:CurrentAccent = $saved.Accent
    } catch { }
}

# Áp dụng cài đặt ban đầu
Set-AppTheme $Global:CurrentTheme -isInitial $true
Update-AppAccent $Global:CurrentAccent -isInitial $true

$Global:BtnLight.Add_Click({ Set-AppTheme "Light" })
$Global:BtnDark.Add_Click({ Set-AppTheme "Dark" })
$Global:BtnExport.Add_Click({ Export-ProfileUI })
$Global:BtnImport.Add_Click({ Import-ProfileUI })

foreach ($i in (1..9)) {
    $btn = $Global:window.FindName("Pal$i")
    if ($btn) {
        $btn.Add_Click({ Update-AppAccent $this.Tag })
    }
}

$Global:window.FindName("BtnFB").Add_Click({ Start-Process "https://fb.me/congtruongit" | Out-Null })
$Global:window.FindName("BtnTG").Add_Click({ Start-Process "https://t.me/congtruongit" | Out-Null })
$Global:window.FindName("BtnGH").Add_Click({ Start-Process "https://github.com/congtruongit/ZaloMulti" | Out-Null })
$Global:window.FindName("BtnWS").Add_Click({ Start-Process "https://truong.it" | Out-Null })
$Global:TxtVersion.Add_MouseDown({ Start-Process "https://github.com/congtruongit/ZaloMulti" | Out-Null })

$Global:MainScroll.Add_ScrollChanged({
    if ($this.VerticalOffset -gt 200) { $Global:BtnToTop.Visibility = "Visible" }
    else { $Global:BtnToTop.Visibility = "Collapsed" }
})
$Global:BtnToTop.Add_Click({ $Global:MainScroll.ScrollToTop() })

$Global:BtnAdd.Add_Click({
    Add-Type -AssemblyName Microsoft.VisualBasic
    $currentProfiles = Get-ChildItem $Global:ProfileRoot | Where-Object { $_.PSIsContainer }
    $currentCount = $currentProfiles.Count + 1
    $defaultName = "Tài khoản $currentCount"
    $name = [Microsoft.VisualBasic.Interaction]::InputBox("Nhập tên tài khoản:", "Thêm tài khoản mới", $defaultName)
    if ($name) {
        $path = Join-Path $Global:ProfileRoot $name
        if (-not (Test-Path $path)) {
            New-Item -ItemType Directory -Path $path -Force | Out-Null
            Update-AppUIList
        } else {
            [System.Windows.MessageBox]::Show("Tên tài khoản đã tồn tại!")
        }
    }
})

$Global:BtnKillAll.Add_Click({
    Get-Process Zalo | Stop-Process -Force -ErrorAction SilentlyContinue
    [System.Windows.MessageBox]::Show("Đã đóng tất cả các phiên làm việc.")
})

$Global:BtnClose.Add_Click({ $Global:window.Close() })
$Global:window.Add_MouseLeftButtonDown({ $this.DragMove() })

# Trình xử lý đối số dòng lệnh
$allArgs = $MyInvocation.BoundParameters.Values + $args
for ($i=0; $i -lt $allArgs.Count; $i++) {
    if ($allArgs[$i] -eq "-LaunchInstance") {
        $targetName = $allArgs[$i+1]
        if ($targetName) {
            $profiles = Get-ChildItem $Global:ProfileRoot | Where-Object { $_.PSIsContainer } | Sort-Object CreationTime
            $idx = [int]($targetName -replace "Zalo ","") - 1
            if ($idx -ge 0 -and $idx -lt $profiles.Count) {
                Start-ZaloInstance $profiles[$idx].Name
            }
            exit
        }
    }
}

# Chạy ứng dụng
Update-AppUIList
$Global:TxtVersion.Text = "Phiên bản 7x7=59"
$Global:window.ShowDialog() | Out-Null
