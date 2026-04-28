# ============================================================
# ZALỎMULTI - PHIÊN BẢN HOÀN THIỆN
# BẢN QUYỀN TRUONG.IT
# ============================================================

Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

# Logic ẩn cửa sổ Terminal (sẽ gọi sau khi XAML load thành công)
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

# Bẫy lỗi toàn cục — hiện MessageBox nếu crash thay vì tắt im lặng
trap {
    [System.Windows.MessageBox]::Show("ZaloMulti gặp lỗi khởi động:`n`n$($_.Exception.Message)`n`nFile: $($_.InvocationInfo.ScriptName)`nDòng: $($_.InvocationInfo.ScriptLineNumber)", "Lỗi ZaloMulti", 0, 16)
    exit 1
}

# Cấu hình toàn cầu
$Global:Version = "2.0.1" # Sửa lỗi Shortcut tiếng Việt
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
        }
    } else {
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

# Tải và nạp XAML
$xamlRaw = Get-Content (Join-Path $Global:AppPath "ZaloMulti.xaml") -Raw -Encoding UTF8
$xamlRaw = $xamlRaw.Replace("__FONT_PATH__", $Global:FontPath)
[xml]$xamlContent = $xamlRaw
$reader = New-Object System.Xml.XmlNodeReader $xamlContent
$Global:window = [Windows.Markup.XamlReader]::Load($reader)

# Ẩn cửa sổ Terminal SAU KHI XAML load thành công
$consolePtr = [Win32]::GetConsoleWindow()
if ($consolePtr -ne [IntPtr]::Zero) {
    [Win32]::ShowWindow($consolePtr, 0)
}

# Ánh xạ UI
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

function Get-ZaloBitmap {
    param($filename)
    $path = Join-Path $Global:IconFolder $filename
    if (Test-Path $path) {
        return New-Object System.Windows.Media.Imaging.BitmapImage(New-Object Uri($path))
    }
    return $null
}

$Global:ImgLogo.Source = Get-ZaloBitmap "zalo.png"
$Global:ImgFB.Source = Get-ZaloBitmap "facebook.png"
$Global:ImgTG.Source = Get-ZaloBitmap "telegram.png"
$Global:ImgGH.Source = Get-ZaloBitmap "github.png"
$Global:ImgWS.Source = Get-ZaloBitmap "website.png"

# --- CHỨC NĂNG SAO LƯU ---
function Export-ProfileUI {
    $profiles = Get-ChildItem $Global:ProfileRoot -ErrorAction SilentlyContinue | Where-Object { $_.PSIsContainer }
    if (-not $profiles -or $profiles.Count -eq 0) { [System.Windows.MessageBox]::Show("Không tìm thấy profile nào để sao lưu!", "Sao lưu", 0, 48); return }

    $subWin = New-Object System.Windows.Window
    $subWin.Title = "Chọn Profile Sao Lưu"
    $subWin.Width = 320; $subWin.Height = 420
    $subWin.WindowStartupLocation = "CenterOwner"
    $subWin.Owner = $Global:window
    $subWin.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#242526")

    $sp = New-Object System.Windows.Controls.StackPanel
    $sp.Margin = 15
    $lbl = New-Object System.Windows.Controls.TextBlock
    $lbl.Text = "Chọn tài khoản cần sao lưu:"; $lbl.Foreground = "White"; $lbl.FontSize = 14; $lbl.Margin = "0,0,0,10"
    $sp.Children.Add($lbl)
    $lb = New-Object System.Windows.Controls.ListBox
    $lb.Height = 280; $lb.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#18191A")
    $lb.Foreground = "White"; $lb.FontSize = 13
    foreach ($p in $profiles) { $lb.Items.Add($p.Name) | Out-Null }
    $sp.Children.Add($lb)

    $btn = New-Object System.Windows.Controls.Button
    $btn.Content = "📦 BẮT ĐẦU SAO LƯU"; $btn.Height = 38; $btn.Margin = "0,10,0,0"; $btn.FontSize = 13
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
            try {
                $sourcePath = Join-Path $Global:ProfileRoot $name
                $destZip = $save.FileName
                [System.Windows.MessageBox]::Show("Đang sao lưu... Vui lòng chờ.`nQuá trình này có thể mất vài phút tùy dung lượng.", "Sao lưu", 0, 64)
                Compress-Archive -Path "$sourcePath\*" -DestinationPath $destZip -Force
                [System.Windows.MessageBox]::Show("Sao lưu thành công!`n$destZip", "Hoàn tất", 0, 64)
            } catch {
                [System.Windows.MessageBox]::Show("Lỗi khi sao lưu:`n$($_.Exception.Message)", "Lỗi sao lưu", 0, 16)
            }
        }
    }
}

