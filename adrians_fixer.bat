@echo off
title adrian's fixer
color 0b
setlocal EnableDelayedExpansion

:: ==========================================================
:: VERSION + UPDATE PATHS
:: ==========================================================
set "FIXER_VERSION=1.3 beta"
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
:: ALWAYS-ON TIMER RESOLUTION (safe, universal)
:: ==========================================================
powershell -NoProfile -Command "try { rundll32.exe winmm.dll,timeBeginPeriod 1 } catch {}" >nul 2>&1

:: ==========================================================
:: UPDATE CHECK (with downgrade protection)
:: ==========================================================
call :check_update

:: ==========================================================
:: MAIN MENU
:: ==========================================================
:menu
cls
echo.
echo  ╔════════════════════════════════════════════════════════════════════╗
echo  ║                          ADRIAN'S FIXER                            ║
echo  ║                           version %FIXER_VERSION%                             ║
if defined OS_NAME (
echo  ║                         %OS_NAME%╣
) else (
echo  ║                         Windows version: unknown              ║
)
echo  ║                        status: %UPDATE_STATUS%║
echo  ╚════════════════════════════════════════════════════════════════════╝
echo.
echo      [ A ] microsoft fix          [ B ] discord fix           [ C ] fan fix
echo.
echo      [ D ] steam fix              [ E ] epic fix              [ F ] gpu repair
echo.
echo      [ G ] system repair          [ H ] cleanup               [ I ] debloat
echo.
echo      [ J ] network reset          [ K ] ram modes             [ L ] startup tools
echo.
echo      [ M ] redistributables       [ N ] activation fix        [ O ] timer info
echo.
echo      [ P ] game mode              [ Q ] unsafe tweaks         [ R ] restore backup
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
:: OS DETECTION FUNCTION
:: ==========================================================
:detect_os
set "OS_BUILD="
for /f "tokens=3" %%B in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v CurrentBuildNumber ^| find /i "CurrentBuildNumber"') do (
    set "OS_BUILD=%%B"
)
if not defined OS_BUILD (
    set "OS_NAME=Windows (unknown build)           "
    set "OS_MAJOR=?"
    goto :eof
)

set /a OS_BUILD_NUM=OS_BUILD+0
if %OS_BUILD_NUM% GEQ 22000 (
    set "OS_MAJOR=11"
    set "OS_NAME=Windows 11 build %OS_BUILD%      "
) else (
    set "OS_MAJOR=10"
    set "OS_NAME=Windows 10 build %OS_BUILD%      "
)
goto :eof

:: ==========================================================
:: UPDATE CHECK + DOWNGRADE PROTECTION
:: ==========================================================
:check_update
set "REMOTE_VERSION="

for /f "usebackq delims=" %%V in (`
  powershell -NoProfile -Command "try { (Invoke-WebRequest -UseBasicParsing '%UPDATE_URL%').Content.Trim() } catch { '' }"
`) do (
  set "REMOTE_VERSION=%%V"
)

if not defined REMOTE_VERSION (
    set "UPDATE_STATUS=update check failed              "
    goto :eof
)

if /i "%REMOTE_VERSION%"=="%FIXER_VERSION%" (
    set "UPDATE_STATUS=latest version                   "
    goto :eof
)

:: --- basic downgrade protection using numeric version (major.minor) ---
set "CURR_NUM=%FIXER_VERSION%"
for /f "tokens=1 delims= " %%A in ("%CURR_NUM%") do set "CURR_NUM=%%A"
for /f "tokens=1,2 delims=." %%A in ("%CURR_NUM%") do (
    set "CURR_MAJOR=%%A"
    set "CURR_MINOR=%%B"
)
if not defined CURR_MINOR set "CURR_MINOR=0"

set "REM_NUM=%REMOTE_VERSION%"
for /f "tokens=1 delims= " %%A in ("%REM_NUM%") do set "REM_NUM=%%A"
for /f "tokens=1,2 delims=." %%A in ("%REM_NUM%") do (
    set "REM_MAJOR=%%A"
    set "REM_MINOR=%%B"
)
if not defined REM_MINOR set "REM_MINOR=0"

