@echo off
setlocal enabledelayedexpansion

:: Set the source folder to the Downloads folder
set "source=C:\Users\%USERNAME%\Downloads"

:: Check if the source folder exists
if not exist "%source%" (
    echo The source folder does not exist: %source%
    pause
    exit /b
)

:: Change to the source directory
cd /d "%source%"

:: Organize files by type
for %%f in (*.*) do (
    set "ext=%%~xf"
    :: Remove the leading dot from the file extension
    set "ext=!ext:~1!"
    
    :: Check if the extension is not empty
    if not "!ext!"=="" (
        :: Create the subfolder for the file type if it doesn't exist
        mkdir "!ext!" 2>nul
        :: Move the file to the appropriate subfolder
        move "%%f" "!ext!\" >nul
    )
)

echo Downloads organized by file type.
pause
