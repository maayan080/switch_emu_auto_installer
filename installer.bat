@echo off
setlocal enabledelayedexpansion

:: ============================================================
::  YUZU AUTO INSTALLER
::  Repo: https://github.com/maayan080/switch_emu_auto_installer
:: ============================================================

set "REPO_URL=https://raw.githubusercontent.com/maayan080/switch_emu_auto_installer/main"
set "YUZU_DIR=%APPDATA%\yuzu"
set "KEYS_DIR=%APPDATA%\yuzu\keys"
set "FIRMWARE_DIR=%LOCALAPPDATA%\yuzu\nand\system\Contents\registered"
set "TEMP_DIR=%TEMP%\yuzu_install"
set "DESKTOP=%USERPROFILE%\Desktop"

echo.
echo  ================================================
echo          YUZU AUTO INSTALLER
echo  ================================================
echo.

:: Create temp working directory
echo  [1/7] Creating temp folder...
if exist "%TEMP_DIR%" rd /s /q "%TEMP_DIR%"
mkdir "%TEMP_DIR%"

:: Create all required Yuzu directories
echo  [2/7] Preparing Yuzu directories...
mkdir "%YUZU_DIR%"       2>nul
mkdir "%KEYS_DIR%"       2>nul
mkdir "%FIRMWARE_DIR%"   2>nul

:: Download all files
echo  [3/7] Downloading files from GitHub...

echo    ^> yuzu.zip
curl -L --progress-bar -o "%TEMP_DIR%\yuzu.zip" "%REPO_URL%/yuzu.zip"
if errorlevel 1 ( echo. & echo  [ERROR] Failed to download yuzu.zip & echo  Check your internet connection or that the file exists in the repo. & pause & exit /b 1 )

echo    ^> firmware.zip
curl -L --progress-bar -o "%TEMP_DIR%\firmware.zip" "%REPO_URL%/firmware.zip"
if errorlevel 1 ( echo. & echo  [ERROR] Failed to download firmware.zip & pause & exit /b 1 )

echo    ^> prod.keys
curl -L --progress-bar -o "%KEYS_DIR%\prod.keys" "%REPO_URL%/prod.keys"
if errorlevel 1 ( echo. & echo  [ERROR] Failed to download prod.keys & pause & exit /b 1 )

echo    ^> title.keys
curl -L --progress-bar -o "%KEYS_DIR%\title.keys" "%REPO_URL%/title.keys"
if errorlevel 1 ( echo. & echo  [ERROR] Failed to download title.keys & pause & exit /b 1 )

:: Extract Yuzu
echo  [4/7] Extracting Yuzu...
tar -xf "%TEMP_DIR%\yuzu.zip" -C "%YUZU_DIR%"
if errorlevel 1 (
    echo.
    echo  [ERROR] Failed to extract yuzu.zip
    echo  Requires Windows 10 build 17063 or later.
    pause & exit /b 1
)

:: Extract Firmware
echo  [5/7] Installing firmware...
tar -xf "%TEMP_DIR%\firmware.zip" -C "%FIRMWARE_DIR%"
if errorlevel 1 (
    echo.
    echo  [ERROR] Failed to extract firmware.zip
    pause & exit /b 1
)

:: Cleanup
echo  [6/7] Cleaning up...
rd /s /q "%TEMP_DIR%"

:: Create Desktop Shortcut
echo  [7/7] Creating desktop shortcut...

set "YUZU_EXE="
for /r "%YUZU_DIR%" %%f in (yuzu.exe) do (
    if not defined YUZU_EXE set "YUZU_EXE=%%f"
)

if defined YUZU_EXE (
    powershell -NoProfile -Command ^
        "$ws = New-Object -ComObject WScript.Shell;" ^
        "$s = $ws.CreateShortcut('%DESKTOP%\Yuzu.lnk');" ^
        "$s.TargetPath = '%YUZU_EXE%';" ^
        "$s.WorkingDirectory = '%YUZU_DIR%';" ^
        "$s.Description = 'Yuzu Nintendo Switch Emulator';" ^
        "$s.Save()"
    if errorlevel 1 (
        echo  [!] Could not create shortcut, but Yuzu is installed fine.
    ) else (
        echo   Shortcut created on Desktop!
    )
) else (
    echo  [!] yuzu.exe not found - skipping shortcut creation.
    echo      Navigate to %YUZU_DIR% to run Yuzu manually.
)

:: Summary
echo.
echo  ================================================
echo   INSTALLATION COMPLETE!
echo  ================================================
echo.
echo   Yuzu folder : %YUZU_DIR%
echo   Keys folder : %KEYS_DIR%
echo   Firmware    : %FIRMWARE_DIR%
echo.

if defined YUZU_EXE (
    set /p LAUNCH="  Launch Yuzu now? (Y/N): "
    if /i "!LAUNCH!"=="Y" start "" "%YUZU_EXE%"
)

echo.
pause
endlocal