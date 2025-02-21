@echo off
setlocal enabledelayedexpansion

:: Script Configuration
set "version=1.0"
set "logfile=%userprofile%\Documents\TaskSchedulerManager\logs\task_scheduler_manager.log"
set "backupdir=%userprofile%\Documents\TaskSchedulerManager\backups"
set "configfile=%userprofile%\Documents\TaskSchedulerManager\config.ini"
title Windows Task Scheduler Manager v%version%

:: Initialize
call :init

:menu
call :clear_screen
call :print_header "Windows Task Scheduler Manager v%version%"
echo 1.  Create a new task
echo 2.  List all tasks
echo 3.  Delete a task
echo 4.  Enable/Disable a task
echo 5.  Run a task
echo 6.  Export/Import tasks
echo 7.  View task details
echo 8.  Modify existing task
echo 9.  Search tasks
echo 10. Backup/Restore tasks
echo 11. Task history and logs
echo 12. Configure settings
echo 13. Advanced operations
echo 14. Help
echo 15. Exit
echo.
call :get_input "Enter your choice (1-15)" choice

if "%choice%"=="1" goto create_task
if "%choice%"=="2" goto list_tasks
if "%choice%"=="3" goto delete_task
if "%choice%"=="4" goto toggle_task
if "%choice%"=="5" goto run_task
if "%choice%"=="6" goto export_import_tasks
if "%choice%"=="7" goto view_task
if "%choice%"=="8" goto modify_task
if "%choice%"=="9" goto search_tasks
if "%choice%"=="10" goto backup_restore_tasks
if "%choice%"=="11" goto task_history
if "%choice%"=="12" goto configure_settings
if "%choice%"=="13" goto advanced_operations
if "%choice%"=="14" goto help
if "%choice%"=="15" exit

echo Invalid choice. Please try again.
pause
goto menu

:create_task
call :print_header "Create a New Task"
call :get_input "Enter task name" taskname
call :get_input "Enter schedule (MINUTE, HOURLY, DAILY, WEEKLY, MONTHLY, ONCE, ONSTART, ONLOGON, ONIDLE)" schedule
call :get_input "Enter start time (HH:MM)" time
call :get_input "Enter command to run" command
call :get_input "Run with highest privileges? (Y/N)" elevated
if /i "%elevated%"=="Y" (
    set "elevate=/rl HIGHEST"
) else (
    set "elevate="
)
schtasks /create /tn "%taskname%" /tr "%command%" /sc %schedule% /st %time% %elevate% /f
call :log_operation "Created task: %taskname%"
call :check_error "Task creation"
goto menu

:list_tasks
call :print_header "List All Tasks"
call :get_input "Display format (TABLE/LIST/CSV)" format
schtasks /query /fo %format% /v
pause
goto menu

:delete_task
call :print_header "Delete a Task"
call :get_input "Enter task name to delete" taskname
schtasks /delete /tn "%taskname%" /f
call :log_operation "Deleted task: %taskname%"
call :check_error "Task deletion"
goto menu

:toggle_task
call :print_header "Enable/Disable a Task"
call :get_input "Enter task name" taskname
call :get_input "Enable or Disable? (E/D)" action
if /i "%action%"=="E" (
    schtasks /change /tn "%taskname%" /enable
    call :log_operation "Enabled task: %taskname%"
) else (
    schtasks /change /tn "%taskname%" /disable
    call :log_operation "Disabled task: %taskname%"
)
call :check_error "Task toggle"
goto menu

:run_task
call :print_header "Run a Task"
call :get_input "Enter task name to run" taskname
schtasks /run /tn "%taskname%"
call :log_operation "Ran task: %taskname%"
call :check_error "Task execution"
goto menu

:export_import_tasks
call :print_header "Export/Import Tasks"
call :get_input "Export or Import? (E/I)" action
if /i "%action%"=="E" (
    call :get_input "Enter filename to export tasks (e.g., tasks.xml)" filename
    schtasks /query /xml > "%filename%"
    call :log_operation "Exported tasks to: %filename%"
    call :check_error "Task export"
) else (
    call :get_input "Enter filename to import tasks from" filename
    schtasks /create /xml "%filename%" /tn "ImportedTask"
    call :log_operation "Imported tasks from: %filename%"
    call :check_error "Task import"
)
goto menu

:view_task
call :print_header "View Task Details"
call :get_input "Enter task name to view" taskname
schtasks /query /tn "%taskname%" /fo list /v
pause
goto menu

:modify_task
call :print_header "Modify Existing Task"
call :get_input "Enter task name to modify" taskname
call :get_input "Enter new schedule (leave blank to keep current)" newschedule
call :get_input "Enter new start time (leave blank to keep current)" newtime
call :get_input "Enter new command (leave blank to keep current)" newcommand
call :get_input "Change run level? (Y/N)" changelevel

