@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION

SET file=%~dp0profiles.reg
IF NOT EXIST "!file!" (
  ECHO '!file!' doesn't exist
  SET /p DUMMY=Hit ENTER to acknowledge...
  EXIT /b
)

%SystemRoot%\System32\reg.exe DELETE HKCU\Software\WinRAR\Profiles /f
%SystemRoot%\System32\reg.exe IMPORT "!file!"

SET /p DUMMY=Profiles imported successfully