@echo off
setlocal

:: Check if any addresses were provided as arguments
if "%~1"=="" (
    echo No addresses provided. Using default addresses: 8.8.8.8 and 1.1.1.1
    set ADDRESSES=8.8.8.8 1.1.1.1
) else (
    set ADDRESSES=%*
)

:: Display header
echo Network Connectivity Check - %date% %time%
echo ----------------------------------------

:: Loop through each address and ping
for %%A in (%ADDRESSES%) do (
    echo Pinging %%A...
    ping -n 4 %%A >nul
    if errorlevel 1 (
        echo Ping to %%A failed.
    ) else (
        echo Ping to %%A successful.
    )
    echo.
)

:: End of script
echo Connectivity check completed.
endlocal
pause
