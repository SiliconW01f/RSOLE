@echo off

color 0a

net session >nul 2>&1
    if %errorLevel% == 0 (
        goto start
    ) else (
        echo *** Script Requires Admin Permissions ***&timeout /t 5 > nul&goto eof
    )

:start
set host=""
call %~dp0\banner.bat

echo Kill Remote Processes and Reboot Remote Hosts
echo.

set /p host="Enter Hostname or IP Address (Leave Blank to Exit): "
echo.

if %host%=="" (exit&pause)

ping -n 1 %host%|find "Reply from " >nul
if errorlevel 1 echo %host% is not currently accessible&echo.&timeout /t 3 > nul&goto start

choice /c RK /n /t 10 /d R /m "Reboot Remote Host(R) or Kill Remote Process(K)?: "

if "%errorlevel%" == "2" goto kill
if "%errorlevel%" == "1" goto reboot

:reboot

%~dp0/psshutdown.exe -e u:5:19 -f -r -t 0 -accepteula \\%host%

:testping
ping -n 1 %host%|find "Reply from " >nul
if errorlevel 1 echo.&echo %host% has rebooted&echo.&echo %date%-%time%: Host %host% rebooted>> %~dp0\..\RemoteReboots.log&timeout /t 3 > nul&goto start
echo %host% is still up. Retesting in 5 seconds...
timeout /t 5 > nul
goto testping

:kill

wmic /node: %host% os get osarchitecture  | find /i "64" > nul
if errorlevel 1 (set osarchitecture=
) else (
set osarchitecture=64
)

%~dp0/psexec%osarchitecture%.exe -h -nobanner -accepteula "\\%host%" cmd /c "echo. | c:\loki\script_tools\pslist%osarchitecture%.exe -t -accepteula -nobanner"
echo.
set /p pid="Enter PID or Task Name: "
echo.

%~dp0/psexec%osarchitecture%.exe -h -nobanner -accepteula "\\%host%" cmd /c "echo. | c:\loki\script_tools\pskill%osarchitecture%.exe -t -accepteula -nobanner %pid%"

echo %date%-%time%: Task %pid% killed on %host% >> %~dp0\..\KilledTasks.log

timeout /t 3 > nul

goto start