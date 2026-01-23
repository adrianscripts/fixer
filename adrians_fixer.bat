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
set "UPDATE_STATUS=checking..."

:: ==========================================================
:: ALWAYS-ON TIMER RESOLUTION (simple, safe)
:: ==========================================================
powershell -NoProfile -Command "try { rundll32.exe winmm.dll,timeBeginPeriod 1 } catch {}" >nul 2>&1

:: ==========================================================
:: OS DETECT + UPDATE CHECK
:: ==========================================================
call :detect_os
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
echo  ║                     %OS_NAME%                                    ║
echo  ║                        status: %UPDATE_STATUS%                   ║
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
:: OS DETECTION
:: ==========================================================
:detect_os
set "OS_BUILD="
for /f "tokens=3" %%B in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v CurrentBuildNumber ^| find "REG_"') do (
    set "OS_BUILD=%%B"
)
if not defined OS_BUILD (
    set "OS_NAME=Windows (unknown build)           "
    set "OS_MAJOR=?"
    goto :eof
)

set /a OS_BUILD_NUM=%OS_BUILD%
if %OS_BUILD_NUM% GEQ 22000 (
    set "OS_MAJOR=11"
    set "OS_NAME=Windows 11 build %OS_BUILD%      "
) else (
    set "OS_MAJOR=10"
    set "OS_NAME=Windows 10 build %OS_BUILD%      "
)
goto :eof


:: ==========================================================
:: UPDATE CHECK (NO AUTO UPDATE, JUST STATUS)
:: ==========================================================
:check_update
set "REMOTE_VERSION="
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

set "UPDATE_STATUS=update available: %REMOTE_VERSION%"
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
:: CONFIRMATION SYSTEM
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
:: RESTORE BACKUP (SCRIPT SELF RESTORE — OPTIONAL)
:: ==========================================================
:restorebackup
cls
set "WARN=This will try to restore a previous backup of adrian's fixer from adrians_fixer_backup.bat and overwrite this script."
call :confirm

echo restoring previous backup (if present)...
call :anim
set "BACKUP_FILE=%~dp0adrians_fixer_backup.bat"
if not exist "%BACKUP_FILE%" (
    echo no backup file found: %BACKUP_FILE%
    pause
    goto menu
)

copy /y "%BACKUP_FILE%" "%~f0" >nul
echo backup restored. restarting...
start "" "%~f0"
exit /b



:: ==========================================================
:: UNSAFE TWEAKS (AGGRESSIVE)
:: ==========================================================
:unsafe_tweaks
cls
set "WARN=Unsafe tweaks apply aggressive registry / service / power changes. They can break features or require reinstall to fully undo."
call :confirm

echo applying unsafe tweaks...
call :anim

:: disable telemetry-style services
for %%S in (
DiagTrack dmwappushservice RetailDemo lfsvc WSearch SysMain WbioSrvc
) do (
    sc stop "%%S" >nul 2>&1
    sc config "%%S" start=disabled >nul 2>&1
)

:: high performance plan
powercfg -setactive SCHEME_MIN >nul 2>&1

:: visual effects -> performance
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v VisualFXSetting /t REG_DWORD /d 2 /f >nul 2>&1

:: scheduler / network tweaks
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v SystemResponsiveness /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /t REG_DWORD /d 8 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Priority" /t REG_DWORD /d 6 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v NetworkThrottlingIndex /t REG_DWORD /d 4294967295 /f >nul 2>&1

:: disable some telemetry tasks
schtasks /Change /TN "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" /DISABLE >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /DISABLE >nul 2>&1

echo unsafe tweaks applied. reboot recommended.
pause
goto menu



:: ==========================================================
:: RAM MENU (WITH RAM CHECK)
:: ==========================================================
:rammenu
cls
echo.
echo RAM CLEANER
echo.
echo   [ 1 ] light clean
echo   [ 2 ] deep clean
echo   [ 3 ] extreme clean
echo   [ 4 ] ram check (sticks info)
echo   [ 5 ] back
echo.
set /p rm= choose: 

