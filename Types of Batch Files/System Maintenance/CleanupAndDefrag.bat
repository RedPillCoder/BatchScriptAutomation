@echo off
setlocal

:: Set the drive letter you want to check and optimize
set "drive=C:"

:: Perform Disk Cleanup
echo Running Disk Cleanup on %drive%...
cleanmgr /sagerun:1

:: Check if the drive is SSD or HDD using PowerShell
for /f "delims=" %%I in ('powershell -command "Get-PhysicalDisk | Where-Object { $_.DeviceID -eq '0' } | Select-Object -ExpandProperty MediaType"') do set "mediaType=%%I"

echo Media type of %drive%: %mediaType%

:: Perform Disk Optimization only if the drive is HDD
if /i "%mediaType%"=="HDD" (
    echo Optimizing the disk...
    defrag %drive% /O
) else (
    echo Disk Optimization skipped for SSD.
)

echo Done.
endlocal
pause
