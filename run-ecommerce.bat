@echo off
setlocal
title E-Commerce launcher
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0run-ecommerce.ps1"
if errorlevel 1 (
  echo.
  echo E-Commerce could not be started. Read the message above, then press any key to close.
  pause >nul
)
endlocal
