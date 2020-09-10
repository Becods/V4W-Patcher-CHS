:: ViPER4Windows Patcher.
:: Version: 1.1
:: Written by Metaspook
:: License: <http://opensource.org/licenses/MIT>
:: Copyright (c) 2019 Metaspook.
:: 
@echo off

::
:: REQUESTING ADMINISTRATIVE PRIVILEGES
::
REM >nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
>nul 2>&1 reg query "HKU\S-1-5-19\Environment"
if '%errorlevel%' NEQ '0' (
	(echo.Set UAC = CreateObject^("Shell.Application"^)&echo.UAC.ShellExecute "%~s0", "", "", "runas", 1)>"%temp%\getadmin.vbs"
	"%temp%\getadmin.vbs"
	exit /B
) else ( >nul 2>&1 del "%temp%\getadmin.vbs" )

::
:: MAIN SCRIPT STARTS BELOW
::
title "ViPER4Windows 修复程序"
color 0B
pushd "%~dp0"
set APPVAR=1.1
for /f "tokens=2*" %%X in ('REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\ViPER4Windows" /v ConfigPath') do set PAPPDIR=%%Y
set APPDIR=%PAPPDIR:\DriverComm=%
mode con: cols=91 lines=24

:CHOICE_MENU
call:BANNER                       
echo   ===================================== 选择菜单 ========================================
echo                       ^|                          ^|                         ^| 
echo    1. 修复注册表      ^|  2. 启动配置程序         ^|  3. 重启音频服务        ^|  0. 退出
echo                       ^|                          ^|                         ^| 
echo   =======================================================================================
echo.
echo 使用：选择一个数字，然后按回车键
echo       建议在重启音频服务之前关闭音频输出，以免出现问题
echo       不需要重启电脑
echo.
set CMVAR=
set /p "CMVAR=请选择: "
if "%CMVAR%"=="0" exit
if not exist "%APPDIR%" (
	call:BANNER
	echo [失败!] ViPER4Windows 未安装！
	>nul 2>&1 timeout /t 7
	exit
)
if "%CMVAR%"=="1" (
	call:BANNER
	for %%a in (HKLM\SOFTWARE\Classes HKCR) do (
	>nul 2>&1 reg delete "%%a\AudioEngine\AudioProcessingObjects" /f
	>nul 2>&1 reg add "%%a\AudioEngine\AudioProcessingObjects\{DA2FB532-3014-4B93-AD05-21B2C620F9C2}" /v "FriendlyName" /t REG_SZ /d "ViPER4Windows" /f
	>nul 2>&1 reg add "%%a\AudioEngine\AudioProcessingObjects\{DA2FB532-3014-4B93-AD05-21B2C620F9C2}" /v "Copyright" /t REG_SZ /d "Copyright (C) 2013, vipercn.com" /f
	>nul 2>&1 reg add "%%a\AudioEngine\AudioProcessingObjects\{DA2FB532-3014-4B93-AD05-21B2C620F9C2}" /v "MajorVersion" /t REG_DWORD /d "1" /f
	>nul 2>&1 reg add "%%a\AudioEngine\AudioProcessingObjects\{DA2FB532-3014-4B93-AD05-21B2C620F9C2}" /v "MinorVersion" /t REG_DWORD /d "0" /f
	>nul 2>&1 reg add "%%a\AudioEngine\AudioProcessingObjects\{DA2FB532-3014-4B93-AD05-21B2C620F9C2}" /v "Flags" /t REG_DWORD /d "13" /f
	>nul 2>&1 reg add "%%a\AudioEngine\AudioProcessingObjects\{DA2FB532-3014-4B93-AD05-21B2C620F9C2}" /v "MinInputConnections" /t REG_DWORD /d "1" /f
	>nul 2>&1 reg add "%%a\AudioEngine\AudioProcessingObjects\{DA2FB532-3014-4B93-AD05-21B2C620F9C2}" /v "MaxInputConnections" /t REG_DWORD /d "1" /f
	>nul 2>&1 reg add "%%a\AudioEngine\AudioProcessingObjects\{DA2FB532-3014-4B93-AD05-21B2C620F9C2}" /v "MinOutputConnections" /t REG_DWORD /d "1" /f
	>nul 2>&1 reg add "%%a\AudioEngine\AudioProcessingObjects\{DA2FB532-3014-4B93-AD05-21B2C620F9C2}" /v "MaxOutputConnections" /t REG_DWORD /d "1" /f
	>nul 2>&1 reg add "%%a\AudioEngine\AudioProcessingObjects\{DA2FB532-3014-4B93-AD05-21B2C620F9C2}" /v "MaxInstances" /t REG_DWORD /d "4294967295" /f
	>nul 2>&1 reg add "%%a\AudioEngine\AudioProcessingObjects\{DA2FB532-3014-4B93-AD05-21B2C620F9C2}" /v "NumAPOInterfaces" /t REG_DWORD /d "1" /f
	>nul 2>&1 reg add "%%a\AudioEngine\AudioProcessingObjects\{DA2FB532-3014-4B93-AD05-21B2C620F9C2}" /v "APOInterface0" /t REG_SZ /d "{FD7F2B29-24D0-4B5C-B177-592C39F9CA10}" /f
	)
	>nul 2>&1 reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v "%APPDIR%\ViPER4WindowsCtrlPanel.exe" /t REG_SZ /d "RUNASADMIN" /f
	echo [提示] 注册表修复成功！
	>nul 2>&1 timeout /t 2
	goto:CHOICE_MENU
)
if "%CMVAR%"=="2" (
	start "" "%APPDIR%\Configurator.exe"
	goto:CHOICE_MENU
)
if "%CMVAR%"=="3" (
	call:BANNER
	powershell -command "Restart-Service -DisplayName 'Windows Audio' -Confirm"
	goto:CHOICE_MENU
)

:BANNER
cls                                   
echo                                                  ________________
echo                                    ViPER4Windows 修复程序 v%APPVAR%   \__ 
echo                              \\  作者 Metaspook 汉化 BecodReyes  /  \ 
echo                               \\__________________________       \__/
echo.&echo.&echo.&echo.
goto:eof








::[-HKEY_CLASSES_ROOT\AudioEngine\AudioProcessingObjects]
::[HKEY_CLASSES_ROOT\AudioEngine\AudioProcessingObjects\{DA2FB532-3014-4B93-AD05-21B2C620F9C2}]
::"FriendlyName"="ViPER4Windows"
::"Copyright"="Copyright (C) 2013, vipercn.com"
::"MajorVersion"=dword:00000001
::"MinorVersion"=dword:00000000
::"Flags"=dword:0000000d
::"MinInputConnections"=dword:00000001
::"MaxInputConnections"=dword:00000001
::"MinOutputConnections"=dword:00000001
::"MaxOutputConnections"=dword:00000001
::"MaxInstances"=dword:ffffffff
::"NumAPOInterfaces"=dword:00000001
::"APOInterface0"="{FD7F2B29-24D0-4B5C-B177-592C39F9CA10}"

