@echo off

echo Testing connectivity of hosts in Host_List_1.txt
echo.

:start
for /F "delims=" %%a in (../host_files/Host_List_1.txt) do (
ping %%a -n 1 | find /i "bytes=" > nul
if errorlevel 1 echo %time% - %%a is down
)
goto start