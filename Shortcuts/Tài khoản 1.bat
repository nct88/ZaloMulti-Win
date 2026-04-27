@echo off
start "" powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File "
    param($name, $index)
    try {
        $desktopPath = [Environment]::GetFolderPath("Desktop")
        $ShortcutPath = Join-Path $desktopPath "$name.lnk"
        $batFolder = Join-Path $Global:AppPath "Shortcuts"
        if (-not (Test-Path $batFolder)) { New-Item -ItemType Directory -Path $batFolder -Force | Out-Null }
        $batPath = Join-Path $batFolder "$name.bat"
        
        $batContent = "@echo off`nstart `"`" powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$($MyInvocation.MyCommand.Definition)`" -LaunchInstance `"$name`""
        $batContent | Set-Content $batPath -Force -Encoding ASCII

        $WshShell = New-Object -ComObject WScript.Shell
        $Shortcut = $WshShell.CreateShortcut($ShortcutPath)
        $Shortcut.TargetPath = "cmd.exe"
        $Shortcut.Arguments = "/c `"$batPath`""
        $Shortcut.WindowStyle = 7
        
        if (Test-Path $Global:IconFolder) {
            $icons = Get-ChildItem $Global:IconFolder -Filter *.ico | Sort-Object Name
            if ($icons.Count -gt 0) { $Shortcut.IconLocation = $icons[$index % $icons.Count].FullName }
        }
        $Shortcut.Save()
        [System.Windows.MessageBox]::Show("?? t?o l?i t?t cho '$name' ngo?i Desktop.")
    } catch {
        [System.Windows.MessageBox]::Show("L?i khi t?o shortcut: $($_.Exception.Message)")
    }
" -LaunchInstance "T?i kho?n 1"
