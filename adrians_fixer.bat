@echo off
title adrian's fixer
color 0b
setlocal EnableDelayedExpansion

:: ==========================================================
:: VERSION + UPDATE PATHS
:: ==========================================================
set "FIXER_VERSION=1.3 stable"
set "UPDATE_URL=https://raw.githubusercontent.com/adrianscripts/fixer/refs/heads/main/version.txt"
set "UPDATE_SCRIPT_URL=https://raw.githubusercontent.com/adrianscripts/fixer/refs/heads/main/adrians_fixer.bat"

:: ==========================================================
:: ADMIN CHECK
:: ==========================================================
>nul 2>&1 net session
if %errorlevel% neq 0 (
    powershell -NoProfile -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

chcp 65001 >nul

:: ==========================================================
:: OS DETECTION (WIN 10 vs WIN 11)
:: ==========================================================
call :detect_os

:: ==========================================================
:: ALWAYS-ON TIMER RESOLUTION
:: ==========================================================
powershell -NoProfile -Command "try { rundll32.exe winmm.dll,timeBeginPeriod 1 } catch {}" >nul 2>&1

:: ==========================================================
:: UPDATE CHECK
:: ==========================================================
call :check_update

:: ==========================================================
:: MAIN MENU
:: ==========================================================
:menu
cls
echo.
echo  ╔══════════════════════════════════════════════════════════════════╗
echo  ║                          ADRIAN'S FIXER                          ║
echo  ║                           version %FIXER_VERSION%                       ║
echo  ║                     %OS_NAME%                     ║
echo  ║                        status: %UPDATE_STATUS%║
echo  ╚══════════════════════════════════════════════════════════════════╝
echo.

echo      [ A ] microsoft fix         [ B ] discord fix          [ C ] fan fix
echo.
echo      [ D ] steam fix             [ E ] epic fix             [ F ] gpu repair
echo.
echo      [ G ] system repair         [ H ] cleanup              [ I ] debloat
echo.
echo      [ J ] network reset         [ K ] ram modes            [ L ] startup tools
echo.
echo      [ M ] redistributables      [ N ] activation fix       [ O ] timer info
echo.

if "%OS_MAJOR%"=="11" (
    echo      [ P ] win11 interface reset    (available)
) else (
    echo      [ P ] win11 interface reset    (disabled on win10)
)
echo.

echo      [ Q ] game mode             [ R ] restore backup        [ S ] exit
echo.

set /p choice= choose an option: 
set "choice=%choice:~0,1%"

if /i "%choice%"=="A" goto microsoft
if /i "%choice%"=="B" goto discord
if /i "%choice%"=="C" goto fanfix
if /i "%choice%"=="D" goto steam
if /i "%choice%"=="E" goto epic
if /i "%choice%"=="F" goto gpu
if /i "%choice%"=="G" goto systemrepair
if /i "%choice%"=="H" goto cleanup
if /i "%choice%"=="I" goto debloat
if /i "%choice%"=="J" goto network
if /i "%choice%"=="K" goto rammenu
if /i "%choice%"=="L" goto startup
if /i "%choice%"=="M" goto redist
if /i "%choice%"=="N" goto activation
if /i "%choice%"=="O" goto timerinfo
if /i "%choice%"=="P" goto win11reset
if /i "%choice%"=="Q" goto gamemode
if /i "%choice%"=="R" goto restorebackup
if /i "%choice%"=="S" exit /b
goto menu


:: ==========================================================
:: OS DETECTION
:: ==========================================================
:detect_os
set "OS_BUILD="
for /f "tokens=3" %%B in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v CurrentBuildNumber ^| find "REG_"') do set "OS_BUILD=%%B"
if not defined OS_BUILD (
    set "OS_NAME=Windows (unknown build)"
    set "OS_MAJOR=?"
    goto :eof
)

set /a OS_BUILD_NUM=%OS_BUILD%
if %OS_BUILD_NUM% GEQ 22000 (
    set "OS_MAJOR=11"
    set "OS_NAME=Windows 11 build %OS_BUILD%"
) else (
    set "OS_MAJOR=10"
    set "OS_NAME=Windows 10 build %OS_BUILD%"
)
goto :eof


:: ==========================================================
:: UPDATE CHECK + DOWNGRADE PROTECTION
:: ==========================================================
:check_update
set "REMOTE_VERSION="

for /f "usebackq delims=" %%V in (`
  powershell -NoProfile -Command "try { (Invoke-WebRequest -UseBasicParsing '%UPDATE_URL%').Content.Trim() } catch { '' }"
`) do set "REMOTE_VERSION=%%V"

if not defined REMOTE_VERSION (
    set "UPDATE_STATUS=update check failed     "
    goto :eof
)

if /i "%REMOTE_VERSION%"=="%FIXER_VERSION%" (
    set "UPDATE_STATUS=latest version          "
    goto :eof
)

set "UPDATE_STATUS=update available -> %REMOTE_VERSION%"
call :auto_update
goto :eof


:: ==========================================================
:: AUTO UPDATE
:: ==========================================================
:auto_update
set "NEW_FILE=%TEMP%\adrians_fixer_new.bat"

powershell -NoProfile -Command ^
"try { Invoke-WebRequest '%UPDATE_SCRIPT_URL%' -OutFile '%NEW_FILE%' -UseBasicParsing } catch {}" >nul 2>&1

if not exist "%NEW_FILE%" (
    set "UPDATE_STATUS=update failed           "
    goto :eof
)

set "SCRIPT_PATH=%~f0"
set "BACKUP_FILE=%~dp0adrians_fixer_backup.bat"
set "UPDATER=%TEMP%\af_updater.bat"

(
echo @echo off
echo copy /y "%SCRIPT_PATH%" "%BACKUP_FILE%" ^>nul
echo copy /y "%NEW_FILE%" "%SCRIPT_PATH%" ^>nul
echo start "" "%SCRIPT_PATH%"
echo exit
) > "%UPDATER%"

start "" "%UPDATER%"
exit /b


:: ==========================================================
:: SIMPLE ANIM
:: ==========================================================
:anim
<nul set /p="..."
ping -n 2 127.0.0.1 >nul
echo.
goto :eof


:: ==========================================================
:: CONFIRMATION SYSTEM
:: ==========================================================
:confirm
color 0c
echo.
echo are you sure you want to continue?
echo this action may change system behavior.
echo it cannot be undone automatically.
echo.
set "CONFIRM="
set /p CONFIRM= continue? (Y/N): 
color 0b
if /i "%CONFIRM%"=="Y" goto :eof
set "CONFIRM=N"
goto :eof


:: ==========================================================
:: RESTORE BACKUP
:: ==========================================================
:restorebackup
cls
call :confirm
if /i "%CONFIRM%" NEQ "Y" goto menu

set "BACKUP_FILE=%~dp0adrians_fixer_backup.bat"
if not exist "%BACKUP_FILE%" (
    echo no backup available.
    pause
    goto menu
)

copy /y "%BACKUP_FILE%" "%~f0" >nul
echo backup restored.
echo restarting...
start "" "%~f0"
exit /b


:: ==========================================================
:: WIN 11 ONLY FEATURE
:: ==========================================================
:win11reset
cls

if "%OS_MAJOR%"=="10" (
    color 08
    echo this feature only works on windows 11.
    echo.
    echo continue anyway? (Y/N)
    set /p xx=
    color 0b
    if /i "!xx!" NEQ "Y" goto menu
)

call :confirm
if /i "%CONFIRM%" NEQ "Y" goto menu

echo resetting win11 shell / interface...
call :anim

taskkill /f /im explorer.exe >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /f >nul 2>&1
start explorer.exe

echo done.
pause
goto menu


:: ==========================================================
:: RAM MENU
:: ==========================================================
:rammenu
cls
echo.
echo RAM CLEANER
echo.
echo   [ 1 ] light clean
echo   [ 2 ] deep clean
echo   [ 3 ] extreme clean
echo   [ 4 ] back
echo.
set /p rm= choose: 

if "%rm%"=="1" goto ram_light
if "%rm%"=="2" goto ram_deep
if "%rm%"=="3" goto ram_extreme
goto menu


:ram_light
cls
call :confirm
if /i "%CONFIRM%" NEQ "Y" goto rammenu

taskkill /f /im Discord.exe >nul 2>&1
taskkill /f /im steam.exe >nul 2>&1
taskkill /f /im EpicGamesLauncher.exe >nul 2>&1
del /f /s /q "%temp%\*" >nul 2>&1
echo done.
pause
goto rammenu


:ram_deep
cls
call :confirm
if /i "%CONFIRM%" NEQ "Y" goto rammenu

taskkill /f /im Discord.exe >nul 2>&1
taskkill /f /im steam.exe >nul 2>&1
taskkill /f /im chrome.exe >nul 2>&1
taskkill /f /im EpicGamesLauncher.exe >nul 2>&1
net stop SysMain >nul 2>&1
net stop WSearch >nul 2>&1
taskkill /f /im explorer.exe >nul 2>&1
del /f /s /q "%temp%\*" >nul 2>&1
start explorer.exe
echo done.
pause
goto rammenu


:ram_extreme
cls
call :confirm
if /i "%CONFIRM%" NEQ "Y" goto rammenu

for %%P in (
Discord.exe steam.exe EpicGamesLauncher.exe chrome.exe Widgets.exe
Teams.exe OneDrive.exe msedge.exe SearchApp.exe SearchHost.exe
RuntimeBroker.exe GameBar.exe RobloxPlayerBeta.exe
) do taskkill /f /im %%P >nul 2>&1

for %%S in (
SysMain WSearch DiagTrack lfsvc MapsBroker DoSvc RetailDemo
) do net stop %%S >nul 2>&1

taskkill /f /im explorer.exe >nul 2>&1
del /f /s /q "%temp%\*" >nul 2>&1
start explorer.exe
echo done.
pause
goto rammenu


:: ==========================================================
:: FAN FIX
:: ==========================================================
:fanfix
cls
call :confirm
if /i "%CONFIRM%" NEQ "Y" goto menu

for %%S in (
SysMain DiagTrack lfsvc MapsBroker RetailDemo WSearch
) do net stop %%S >nul 2>&1

schtasks /Change /TN "\Microsoft\Windows\Maintenance\WinSAT" /DISABLE >nul 2>&1
taskkill /f /im explorer.exe >nul 2>&1
start explorer.exe
echo applied.
pause
goto menu


:: ==========================================================
:: ACTIVATION FIX
:: ==========================================================
:activation
cls
call :confirm
if /i "%CONFIRM%" NEQ "Y" goto menu

net stop sppsvc >nul 2>&1
cscript /nologo "%SystemRoot%\System32\slmgr.vbs" /rilc
cscript /nologo "%SystemRoot%\System32\slmgr.vbs" /upk
cscript /nologo "%SystemRoot%\System32\slmgr.vbs" /cpky
net start sppsvc >nul 2>&1
echo done.
pause
goto menu


:: ==========================================================
:: TIMER INFO
:: ==========================================================
:timerinfo
cls
echo timer resolution active (1ms)
echo improves input latency + frame pacing
echo.
pause
goto menu


:: ==========================================================
:: GAME MODE
:: ==========================================================
:gamemode
cls
call :confirm
if /i "%CONFIRM%" NEQ "Y" goto menu

for %%P in (
Discord.exe steam.exe EpicGamesLauncher.exe chrome.exe Widgets.exe
GameBar.exe Teams.exe SearchHost.exe RuntimeBroker.exe
) do taskkill /f /im %%P >nul 2>&1

net stop SysMain >nul 2>&1
net stop WSearch >nul 2>&1
powercfg -setactive SCHEME_MIN >nul 2>&1
ipconfig /flushdns >nul 2>&1
netsh winsock reset >nul 2>&1
echo done.
pause
goto menu


:: ==========================================================
:: MICROSOFT FIX
:: ==========================================================
:microsoft
cls
call :confirm
if /i "%CONFIRM%" NEQ "Y" goto menu

net stop wuauserv >nul 2>&1
net stop bits >nul 2>&1
rmdir /s /q "%systemroot%\SoftwareDistribution" >nul 2>&1
net start wuauserv >nul 2>&1
net start bits >nul 2>&1
echo done.
pause
goto menu


:: ==========================================================
:: DISCORD FIX
:: ==========================================================
:discord
cls
echo this will delete discord data.
echo you will need to log in again.
echo.
call :confirm
if /i "%CONFIRM%" NEQ "Y" goto menu

taskkill /f /im discord.exe >nul 2>&1
rmdir /s /q "%appdata%\discord" >nul 2>&1
rmdir /s /q "%localappdata%\Discord" >nul 2>&1
echo reinstalling...
powershell -NoProfile -Command "Invoke-WebRequest 'https://discord.com/api/download?platform=win' -OutFile $env:TEMP\discord.exe" >nul 2>&1
start "" "%TEMP%\discord.exe"
pause
goto menu


:: ==========================================================
:: STEAM FIX
:: ==========================================================
:steam
cls
call :confirm
if /i "%CONFIRM%" NEQ "Y" goto menu

taskkill /f /im steam.exe >nul 2>&1
start "" "steam://flushconfig"
pause
goto menu


:: ==========================================================
:: EPIC FIX
:: ==========================================================
:epic
cls
call :confirm
if /i "%CONFIRM%" NEQ "Y" goto menu

taskkill /f /im EpicGamesLauncher.exe >nul 2>&1
rmdir /s /q "%localappdata%\EpicGamesLauncher\Saved\webcache" >nul 2>&1
echo done.
pause
goto menu


:: ==========================================================
:: GPU FIX
:: ==========================================================
:gpu
cls
call :confirm
if /i "%CONFIRM%" NEQ "Y" goto menu

rmdir /s /q "%localappdata%\NVIDIA" >nul 2>&1
rmdir /s /q "%localappdata%\AMD"    >nul 2>&1
echo driver cleanup done.
pause
goto menu


:: ==========================================================
:: SYSTEM REPAIR
:: ==========================================================
:systemrepair
cls
call :confirm
if /i "%CONFIRM%" NEQ "Y" goto menu

sfc /scannow
dism /online /cleanup-image /restorehealth
pause
goto menu


:: ==========================================================
:: CLEANUP
:: ==========================================================
:cleanup
cls
call :confirm
if /i "%CONFIRM%" NEQ "Y" goto menu

del /f /s /q "%temp%\*" >nul 2>&1
del /f /s /q "C:\Windows\Temp\*" >nul 2>&1
pause
goto menu


:: ==========================================================
:: DEBLOAT
:: ==========================================================
:debloat
cls
call :confirm
if /i "%CONFIRM%" NEQ "Y" goto menu

sc stop DiagTrack >nul 2>&1
sc config DiagTrack start=disabled >nul 2>&1
powershell -NoProfile -Command "Get-AppxPackage *xbox* ^| Remove-AppxPackage" >nul 2>&1
pause
goto menu


:: ==========================================================
:: NETWORK RESET
:: ==========================================================
:network
cls
call :confirm
if /i "%CONFIRM%" NEQ "Y" goto menu

ipconfig /flushdns >nul
netsh int ip reset >nul
netsh winsock reset >nul
pause
goto menu


:: ==========================================================
:: STARTUP TOOLS
:: ==========================================================
:startup
cls
call :confirm
if /i "%CONFIRM%" NEQ "Y" goto menu

start "" ms-settings:startupapps
start "" taskmgr
pause
goto menu


:: ==========================================================
:: REDISTS
:: ==========================================================
:redist
cls
call :confirm
if /i "%CONFIRM%" NEQ "Y" goto menu

powershell -NoProfile -Command "Invoke-WebRequest 'https://aka.ms/vs/17/release/vc_redist.exe' -OutFile $env:TEMP\vc_redist.exe" >nul 2>&1
start /wait "" "%TEMP%\vc_redist.exe" /install /quiet /norestart
pause
goto menu

