@echo off
title ZaloMulti Pro Launcher
where pwsh >nul 2>nul
if %errorlevel% equ 0 (
    pwsh -ExecutionPolicy Bypass -File "C:\Users\truongit\ZaloMulti\ZaloMulti.ps1"
) else (
    powershell -ExecutionPolicy Bypass -File "C:\Users\truongit\ZaloMulti\ZaloMulti.ps1"
)
exit
