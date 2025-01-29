@echo off
sfc /scannow
pause
dism /online /cleanup-image /checkhealth
pause
dism /online /cleanup-image /scanhealth
pause
dism /online /cleanup-image /restorehealth
