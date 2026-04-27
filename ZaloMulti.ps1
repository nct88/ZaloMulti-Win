# ============================================================
# ZALỎMULTI - PHIÊN BẢN HOÀN THIỆN
# BẢN QUYỀN TRUONG.IT
# ============================================================

Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

# Hide Terminal Window logic
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

# Global Configuration
$Global:AppPath = $PSScriptRoot
$Global:ZaloPath = "C:\Users\$($env:USERNAME)\AppData\Local\Programs\Zalo\Zalo.exe"
$Global:ProfileRoot = "C:\Zalo_Clone_Profiles"
$Global:IconFolder = Join-Path $Global:AppPath "Assets"
$Global:FontPath = "file:///$($Global:AppPath.Replace('\','/'))/Assets/#Pin-Sans-Regular"

if (-not (Test-Path $Global:ProfileRoot)) { 
    New-Item -ItemType Directory -Path $Global:ProfileRoot -Force | Out-Null
}

# Load & Patch XAML (Dynamic Font Path for Portability)
$xamlRaw = Get-Content (Join-Path $Global:AppPath "ZaloMulti.xaml") -Raw
$xamlRaw = $xamlRaw.Replace("file:///C:/Users/truongit/ZaloMulti/Assets/#Pin-Sans-Regular", $Global:FontPath)

[xml]$xamlContent = $xamlRaw
$reader = New-Object System.Xml.XmlNodeReader $xamlContent
$Global:window = [Windows.Markup.XamlReader]::Load($reader)

# UI Elements Mapping
$Global:BtnAdd = $Global:window.FindName("BtnAdd")
$Global:BtnKillAll = $Global:window.FindName("BtnKillAll")
$Global:InstanceGrid = $Global:window.FindName("InstanceGrid")
$Global:BtnClose = $Global:window.FindName("BtnClose")
$Global:BtnLight = $Global:window.FindName("BtnLight")
$Global:BtnDark = $Global:window.FindName("BtnDark")
$Global:ImgLogo = $Global:window.FindName("ImgLogo")
$Global:ImgFB = $Global:window.FindName("ImgFB")
$Global:ImgTG = $Global:window.FindName("ImgTG")
$Global:ImgGH = $Global:window.FindName("ImgGH")
$Global:ImgWS = $Global:window.FindName("ImgWS")
$Global:TxtVersion = $Global:window.FindName("TxtVersion")
$Global:MainScroll = $Global:window.FindName("MainScroll")
$Global:BtnToTop = $Global:window.FindName("BtnToTop")

# Helper: Bitmap Loader
function Get-ZaloBitmap {
    param($filename)
    $path = Join-Path $Global:IconFolder $filename
    if (Test-Path $path) {
        return New-Object System.Windows.Media.Imaging.BitmapImage(New-Object Uri($path))
    }
    return $null
}

# Initialize Images
$Global:ImgLogo.Source = Get-ZaloBitmap "zalo.png"
$Global:ImgFB.Source = Get-ZaloBitmap "facebook.png"
$Global:ImgTG.Source = Get-ZaloBitmap "telegram.png"
$Global:ImgGH.Source = Get-ZaloBitmap "github.png"
$Global:ImgWS.Source = Get-ZaloBitmap "website.png"

# Helper: Update Brush Resource
function Set-GlobalBrush {
    param($key, $hex)
    try {
        $brush = [System.Windows.Media.BrushConverter]::new().ConvertFromString($hex)
        $Global:window.Resources[$key] = $brush
    } catch { }
}

# Helper: Theme Switcher
function Set-AppTheme {
    param($mode)
    try {
        if ($mode -eq "Dark") {
            Set-GlobalBrush "BgDark" "#0A0A0A"
            Set-GlobalBrush "BgSidebar" "#18191A"
            Set-GlobalBrush "BgCard" "#242526"
            Set-GlobalBrush "BgToggle" "#3A3B3C"
            Set-GlobalBrush "BorderBrush" "#3E4042"
            Set-GlobalBrush "TextMain" "#E4E6EB"
            Set-GlobalBrush "TextSec" "#B0B3B8"
            $Global:BtnDark.Background = $Global:window.Resources["BgToggle"]
            $Global:BtnDark.BorderBrush = $Global:window.Resources["AccentBlue"]
            $Global:BtnDark.BorderThickness = 1
            $Global:BtnLight.Background = [System.Windows.Media.Brushes]::Transparent
            $Global:BtnLight.BorderThickness = 0
        } else {
            Set-GlobalBrush "BgDark" "#F0F2F5"
            Set-GlobalBrush "BgSidebar" "#FFFFFF"
            Set-GlobalBrush "BgCard" "#FFFFFF"
            Set-GlobalBrush "BgToggle" "#E4E6EB"
            Set-GlobalBrush "BorderBrush" "#CED0D4"
            Set-GlobalBrush "TextMain" "#050505"
            Set-GlobalBrush "TextSec" "#65676B"
            $Global:BtnLight.Background = $Global:window.Resources["BgToggle"]
            $Global:BtnLight.BorderBrush = $Global:window.Resources["AccentBlue"]
            $Global:BtnLight.BorderThickness = 1
            $Global:BtnDark.Background = [System.Windows.Media.Brushes]::Transparent
            $Global:BtnDark.BorderThickness = 0
        }
    } catch { }
}

# Helper: Update Accent Color
function Update-AppAccent {
    param($hex)
    try {
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

# Helper: Desktop Shortcut
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

# Helper: Zalo Launcher
function Start-ZaloInstance {
    param($name)
    $profilePath = Join-Path $Global:ProfileRoot $name
    $roamingPath = Join-Path $profilePath "AppData\Roaming"
    $localPath = Join-Path $profilePath "AppData\Local"
    
    if (-not (Test-Path $roamingPath)) { New-Item -ItemType Directory -Path $roamingPath -Force | Out-Null }
    if (-not (Test-Path $localPath)) { New-Item -ItemType Directory -Path $localPath -Force | Out-Null }

    $processInfo = New-Object System.Diagnostics.ProcessStartInfo
    $processInfo.FileName = $Global:ZaloPath
    $processInfo.UseShellExecute = $false
    $processInfo.EnvironmentVariables["USERPROFILE"] = $profilePath
    $processInfo.EnvironmentVariables["APPDATA"] = $roamingPath
    $processInfo.EnvironmentVariables["LOCALAPPDATA"] = $localPath
    [System.Diagnostics.Process]::Start($processInfo) | Out-Null
}

# Main UI Refresh
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
        if (Test-Path $phonePath) { $currentPhone = (Get-Content $phonePath -Raw).Trim() }

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
            $res = [System.Windows.MessageBox]::Show("Bạn có chắc chắn muốn xóa tài khoản '$targetName'?", "Xác nhận xóa", [System.Windows.MessageBoxButton]::YesNo, [System.Windows.MessageBoxImage]::Warning)
            if ($res -eq "Yes") {
                $delPath = Join-Path $Global:ProfileRoot $targetName
                if (Test-Path $delPath) {
                    Remove-Item -Path $delPath -Recurse -Force | Out-Null
                    Update-AppUIList
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
            $val | Set-Content $path -Force | Out-Null
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

# Events Handlers
$Global:BtnLight.Add_Click({ Set-AppTheme "Light" })
$Global:BtnDark.Add_Click({ Set-AppTheme "Dark" })
Update-AppAccent "#74B9FF"

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

# CLI Argument Handler
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

# Run Application
Update-AppUIList
$Global:window.ShowDialog() | Out-Null
