@echo off
title ZaloMulti - Dang khoi dong...
chcp 65001 >nul 2>nul

:: Tu dong Unblock file PS1 neu bi Windows chan
powershell -NoProfile -Command "Get-ChildItem -Path '%~dp0' -Recurse | Unblock-File -ErrorAction SilentlyContinue" 2>nul

set "SCRIPT_PATH=%~dp0ZaloMulti.ps1"

:: Kiem tra file PS1 co ton tai khong
if not exist "%SCRIPT_PATH%" (
    echo [LOI] Khong tim thay file ZaloMulti.ps1
    echo Hay dam bao ban da giai nen day du thu muc.
    pause
    exit /b 1
)

:: Chay script
powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "%SCRIPT_PATH%"

:: Neu co loi, hien thong bao
if %errorlevel% neq 0 (
    echo.
    echo [LOI] ZaloMulti gap loi khi khoi dong.
    echo Thu cach sau:
    echo   1. Click phai vao thu muc nay ^> Properties ^> Unblock
    echo   2. Mo PowerShell va chay: Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
    echo.
    pause
)
:: Bản quyền thuộc về truong.it - Tác giả: truong.it
:: Bản quyền thuộc về truong.it - Tác giả: truong.it