# 🧠 ZaloMulti - Lessons Learned & Error Log

This file tracks technical issues encountered during development to avoid repeating them in future updates.

## ❌ XAML Loading Errors
- **Property: `LetterSpacing`**
  - *Issue*: `TextBlock.LetterSpacing` is not a valid property in standard WPF.
  - *Fix*: Remove it. Use standard `Typography` or just font size/margins.
- **StaticResource Order**
  - *Issue*: `StaticResource` references fail if the resource (e.g., `Style`) is defined *after* the element that uses it.
  - *Fix*: Always move `<Window.Resources>` to the very top of the `<Window>` tag.

## ❌ PowerShell GUI Issues
- **`Read-Host` in GUI**
  - *Issue*: `Read-Host` blocks the thread and expects a visible console. If the console is hidden, the app hangs.
  - *Fix*: Use `[Microsoft.VisualBasic.Interaction]::InputBox` for pop-up input.
- **Event Handler Scope**
  - *Issue*: Variables or functions defined in the script scope might not be accessible inside an `Add_Click({...})` scriptblock.
  - *Fix*: Use the `$Global:` or `$Script:` prefix for important functions like `Launch-Account`.

## ❌ Zalo/Electron Specifics
- **Single Instance Lock**
  - *Issue*: Zalo PC detects if another instance is running and redirects to it.
  - *Fix*: Use the **PWA (Chromium App Mode)** approach with `--user-data-dir`. It is 100% reliable compared to "Cloning" the .exe.
- **Dependency Paths**
  - *Issue*: Copying only `Zalo.exe` to a new folder fails because it can't find its DLLs (e.g., `node.dll`).
  - *Fix*: If using the EXE method, keep the renamed EXE in the original Zalo installation folder.

## ❌ System Permissions
- **`mklink` Failures**
  - *Issue*: Creating symbolic links (`mklink`) requires Administrator privileges.
  - *Fix*: Use `Copy-Item` or `PWA Profiles` which do not require elevation.
