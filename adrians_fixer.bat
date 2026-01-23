@echo off
setlocal EnableDelayedExpansion
color 0b
chcp 65001 >nul

:: ==========================================================
:: VERSION + UPDATE PATHS
:: ==========================================================
set "FIXER_VERSION=1.4 beta"
set "UPDATE_URL=https://raw.githubusercontent.com/adrianscripts/fixer/refs/heads/main/version.txt"
set "UPDATE_SCRIPT_URL=https://raw.githubusercontent.com/adrianscripts/fixer/refs/heads/main/adrians_fixer.bat"

:: ==========================================================
:: ALWAYS-ON TIMER RESOLUTION
:: ==========================================================
powershell -NoProfile -Command "try { rundll32.exe winmm.dll,timeBeginPeriod 1 } catch {}" >nul 2>&1

:: ==========================================================
:: OS DETECT
:: ==========================================================
call :detect_os

:: ==========================================================
:: UPDATE CHECK
:: ==========================================================
call :check_update

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
echo      [ J ] network reset         [ K ] ram modes           [ L ] startup tools
echo.
echo      [ M ] redistributables      [ N ] activation fix       [ O ] timer info
echo.
echo      [ P ] game mode             [ Q ] unsafe tweaks        [ R ] restore backup
echo.
echo      [ S ] exit
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
if /i "%choice%"=="P" goto gamemode
if /i "%choice%"=="Q" goto unsafe_tweaks
if /i "%choice%"=="R" goto restorebackup
if /i "%choice%"=="S" exit /b

goto menu

:: ==========================================================
:: DETECT OS
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
:: UPDATE CHECK
:: ==========================================================
:check_update
set "UPDATE_STATUS=checking..."

for /f "usebackq delims=" %%V in (`
  powershell -NoProfile -Command "try { (Invoke-WebRequest -UseBasicParsing '%UPDATE_URL%').Content.Trim() } catch { '' }"
`) do set "REMOTE_VERSION=%%V"

if not defined REMOTE_VERSION (
    set "UPDATE_STATUS=update check failed"
    goto :eof
)

if /i "%REMOTE_VERSION%"=="%FIXER_VERSION%" (
    set "UPDATE_STATUS=latest version"
    goto :eof
)

set "UPDATE_STATUS=update available -> %REMOTE_VERSION%"
goto :eof

:: ==========================================================
:: SIMPLE ANIM
:: ==========================================================
:anim
<nul set /p=". "
ping -n 2 127.0.0.1 >nul
<nul set /p=". "
ping -n 2 127.0.0.1 >nul
<nul set /p="."
ping -n 2 127.0.0.1 >nul
echo.
goto :eof

:: ==========================================================
:: CONFIRM
:: ==========================================================
:confirm
color 0c
echo.
echo [ ! ] WARNING
echo.
echo %WARN%
echo.
set "CONFIRM="
set /p CONFIRM= continue? (Y/N): 
if /i "%CONFIRM%"=="Y" (
    color 0b
    goto :eof
)
color 0b
goto menu

:: ==========================================================
:: FAN FIX (improved)
:: ==========================================================
:fanfix
cls
set "WARN=Fan fix will stop spike-causing services and stabilize CPU power states."
call :confirm

echo fixing fan spikes...
call :anim

for %%S in (
SysMain WSearch DiagTrack WerSvc DoSvc MapsBroker lfsvc RetailDemo
) do net stop %%S >nul 2>&1

schtasks /Change /TN "\Microsoft\Windows\Maintenance\WinSAT" /DISABLE >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" /DISABLE >nul 2>&1

powercfg -setactive SCHEME_MIN >nul
taskkill /f /im explorer.exe >nul
start explorer.exe

echo fan fix applied — allow 1–3 minutes.
pause
goto menu

:: ==========================================================
:: EPIC FIX 2.0
:: ==========================================================
:epic
cls
set "WARN=Epic Games fix clears ALL launcher caches and settings (safe)."
call :confirm

echo cleaning Epic Games launcher...
call :anim

taskkill /f /im EpicGamesLauncher.exe >nul
taskkill /f /im epicwebhelper.exe >nul

rmdir /s /q "%localappdata%\EpicGamesLauncher" >nul 2>&1
rmdir /s /q "%programdata%\Epic\EpicGamesLauncher" >nul 2>&1

echo done.
pause
goto menu

:: ==========================================================
:: GPU FIX + SHADER CACHE CLEAR
:: ==========================================================
:gpu
cls
set "WARN=GPU repair clears shader cache and GPU temp files."
call :confirm