if "%rm%"=="1" goto ram_light
if "%rm%"=="2" goto ram_deep
if "%rm%"=="3" goto ram_extreme
if "%rm%"=="4" goto ram_check
if "%rm%"=="5" goto menu
goto rammenu


:ram_light
cls
set "WARN=Light RAM clean closes Discord/Steam/Epic and clears temp."
call :confirm

echo running light ram clean...
call :anim
taskkill /f /im Discord.exe >nul 2>&1
taskkill /f /im steam.exe >nul 2>&1
taskkill /f /im EpicGamesLauncher.exe >nul 2>&1
del /f /s /q "%temp%\*" >nul 2>&1
echo done.
pause
goto rammenu


:ram_deep
cls
set "WARN=Deep RAM clean closes browsers/launchers, stops SysMain/WSearch, restarts explorer."
call :confirm

echo deep cleaning ram...
call :anim
taskkill /f /im Discord.exe >nul 2>&1
taskkill /f /im steam.exe >nul 2>&1
taskkill /f /im EpicGamesLauncher.exe >nul 2>&1
taskkill /f /im OneDrive.exe >nul 2>&1
taskkill /f /im chrome.exe >nul 2>&1
taskkill /f /im msedge.exe >nul 2>&1

for %%S in (SysMain WSearch) do net stop %%S >nul 2>&1

del /f /s /q "%temp%\*" >nul 2>&1
taskkill /f /im explorer.exe >nul 2>&1
start explorer.exe
echo done.
pause
goto rammenu


:ram_extreme
cls
set "WARN=Extreme RAM clean kills many background apps/services. Some live features pause until reboot."
call :confirm

echo extreme ram clean...
call :anim
for %%P in (
Discord.exe steam.exe EpicGamesLauncher.exe Widgets.exe
OneDrive.exe chrome.exe msedge.exe SearchApp.exe SearchHost.exe
Teams.exe XboxApp.exe RuntimeBroker.exe GameBar.exe
) do taskkill /f /im %%P >nul 2>&1

for %%S in (
SysMain WSearch DiagTrack WerSvc MapsBroker lfsvc RetailDemo DoSvc
) do net stop %%S >nul 2>&1

del /f /s /q "%temp%\*" >nul 2>&1

taskkill /f /im explorer.exe >nul 2>&1
start explorer.exe

echo done.
pause
goto rammenu


:ram_check
cls
echo checking RAM sticks...
call :anim
powershell "Get-CimInstance Win32_PhysicalMemory ^| ft BankLabel,Capacity,Speed,Manufacturer,PartNumber -autosize"
echo.
echo if a stick is installed but not listed, bios/windows is not seeing it.
echo.
pause
goto rammenu



:: ==========================================================
:: FAN FIX
:: ==========================================================
:fanfix
cls
set "WARN=Fan fix stops spike-prone services and disables some maintenance tasks. Indexing/telemetry may be reduced."
call :confirm

echo fixing fan spikes...
call :anim

for %%S in (
SysMain WSearch DiagTrack WerSvc DoSvc MapsBroker lfsvc RetailDemo
) do net stop %%S >nul 2>&1

schtasks /Change /TN "\Microsoft\Windows\Maintenance\WinSAT" /DISABLE >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" /DISABLE >nul 2>&1

powercfg -setactive SCHEME_MIN >nul 2>&1

taskkill /f /im explorer.exe >nul 2>&1
start explorer.exe

echo fan fix applied — give it a few minutes to calm down.
pause
goto menu



:: ==========================================================
:: ACTIVATION FIX (LEGIT RESET)
:: ==========================================================
:activation
cls
set "WARN=Activation fix resets licensing config. You may need to re-enter your valid key."
call :confirm

echo repairing activation...
call :anim

net stop sppsvc >nul 2>&1
taskkill /f /im slui.exe >nul 2>&1

cscript /nologo "%SystemRoot%\System32\slmgr.vbs" /rilc
echo done (licensing config reset). you may need to activate again.
pause
goto menu



