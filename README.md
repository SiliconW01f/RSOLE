1. Download latest release from https://github.com/Neo23x0/Loki/releases
2. Unzip into the loki directory
3. Download the Sysinternals files from https://docs.microsoft.com/en-us/sysinternals/downloads/pstools
4. Copy the tools detailed below to the folders detailed below 
5. Modify \LogStore.conf to point to a location for storing logs (can be local or a read-write share)
6. Populate the \Host_files\Host_List files as required
7. Run \RSOLE_Script.bat as Administrator
8. Update Loki signatures on the first run

Additional Files:

\script_tools

PsExec.exe
PsExec64.exe
psshutdown.exe

\loki\script_tools\

autorunsc.exe
autorunsc64.exe
pskill.exe
pskill64.exe
pslist.exe
pslist64.exe
psloglist.exe
PsService.exe
PsService64.exe
Tcpvcon.exe
