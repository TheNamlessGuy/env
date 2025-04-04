@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION

SET installdir=%1
IF "!installdir!"=="" (
  IF EXIST install-dir.txt (
    SET /p installdir=<install-dir.txt

    IF NOT EXIST "!installdir!/VSCodium.exe" (
      ECHO 'install-dir.txt' seems to be corrupt, as '!installdir!' is not a VSCode installation directory
      SET /p DUMMY=Hit ENTER to acknowledge...
      EXIT /b
    )

  ) ELSE (
    SET /p installdir=Installation directory:

    IF NOT EXIST "!installdir!/VSCodium.exe" (
      ECHO '!installdir!' is not a VSCode installation directory
      SET /p DUMMY=Hit ENTER to acknowledge...
      EXIT /b
    )

    ECHO !installdir!>install-dir.txt
  )
)

SET code=!installdir:\=\\!VSCodium.exe

ECHO Windows Registry Editor Version 5.00>open-with-code.reg
ECHO.>> open-with-code.reg
ECHO ; Open files>> open-with-code.reg
ECHO [HKEY_CLASSES_ROOT\*\shell\Open folder in VSCode]>> open-with-code.reg
ECHO @="Open folder in VSCode">> open-with-code.reg
ECHO "Icon"="!code!,0">> open-with-code.reg
ECHO [HKEY_CLASSES_ROOT\*\shell\Open folder in VSCode\command]>> open-with-code.reg
ECHO @="\"!code!\" \"%%1/../\"">> open-with-code.reg
ECHO.>> open-with-code.reg
ECHO ; Open folder>> open-with-code.reg
ECHO [HKEY_CLASSES_ROOT\Directory\shell\Open folder in VSCode]>> open-with-code.reg
ECHO @="Open folder in VSCode">> open-with-code.reg
ECHO "Icon"="\"!code!\",0">> open-with-code.reg
ECHO [HKEY_CLASSES_ROOT\Directory\shell\Open folder in VSCode\command]>> open-with-code.reg
ECHO @="\"!code!\" \"%%1\"">> open-with-code.reg
ECHO.>> open-with-code.reg
ECHO ; Open current folder>> open-with-code.reg
ECHO [HKEY_CLASSES_ROOT\Directory\Background\shell\Open folder in VSCode]>> open-with-code.reg
ECHO @="Open folder in VSCode">> open-with-code.reg
ECHO "Icon"="\"!code!\",0">> open-with-code.reg
ECHO [HKEY_CLASSES_ROOT\Directory\Background\shell\Open folder in VSCode\command]>> open-with-code.reg
ECHO @="\"!code!\" \"%%V\"">> open-with-code.reg