:: ==========================================================
:: TIMER INFO
:: ==========================================================
:timerinfo
cls
set "WARN=High-resolution timer (1ms) is enabled while fixer is running. Slightly higher power usage."
call :confirm

echo timer resolution: 1ms (requested via timeBeginPeriod)
echo this can help with input latency and frame pacing under load.
echo.
pause
goto menu



:: ==========================================================
:: GAME MODE
:: ==========================================================
:gamemode
cls
set "WARN=Game mode will close many background apps and some services, and tweak power. Downloads and background stuff may stop."
call :confirm

echo enabling game mode...
call :anim

for %%P in (
Discord.exe steam.exe EpicGamesLauncher.exe chrome.exe msedge.exe OneDrive.exe
GameBar.exe XboxApp.exe Widgets.exe Teams.exe
SearchApp.exe SearchHost.exe RuntimeBroker.exe NVIDIAWebHelper.exe NVIDIAShare.exe
) do taskkill /f /im %%P >nul 2>&1

for %%S in (
SysMain WSearch DiagTrack RetailDemo lfsvc MapsBroker WbioSrvc
) do net stop %%S >nul 2>&1

powercfg -setactive SCHEME_MIN >nul 2>&1

ipconfig /flushdns >nul 2>&1
netsh winsock reset >nul 2>&1

taskkill /f /im explorer.exe >nul 2>&1
start explorer.exe

echo game mode activated.
pause
goto menu



:: ==========================================================
:: MICROSOFT FIX
:: ==========================================================
:microsoft
cls
set "WARN=Microsoft fix resets update/installer cache folders."
call :confirm

echo repairing Microsoft services...
call :anim
net stop wuauserv >nul 2>&1
net stop bits >nul 2>&1
net stop cryptsvc >nul 2>&1
net stop msiserver >nul 2>&1

rmdir /s /q "%systemroot%\SoftwareDistribution" >nul 2>&1
rmdir /s /q "%systemroot%\System32\catroot2" >nul 2>&1

net start wuauserv >nul 2>&1
net start bits >nul 2>&1
net start cryptsvc >nul 2>&1
net start msiserver >nul 2>&1
echo done.
pause
goto menu



:: ==========================================================
:: DISCORD FIX
:: ==========================================================
:discord
cls
set "WARN=Discord fix deletes Discord data folders. You WILL need to log in again."
echo this will delete discord data and log you out.
echo.
call :confirm

echo fixing Discord...
call :anim
taskkill /f /im discord.exe >nul 2>&1
rmdir /s /q "%appdata%\discord" >nul 2>&1
rmdir /s /q "%localappdata%\Discord" >nul 2>&1
powershell -NoProfile -Command "try { Invoke-WebRequest 'https://discord.com/api/download?platform=win' -OutFile $env:TEMP\discordsetup.exe } catch {}" >nul 2>&1
if exist "%TEMP%\discordsetup.exe" start "" "%TEMP%\discordsetup.exe"
echo done.
pause
goto menu



:: ==========================================================
:: STEAM FIX
:: ==========================================================
:steam
cls
set "WARN=Steam fix clears appcache and runs flushconfig. You might be logged out."
call :confirm

echo fixing Steam...
call :anim
taskkill /f /im steam.exe >nul 2>&1
if exist "%programfiles(x86)%\Steam\appcache" del /f /s /q "%programfiles(x86)%\Steam\appcache\*" >nul 2>&1
start "" "steam://flushconfig"
echo done.
pause
goto menu



:: ==========================================================
:: EPIC FIX 2.0 (STRONG)
:: ==========================================================
:epic
cls
set "WARN=Epic fix wipes launcher cache/config and fetches fresh installer. You may need to log in again."
call :confirm

echo fixing Epic Games Launcher...
call :anim

echo killing epic processes...
taskkill /f /im EpicGamesLauncher.exe >nul 2>&1
taskkill /f /im epicwebhelper.exe >nul 2>&1

echo clearing epic data...
rmdir /s /q "%localappdata%\EpicGamesLauncher\Saved\webcache" >nul 2>&1
rmdir /s /q "%localappdata%\EpicGamesLauncher\Saved\webcache_4147" >nul 2>&1
rmdir /s /q "%localappdata%\EpicGamesLauncher\Saved\Logs" >nul 2>&1
rmdir /s /q "%localappdata%\EpicGamesLauncher\Saved\Config" >nul 2>&1