set /a CURR_MAJOR_PLUS=CURR_MAJOR+0
set /a CURR_MINOR_PLUS=CURR_MINOR+0
set /a REM_MAJOR_PLUS=REM_MAJOR+0
set /a REM_MINOR_PLUS=REM_MINOR+0

if %REM_MAJOR_PLUS% LSS %CURR_MAJOR_PLUS% (
    set "UPDATE_STATUS=downgrade blocked (%REMOTE_VERSION%)"
    goto :eof
)
if %REM_MAJOR_PLUS% EQU %CURR_MAJOR_PLUS% if %REM_MINOR_PLUS% LSS %CURR_MINOR_PLUS% (
    set "UPDATE_STATUS=downgrade blocked (%REMOTE_VERSION%)"
    goto :eof
)

set "UPDATE_STATUS=update available -> %REMOTE_VERSION%"
call :auto_update
goto :eof

:: ==========================================================
:: AUTO UPDATE + BACKUP
:: ==========================================================
:auto_update
set "NEW_FILE=%TEMP%\adrians_fixer_new.bat"

powershell -NoProfile -Command ^
"try { Invoke-WebRequest '%UPDATE_SCRIPT_URL%' -OutFile '%NEW_FILE%' -UseBasicParsing } catch {}" >nul 2>&1

if not exist "%NEW_FILE%" (
    set "UPDATE_STATUS=update failed                   "
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
:: CONFIRMATION (RED WARNING FOR ALL TOOLS)
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
    set "CONFIRM=Y"
) else (
    set "CONFIRM=N"
)
color 0b
echo.
goto :eof

:: ==========================================================
:: BACKUP RESTORE
:: ==========================================================
:restorebackup
cls
set "WARN=This will restore the previous backup of adrian's fixer and overwrite the current script."
call :confirm
if /i "%CONFIRM%" NEQ "Y" goto menu

echo restoring previous backup...
call :anim
set "BACKUP_FILE=%~dp0adrians_fixer_backup.bat"
if not exist "%BACKUP_FILE%" (
    echo no backup found.
    pause
    goto menu
)
copy /y "%BACKUP_FILE%" "%~f0" >nul
echo backup restored. restarting...
start "" "%~f0"
exit /b

:: ==========================================================
:: UNSAFE TWEAKS (HEAVY / RISKY)
:: ==========================================================
:unsafe_tweaks
cls
set "WARN=UNSAFE TWEAKS will apply aggressive registry and service changes.^& echo It may break Windows features, updates, store, or cause instability.^& echo NOT recommended on daily driver machines."
:: we can't echo multiline via WARN easily, so print manually:
color 0c
echo.
echo [ ! ] DANGER - UNSAFE TWEAKS
echo.
echo This will apply aggressive registry / service / power tweaks.
echo It may:
echo   - break some Windows features or apps
echo   - cause issues on Windows %OS_MAJOR% builds
echo   - be difficult to fully revert without reinstall
echo.
if "%OS_MAJOR%"=="11" (
    echo NOTE: This set was mainly tested for Windows 10.
    echo On Windows 11 it is more likely to cause issues.
    echo.
)
set "CONFIRM="
set /p CONFIRM= are you REALLY sure? (Y/N): 
if /i "%CONFIRM%" NEQ "Y" (
    color 0b
    echo.
    echo cancelled.
    pause
    goto menu
)
echo.
set "CONFIRM="
set /p CONFIRM= last chance. type Y to proceed: 
if /i "%CONFIRM%" NEQ "Y" (
    color 0b
    echo.
    echo cancelled.
    pause
    goto menu
)
color 0b
echo.
echo applying unsafe tweaks...
call :anim

:: aggressive but not outright destructive tweaks:

:: disable some background services (telemetry / experience)
for %%S in (
DiagTrack dmwappushservice RetailDemo lfsvc WSearch SysMain WbioSrvc
) do sc stop "%%S" >nul 2>&1 & sc config "%%S" start=disabled >nul 2>&1

:: power plan: high performance (or min)
powercfg -setactive SCHEME_MIN >nul 2>&1

:: visual effects -> performance bias
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v VisualFXSetting /t REG_DWORD /d 2 /f >nul 2>&1

