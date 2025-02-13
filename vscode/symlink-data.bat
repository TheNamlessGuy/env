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

IF EXIST "%installdir%\data" (
  ECHO A data folder already exists in '%installdir%'. Remove it to continue
  SET /p DUMMY=Hit ENTER to acknowledge...
  EXIT /b
)

SET actual=%~dp0data
MKLINK /D "%installdir%\data" "%actual%"
IF %errorLevel%==0 (
  SET /p DUMMY=Symlinked data folder successfully
) ELSE (
  SET /p DUMMY=Failed to symlink data folder. See error message above
)