# --- CHỨC NĂNG NHẬP ---
function Import-ProfileUI {
    $open = New-Object Microsoft.Win32.OpenFileDialog
    $open.Filter = "Zalo Profile Package (*.zlp)|*.zlp"
    $open.Title = "Chọn file sao lưu (.zlp) để nhập"
    
    if ($open.ShowDialog()) {
        try {
            Add-Type -AssemblyName Microsoft.VisualBasic
            $defaultName = [System.IO.Path]::GetFileNameWithoutExtension($open.FileName).Replace("Backup_Zalo_", "")
            $newName = [Microsoft.VisualBasic.Interaction]::InputBox("Nhập tên cho tài khoản mới:", "Nhập dữ liệu", $defaultName)
            
            if ($newName) {
                $destPath = Join-Path $Global:ProfileRoot $newName
                if (Test-Path $destPath) { [System.Windows.MessageBox]::Show("Tên '$newName' đã tồn tại! Vui lòng chọn tên khác.", "Trùng tên", 0, 48); return }
                
                New-Item -ItemType Directory -Path $destPath -Force | Out-Null
                Expand-Archive -Path $open.FileName -DestinationPath $destPath -Force
                Update-AppUIList
                [System.Windows.MessageBox]::Show("Nhập dữ liệu thành công!`nTài khoản '$newName' đã sẵn sàng.", "Hoàn tất", 0, 64)
            }
        } catch {
            [System.Windows.MessageBox]::Show("Lỗi khi nhập dữ liệu:`n$($_.Exception.Message)", "Lỗi nhập", 0, 16)
        }
    }
}

function Set-GlobalBrush {
    param($key, $hex)
    try {
        $brush = [System.Windows.Media.BrushConverter]::new().ConvertFromString($hex)
        $Global:window.Resources[$key] = $brush
    } catch { }
}

function Save-AppSettings {
    $settings = @{ Theme = $Global:CurrentTheme; Accent = $Global:CurrentAccent }
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($Global:SettingsFile, ($settings | ConvertTo-Json), $utf8NoBom)
}

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
            $anim.To = 0
            $Global:ThemeIndicator.RenderTransform.BeginAnimation([System.Windows.Media.TranslateTransform]::XProperty, $anim)
            $Global:BtnLight.Foreground = [System.Windows.Media.Brushes]::White
            $Global:BtnDark.Foreground = $Global:window.Resources["TextSec"]
        }
    } catch { }
}

