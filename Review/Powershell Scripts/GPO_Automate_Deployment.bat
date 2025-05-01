@echo off
REM
If EXIST c:\windows\ltsvc\ltsvc.exe GOTO EXIT
GOTO INSTALL

:INSTALL
powershell -Noninteractive -ExecutionPolicy Bypass -Noprofile -file "\\slcdomain.local\netlogon\MgmtAgent_GPO_TokenBased_Installer.ps1"

GOTO EXIT

:EXIT
Exit