:: more aggressive scheduler / network tweaks
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v SystemResponsiveness /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v GPU Priority /t REG_DWORD /d 8 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v Priority /t REG_DWORD /d 6 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v NetworkThrottlingIndex /t REG_DWORD /d 4294967295 /f >nul 2>&1

:: disable some scheduled telemetry tasks
schtasks /Change /TN "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" /DISABLE >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /DISABLE >nul 2>&1

:: optional: turn off tips / consumer features
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-338388Enabled /t REG_DWORD /d 0 /f >nul 2>&1

echo done. unsafe tweaks applied.
echo a reboot is recommended.
pause
goto menu

:: ==========================================================
:: RAM MODES
:: ==========================================================
:rammenu
cls
echo.
echo RAM CLEANER MODES
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
if "%rm%"=="4" goto menu
goto rammenu

:ram_light
cls
set "WARN=Light RAM clean: closes some launchers (Discord/Steam/Epic) and clears temp files."
call :confirm
if /i "%CONFIRM%" NEQ "Y" goto rammenu

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
set "WARN=Deep RAM clean: closes browsers, launchers, some services, and restarts explorer."
call :confirm
if /i "%CONFIRM%" NEQ "Y" goto rammenu

echo deep cleaning ram...
call :anim
taskkill /f /im Discord.exe >nul 2>&1
taskkill /f /im steam.exe >nul 2>&1
taskkill /f /im EpicGamesLauncher.exe >nul 2>&1
taskkill /f /im OneDrive.exe >nul 2>&1
taskkill /f /im chrome.exe >nul 2>&1
for %%S in (SysMain WSearch) do net stop %%S >nul 2>&1
del /f /s /q "%temp%\*" >nul 2>&1
taskkill /f /im explorer.exe >nul 2>&1
start explorer.exe
echo done.
pause
goto rammenu

:ram_extreme
cls
set "WARN=Extreme RAM clean: kills many background apps and services, may break some live features until reboot."
call :confirm
if /i "%CONFIRM%" NEQ "Y" goto rammenu

echo extreme ram clean...
call :anim
for %%P in (
Discord.exe steam.exe EpicGamesLauncher.exe Widgets.exe
OneDrive.exe chrome.exe msedge.exe SearchApp.exe SearchHost.exe
Teams.exe XboxApp.exe RuntimeBroker.exe
) do taskkill /f /im %%P >nul 2>&1

for %%S in (
SysMain WSearch DiagTrack WerSvc MapsBroker lfsvc RetailDemo
) do net stop %%S >nul 2>&1

del /f /s /q "%temp%\*" >nul 2>&1

taskkill /f /im explorer.exe >nul 2>&1
start explorer.exe

echo done.
pause
goto rammenu

:: ==========================================================
:: FAN FIX
:: ==========================================================
:fanfix
cls
set "WARN=Fan fix will stop some background services and adjust power behavior. May affect indexing and maintenance tasks."
call :confirm
if /i "%CONFIRM%" NEQ "Y" goto menu

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

echo fan fix applied — allow 1–3 minutes.
pause
goto menu

:: ==========================================================
:: ACTIVATION FIX
:: ==========================================================
:activation
cls
set "WARN=Activation fix will reset licensing configuration and remove stored keys. You may need to re-activate Windows."
call :confirm
if /i "%CONFIRM%" NEQ "Y" goto menu

echo repairing activation...
call :anim

net stop wlidsvc >nul 2>&1
net stop sppsvc  >nul 2>&1

taskkill /f /im slui.exe >nul 2>&1

cscript /nologo "%SystemRoot%\System32\slmgr.vbs" /rilc
cscript /nologo "%SystemRoot%\System32\slmgr.vbs" /upk
cscript /nologo "%SystemRoot%\System32\slmgr.vbs" /cpky

net start sppsvc >nul 2>&1

echo done.
pause
goto menu

:: ==========================================================
:: TIMER RES INFO
:: ==========================================================
:timerinfo
cls
set "WARN=Timer resolution tweak is always-on while this tool is running. This may slightly increase power usage."
call :confirm
if /i "%CONFIRM%" NEQ "Y" goto menu

echo High-resolution timer is automatically active.
echo This can improve input latency and frame pacing while the system is under load.
echo.
pause
goto menu

