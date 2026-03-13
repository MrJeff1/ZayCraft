@echo off
title ZayCraft Legends Launcher

echo ========================================
echo ZayCraft Legends Launcher
echo ========================================

:: Change to the directory where this batch file is located
cd /d "%~dp0"

echo Current directory: %CD%
echo.

:: Check if main.lua exists
if not exist "main.lua" (
    echo ERROR: main.lua not found in current directory!
    echo Please make sure this batch file is in the same directory as your game files.
    pause
    exit /b 1
)

:: Find love executable
set LOVE_PATH=
for %%p in (love.exe love2d.exe) do (
    where %%p >nul 2>nul
    if not errorlevel 1 set LOVE_PATH=%%p
)

if "%LOVE_PATH%"=="" (
    if exist "C:\Program Files\LOVE\love.exe" (
        set LOVE_PATH="C:\Program Files\LOVE\love.exe"
    ) else if exist "C:\Program Files (x86)\LOVE\love.exe" (
        set LOVE_PATH="C:\Program Files (x86)\LOVE\love.exe"
    ) else (
        echo ERROR: Love2D executable not found!
        echo Please install Love2D from: https://love2d.org
        pause
        exit /b 1
    )
)

echo Found Love2D: %LOVE_PATH%
echo.

:: Check for debug flag
set DEBUG_FLAG=
if "%1"=="--debug" set DEBUG_FLAG=--console
if "%1"=="-d" set DEBUG_FLAG=--console

echo Starting ZayCraft Legends...
echo.

:: Run the game
%LOVE_PATH% . %DEBUG_FLAG%

:: Check exit code
if errorlevel 1 (
    echo.
    echo Game exited with error code %errorlevel%
    echo.
    echo Troubleshooting tips:
    echo   1. Make sure you have Love2D 11.4 or later installed
    echo   2. Try running with --debug flag for more information
    echo   3. Check if all game files are present in: %CD%
    pause
    exit /b %errorlevel%
)

echo.
echo Game closed successfully.
pause