@echo off
echo Running System File Checker...
sfc /scannow
echo.

echo Checking Windows image health...
dism /online /cleanup-image /checkhealth
echo.

echo Scanning Windows image...
dism /online /cleanup-image /scanhealth
echo.

if %errorlevel% neq 0 (
    echo Attempting to restore Windows image health...
    dism /online /cleanup-image /restorehealth
    echo.
) else (
    echo No issues detected. Skipping restore health operation.
    echo.
)

echo All scans and repairs completed.
pause