if exist "%programdata%\Epic\EpicGamesLauncher" rmdir /s /q "%programdata%\Epic\EpicGamesLauncher" >nul 2>&1

echo you should reinstall epic from:
echo   https://store.epicgames.com/
echo (launcher installer link may change over time)
echo.
pause
goto menu



:: ==========================================================
:: GPU FIX + SHADER CACHE CLEAN
:: ==========================================================
:gpu
cls
set "WARN=GPU fix clears shader caches and GPU temp folders. Safe, but first launch of games may stutter once."
call :confirm

echo gpu + shader cache cleanup...
call :anim

del /f /s /q "%localappdata%\NVIDIA\DXCache\*" >nul 2>&1
del /f /s /q "%localappdata%\NVIDIA\GLCache\*" >nul 2>&1
del /f /s /q "%localappdata%\NVIDIA Corporation\NV_Cache\*" >nul 2>&1
del /f /s /q "%localappdata%\Microsoft\DirectX Shader Cache\*" >nul 2>&1
del /f /s /q "%appdata%\AMD\DXCache\*" >nul 2>&1
del /f /s /q "%appdata%\AMD\GLCache\*" >nul 2>&1

echo gpu caches cleared.
pause
goto menu



:: ==========================================================
:: SYSTEM REPAIR
:: ==========================================================
:systemrepair
cls
set "WARN=System repair runs SFC and DISM. This can take a while."
call :confirm

echo system repair...
call :anim
sfc /scannow
dism /online /cleanup-image /restorehealth
echo done.
pause
goto menu



:: ==========================================================
:: CLEANUP
:: ==========================================================
:cleanup
cls
set "WARN=Cleanup deletes temp files from user and system temp folders."
call :confirm

echo cleanup...
call :anim
del /f /s /q "%temp%\*" >nul 2>&1
del /f /s /q "C:\Windows\Temp\*" >nul 2>&1
echo done.
pause
goto menu



:: ==========================================================
:: DEBLOAT
:: ==========================================================
:debloat
cls
set "WARN=Debloat disables telemetry service and removes some Xbox apps. Some features may not come back easily."
call :confirm

echo debloating Windows...
call :anim
sc stop DiagTrack >nul 2>&1
sc config DiagTrack start=disabled >nul 2>&1
powershell -NoProfile -Command "try { Get-AppxPackage *xbox* ^| Remove-AppxPackage } catch {}" >nul 2>&1
echo done.
pause
goto menu



:: ==========================================================
:: NETWORK RESET
:: ==========================================================
:network
cls
set "WARN=Network reset flushes DNS and resets IP/Winsock. Network may drop briefly."
call :confirm

echo resetting network...
call :anim
ipconfig /flushdns >nul 2>&1
netsh int ip reset >nul 2>&1
netsh winsock reset >nul 2>&1
echo done.
pause
goto menu



:: ==========================================================
:: STARTUP TOOLS
:: ==========================================================
:startup
cls
set "WARN=Startup tools open Windows startup settings and Task Manager (no auto changes)."
call :confirm

echo opening startup tools...
call :anim
start "" ms-settings:startupapps
start "" taskmgr
pause
goto menu



:: ==========================================================
:: REDISTRIBUTABLES
:: ==========================================================
:redist
cls
set "WARN=Redistributables install VC++ runtime. Existing runtimes may be updated."
call :confirm

echo installing redistributables...
call :anim
powershell -NoProfile -Command "try { Invoke-WebRequest 'https://aka.ms/vs/17/release/vc_redist.x64.exe' -OutFile $env:TEMP\vc_redist.exe } catch {}" >nul 2>&1
if exist "%TEMP%\vc_redist.exe" (
    start /wait "" "%TEMP%\vc_redist.exe" /install /quiet /norestart
    echo done.
) else (
    echo download failed.
)
pause
goto menu
