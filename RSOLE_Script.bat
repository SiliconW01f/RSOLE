@echo off

setlocal EnableExtensions EnableDelayedExpansion

color 0a

for /f "delims=:" %%a in (%~dp0\LogStore.conf) do (
set /a c+=1
set x[!c!]=%%a
)
set x > nul
set logs="%x[1]%"

call %~dp0\script_tools\banner.bat

:checkadmin

net session >nul 2>&1
    if %errorLevel% == 0 (
        goto checkinternet
    ) else (
        echo *** Script Requires Admin Permissions ***&timeout /t 5 > nul&goto eof
    )

:checkinternet

ping 8.8.8.8 -n 1 | find /i "bytes=" > nul
if errorlevel 1 goto start

choice /c YN /n /t 10 /d N /m "Update Loki Signatures? (Y/N): "

if "%errorlevel%" == "2" goto start
if "%errorlevel%" == "1" %~dp0/loki\loki-upgrader.exe

:start

echo.
choice /c PF /n /t 10 /d P /m "Process Only(P) or Full(F) Scan?: "

if "%errorlevel%" == "2" set scantype=Full
if "%errorlevel%" == "1" set scantype=Proc_Only

echo.

choice /c S12345U /n /t 10 /d U /m "Single Host(S), Host List (1,2,3,4,5)?: 

if "%errorlevel%" == "7" set host=localhost&goto unattended
if "%errorlevel%" == "6" set hosts=%~dp0/host_files/Host_List_5.txt&goto multiplehosts
if "%errorlevel%" == "5" set hosts=%~dp0/host_files/Host_List_4.txt&goto multiplehosts
if "%errorlevel%" == "4" set hosts=%~dp0/host_files/Host_List_3.txt&goto multiplehosts
if "%errorlevel%" == "3" set hosts=%~dp0/host_files/Host_List_2.txt&goto multiplehosts
if "%errorlevel%" == "2" set hosts=%~dp0/host_files/Host_List_1.txt&goto multiplehosts
if "%errorlevel%" == "1" goto singlehost

:singlehost

echo.

set /p host=Enter the IP address or hostname: 

ping -n 1 %host%|find "Reply from " >nul
if errorlevel 1 echo.&echo %host% is not currently accessible&echo.&timeout /t 3 > nul&goto start

:unattended

set time0=%TIME: =0%
set hour=%time0:~0,2%
set minute=%time0:~3,2%
set second=%time0:~6,2%
set millisecond=%time0:~9,2%

set UID=%hour%%minute%%second%%millisecond%

wmic /node: %host% os get osarchitecture  | find /i "64" > nul
if errorlevel 1 (set osarchitecture=
) else (
set osarchitecture=64
)

xcopy /e /y /i /d "%~dp0\loki" "\\%host%\c$\loki"
start %~dp0/script_tools/psexec%osarchitecture%.exe -h -nobanner -accepteula "\\%host%" cmd /c "echo. | c:\loki\host_script.bat %scantype% %uid% %osarchitecture%"
call %~dp0\script_tools\banner.bat
echo Wating for Data collect to complete on %host%

:datacollect
timeout /t 5 > nul
xcopy /y "\\%host%\c$\loki\datacollect-%uid%.txt" "%~dp0\tmp" 2>nul >nul

if exist "%~dp0\tmp\datacollect-%uid%.txt" (start /max notepad "%~dp0\tmp\datacollect-%uid%.txt"
) else (
goto datacollect
)

:txlogs
call %~dp0\script_tools\banner.bat
echo Wating for Loki Scan to complete on %host%
timeout /t 5 > nul
xcopy /y "\\%host%\c$\loki\scancomplete-%uid%.tmp" "%~dp0\tmp" 2>nul >nul
if exist "%~dp0\tmp\scancomplete-%uid%.tmp" (xcopy /y /i /d "\\%host%\c$\loki\logs" %logs%
) else (
goto txlogs
)

del /q "%~dp0\tmp\scancomplete-%uid%.tmp"

goto killreboot

:multiplehosts

for /F "delims=" %%a in (%hosts%) do (

set time0=!TIME: =0!
set hour=!time0:~0,2!
set minute=!time0:~3,2!
set second=!time0:~6,2!
set millisecond=!time0:~9,2!

set UID=!hour!!minute!!second!!millisecond!
xcopy /e /y /i /d "%~dp0\loki" "\\%%a\c$\loki"

wmic /node: %%a os get osarchitecture  | find /i "64" > nul
if errorlevel 1 (set osarchitecture=
) else (
set osarchitecture=64
)

start %~dp0/script_tools/psexec!osarchitecture!.exe -h -nobanner -accepteula "\\%%a" cmd /c "echo. | c:\loki\host_script.bat !scantype! !uid! !osarchitecture!"
call %~dp0\script_tools\banner.bat
echo Wating for Data collect to complete on %%a
call :datacollect-multi %%a !uid!
del /q "%~dp0\tmp\scancomplete-!uid!.tmp"

)

goto killreboot

:datacollect-multi

timeout /t 5 > nul
xcopy /y "\\%1\c$\loki\datacollect-%2.txt" "%~dp0\tmp" 2>nul >nul
call %~dp0\script_tools\banner.bat
echo Waiting for Loki Scan to complete on %1
if exist "%~dp0\tmp\datacollect-%2.txt" (start /max notepad "%~dp0\tmp\datacollect-%uid%.txt"
) else (
goto datacollect-multi
)

:txlogs-multi
timeout /t 5 > nul
xcopy /y "\\%1\c$\loki\scancomplete-%2.tmp" "%~dp0\tmp" 2>nul >nul
if exist "%~dp0\tmp\scancomplete-%2.tmp" (call %~dp0\script_tools\banner.bat&echo Transferring log files to repository&xcopy /y /i /d "\\%1\c$\loki\logs" %logs% 2>nul >nul
) else (
goto txlogs-multi
)

goto eof 2>nul


:killreboot

call %~dp0\script_tools\banner.bat

choice /c YN /n /t 10 /d N /m "Open Kill Process and Reboot Remote Host Subroutine? (Y/N): "

if "%errorlevel%" == "2" exit
if "%errorlevel%" == "1" call %~dp0\script_tools\Reboot_Kill.bat