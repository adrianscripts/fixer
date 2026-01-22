@echo off
title adrian's fixer
color 0a
setlocal EnableDelayedExpansion

:: version and update source
set "FIXER_VERSION=1.0 beta"
set "UPDATE_URL=https://raw.githubusercontent.com/adrianscripts/fixer/refs/heads/main/version.txt"

:: elevation check
>nul 2>&1 net session
if %errorlevel% neq 0 (
    powershell -NoProfile -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

chcp 65001 >nul

call :check_update

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
echo.                            adrian's fixer
echo.                           version %FIXER_VERSION%
if defined REMOTE_VERSION if /I not "%REMOTE_VERSION%"=="%FIXER_VERSION%" echo.                     update available: %REMOTE_VERSION%
echo.
echo.      [ 1 ] microsoft fix        [ 2 ] discord fix         [ 3 ] fan fix
echo.      [ 4 ] steam fix            [ 5 ] epic fix            [ 6 ] gpu repair
echo.      [ 7 ] system repair        [ 8 ] cleanup             [ 9 ] debloat
echo.     [ 10 ] network reset       [ 11 ] ram modes          [ 12 ] startup tools
echo.     [ 13 ] redistributables    [ 14 ] exit               [ 15 ] game mode
echo.
set /p choice=   choose an option: 

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
if "%choice%"=="14" exit /b
if "%choice%"=="15" goto gamemode
goto menu


:check_update
set "REMOTE_VERSION="
for /f "usebackq delims=" %%V in (`powershell -NoProfile -Command "try { (Invoke-WebRequest -UseBasicParsing '%UPDATE_URL%').Content.Trim() } catch { '' }"`) do (
    set "REMOTE_VERSION=%%V"
)
goto :eof


:anim
<nul set /p="..."
ping -n 2 127.0.0.1 >nul
echo.
goto :eof


:rammenu
cls
echo.
echo  ram cleaner modes
echo.
echo    [ 1 ] light clean
echo    [ 2 ] deep clean
echo    [ 3 ] extreme clean
echo    [ 4 ] back
echo.
set /p rm=   choose a mode: 

if "%rm%"=="1" goto ram_light
if "%rm%"=="2" goto ram_deep
if "%rm%"=="3" goto ram_extreme
if "%rm%"=="4" goto menu
goto rammenu


:ram_light
cls
echo light ram clean
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
echo deep ram clean
call :anim

taskkill /f /im Discord.exe >nul 2>&1
taskkill /f /im steam.exe >nul 2>&1
taskkill /f /im EpicGamesLauncher.exe >nul 2>&1
taskkill /f /im OneDrive.exe >nul 2>&1
taskkill /f /im msedge.exe >nul 2>&1
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
echo extreme ram clean
call :anim

for %%P in (
Discord.exe steam.exe EpicGamesLauncher.exe OneDrive.exe Widgets.exe
msedge.exe chrome.exe firefox.exe GameBar.exe SearchApp.exe SearchHost.exe
Teams.exe XboxApp.exe RuntimeBroker.exe PhoneExperienceHost.exe
) do taskkill /f /im %%P >nul 2>&1

for %%S in (
DiagTrack WSearch SysMain WerSvc WbioSrvc MapsBroker lfsvc RetailDemo
) do net stop %%S >nul 2>&1

powershell -NoProfile -Command "try { Clear-MemoryPressure } catch { }" >nul 2>&1
powershell -NoProfile -Command "try { Get-Process ^| where { $_.Name -eq 'Memory Compression' } ^| Stop-Process -Force } catch { }" >nul 2>&1

del /f /s /q "%temp%\*" >nul 2>&1

taskkill /f /im explorer.exe >nul 2>&1
start explorer.exe

echo done.
pause
goto rammenu


:fanfix
cls
echo fan fix
call :anim

for %%S in (
SysMain WSearch DiagTrack WerSvc DoSvc WbioSrvc MapsBroker lfsvc RetailDemo
) do net stop %%S >nul 2>&1

schtasks /Change /TN "\Microsoft\Windows\Maintenance\WinSAT" /DISABLE >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" /DISABLE >nul 2>&1

powercfg -setactive SCHEME_MIN >nul 2>&1

reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\0cc5b647-c1df-4637-891a-dec35c318583" /v ValueMax /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\System\CurrentControlSet\Control\GraphicsDrivers\PowerSettings" /v PowerPolicy /t REG_DWORD /d 1 /f >nul 2>&1

taskkill /f /im explorer.exe >nul 2>&1
start explorer.exe

echo.
echo fan fix applied. allow a few minutes for behavior to settle.
echo.
pause
goto menu


:gamemode
cls
echo game mode
call :anim

for %%P in (
Discord.exe steam.exe EpicGamesLauncher.exe OneDrive.exe
chrome.exe msedge.exe firefox.exe opera.exe brave.exe
GameBar.exe XboxApp.exe Widgets.exe Teams.exe
RiotClientServices.exe SteamWebHelper.exe
SearchApp.exe SearchHost.exe PhoneExperienceHost.exe
RuntimeBroker.exe NVIDIAShare.exe NVIDIAWebHelper.exe
) do taskkill /f /im %%P >nul 2>&1

for %%S in (
SysMain WSearch DiagTrack RetailDemo WbioSrvc MapsBroker lfsvc
Spooler WerSvc RemoteRegistry XblAuthManager XblGameSave
WpnService BITS UsoSvc DoSvc
) do net stop %%S >nul 2>&1

powercfg -setactive SCHEME_MIN >nul 2>&1
reg add "HKLM\System\CurrentControlSet\Control\GraphicsDrivers\PowerSettings" /v PowerPolicy /t REG_DWORD /d 1 /f >nul 2>&1

powershell -NoProfile -Command "try { Clear-MemoryPressure } catch { }" >nul 2>&1

ipconfig /flushdns >nul 2>&1
netsh int ip reset >nul 2>&1
netsh winsock reset >nul 2>&1

taskkill /f /im explorer.exe >nul 2>&1
start explorer.exe

echo.
echo game mode applied.
echo.
pause
goto menu


:microsoft
cls
echo microsoft installer / update repair
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


:discord
cls
echo discord fix
call :anim

taskkill /f /im discord.exe >nul 2>&1
rmdir /s /q "%appdata%\discord" >nul 2>&1
rmdir /s /q "%localappdata%\Discord" >nul 2>&1

powershell -NoProfile -Command "try { Invoke-WebRequest 'https://discord.com/api/download?platform=win' -OutFile $env:TEMP\discordsetup.exe } catch { }"
if exist "%TEMP%\discordsetup.exe" start "" "%TEMP%\discordsetup.exe"

echo done.
pause
goto menu


:steam
cls
echo steam fix
call :anim

taskkill /f /im steam.exe >nul 2>&1
if exist "%programfiles(x86)%\Steam\appcache" del /f /s /q "%programfiles(x86)%\Steam\appcache\*" >nul 2>&1

start "" "steam://flushconfig"

echo done.
pause
goto menu


:epic
cls
echo epic games launcher fix
call :anim

taskkill /f /im EpicGamesLauncher.exe >nul 2>&1
rmdir /s /q "%localappdata%\EpicGamesLauncher\Saved\webcache" >nul 2>&1

echo done.
pause
goto menu


:gpu
cls
echo gpu repair
call :anim

rmdir /s /q "%localappdata%\NVIDIA" >nul 2>&1
rmdir /s /q "%localappdata%\AMD" >nul 2>&1

powershell -NoProfile -Command "try { Invoke-WebRequest 'https://us.download.nvidia.com/Windows/551.86/551.86-desktop-win10-win11-64bit-international-dch-whql.exe' -OutFile $env:TEMP\nvidia_driver.exe } catch { }"
if exist "%TEMP%\nvidia_driver.exe" start "" "%TEMP%\nvidia_driver.exe"

echo done.
pause
goto menu


:systemrepair
cls
echo system repair
call :anim

sfc /scannow
dism /online /cleanup-image /restorehealth
chkdsk C: /scan

echo done.
pause
goto menu


:cleanup
cls
echo cleanup
call :anim

del /f /s /q "%temp%\*" >nul 2>&1
del /f /s /q "C:\Windows\Temp\*" >nul 2>&1

echo done.
pause
goto menu


:debloat
cls
echo debloat
call :anim

sc stop DiagTrack >nul 2>&1
sc config DiagTrack start=disabled >nul 2>&1
powershell -NoProfile -Command "try { Get-AppxPackage *xbox* ^| Remove-AppxPackage } catch { }" >nul 2>&1

echo done.
pause
goto menu


:network
cls
echo network reset
call :anim

ipconfig /flushdns >nul 2>&1
netsh int ip reset >nul 2>&1
netsh winsock reset >nul 2>&1

echo done.
pause
goto menu


:startup
cls
echo startup tools
call :anim

start "" ms-settings:startupapps
start "" taskmgr

echo opened startup controls.
pause
goto menu


:redist
cls
echo installing redistributables
call :anim

powershell -NoProfile -Command "try { Invoke-WebRequest 'https://download.microsoft.com/download/1/1/0/11055A2A/directx_Jun2010_redist.exe' -OutFile $env:TEMP\dx_redist.exe } catch { }"
if exist "%TEMP%\dx_redist.exe" start /wait "" "%TEMP%\dx_redist.exe" /Q

powershell -NoProfile -Command "try { Invoke-WebRequest 'https://aka.ms/vs/17/release/vc_redist.x64.exe' -OutFile $env:TEMP\vc_redist.exe } catch { }"
if exist "%TEMP%\vc_redist.exe" start /wait "" "%TEMP%\vc_redist.exe" /install /quiet /norestart

echo done.
pause
goto menu
