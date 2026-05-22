@ECHO OFF
TITLE rAthena Server Launcher
COLOR 0A

ECHO ============================================
ECHO    rAthena Private Server - Launcher
ECHO ============================================
ECHO.

:: Check if servers exist
IF NOT EXIST login-server.exe (
    ECHO [ERROR] login-server.exe not found!
    PAUSE
    EXIT
)
IF NOT EXIST char-server.exe (
    ECHO [ERROR] char-server.exe not found!
    PAUSE
    EXIT
)
IF NOT EXIST map-server.exe (
    ECHO [ERROR] map-server.exe not found!
    PAUSE
    EXIT
)

ECHO [1] Starting Login Server...
START "Login Server" serv.bat login-server.exe "Login Server" off

ECHO [2] Waiting 5 seconds for Login Server...
PING -n 6 127.0.0.1 > NUL

ECHO [3] Starting Char Server...
START "Char Server" serv.bat char-server.exe "Char Server" off

ECHO [4] Waiting 5 seconds for Char Server...
PING -n 6 127.0.0.1 > NUL

ECHO [5] Starting Map Server...
START "Map Server" serv.bat map-server.exe "Map Server" off

ECHO.
ECHO ============================================
ECHO    All servers started!
ECHO    - Login Server : port 6900
ECHO    - Char Server  : port 6121
ECHO    - Map Server   : port 5121
ECHO ============================================
ECHO.
ECHO Press any key to exit this launcher...
ECHO (Server windows will remain open)
PAUSE > NUL