function Update-AppAccent {
    param($hex, $isInitial = $false)
    try {
        $Global:CurrentAccent = $hex
        if (-not $isInitial) { Save-AppSettings }
        $c1 = [System.Drawing.ColorTranslator]::FromHtml($hex)
        $c2 = [System.Drawing.Color]::FromArgb(255, [int]($c1.R * 0.7), [int]($c1.G * 0.7), [int]($c1.B * 0.7))
        
        $brush = New-Object System.Windows.Media.LinearGradientBrush
        $brush.StartPoint = "0,0"; $brush.EndPoint = "1,1"
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

function Remove-Diacritics {
    param([string]$text)
    $normalized = $text.Normalize([System.Text.NormalizationForm]::FormD)
    $sb = New-Object System.Text.StringBuilder
    foreach ($c in $normalized.ToCharArray()) {
        $cat = [System.Globalization.CharUnicodeInfo]::GetUnicodeCategory($c)
        if ($cat -ne [System.Globalization.UnicodeCategory]::NonSpacingMark) {
            [void]$sb.Append($c)
        }
    }
    # Xử lý thêm ký tự đặc biệt tiếng Việt mà Normalize không xử lý hết
    $result = $sb.ToString()
    $result = $result -replace 'đ','d' -replace 'Đ','D'
    return $result
}

function New-AppShortcut {
    param($name, $index)
    try {
        $desktopPath = [Environment]::GetFolderPath("Desktop")
        # Tạo tên file an toàn (không dấu) cho .lnk và .bat vì WScript.Shell dùng ANSI
        $safeName = Remove-Diacritics $name
        $ShortcutPath = Join-Path $desktopPath "$safeName.lnk"
        $batFolder = Join-Path $Global:AppPath "Shortcuts"
        if (-not (Test-Path $batFolder)) { New-Item -ItemType Directory -Path $batFolder -Force | Out-Null }
        $batPath = Join-Path $batFolder "$safeName.bat"
        
        $scriptPath = Join-Path $Global:AppPath "ZaloMulti.ps1"
        # Nội dung .bat vẫn giữ tên gốc (có dấu) trong tham số -LaunchInstance
        $batContent = "@echo off`nchcp 65001 >nul`nstart `"`" powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$scriptPath`" -LaunchInstance `"$name`""
        $utf8NoBom = New-Object System.Text.UTF8Encoding $false
        [System.IO.File]::WriteAllText($batPath, $batContent, $utf8NoBom)

        $WshShell = New-Object -ComObject WScript.Shell
        $Shortcut = $WshShell.CreateShortcut($ShortcutPath)
        $Shortcut.TargetPath = "cmd.exe"
        $Shortcut.Arguments = "/c `"$batPath`""
        $Shortcut.WindowStyle = 7
        $Shortcut.Description = $name
        
        if (Test-Path $Global:IconFolder) {
            $icons = Get-ChildItem $Global:IconFolder -Filter *.ico | Sort-Object Name
            if ($icons.Count -gt 0) { $Shortcut.IconLocation = $icons[$index % $icons.Count].FullName }
        }
        $Shortcut.Save()
        [System.Windows.MessageBox]::Show("Đã tạo lối tắt cho '$name' ngoài Desktop.")
    } catch {
        [System.Windows.MessageBox]::Show("Lỗi khi tạo shortcut: $($_.Exception.Message)")
    }
}

function Start-ZaloInstance {
    param($name)
    $profilePath = Join-Path $Global:ProfileRoot $name
    $roamingPath = Join-Path $profilePath "AppData\Roaming"
    $localPath = Join-Path $profilePath "AppData\Local"
    $zaloDataPath = Join-Path $roamingPath "ZaloData"
    
    if (-not (Test-Path $roamingPath)) { New-Item -ItemType Directory -Path $roamingPath -Force | Out-Null }
    if (-not (Test-Path $localPath)) { New-Item -ItemType Directory -Path $localPath -Force | Out-Null }
    if (-not (Test-Path $zaloDataPath)) { New-Item -ItemType Directory -Path $zaloDataPath -Force | Out-Null }

    $randomPart1 = -join ((1..19) | ForEach-Object { Get-Random -Minimum 0 -Maximum 10 })
    $timestamp = [DateTimeOffset]::Now.ToUnixTimeMilliseconds()
    $randomHash = [System.Guid]::NewGuid().ToString("n")
    $zuContent = "$randomPart1.$timestamp.$randomHash"
    $zuContent | Set-Content (Join-Path $roamingPath "z_u.txt") -Force -Encoding ASCII

    $deviceId = [System.Guid]::NewGuid().ToString().ToUpper()
    $storageContent = @{ deviceId = $deviceId } | ConvertTo-Json -Compress
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText((Join-Path $zaloDataPath "storage.json"), $storageContent, $utf8NoBom)

    $configPath = Join-Path $zaloDataPath "config.json"
    if (-not (Test-Path $configPath)) {
        $configContent = @{ zalo_installed = $timestamp } | ConvertTo-Json -Compress
        [System.IO.File]::WriteAllText($configPath, $configContent, $utf8NoBom)
    }

    $processInfo = New-Object System.Diagnostics.ProcessStartInfo
    $processInfo.FileName = $Global:ZaloPath
    $processInfo.UseShellExecute = $false
    $processInfo.EnvironmentVariables["USERPROFILE"] = $profilePath
    $processInfo.EnvironmentVariables["APPDATA"] = $roamingPath
    $processInfo.EnvironmentVariables["LOCALAPPDATA"] = $localPath
    
    try {
        $proc = [System.Diagnostics.Process]::Start($processInfo)
        # Lưu PID để theo dõi trạng thái
        if ($proc) {
            $proc.Id | Set-Content (Join-Path $profilePath "pid.txt") -Force -Encoding ASCII
        }
    } catch {
        [System.Windows.MessageBox]::Show("Không thể khởi chạy Zalo: $($_.Exception.Message)", "Lỗi", 0, 16)
    }
}

# Kiểm tra trạng thái tài khoản (đang mở hay đã đóng)
function Get-AccountStatus {
    param($profileDir)
    $pidFile = Join-Path $profileDir "pid.txt"
    if (Test-Path $pidFile) {
        $savedPid = (Get-Content $pidFile -Raw -ErrorAction SilentlyContinue).Trim()
        if ($savedPid -and (Get-Process -Id $savedPid -ErrorAction SilentlyContinue)) {
            return $true
        }
    }
    return $false
}

# --- CƠ CHẾ CẬP NHẬT TỰ ĐỘNG (ZIP-based) ---
function Update-AppSilently {
    $repoBase = "https://raw.githubusercontent.com/congtruongitvn/ZaloMulti-Win/main"
    $tempZip = Join-Path $env:TEMP "ZaloMulti_update.zip"
    $tempExtract = Join-Path $env:TEMP "ZaloMulti_update"
    
    try {
        $wc = New-Object System.Net.WebClient
        
        # Thử tải file ZIP trước (cập nhật toàn diện)
        $zipUrl = "$repoBase/update.zip"
        $useZip = $true
        try { $wc.DownloadFile($zipUrl, $tempZip) } catch { $useZip = $false }
        
        if ($useZip -and (Test-Path $tempZip) -and (Get-Item $tempZip).Length -gt 5000) {
            # Giải nén vào thư mục tạm
            if (Test-Path $tempExtract) { Remove-Item $tempExtract -Recurse -Force }
            Expand-Archive -Path $tempZip -DestinationPath $tempExtract -Force
            
            # Tạo file .bat để copy đè và khởi động lại
            $currentScript = Join-Path $Global:AppPath "ZaloMulti.ps1"
            $updateBat = Join-Path $env:TEMP "update_zalo_multi.bat"
            $destPath = $Global:AppPath
            $batContent = "@echo off`ntitle Dang cap nhat ZaloMulti...`ntimeout /t 1 /nobreak > nul`nxcopy /s /y /q `"$tempExtract\*`" `"$destPath\`"`nstart `"`" powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$currentScript`"`nrmdir /s /q `"$tempExtract`"`ndel `"$tempZip`"`ndel `"%~f0`""
            $utf8NoBom = New-Object System.Text.UTF8Encoding $false
            [System.IO.File]::WriteAllText($updateBat, $batContent, $utf8NoBom)
            Start-Process $updateBat -WindowStyle Hidden
            $Global:window.Close()
            exit
        } else {
            # Fallback: Cập nhật chỉ file .ps1 (tương thích ngược)
            $remoteScriptUrl = "$repoBase/ZaloMulti.ps1"
            $tempFile = Join-Path $env:TEMP "ZaloMulti_new.ps1"
            $wc.DownloadFile($remoteScriptUrl, $tempFile)
            
            $tempContent = Get-Content $tempFile -Raw -Encoding UTF8
            if ($tempContent.Length -lt 10000 -or $tempContent -notmatch "ZALỎMULTI") {
                [System.Windows.MessageBox]::Show("Bản tải xuống bị lỗi. Quá trình cập nhật đã bị hủy.", "Lỗi cập nhật", 0, 16)
                return
            }
            
            $currentScript = Join-Path $Global:AppPath "ZaloMulti.ps1"
            $updateBat = Join-Path $env:TEMP "update_zalo_multi.bat"
            $batContent = "@echo off`ntitle Dang cap nhat ZaloMulti...`ntimeout /t 1 /nobreak > nul`nmove /y `"$tempFile`" `"$currentScript`"`nstart `"`" powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$currentScript`"`ndel `"%~f0`""
            $utf8NoBom = New-Object System.Text.UTF8Encoding $false
            [System.IO.File]::WriteAllText($updateBat, $batContent, $utf8NoBom)
            Start-Process $updateBat -WindowStyle Hidden
            $Global:window.Close()
            exit
        }
    } catch {
        [System.Windows.MessageBox]::Show("Lỗi khi tải bản cập nhật: $($_.Exception.Message)")
    }
}

function Test-ForUpdates {
    $repoBase = "https://raw.githubusercontent.com/congtruongitvn/ZaloMulti-Win/main"
    
    # Chạy ngầm việc kiểm tra để không làm chậm lúc mở app
    Start-Job -ScriptBlock {
        param($baseUrl)
        try {
            $ver = (Invoke-RestMethod -Uri "$baseUrl/version.txt" -TimeoutSec 5).Trim()
            $log = $null
            try { $log = (Invoke-RestMethod -Uri "$baseUrl/changelog.txt" -TimeoutSec 3).Trim() } catch { }
            return @{ Version = $ver; Changelog = $log }
        } catch { return $null }
    } -ArgumentList $repoBase | Out-Null
    
    # Đợi tối đa 3 giây để lấy thông tin
    $job = Get-Job | Sort-Object ID -Descending | Select-Object -First 1
    Wait-Job $job -Timeout 3 | Out-Null
    $result = Receive-Job $job
    
    if ($result -and $result.Version -match '^\d+\.\d+\.\d+$') {
        try {
            if ([version]$result.Version -gt [version]$Global:Version) {
                $msg = "Đã có phiên bản mới ($($result.Version)).`n"
                if ($result.Changelog) {
                    $msg += "`n📋 Có gì mới:`n$($result.Changelog)`n"
                }
                $msg += "`nBạn có muốn cập nhật ngay không?`n(Ứng dụng sẽ tự khởi động lại sau khi cập nhật xong)"
                $res = [System.Windows.MessageBox]::Show($msg, "Bản cập nhật mới", [System.Windows.MessageBoxButton]::YesNo, [System.Windows.MessageBoxImage]::Information)
                if ($res -eq "Yes") {
                    Update-AppSilently
                }
            }
        } catch { }
    }
}

# --- TỰ ĐỘNG SỬA SHORTCUT CŨ BỊ LỖI ---
function Repair-OldShortcuts {
    $batFolder = Join-Path $Global:AppPath "Shortcuts"
    if (-not (Test-Path $batFolder)) { return }
    
    $scriptPath = Join-Path $Global:AppPath "ZaloMulti.ps1"
    $batFiles = Get-ChildItem $batFolder -Filter *.bat -ErrorAction SilentlyContinue
    foreach ($bat in $batFiles) {
        $content = Get-Content $bat.FullName -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
        # Nếu file .bat chứa mã nguồn hàm (dấu hiệu bị lỗi) hoặc không bắt đầu bằng @echo off hoặc thiếu chcp 65001
        $isBroken = ($content -match "param\(") -or ($content -match "try \{") -or (-not ($content -match "^@echo off")) -or (-not ($content -match "chcp 65001"))
        if ($isBroken) {
            # Tìm tên tài khoản gốc từ nội dung .bat (lấy từ -LaunchInstance)
            $accountName = [System.IO.Path]::GetFileNameWithoutExtension($bat.Name)
            if ($content -match '-LaunchInstance\s+\"([^\"]+)\"') {
                $accountName = $Matches[1]
            }
            # Tạo lại nội dung .bat đúng
            $fixedContent = "@echo off`nchcp 65001 >nul`nstart `"`" powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$scriptPath`" -LaunchInstance `"$accountName`""
            $utf8NoBom = New-Object System.Text.UTF8Encoding $false
            [System.IO.File]::WriteAllText($bat.FullName, $fixedContent, $utf8NoBom)
        }
    }
}

function Update-AppUIList {
    $Global:InstanceGrid.Children.Clear()
    $profiles = Get-ChildItem $Global:ProfileRoot | Where-Object { $_.PSIsContainer } | Sort-Object CreationTime
    $count = 0
    $activeCount = 0
    foreach ($p in $profiles) {
        $name = $p.Name
        $count++
        $profileDir = $p.FullName
        $phonePath = Join-Path $profileDir "phone.txt"
        $currentPhone = "Nhập số ĐT tài khoản này"
        if (Test-Path $phonePath) { $currentPhone = (Get-Content $phonePath -Raw -Encoding UTF8).Trim() }
        $isRunning = Get-AccountStatus $profileDir

        $border = New-Object System.Windows.Controls.Border
        $border.SetResourceReference([System.Windows.Controls.Border]::BackgroundProperty, "BgCard")
        $border.SetResourceReference([System.Windows.Controls.Border]::BorderBrushProperty, "BorderBrush")
        $border.CornerRadius = 15; $border.Margin = 10; $border.Padding = 20; $border.Width = 310; $border.BorderThickness = 1
        
        $cardStack = New-Object System.Windows.Controls.StackPanel
        $headerGrid = New-Object System.Windows.Controls.Grid
        $headerGrid.ColumnDefinitions.Add((New-Object System.Windows.Controls.ColumnDefinition -Property @{Width = New-Object System.Windows.GridLength(1, "Star")}))
        $headerGrid.ColumnDefinitions.Add((New-Object System.Windows.Controls.ColumnDefinition -Property @{Width = New-Object System.Windows.GridLength(30)}))
        $headerGrid.ColumnDefinitions.Add((New-Object System.Windows.Controls.ColumnDefinition -Property @{Width = New-Object System.Windows.GridLength(30)}))

        $nameBox = New-Object System.Windows.Controls.TextBox
        $nameBox.Text = $name.ToUpper(); $nameBox.Style = $Global:window.Resources["EditBox"]
        $nameBox.FontSize = 14; $nameBox.FontWeight = "Bold"; $nameBox.Margin = "0,0,5,5"; $nameBox.Tag = $name
        $nameBox.SetResourceReference([System.Windows.Controls.TextBox]::ForegroundProperty, "TextMain")
        [System.Windows.Controls.Grid]::SetColumn($nameBox, 0)

        $scBtn = New-Object System.Windows.Controls.Button
        $scBtn.Content = "🔗"; $scBtn.ToolTip = "Tạo lối tắt"; $scBtn.Style = $Global:window.Resources["ActionBtn"]
        $scBtn.FontSize = 14; $scBtn.Width = 24; $scBtn.Height = 24; $scBtn.Cursor = [Windows.Input.Cursors]::Hand
        $scBtn.Tag = @{ Name = $name; Index = $count - 1 }
        $scBtn.Add_Click({ New-AppShortcut -name $this.Tag.Name -index $this.Tag.Index })
        [System.Windows.Controls.Grid]::SetColumn($scBtn, 1)
        
        $delBorder = New-Object System.Windows.Controls.Border
        $delBorder.Background = [System.Windows.Media.Brushes]::White; $delBorder.CornerRadius = 12
        $delBorder.Width = 24; $delBorder.Height = 24; $delBorder.Cursor = [Windows.Input.Cursors]::Hand
        $delBorder.HorizontalAlignment = "Center"; $delBorder.VerticalAlignment = "Center"
        [System.Windows.Controls.Grid]::SetColumn($delBorder, 2)
        
        $trashIcon = New-Object System.Windows.Controls.TextBlock
        $trashIcon.Text = "🗑"; $trashIcon.Foreground = [System.Windows.Media.Brushes]::Red
        $trashIcon.FontSize = 12; $trashIcon.HorizontalAlignment = "Center"; $trashIcon.VerticalAlignment = "Center"
        $delBorder.Child = $trashIcon
        $delBorder.Tag = $name
        $delBorder.Add_MouseDown({
            $targetName = $this.Tag
            $msg = "Để xóa tài khoản '$targetName', hệ thống sẽ đóng phiên Zalo này và xóa dữ liệu vĩnh viễn. Bạn có đồng ý không?"
            if ([System.Windows.MessageBox]::Show($msg, "Xác nhận xóa", [System.Windows.MessageBoxButton]::YesNo, [System.Windows.MessageBoxImage]::Warning) -eq "Yes") {
                try {
                    # Chỉ đóng Zalo của profile này (dùng PID), không đóng tất cả
                    $pidFile = Join-Path (Join-Path $Global:ProfileRoot $targetName) "pid.txt"
                    if (Test-Path $pidFile) {
                        $savedPid = (Get-Content $pidFile -Raw -ErrorAction SilentlyContinue).Trim()
                        if ($savedPid) { Stop-Process -Id $savedPid -Force -ErrorAction SilentlyContinue }
                    }
                    Start-Sleep -Milliseconds 500
                    Remove-Item -Path (Join-Path $Global:ProfileRoot $targetName) -Recurse -Force
                    # Xóa Shortcut liên quan (dùng tên không dấu)
                    $safeTarget = Remove-Diacritics $targetName
                    $batPath = Join-Path (Join-Path $Global:AppPath "Shortcuts") "$safeTarget.bat"
                    $lnkPath = Join-Path ([Environment]::GetFolderPath("Desktop")) "$safeTarget.lnk"
                    if (Test-Path $batPath) { Remove-Item $batPath -Force -ErrorAction SilentlyContinue }
                    if (Test-Path $lnkPath) { Remove-Item $lnkPath -Force -ErrorAction SilentlyContinue }
                    # Dọn luôn file cũ nếu có (tên có dấu từ bản trước)
                    $oldBat = Join-Path (Join-Path $Global:AppPath "Shortcuts") "$targetName.bat"
                    $oldLnk = Join-Path ([Environment]::GetFolderPath("Desktop")) "$targetName.lnk"
                    if (Test-Path $oldBat) { Remove-Item $oldBat -Force -ErrorAction SilentlyContinue }
                    if (Test-Path $oldLnk) { Remove-Item $oldLnk -Force -ErrorAction SilentlyContinue }
                    Update-AppUIList
                } catch { [System.Windows.MessageBox]::Show("Lỗi: $($_.Exception.Message)") }
            }
        })

        $headerGrid.Children.Add($nameBox); $headerGrid.Children.Add($scBtn); $headerGrid.Children.Add($delBorder)

        $nameBox.Add_LostFocus({
            $newName = $this.Text.Trim(); $oldName = $this.Tag
            if ($newName -and $newName -ne $oldName.ToUpper()) {
                if (-not (Test-Path (Join-Path $Global:ProfileRoot $newName))) {
                    Rename-Item -Path (Join-Path $Global:ProfileRoot $oldName) -NewName $newName -Force
                    # Cập nhật Shortcut khi đổi tên (dùng tên không dấu)
                    $batFolder = Join-Path $Global:AppPath "Shortcuts"
                    $safeOld = Remove-Diacritics $oldName
                    $oldBat = Join-Path $batFolder "$safeOld.bat"
                    $oldLnk = Join-Path ([Environment]::GetFolderPath("Desktop")) "$safeOld.lnk"
                    if (Test-Path $oldBat) { Remove-Item $oldBat -Force -ErrorAction SilentlyContinue }
                    if (Test-Path $oldLnk) { Remove-Item $oldLnk -Force -ErrorAction SilentlyContinue }
                    # Dọn luôn file cũ nếu có (tên có dấu từ bản trước)
                    $oldBatVn = Join-Path $batFolder "$oldName.bat"
                    $oldLnkVn = Join-Path ([Environment]::GetFolderPath("Desktop")) "$oldName.lnk"
                    if (Test-Path $oldBatVn) { Remove-Item $oldBatVn -Force -ErrorAction SilentlyContinue }
                    if (Test-Path $oldLnkVn) { Remove-Item $oldLnkVn -Force -ErrorAction SilentlyContinue }
                    Update-AppUIList
                }
            }
        })

        $grid = New-Object System.Windows.Controls.Grid
        $grid.ColumnDefinitions.Add((New-Object System.Windows.Controls.ColumnDefinition -Property @{Width = New-Object System.Windows.GridLength(40)}))
        $grid.ColumnDefinitions.Add((New-Object System.Windows.Controls.ColumnDefinition -Property @{Width = New-Object System.Windows.GridLength(1, "Star")}))
        $grid.Margin = "0,0,0,15"

        $phonePrefix = New-Object System.Windows.Controls.TextBlock
        $phonePrefix.Text = "SĐT:"; $phonePrefix.SetResourceReference([System.Windows.Controls.TextBlock]::ForegroundProperty, "AccentBlue")
        $phonePrefix.FontSize = 11; $phonePrefix.FontWeight = "Bold"; $phonePrefix.VerticalAlignment = "Center"
        [System.Windows.Controls.Grid]::SetColumn($phonePrefix, 0)

        $phoneBox = New-Object System.Windows.Controls.TextBox
        $phoneBox.Text = $currentPhone; $phoneBox.Style = $Global:window.Resources["EditBox"]
        $phoneBox.FontSize = 11; $phoneBox.Tag = $profileDir; $phoneBox.VerticalAlignment = "Center"
        $phoneBox.SetResourceReference([System.Windows.Controls.TextBox]::ForegroundProperty, "TextSec")
        [System.Windows.Controls.Grid]::SetColumn($phoneBox, 1)
        $phoneBox.Add_LostFocus({
            $this.Text.Trim() | Set-Content (Join-Path $this.Tag "phone.txt") -Force -Encoding UTF8
        })
        $grid.Children.Add($phonePrefix); $grid.Children.Add($phoneBox)

        # Badge trạng thái tài khoản
        $statusPanel = New-Object System.Windows.Controls.StackPanel
        $statusPanel.Orientation = "Horizontal"; $statusPanel.Margin = "0,0,0,10"
        $statusPanel.Tag = $profileDir
        $statusDot = New-Object System.Windows.Controls.TextBlock
        $statusDot.Name = "StatusDot"
        $statusLabel = New-Object System.Windows.Controls.TextBlock
        $statusLabel.Name = "StatusLabel"
        $statusLabel.FontSize = 11; $statusLabel.VerticalAlignment = "Center"; $statusLabel.Margin = "5,0,0,0"
        if ($isRunning) {
            $activeCount++
            $statusDot.Text = "●"; $statusDot.Foreground = [System.Windows.Media.Brushes]::LimeGreen; $statusDot.FontSize = 14
            $statusLabel.Text = "Đang hoạt động"; $statusLabel.Foreground = [System.Windows.Media.Brushes]::LimeGreen
        } else {
            $statusDot.Text = "●"; $statusDot.Foreground = [System.Windows.Media.Brushes]::Gray; $statusDot.FontSize = 14
            $statusLabel.Text = "Chưa mở"; $statusLabel.SetResourceReference([System.Windows.Controls.TextBlock]::ForegroundProperty, "TextSec")
        }
        $statusPanel.Children.Add($statusDot); $statusPanel.Children.Add($statusLabel)

        $launchBtn = New-Object System.Windows.Controls.Button
        $launchBtn.Content = "MỞ TÀI KHOẢN"; $launchBtn.Style = $Global:window.Resources["RoundBtn"]
        $launchBtn.Tag = $name; $launchBtn.Width = 270
        $launchBtn.Add_Click({
            $btn = $this
            $originalText = $btn.Content
            $btn.Content = "Đang mở..."; $btn.IsEnabled = $false
            Start-ZaloInstance $btn.Tag
            # Khôi phục nút sau 2 giây
            $timer = New-Object System.Windows.Threading.DispatcherTimer
            $timer.Interval = [TimeSpan]::FromSeconds(2)
            $timer.Tag = @{ Button = $btn; Text = $originalText }
            $timer.Add_Tick({
                $this.Tag.Button.Content = $this.Tag.Text
                $this.Tag.Button.IsEnabled = $true
                $this.Stop()
            })
            $timer.Start()
        })
        
        # Hover effect cho thẻ tài khoản
        $border.Add_MouseEnter({
            $this.BorderBrush = $Global:window.Resources["AccentBlue"]
            $this.BorderThickness = [System.Windows.Thickness]::new(1.5)
        })
        $border.Add_MouseLeave({
            $this.SetResourceReference([System.Windows.Controls.Border]::BorderBrushProperty, "BorderBrush")
            $this.BorderThickness = [System.Windows.Thickness]::new(1)
        })
        
        $cardStack.Children.Add($headerGrid); $cardStack.Children.Add($grid); $cardStack.Children.Add($statusPanel); $cardStack.Children.Add($launchBtn)
        $border.Child = $cardStack
        $Global:InstanceGrid.Children.Add($border)
    }
    # Cập nhật số lượng tài khoản đang hoạt động trên tiêu đề
    $Global:TxtVersion.Text = "Phiên bản $Global:Version • $activeCount/$count đang mở"
}

# Áp dụng cài đặt ban đầu
if (Test-Path $Global:SettingsFile) {
    try {
        $saved = Get-Content $Global:SettingsFile -Raw | ConvertFrom-Json
        $Global:CurrentTheme = $saved.Theme; $Global:CurrentAccent = $saved.Accent
    } catch { }
}
Set-AppTheme $Global:CurrentTheme -isInitial $true
Update-AppAccent $Global:CurrentAccent -isInitial $true

$Global:BtnLight.Add_Click({ Set-AppTheme "Light" })
$Global:BtnDark.Add_Click({ Set-AppTheme "Dark" })
$Global:BtnExport.Add_Click({ Export-ProfileUI })
$Global:BtnImport.Add_Click({ Import-ProfileUI })

foreach ($i in (1..9)) {
    $btn = $Global:window.FindName("Pal$i")
    if ($btn) { $btn.Add_Click({ Update-AppAccent $this.Tag }) }
}

$Global:window.FindName("BtnFB").Add_Click({ Start-Process "https://fb.me/congtruongit" | Out-Null })
$Global:window.FindName("BtnTG").Add_Click({ Start-Process "https://t.me/congtruongit" | Out-Null })
$Global:window.FindName("BtnGH").Add_Click({ Start-Process "https://github.com/congtruongitvn/ZaloMulti" | Out-Null })
$Global:window.FindName("BtnWS").Add_Click({ Start-Process "https://truong.it" | Out-Null })
$Global:TxtVersion.Add_MouseDown({ Start-Process "https://github.com/congtruongitvn/ZaloMulti" | Out-Null })

$Global:MainScroll.Add_ScrollChanged({
    if ($this.VerticalOffset -gt 200) { $Global:BtnToTop.Visibility = "Visible" }
    else { $Global:BtnToTop.Visibility = "Collapsed" }
})
$Global:BtnToTop.Add_Click({ $Global:MainScroll.ScrollToTop() })

$Global:BtnAdd.Add_Click({
    Add-Type -AssemblyName Microsoft.VisualBasic
    $defaultName = "Tài khoản $( (Get-ChildItem $Global:ProfileRoot | Where-Object { $_.PSIsContainer }).Count + 1 )"
    $name = [Microsoft.VisualBasic.Interaction]::InputBox("Nhập tên tài khoản:", "Thêm mới", $defaultName)
    if ($name) {
        $path = Join-Path $Global:ProfileRoot $name
        if (-not (Test-Path $path)) { New-Item -ItemType Directory -Path $path -Force | Out-Null; Update-AppUIList }
        else { [System.Windows.MessageBox]::Show("Tên tài khoản đã tồn tại!") }
    }
})

$Global:BtnKillAll.Add_Click({
    Get-Process Zalo -ErrorAction SilentlyContinue | Stop-Process -Force
    [System.Windows.MessageBox]::Show("Đã đóng tất cả các phiên làm việc.")
})

$Global:BtnClose.Add_Click({ $Global:window.Close() })
$Global:window.Add_MouseLeftButtonDown({ $this.DragMove() })

$allArgs = $MyInvocation.BoundParameters.Values + $args
for ($i=0; $i -lt $allArgs.Count; $i++) {
    if ($allArgs[$i] -eq "-LaunchInstance") {
        $targetName = $allArgs[$i+1]
        if ($targetName) {
            # Kiểm tra xem profile có tồn tại không trước khi khởi chạy
            if (Test-Path (Join-Path $Global:ProfileRoot $targetName)) {
                Start-ZaloInstance $targetName
            } else {
                # Fallback cho các bản cũ hoặc lỗi đặt tên
                $profiles = Get-ChildItem $Global:ProfileRoot | Where-Object { $_.PSIsContainer } | Sort-Object CreationTime
                $cleanName = $targetName -replace "Zalo ","" -replace "Tài khoản ",""
                if ($cleanName -as [int]) {
                    $idx = [int]$cleanName - 1
                    if ($idx -ge 0 -and $idx -lt $profiles.Count) { Start-ZaloInstance $profiles[$idx].Name }
                }
            }
            exit
        }
    }
}

Test-ForUpdates
Repair-OldShortcuts
Update-AppUIList
$Global:TxtVersion.Text = "Phiên bản $Global:Version"

# --- HÀM LÀM MỚI TRẠNG THÁI NHẸ (không rebuild UI) ---
function Refresh-StatusOnly {
    $profiles = Get-ChildItem $Global:ProfileRoot -ErrorAction SilentlyContinue | Where-Object { $_.PSIsContainer } | Sort-Object CreationTime
    $activeCount = 0
    $totalCount = 0
    foreach ($p in $profiles) {
        $totalCount++
        $profileDir = $p.FullName
        $isRunning = Get-AccountStatus $profileDir
        if ($isRunning) { $activeCount++ }
    }
    # Tìm và cập nhật từng statusPanel đã gắn Tag
    foreach ($border in $Global:InstanceGrid.Children) {
        if ($border -is [System.Windows.Controls.Border] -and $border.Child) {
            $stack = $border.Child
            foreach ($child in $stack.Children) {
                if ($child -is [System.Windows.Controls.StackPanel] -and $child.Tag) {
                    $dir = $child.Tag
                    $running = Get-AccountStatus $dir
                    $dot = $child.Children[0]
                    $label = $child.Children[1]
                    if ($running) {
                        $dot.Foreground = [System.Windows.Media.Brushes]::LimeGreen
                        $label.Text = "Đang hoạt động"
                        $label.Foreground = [System.Windows.Media.Brushes]::LimeGreen
                    } else {
                        $dot.Foreground = [System.Windows.Media.Brushes]::Gray
                        $label.Text = "Chưa mở"
                        $label.SetResourceReference([System.Windows.Controls.TextBlock]::ForegroundProperty, "TextSec")
                    }
                }
            }
        }
    }
    $Global:TxtVersion.Text = "Phiên bản $Global:Version • $activeCount/$totalCount đang mở"
}

# --- TỰ ĐỘNG LÀM MỚI TRẠNG THÁI MỖI 5 GIÂY ---
$Global:RefreshTimer = New-Object System.Windows.Threading.DispatcherTimer
$Global:RefreshTimer.Interval = [TimeSpan]::FromSeconds(5)
$Global:RefreshTimer.Add_Tick({ Refresh-StatusOnly })
$Global:RefreshTimer.Start()

$Global:window.ShowDialog() | Out-Null
$Global:RefreshTimer.Stop()
