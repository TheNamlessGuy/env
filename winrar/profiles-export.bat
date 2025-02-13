@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION

SET file=%~dp0profiles.reg
IF EXIST "!file!" (
  DEL "!file!"
)

%SystemRoot%\System32\reg.exe EXPORT HKCU\Software\WinRAR\Profiles "!file!"

SET /p DUMMY=Profiles exported to "!file!"