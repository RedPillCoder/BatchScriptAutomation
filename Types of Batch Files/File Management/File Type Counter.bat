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

:: Initialize a variable to hold the counts
set "fileCount="

:: Count files by type
for /f "delims=" %%e in ('dir "%source%\*" /b /s ^| findstr /r "\.[^\.]*$"') do (
    set "ext=%%~xe"
    set /a count[!ext!]+=1
)

:: Display the results in the console
echo File Type Counts in %source%:
echo.

for /f "tokens=1 delims=:" %%a in ('set count[') do (
    echo %%a: !count[%%a]!
)

echo.
echo File type count completed.
pause
