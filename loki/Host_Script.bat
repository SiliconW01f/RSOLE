@echo off

set utc-offset=0

set date1stchar=%date:~0,1%

if %date1stchar%==0 goto dateformatuk
if %date1stchar%==1 goto dateformatuk
if %date1stchar%==2 goto dateformatuk
if %date1stchar%==3 goto dateformatuk

set year=%date:~12,2%
set month-num=%date:~4,2%
set day=%date:~7,2%

goto setdtg

:dateformatuk

set year=%date:~8,2%
set month-num=%date:~3,2%
set day=%date:~0,2%

:setdtg

set time0=%TIME: =0%
set hour=%time0:~0,2%
set minute=%time0:~3,2%

if %month-num%==01 set month=JAN
if %month-num%==02 set month=FEB
if %month-num%==03 set month=MAR
if %month-num%==04 set month=APR
if %month-num%==05 set month=MAY
if %month-num%==06 set month=JUN
if %month-num%==07 set month=JUL
if %month-num%==08 set month=AUG
if %month-num%==09 set month=SEP
if %month-num%==10 set month=OCT
if %month-num%==11 set month=NOV
if %month-num%==12 set month=DEC

set logname=%day%%hour%%minute%Z%month%%year%-%~1-%computername%.log

del /q "%~dp0\scancomplete-*.tmp" 2>nul >nul

echo 1. IPConfig >> "%~dp0\datacollect-%~2.tmp"
echo 2. PSLogList >> "%~dp0\datacollect-%~2.tmp"
echo 3. PSList%3 >> "%~dp0\datacollect-%~2.tmp"
echo 4. AutoRuns%3 >> "%~dp0\datacollect-%~2.tmp"
echo 5. PsService%3 >> "%~dp0\datacollect-%~2.tmp"
echo 6. TCPView >> "%~dp0\datacollect-%~2.tmp"

echo. >> "%~dp0\datacollect-%2.tmp"
echo -----1. IPConfig----- >> "%~dp0\datacollect-%~2.tmp"
echo. >> "%~dp0\datacollect-%2.tmp"

ipconfig | findstr /R /C:"IPv4 Address" >> "%~dp0\datacollect-%2.tmp"
ipconfig | findstr /R /C:"IP Address" >> "%~dp0\datacollect-%2.tmp"

echo. >> "%~dp0\datacollect-%2.tmp"
echo -----2. PSLogList----- >> "%~dp0\datacollect-%2.tmp"
echo. >> "%~dp0\datacollect-%2.tmp"
%~dp0\script_tools\psloglist -accepteula -h 3 -i 4697,7045 >> "%~dp0\datacollect-%2.tmp"

echo. >> "%~dp0\datacollect-%2.tmp"
echo -----3. PSList%3----- >> "%~dp0\datacollect-%2.tmp"
echo. >> "%~dp0\datacollect-%2.tmp"
%~dp0\script_tools\pslist%3 -t -accepteula -nobanner >> "%~dp0\datacollect-%2.tmp"

echo. >> "%~dp0\datacollect-%2.tmp"
echo -----4. AutoRuns%3----- >> "%~dp0\datacollect-%2.tmp"
echo. >> "%~dp0\datacollect-%2.tmp"
%~dp0\script_tools\autorunsc%3.exe -nobanner -accepteula > "%~dp0\autorunsc-%2.tmp"
type "%~dp0\autorunsc-%2.tmp" >> "%~dp0\datacollect-%2.tmp"
del /q "%~dp0\autorunsc-%2.tmp"

echo. >> "%~dp0\datacollect-%2.tmp"
echo -----5. PsService%3----- >> "%~dp0\datacollect-%2.tmp"
echo. >> "%~dp0\datacollect-%2.tmp"
%~dp0\script_tools\PsService%3.exe query -s active -accepteula >> "%~dp0\datacollect-%2.tmp"

echo. >> "%~dp0\datacollect-%2.tmp"
echo -----6. TCPView----- >> "%~dp0\datacollect-%2.tmp"
echo. >> "%~dp0\datacollect-%2.tmp"
%~dp0\script_tools\tcpvcon.exe -n -a -accepteula >> "%~dp0\datacollect-%2.tmp"

type "%~dp0\datacollect-%2.tmp" > "%~dp0\datacollect-%2.txt"

del /q "%~dp0\datacollect-%2.tmp"

if "%~1"=="Full" "%~dp0\loki.exe" --onlyrelevant --dontwait --intense --noindicator -l "%~dp0\logs\%logname%"
if "%~1"=="Proc_Only" "%~dp0\loki.exe" --onlyrelevant --dontwait --nofilescan --noindicator -l "%~dp0\logs\%logname%"

echo. >> "%~dp0\logs\%logname%"
echo -----Data Collection----- >> "%~dp0\logs\%logname%"

type "%~dp0\datacollect-%2.txt" >> "%~dp0\logs\%logname%"

del /q "%~dp0\datacollect-%2.txt"

echo. > "%~dp0\scancomplete-%2.tmp"