if not "%newschedule%"=="" (
    schtasks /change /tn "%taskname%" /sc %newschedule%
    call :log_operation "Modified schedule for task: %taskname%"
    call :check_error "Schedule modification"
)
if not "%newtime%"=="" (
    schtasks /change /tn "%taskname%" /st %newtime%
    call :log_operation "Modified start time for task: %taskname%"
    call :check_error "Start time modification"
)
if not "%newcommand%"=="" (
    schtasks /change /tn "%taskname%" /tr "%newcommand%"
    call :log_operation "Modified command for task: %taskname%"
    call :check_error "Command modification"
)
if /i "%changelevel%"=="Y" (
    call :get_input "Run with highest privileges? (Y/N)" elevated
    if /i "%elevated%"=="Y" (
        schtasks /change /tn "%taskname%" /rl HIGHEST
    ) else (
        schtasks /change /tn "%taskname%" /rl LIMITED
    )
    call :log_operation "Modified run level for task: %taskname%"
    call :check_error "Run level modification"
)
goto menu

:search_tasks
call :print_header "Search Tasks"
call :get_input "Enter search term" searchterm
schtasks /query /fo list /v | findstr /i "%searchterm%"
pause
goto menu

:backup_restore_tasks
call :print_header "Backup/Restore Tasks"
call :get_input "Backup or Restore? (B/R)" action
if /i "%action%"=="B" (
    set "backupfile=%backupdir%\tasks_backup_%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%.xml"
    schtasks /query /xml > "%backupfile%"
    call :log_operation "Backed up tasks to: %backupfile%"
    call :check_error "Task backup"
) else (
    call :get_input "Enter restore filename" filename
    schtasks /create /xml "%filename%" /tn "RestoredTasks"
    call :log_operation "Restored tasks from: %filename%"
    call :check_error "Task restore"
)
goto menu

:task_history
call :print_header "Task History and Logs"
call :get_input "Enter task name (leave blank for all tasks)" taskname
if "%taskname%"=="" (
    schtasks /query /fo list /v | findstr "TaskName Last Run Time Next Run Time"
) else (
    schtasks /query /tn "%taskname%" /fo list /v | findstr "TaskName Last Run Time Next Run Time"
)
echo.
echo Log file location: %logfile%
pause
goto menu

:configure_settings
call :print_header "Configure Settings"
echo Current settings:
echo Log file: %logfile%
echo Backup directory: %backupdir%
echo.
call :get_input "Change log file location? (Y/N)" changelog
if /i "%changelog%"=="Y" (
    call :get_input "Enter new log file path" newlogfile
    echo logfile=%newlogfile%> "%configfile%"
    set "logfile=%newlogfile%"
)
call :get_input "Change backup directory? (Y/N)" changebackup
if /i "%changebackup%"=="Y" (
    call :get_input "Enter new backup directory path" newbackupdir
    echo backupdir=%newbackupdir%>> "%configfile%"
    set "backupdir=%newbackupdir%"
)
call :log_operation "Updated configuration settings"
goto menu

:advanced_operations
call :print_header "Advanced Operations"
echo 1. Clean up old log files
echo 2. Compress backups
echo 3. Export all task details to CSV
echo 4. Return to main menu
call :get_input "Enter your choice (1-4)" advchoice

if "%advchoice%"=="1" (
    forfiles /p "%userprofile%\Documents\TaskSchedulerManager\logs" /s /m *.log /d -30 /c "cmd /c del @path"
    call :log_operation "Cleaned up old log files"
)
if "%advchoice%"=="2" (
    powershell Compress-Archive -Path "%backupdir%\*" -DestinationPath "%backupdir%\backups_archive.zip" -Force
    call :log_operation "Compressed backups"
)
if "%advchoice%"=="3" (
    schtasks /query /fo csv /v > "%userprofile%\Documents\TaskSchedulerManager\all_tasks_export.csv"
    call :log_operation "Exported all task details to CSV"
)
if "%advchoice%"=="4" goto menu

call :check_error "Advanced operation"
goto advanced_operations

:help
call :print_header "Help"
type "%~dp0help.txt"
pause
goto menu

:init
if not exist "%userprofile%\Documents\TaskSchedulerManager\logs" mkdir "%userprofile%\Documents\TaskSchedulerManager\logs"
if not exist "%userprofile%\Documents\TaskSchedulerManager\backups" mkdir "%userprofile%\Documents\TaskSchedulerManager\backups"
if exist "%configfile%" (
    for /f "tokens=1,2 delims==" %%a in (%configfile%) do (
        if "%%a"=="logfile" set "logfile=%%b"
        if "%%a"=="backupdir" set "backupdir=%%b"
    )
)
exit /b

:clear_screen
cls
exit /b

:print_header
echo ================================================
echo              %~1
echo ================================================
echo.
exit /b

:get_input
set /p "%~2=%~1: "
exit /b

:check_error
if %errorlevel% equ 0 (
    echo %~1 completed successfully.
) else (
    echo %~1 failed. Error code: %errorlevel%
    call :log_operation "ERROR: %~1 failed with code %errorlevel%"
)
pause
exit /b

:log_operation
echo %date% %time% - %~1 >> "%logfile%"
exit /b
