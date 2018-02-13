# ---Real-time Scanning Over Local Ethernet---

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

PsExec.exe<br />
PsExec64.exe<br />
psshutdown.exe<br />

\loki\script_tools\

autorunsc.exe<br />
autorunsc64.exe<br />
pskill.exe<br />
pskill64.exe<br />
pslist.exe<br />
pslist64.exe<br />
psloglist.exe<br />
PsService.exe<br />
PsService64.exe<br />
Tcpvcon.exe
