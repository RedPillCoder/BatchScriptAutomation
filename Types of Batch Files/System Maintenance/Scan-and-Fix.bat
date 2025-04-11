@echo off
:: Check for admin rights
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Please run as Administrator!
    pause
    exit /b
)

echo Running System File Checker...
sfc /scannow
echo.

echo Checking Windows image health...
dism /online /cleanup-image /checkhealth
echo.

echo Scanning Windows image...
dism /online /cleanup-image /scanhealth
echo.

:: Always attempt restore regardless of scan error code
echo Attempting to restore Windows image health...
dism /online /cleanup-image /restorehealth
echo.

echo All operations completed.
pause
