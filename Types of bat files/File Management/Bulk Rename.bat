@echo off
setlocal enabledelayedexpansion

:: Prompt user for the directory
set /p "directory=Enter the full path to the directory: "

:: Check if the directory exists
if not exist "%directory%" (
    echo The specified directory does not exist.
    pause
    exit /b
)

:: Prompt user for the old file name pattern
set /p "oldName=Enter the part of the file name to rename (cannot be blank): "

:: Check if oldName is empty
if "%oldName%"=="" (
    echo You must enter a value for the old file name. Exiting script.
    pause
    exit /b
)

:: Prompt user for the new file name
set /p "newName=Enter the new name to use: "

:: Change to the specified directory
cd /d "%directory%"

:: Initialize a counter for renamed files
set "count=0"

:: Loop through all files that match the old name pattern
for %%f in (*%oldName%*) do (
    set "fileName=%%~nf"
    set "fileExt=%%~xf"
    
    :: Construct the new file name
    set "newFileName=!fileName:%oldName%=%newName%!!fileExt!"
    
    :: Confirm renaming
    echo Renaming "%%f" to "!newFileName!"
    set /p "confirm=Do you want to proceed? (Y/N): "
    
    if /i "!confirm!"=="Y" (
        ren "%%f" "!newFileName!"
        set /a count+=1
    ) else (
        echo Skipping "%%f"
    )
)

:: Summary of changes
echo.
echo Renaming complete. Total files renamed: !count!
pause
