@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION

SET folder=%APPDATA%\vlc\
IF NOT EXIST !folder! (
  ECHO '!folder!' doesn't exist
  SET /p DUMMY=Hit ENTER to acknowledge...
  EXIT /b
)

IF EXIST "!folder!vlc-qt-interface.ini" (
  COPY "!folder!vlc-qt-interface.ini" "%~dp0vlc-qt-interface.ini"
) ELSE (
  ECHO '!folder!vlc-qt-interface.ini' could not be found
  SET /p DUMMY=Hit ENTER to acknowledge...
)

IF EXIST "!folder!vlcrc" (
  COPY "!folder!vlcrc" "%~dp0vlcrc"
) ELSE (
  ECHO '!folder!vlcrc' could not be found
  SET /p DUMMY=Hit ENTER to acknowledge...
)

SET /p DUMMY=Data files gotten!