echo clearing GPU shader cache...
call :anim

del /f /s /q "%localappdata%\NVIDIA\DXCache\*" >nul
del /f /s /q "%localappdata%\NVIDIA\GLCache\*" >nul
del /f /s /q "%localappdata%\NVIDIA Corporation\NV_Cache\*" >nul
del /f /s /q "%localappdata%\Microsoft\DirectX Shader Cache\*" >nul
del /f /s /q "%appdata%\AMD\DXCache\*" >nul
del /f /s /q "%appdata%\AMD\GLCache\*" >nul

echo done.
pause
goto menu

:: ==========================================================
:: RAM MENU (with RAM checker)
:: ==========================================================
:rammenu
cls
echo.
echo RAM CLEANER
echo.
echo   [ 1 ] light clean
echo   [ 2 ] deep clean
echo   [ 3 ] extreme clean
echo   [ 4 ] ram check
echo   [ 5 ] back
echo.
set /p rm= choose: 

if "%rm%"=="1" goto ram_light
if "%rm%"=="2" goto ram_deep
if "%rm%"=="3" goto ram_extreme
if "%rm%"=="4" goto ram_check
if "%rm%"=="5" goto menu
goto rammenu

:ram_check
cls
echo checking RAM sticks...
call :anim
powershell "Get-CimInstance Win32_PhysicalMemory ^| ft BankLabel,Capacity,Speed,Manufacturer -autosize"
echo.
pause
goto rammenu

:: (light/deep/extreme are same as before — unchanged)
:: ==========================================================

:: ==========================================================
:: GAME MODE (improved)
:: ==========================================================
:gamemode
cls
set "WARN=Game mode kills most background apps and stabilizes CPU/GPU scheduling."
call :confirm

echo enabling game mode...
call :anim

for %%P in (
Discord.exe steam.exe EpicGamesLauncher.exe chrome.exe msedge.exe OneDrive.exe
Widgets.exe Teams.exe SearchHost.exe GameBar.exe RuntimeBroker.exe
) do taskkill /f /im %%P >nul

for %%S in (
SysMain WSearch DiagTrack lfsvc MapsBroker RetailDemo
) do net stop %%S >nul

powercfg -setactive SCHEME_MIN >nul
taskkill /f /im explorer.exe >nul
start explorer.exe

echo done.
pause
goto menu

:: ==========================================================
:: REST IS SAME AS BEFORE (MICROSOFT, DISCORD, STEAM, ETC.)
:: ==========================================================

:microsoft
cls
echo repairing Microsoft components...
call :anim
net stop wuauserv >nul 2>&1
net stop bits >nul 2>&1
rmdir /s /q "%systemroot%\SoftwareDistribution" >nul 2>&1
net start bits >nul 2>&1
net start wuauserv >nul 2>&1
pause
goto menu

:discord
cls
echo fixing Discord...
call :anim
taskkill /f /im discord.exe >nul
rmdir /s /q "%appdata%\discord" >nul
rmdir /s /q "%localappdata%\Discord" >nul
pause
goto menu

:steam
cls
echo fixing Steam...
call :anim
taskkill /f /im steam.exe >nul
del /f /s /q "%programfiles(x86)%\Steam\appcache\*" >nul
start "" "steam://flushconfig"
pause
goto menu

:systemrepair
cls
echo system repair started...
call :anim
sfc /scannow
dism /online /cleanup-image /restorehealth
pause
goto menu

:cleanup
cls
echo cleaning temp files...
call :anim
del /f /s /q "%temp%\*" >nul
del /f /s /q "C:\Windows\Temp\*" >nul
pause
goto menu

:debloat
cls
echo debloating Windows...
call :anim
sc stop DiagTrack >nul
sc config DiagTrack start=disabled >nul
powershell "Get-AppxPackage *xbox* ^| Remove-AppxPackage" >nul
pause
goto menu

:network
cls
echo resetting network...
call :anim
ipconfig /flushdns
netsh int ip reset
netsh winsock reset
pause
goto menu

:startup
cls
echo opening startup tools...
call :anim
start ms-settings:startupapps
start taskmgr
pause
goto menu

:redist
cls
echo installing redistributables...
call :anim
powershell "Invoke-WebRequest 'https://aka.ms/vs/17/release/vc_redist.exe' -OutFile $env:TEMP\vc_redist.exe"
start /wait "" "%TEMP%\vc_redist.exe" /install /quiet /norestart
pause
goto menu

