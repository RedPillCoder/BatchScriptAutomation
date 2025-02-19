@echo off
setlocal EnableDelayedExpansion

:: ===============================
:: CONFIGURATION VARIABLES - MODIFY THESE BEFORE RUNNING THE SCRIPT
:: ===============================

:: Directory where backups will be stored
set "backupDir=C:\BackupDirectory"

:: Source directory that will be backed up
set "source=C:\Users\YourComputersAccountName\Downloads"

:: Number of days to keep old backup files before deleting them
:: set "maxFileAgeDays=7"

:: Log file path
set "logFile=%backupDir%\backup_log.txt"

:: ===============================
:: END OF CONFIGURATION VARIABLES
:: ===============================

:: Start logging
echo Backup started at %date% %time% > "%logFile%"

:: Check if directories exist and create if necessary
if not exist "%backupDir%" (
    echo Backup directory does not exist. Creating it now.
    mkdir "%backupDir%" 2>nul
    if errorlevel 1 (
        echo Failed to create backup directory. Please check the path and permissions. >> "%logFile%"
        echo Failed to create backup directory. Please check the path and permissions.
        goto :EOF
    )
)

if not exist "%source%" (
    echo Source directory does not exist. Please check the path. >> "%logFile%"
    echo Source directory does not exist. Please check the path.
    goto :EOF
)

:: Other variables
set "tempDir=%backupDir%\temp"
set "dateStamp=%DATE:~-4,4%-%DATE:~-7,2%-%DATE:~-10,2%_%TIME:~0,2%%TIME:~3,2%%TIME:~6,2%"
set "dateStamp=%dateStamp: =0%"
set "zipFile=%backupDir%\Backup_%dateStamp%.zip"

:: Create the temporary directory if it doesn't exist
if not exist "%tempDir%" mkdir "%tempDir%" 2>nul

:: Copy all files from the source directory to the temporary directory
echo Copying files...
robocopy "%source%" "%tempDir%" /MIR /NDL /NJH /NJS /NC /NS /NP
if errorlevel 8 (
    echo Error occurred during file copy. Exiting script. >> "%logFile%"
    echo Error occurred during file copy. Exiting script.
    goto :EOF
)

:: Compress the temporary directory into a ZIP file
echo Creating ZIP archive...
powershell -command "& {Add-Type -A 'System.IO.Compression.FileSystem'; [IO.Compression.ZipFile]::CreateFromDirectory('%tempDir%', '%zipFile%');}"
if errorlevel 1 (
    echo Error occurred during compression. Exiting script. >> "%logFile%"
    echo Error occurred during compression. Exiting script.
    goto :EOF
)

:: Delete the temporary directory after compression
echo Cleaning up temporary files...
rmdir /S /Q "%tempDir%"

:: Delete old backup files that are older than the specified number of days
echo Removing old backups...
:: forfiles /P "%backupDir%" /M *.zip /D -%maxFileAgeDays% /C "cmd /C del @path" 2>nul

:: Calculate and display backup size
for %%I in ("%zipFile%") do set "size=%%~zI"
set /a "sizeMB=%size% / (1024 * 1024)"
echo Backup size: %sizeMB% MB

:: Log completion and size
echo Backup completed successfully at %date% %time%. Size: %sizeMB% MB >> "%logFile%"
echo Backup completed successfully. Size: %sizeMB% MB

:: Display contents of the ZIP file
echo.
echo Contents of the backup:
powershell -command "& {Add-Type -A 'System.IO.Compression.FileSystem'; $zip = [IO.Compression.ZipFile]::OpenRead('%zipFile%'); $zip.Entries | ForEach-Object { $_.FullName }; $zip.Dispose()}"

pause

endlocal
