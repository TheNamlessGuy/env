@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION

SET folder=%APPDATA%\vlc\
IF NOT EXIST !folder! (
  ECHO '!folder!' doesn't exist
  SET /p DUMMY=Hit ENTER to acknowledge...
  EXIT /b
)

IF EXIST "%~dp0vlc-qt-interface.ini" (
  COPY "%~dp0vlc-qt-interface.ini" "!folder!vlc-qt-interface.ini"
) ELSE (
  ECHO '%~dp0vlc-qt-interface.ini' could not be found
  SET /p DUMMY=Hit ENTER to acknowledge...
)

IF EXIST "%~dp0vlcrc" (
  COPY "%~dp0vlcrc" "!folder!vlcrc"
) ELSE (
  ECHO '%~dp0vlcrc' could not be found
  SET /p DUMMY=Hit ENTER to acknowledge...
)

SET /p DUMMY=Data files set!