@echo off
echo Resetting network settings...

ipconfig /release
ipconfig /renew
ipconfig /flushdns
netsh winsock reset
netsh int ip reset

echo Network settings have been reset. Please restart your computer.
pause
