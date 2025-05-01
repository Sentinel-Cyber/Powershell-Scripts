@ECHO OFF
md "C:\temp"
IF EXIST "%PROGRAMFILES(X86)%" (GOTO 64BIT) ELSE (GOTO 32BIT)
:64BIT
%@Try%
curl "https://api.threatlocker.com/updates/installers/threatlockerstubx64.exe" -o "C:\temp\ThreatLockerStub.exe"
%@EndTry%
:@Catch
bitsadmin /transfer mydownloadjob /download /priority normal "https://api.threatlocker.com/updates/installers/threatlockerstubx64.exe" "c:\temp\ThreatLockerStub.exe"
:@EndCatch
GOTO END
:32BIT
%@Try%
curl "https://api.threatlocker.com/updates/installers/threatlockerstubx86.exe" -o "C:\temp\ThreatLockerStub.exe"
%@EndTry%
:@Catch
bitsadmin /transfer mydownloadjob /download /priority normal "https://api.threatlocker.com/updates/installers/threatlockerstubx86.exe" "c:\temp\ThreatLockerStub.exe"
:@EndCatch
GOTO END
:END
C:\temp\ThreatLockerStub.exe uninstall