@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION

SET folder=%APPDATA%\vlc\
IF NOT EXIST !folder! (
  ECHO '!folder!' doesn't exist
  SET /p DUMMY=Hit ENTER to acknowledge...
  EXIT /b
)

IF EXIST "!folder!\vlc-qt-interface.ini" (
  ECHO '!folder!\vlc-qt-interface.ini' already exists
  SET /p DUMMY=Hit ENTER to acknowledge...
  EXIT /b
)

IF EXIST "!folder!\vlcrc" (
  ECHO '!folder!\vlcrc' already exists
  SET /p DUMMY=Hit ENTER to acknowledge...
  EXIT /b
)

SET file=%~dp0vlc-qt-interface.ini
MKLINK "!folder!\vlc-qt-interface.ini" "!file!"
IF NOT !errorLevel!==0 (
  SET /p DUMMY=Failed to symlink 'vlc-qt-interface.ini'. See error message above
  EXIT /b
)

SET file=%~dp0vlcrc
MKLINK "!folder!\vlcrc" "!file!"
IF NOT !errorLevel!==0 (
  SET /p DUMMY=Failed to symlink 'vlcrc'. See error message above
  EXIT /b
)

SET /p DUMMY=Symlinked data successfully