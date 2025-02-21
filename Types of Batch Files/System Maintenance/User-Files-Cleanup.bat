@echo off
setlocal

:: Create or clear the log file
set "logFile=%USERPROFILE%\cleanup_log.txt"
echo Cleanup Log - %DATE% %TIME% > "%logFile%"
echo ----------------------------------- >> "%logFile%"

:: Prompt for directories to clean
set /p dirs="Enter directories to clean (separated by spaces, or press Enter for default): "
if "%dirs%"=="" (
    set "dirs=%USERPROFILE%\Downloads %USERPROFILE%\Desktop %USERPROFILE%\Documents %USERPROFILE%\Pictures %USERPROFILE%\Music %USERPROFILE%\Videos"
)

:: Prompt for file types to delete
set /p fileTypes="Enter file types to delete (e.g., *.txt, *.jpg, or press Enter for all files): "
if "%fileTypes%"=="" (
    set "fileTypes=*.*"
)

:: Display directories and file types to be cleaned
echo The following directories will be cleaned:
echo %dirs%
echo The following file types will be deleted:
echo %fileTypes%
echo.

:: Confirmation prompt
set /p confirm="Are you sure you want to delete these files? (Y/N): "
if /i not "%confirm%"=="Y" (
    echo Cleanup canceled.
    exit /b
)

:: Dry run option
set /p dryRun="Do you want to perform a dry run (no files will be deleted)? (Y/N): "
set "isDryRun=0"
if /i "%dryRun%"=="Y" (
    set "isDryRun=1"
)

:: Loop through each directory and delete files
for %%D in (%dirs%) do (
    echo Deleting files in %%D...
    for %%F in ("%%D\%fileTypes%") do (
        echo Deleting: %%F >> "%logFile%"
        if "%isDryRun%"=="0" (
            del /q "%%F" 2>> "%logFile%"
        ) else (
            echo [DRY RUN] Would delete: %%F
        )
    )
)

echo Cleanup completed. Check the log file at %logFile% for details.
pause
