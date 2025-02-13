@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION

SET installdir=%1
IF "!installdir!"=="" (
  @REM IF EXIST install-dir.txt (
  @REM   SET /p installdir=<install-dir.txt

  @REM   IF NOT EXIST "!installdir!/Code.exe" (
  @REM     ECHO 'install-dir.txt' seems to be corrupt, as '!installdir!' is not a VSCode installation directory
  @REM     SET /p DUMMY=Hit ENTER to acknowledge...
  @REM     EXIT /b
  @REM   )

  @REM ) ELSE (
    SET /p installdir=Installation directory:

    IF NOT EXIST "!installdir!/Code.exe" (
      ECHO '!installdir!' is not a VSCode installation directory
      SET /p DUMMY=Hit ENTER to acknowledge...
      EXIT /b
    )

    ECHO !installdir!>install-dir.txt
  @REM )
)

for /F "tokens=*" %%A IN (extensions.txt) do CALL :INSTALL %%A

SET /p DUMMY=Hit ENTER to acknowledge...

:INSTALL
  IF NOT "%1"=="" (
    !installdir!\bin\code --install-extension %1 --force
  )
  EXIT /b