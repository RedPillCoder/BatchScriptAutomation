@echo off
title System Resource Monitoring
echo ================================
echo      System Resource Monitoring
echo ================================
echo.

:: Display CPU usage
echo CPU Usage:
echo -------------------------------
powershell -command "Get-CimInstance Win32_Processor | Select-Object -Property Name, NumberOfCores, NumberOfLogicalProcessors, LoadPercentage | Format-Table -AutoSize"
echo.

:: Display Memory usage
echo Memory Usage:
echo -------------------------------
for /f "tokens=1,2,3,4 delims=," %%a in ('powershell -command "Get-CimInstance Win32_OperatingSystem | Select-Object TotalVisibleMemorySize, FreePhysicalMemory, TotalVirtualMemorySize, FreeVirtualMemory | ConvertTo-Csv -NoTypeInformation"') do (
    set /a TotalVisibleMemoryGB=%%a / 1024 / 1024
    set /a FreePhysicalMemoryGB=%%b / 1024 / 1024
    set /a TotalVirtualMemoryGB=%%c / 1024 / 1024
    set /a FreeVirtualMemoryGB=%%d / 1024 / 1024
)
setlocal enabledelayedexpansion
echo Total Physical Memory: !TotalVisibleMemoryGB! GB
echo Free Physical Memory: !FreePhysicalMemoryGB! GB
echo Total Virtual Memory: !TotalVirtualMemoryGB! GB
echo Free Virtual Memory: !FreeVirtualMemoryGB! GB
endlocal
echo.

:: Display Disk usage
echo Disk Usage:
echo -------------------------------
echo Device ID    Volume Name    Free Space (GB)    Total Size (GB)    Drive Type
echo -------------------------------------------------------------------------------
powershell -command "Get-CimInstance Win32_LogicalDisk | Select-Object DeviceID, VolumeName, @{Name='FreeSpace(GB)';Expression={[math]::round($_.FreeSpace/1GB,2)}}, @{Name='Size(GB)';Expression={[math]::round($_.Size/1GB,2)}}, @{Name='DriveType';Expression={switch($_.DriveType){0{'Unknown'};1{'No Root Dir'};2{'Removable Disk'};3{'Local Disk'};4{'Network Drive'};5{'Compact Disc'};6{'RAM Disk'}}}} | Format-Table -AutoSize"
echo.

pause