:: ==========================================================
:: GAME MODE
:: ==========================================================
:gamemode
cls
set "WARN=Game mode will close many background apps and services, and may disrupt downloads or background tasks."
call :confirm
if /i "%CONFIRM%" NEQ "Y" goto menu

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
set "WARN=Microsoft fix will reset Windows Update and installer components. It will clear update cache folders."
call :confirm
if /i "%CONFIRM%" NEQ "Y" goto menu

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
set "WARN=Discord fix will DELETE Discord data folders and you WILL have to log in again. Local settings and caches will be reset."
call :confirm
if /i "%CONFIRM%" NEQ "Y" goto menu

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
set "WARN=Steam fix clears some Steam cache and runs Steam flush config. You may need to log in again or reconfigure some settings."
call :confirm
if /i "%CONFIRM%" NEQ "Y" goto menu

echo fixing Steam...
call :anim
taskkill /f /im steam.exe >nul 2>&1
if exist "%programfiles(x86)%\Steam\appcache" del /f /s /q "%programfiles(x86)%\Steam\appcache\*" >nul 2>&1
start "" "steam://flushconfig"
echo done.
pause
goto menu

:: ==========================================================
:: EPIC FIX
:: ==========================================================
:epic
cls
set "WARN=Epic Games fix clears launcher webcache. It may sign you out or reset some launcher settings."
call :confirm
if /i "%CONFIRM%" NEQ "Y" goto menu

echo fixing Epic Games Launcher...
call :anim
taskkill /f /im EpicGamesLauncher.exe >nul 2>&1
rmdir /s /q "%localappdata%\EpicGamesLauncher\Saved\webcache" >nul 2>&1
echo done.
pause
goto menu

:: ==========================================================
:: GPU REPAIR
:: ==========================================================
:gpu
cls
set "WARN=GPU repair removes local GPU cache folders and downloads an NVIDIA driver installer. Make sure you know your GPU vendor."
call :confirm
if /i "%CONFIRM%" NEQ "Y" goto menu

echo gpu repair...
call :anim
rmdir /s /q "%localappdata%\NVIDIA" >nul 2>&1
rmdir /s /q "%localappdata%\AMD"    >nul 2>&1
powershell -NoProfile -Command "try { Invoke-WebRequest 'https://us.download.nvidia.com/Windows/551.86/551.86-desktop-win10-win11-64bit-international-dch-whql.exe' -OutFile $env:TEMP\nvidia_driver.exe } catch {}" >nul 2>&1
if exist "%TEMP%\nvidia_driver.exe" start "" "%TEMP%\nvidia_driver.exe"
echo done.
pause
goto menu

:: ==========================================================
:: SYSTEM REPAIR
:: ==========================================================
:systemrepair
cls
set "WARN=System repair runs SFC and DISM. It may take a while and can change system files back to default."
call :confirm
if /i "%CONFIRM%" NEQ "Y" goto menu

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
set "WARN=Cleanup deletes temp files from system and user temp folders. Recently opened lists and caches may reset."
call :confirm
if /i "%CONFIRM%" NEQ "Y" goto menu

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
set "WARN=Debloat disables telemetry service and removes some Xbox-related apps. Some features may not be easily restored."
call :confirm
if /i "%CONFIRM%" NEQ "Y" goto menu

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
set "WARN=Network reset flushes DNS, resets IP stack and Winsock. It will drop current connections and may reset some network settings."
call :confirm
if /i "%CONFIRM%" NEQ "Y" goto menu

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
set "WARN=Startup tools will open Windows startup apps settings and Task Manager for manual tweaks."
call :confirm
if /i "%CONFIRM%" NEQ "Y" goto menu

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
set "WARN=Redistributables install may add or update VC++ runtimes. It can change installed runtime versions."
call :confirm
if /i "%CONFIRM%" NEQ "Y" goto menu

echo installing redistributables...
call :anim
powershell -NoProfile -Command "try { Invoke-WebRequest 'https://aka.ms/vs/17/release/vc_redist.exe' -OutFile $env:TEMP\vc_redist.exe } catch {}" >nul 2>&1
if exist "%TEMP%\vc_redist.exe" start /wait "" "%TEMP%\vc_redist.exe" /install /quiet /norestart
echo done.
pause
goto menu
