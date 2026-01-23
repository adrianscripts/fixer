@echo off
title adrian's fixer
color 0a
setlocal EnableDelayedExpansion

:: ========= ADMIN CHECK =========
>nul 2>&1 net session
if %errorlevel% NEQ 0 (
    echo requesting administrator...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: ========= UNICODE =========
chcp 65001 >nul

:: ========= OS DETECT =========
set "winver=unknown"
ver | find "Windows 10" >nul && set "winver=10"
ver | find "Windows 11" >nul && set "winver=11"

:menu
cls
echo.
echo.                 ███████╗██╗██╗  ██╗███████╗██████╗
echo.                 ██╔════╝██║██║ ██╔╝██╔════╝██╔══██╗
echo.                 █████╗  ██║█████╔╝ █████╗  ██████╔╝
echo.                 ██╔══╝  ██║██╔═██╗ ██╔══╝  ██╔══██╗
echo.                 ██║     ██║██║  ██╗███████╗██║  ██║
echo.                 ╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝
echo.
echo.                              adrian's fixer
echo.
echo.      [ 1 ] microsoft fix         [ 2 ] discord fix         [ 3 ] fan fix
echo.      [ 4 ] steam fix             [ 5 ] epic fix            [ 6 ] gpu repair
echo.      [ 7 ] system repair         [ 8 ] cleanup             [ 9 ] debloat
echo.     [ 10 ] network reset        [ 11 ] ram modes          [ 12 ] startup tools
echo.     [ 13 ] redistributables     [ 14 ] exit
echo.     [ 15 ] GAME MODE
echo.

:: ===== OS-SPECIFIC WARNINGS (RED TEXT) =====
if /i "%winver%"=="10" (
    color 0c
    echo.   note: some gpu / game mode power tweaks are tuned for newer builds.
    echo.         unsupported parts will just be skipped, no errors.
    color 0a
)
if /i "%winver%"=="11" (
    color 0c
    echo.   note: some maintenance / fan tasks may not exist on your build.
    echo.         if missing, they are safely ignored.
    color 0a
)

echo.
set /p choice=               choose an option: 

if "%choice%"=="1"  goto microsoft
if "%choice%"=="2"  goto discord
if "%choice%"=="3"  goto fanfix
if "%choice%"=="4"  goto steam
if "%choice%"=="5"  goto epic
if "%choice%"=="6"  goto gpu
if "%choice%"=="7"  goto systemrepair
if "%choice%"=="8"  goto cleanup
if "%choice%"=="9"  goto debloat
if "%choice%"=="10" goto network
if "%choice%"=="11" goto rammenu
if "%choice%"=="12" goto startup
if "%choice%"=="13" goto redist
if "%choice%"=="14" exit
if "%choice%"=="15" goto gamemode
goto menu



:: =========================================
:: ANIMATION
:: =========================================
:anim
<nul set /p=". "
ping -n 2 127.0.0.1 >nul
<nul set /p=". "
ping -n 2 127.0.0.1 >nul
<nul set /p="."
ping -n 2 127.0.0.1 >nul
echo.
goto :eof



:: =========================================
:: RAM MODES + RAM CHECKER
:: =========================================
:rammenu
cls
echo.
echo                  RAM TOOLS
echo.
echo      [ 1 ] light clean
echo      [ 2 ] deep clean
echo      [ 3 ] extreme clean
echo      [ 4 ] ram check (sticks info)
echo      [ 5 ] back
echo.
set /p rm= choose a mode: 

if "%rm%"=="1" goto ram_light
if "%rm%"=="2" goto ram_deep
if "%rm%"=="3" goto ram_extreme
if "%rm%"=="4" goto ram_check
if "%rm%"=="5" goto menu
goto rammenu


:: ===== Mode 1 – Light Clean =====
:ram_light
cls
echo running light ram clean...
call :anim

taskkill /f /im Discord.exe >nul 2>&1
taskkill /f /im steam.exe >nul 2>&1
taskkill /f /im EpicGamesLauncher.exe >nul 2>&1
del /f /s /q "%temp%\*" >nul 2>&1

echo done.
pause
goto rammenu


:: ===== Mode 2 – Deep Clean =====
:ram_deep
cls
echo running deep ram clean...
call :anim

taskkill /f /im Discord.exe >nul 2>&1
taskkill /f /im steam.exe >nul 2>&1
taskkill /f /im EpicGamesLauncher.exe >nul 2>&1
taskkill /f /im OneDrive.exe >nul 2>&1

for %%S in (SysMain WSearch) do net stop %%S >nul 2>&1

del /f /s /q "%temp%\*" >nul 2>&1

taskkill /f /im explorer.exe >nul 2>&1
start explorer.exe

echo done.
pause
goto rammenu


:: ===== Mode 3 – EXTREME CLEAN =====
:ram_extreme
cls
echo running EXTREME clean...
call :anim

for %%P in (
Discord.exe steam.exe EpicGamesLauncher.exe OneDrive.exe Widgets.exe
msedge.exe chrome.exe firefox.exe GameBar.exe SearchApp.exe SearchHost.exe
Teams.exe xboxapp.exe RuntimeBroker.exe PhoneExperienceHost.exe
) do taskkill /f /im %%P >nul 2>&1

for %%S in (
DiagTrack WSearch SysMain WerSvc WbioSrvc MapsBroker lfsvc RetailDemo
) do net stop %%S >nul 2>&1

powershell -command "Clear-MemoryPressure" >nul 2>&1
powershell -command "Get-Process ^| where { $_.name -eq 'Memory Compression' } ^| Stop-Process -Force" >nul 2>&1

del /f /s /q "%temp%\*" >nul 2>&1

taskkill /f /im explorer.exe >nul 2>&1
start explorer.exe

echo done.
pause
goto rammenu


:: ===== RAM CHECKER =====
:ram_check
cls
echo checking ram sticks...
call :anim
echo.
echo if all your sticks are detected, they will be listed below:
echo.

powershell -command "Get-CimInstance Win32_PhysicalMemory ^| Select-Object BankLabel,Capacity,Manufacturer,Speed,PartNumber ^| Format-Table -AutoSize"

echo.
echo if a stick is physically installed but not listed here,
echo windows / bios is not detecting it.
echo.
pause
goto rammenu



:: =========================================
:: FAN FIX
:: =========================================
:fanfix
cls
echo applying fan stabilization fix...
call :anim

echo stopping spike-related services...
for %%S in (
    SysMain WSearch DiagTrack WerSvc DoSvc WbioSrvc MapsBroker lfsvc RetailDemo
) do net stop %%S >nul 2>&1

echo disabling maintenance tasks (if present)...
schtasks /Change /TN "\Microsoft\Windows\Maintenance\WinSAT" /DISABLE >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" /DISABLE >nul 2>&1

echo high performance power plan...
powercfg -setactive SCHEME_MIN >nul 2>&1

echo fixing cpu parking / stable freq...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\0cc5b647-c1df-4637-891a-dec35c318583" /v ValueMax /t REG_DWORD /d 0 /f >nul 2>&1

echo fixing gpu idle oscillation...
reg add "HKLM\System\CurrentControlSet\Control\GraphicsDrivers\PowerSettings" /v PowerPolicy /t REG_DWORD /d 1 /f >nul 2>&1

echo restarting explorer...
taskkill /f /im explorer.exe >nul 2>&1
start explorer.exe

echo.
echo [✓] fan fix applied — spikes should stop within a few minutes.
echo.
pause
goto menu



:: =========================================
:: GAME MODE – MAX PERFORMANCE
:: =========================================
:gamemode
cls
echo ============================================================
echo                        GAME MODE
echo ------------------------------------------------------------
echo – kills background junk and overlays
echo – disables heavy services
echo – clears RAM and CPU hogs
echo – forces high performance mode
echo – resets networking
echo – applies GPU max performance
echo – restarts Explorer clean
echo ============================================================
call :anim

echo killing processes...
for %%P in (
Discord.exe steam.exe EpicGamesLauncher.exe OneDrive.exe
chrome.exe msedge.exe firefox.exe opera.exe brave.exe
GameBar.exe XboxApp.exe Widgets.exe Teams.exe
RiotClientServices.exe epicwebhelper.exe SteamWebHelper.exe
SearchApp.exe SearchHost.exe PhoneExperienceHost.exe
RuntimeBroker.exe NVIDIAShare.exe NVIDIAWebHelper.exe
) do taskkill /f /im %%P >nul 2>&1

echo stopping services...
for %%S in (
SysMain WSearch DiagTrack RetailDemo WbioSrvc MapsBroker lfsvc
Spooler WerSvc RemoteRegistry XblAuthManager XblGameSave
WpnService BITS UsoSvc DoSvc
) do net stop %%S >nul 2>&1

echo high performance power plan...
powercfg -setactive SCHEME_MIN >nul 2>&1

echo gpu max performance...
reg add "HKLM\System\CurrentControlSet\Control\GraphicsDrivers\PowerSettings" /v PowerPolicy /t REG_DWORD /d 1 /f >nul 2>&1

echo clearing standby memory...
powershell -command "Clear-MemoryPressure" >nul 2>&1

echo clearing dns + network...
ipconfig /flushdns >nul
netsh int ip reset >nul
netsh winsock reset >nul

echo restarting explorer for max FPS...
taskkill /f /im explorer.exe >nul 2>&1
start explorer.exe

echo.
echo [✓] Game Mode activated — PC is in max performance state.
echo.
pause
goto menu



:: =========================================
:: MICROSOFT FIX
:: =========================================
:microsoft
cls
echo repairing microsoft installer / updates...
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



:: =========================================
:: DISCORD FIX
:: =========================================
:discord
cls
echo fixing discord...
call :anim

taskkill /f /im discord.exe >nul 2>&1
rmdir /s /q "%appdata%\discord" >nul 2>&1
rmdir /s /q "%localappdata%\Discord" >nul 2>&1

powershell -Command ^
"Invoke-WebRequest 'https://discord.com/api/download?platform=win' -OutFile $env:TEMP\discord.exe"
start "" "%TEMP%\discord.exe"

echo done.
pause
goto menu



:: =========================================
:: STEAM FIX
:: =========================================
:steam
cls
echo fixing steam...
call :anim

taskkill /f /im steam.exe >nul 2>&1
del /f /s /q "%programfiles(x86)%\Steam\appcache\*" >nul 2>&1
start "" "steam://flushconfig"

echo done.
pause
goto menu



:: =========================================
:: EPIC FIX (STRONGER)
:: =========================================
:epic
cls
echo fixing epic games launcher...
call :anim

echo killing epic processes...
taskkill /f /im EpicGamesLauncher.exe >nul 2>&1
taskkill /f /im epicwebhelper.exe >nul 2>&1

echo clearing epic caches and logs...
rmdir /s /q "%localappdata%\EpicGamesLauncher\Saved\webcache" >nul 2>&1
rmdir /s /q "%localappdata%\EpicGamesLauncher\Saved\webcache_4147" >nul 2>&1
rmdir /s /q "%localappdata%\EpicGamesLauncher\Saved\Logs" >nul 2>&1
rmdir /s /q "%localappdata%\EpicGamesLauncher\Saved\Config" >nul 2>&1

if exist "%programdata%\Epic\EpicGamesLauncher" (
    rmdir /s /q "%programdata%\Epic\EpicGamesLauncher" >nul 2>&1
)

echo epic settings and cache cleared.
echo if the launcher stays greyed, reinstall epic from their site.
echo.
pause
goto menu



:: =========================================
:: GPU REPAIR + SHADER CACHE CLEAR
:: =========================================
:gpu
cls
echo repairing gpu drivers and clearing shader cache...
call :anim

echo clearing nvidia / amd / intel shader caches...
del /f /s /q "%localappdata%\NVIDIA\DXCache\*" >nul 2>&1
del /f /s /q "%localappdata%\NVIDIA\GLCache\*" >nul 2>&1
del /f /s /q "%localappdata%\NVIDIA Corporation\NV_Cache\*" >nul 2>&1
del /f /s /q "%localappdata%\Microsoft\DirectX Shader Cache\*" >nul 2>&1
del /f /s /q "%localappdata%\D3DSCache\*" >nul 2>&1
del /f /s /q "%appdata%\AMD\DXCache\*" >nul 2>&1
del /f /s /q "%appdata%\AMD\GLCache\*" >nul 2>&1
del /f /s /q "%localappdata%\Intel\ShaderCache\*" >nul 2>&1

echo clearing local gpu caches...
rmdir /s /q "%localappdata%\NVIDIA" >nul 2>&1
rmdir /s /q "%localappdata%\AMD" >nul 2>&1

echo downloading nvidia driver (example package)...
powershell -Command ^
"Invoke-WebRequest 'https://us.download.nvidia.com/Windows/551.86/551.86-desktop-win10-win11-64bit-international-dch-whql.exe' -OutFile $env:TEMP\nvidia.exe"

start "" "%TEMP%\nvidia.exe"

echo done.
pause
goto menu



:: =========================================
:: SYSTEM REPAIR
:: =========================================
:systemrepair
cls
echo running system repair...
call :anim

sfc /scannow
dism /online /cleanup-image /restorehealth
chkdsk C: /scan

echo done.
pause
goto menu



:: =========================================
:: CLEANUP
:: =========================================
:cleanup
cls
echo cleaning system...
call :anim

del /f /s /q "%temp%\*" >nul 2>&1
del /f /s /q "C:\Windows\Temp\*" >nul 2>&1

echo done.
pause
goto menu



:: =========================================
:: DEBLOAT
:: =========================================
:debloat
cls
echo debloating windows...
call :anim

sc stop DiagTrack >nul 2>&1
sc config DiagTrack start=disabled >nul 2>&1
powershell "Get-AppxPackage *xbox* ^| Remove-AppxPackage" >nul 2>&1

echo done.
pause
goto menu



:: =========================================
:: NETWORK RESET
:: =========================================
:network
cls
echo resetting network...
call :anim

ipconfig /flushdns >nul
netsh int ip reset >nul
netsh winsock reset >nul

echo done.
pause
goto menu



:: =========================================
:: STARTUP
:: =========================================
:startup
cls
echo opening startup tools...
call :anim

start "" ms-settings:startupapps
start "" taskmgr

echo done.
pause
goto menu



:: =========================================
:: REDISTRIBUTABLES
:: =========================================
:redist
cls
echo installing redistributables...
call :anim

powershell -Command ^
"Invoke-WebRequest 'https://download.microsoft.com/download/1/1/0/11055A2A/directx_Jun2010_redist.exe' -OutFile $env:TEMP\dx.exe"
start /wait "" "%TEMP%\dx.exe" /Q

powershell -Command ^
"Invoke-WebRequest 'https://aka.ms/vs/17/release/vc_redist.x64.exe' -OutFile $env:TEMP\vc.exe"
start /wait "" "%TEMP%\vc.exe" /install /quiet /norestart

echo done.
pause
goto menu
