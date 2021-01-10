:: ViPER4Windows Patcher.
:: Version: 2.0
:: Written by Metaspook
:: License: <http://opensource.org/licenses/MIT>
:: Copyright (c) 2019-2020 Metaspook.
:: 
@echo off

::
:: 请求管理员权限
::
>nul 2>&1 reg query "HKU\S-1-5-19\Environment"
if '%errorlevel%' NEQ '0' (
	(echo.Set UAC = CreateObject^("Shell.Application"^)&echo.UAC.ShellExecute "%~s0", "", "", "runas", 1)>"%temp%\getadmin.vbs"
	"%temp%\getadmin.vbs"
	exit /B
) else ( >nul 2>&1 del "%temp%\getadmin.vbs" )

::
:: 主程序
::
title "ViPER4Windows 修复程序"
color 0B
pushd "%~dp0"
set APPVAR=2.0
for /f "tokens=2*" %%X in ('REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\ViPER4Windows" /v ConfigPath') do set PAPPDIR=%%Y
set APPDIR=%PAPPDIR:\DriverComm=%
mode con: cols=91 lines=24

:CHOICE_MENU
call:BANNER
echo      +----[ 选择菜单 ]----+
echo      ^|                    ^|
echo      ^|  1. 修复注册表     ^|
echo      ^|  2. 启动配置程序   ^|
echo      ^|  3. 重启音频服务   ^|
echo      ^|  0. 退出           ^|
echo      +--------------------+
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
	>nul 2>&1 timeout /t 2
	goto:CHOICE_MENU
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
	if exist "%APPDIR%\Configurator.exe" (
		start "" "%APPDIR%\Configurator.exe"
		goto:CHOICE_MENU
	) else (
		call:BANNER
		echo [失败!] ViPER4Windows 配置程序未找到.
		>nul 2>&1 timeout /t 2
		goto:CHOICE_MENU
	)
)
if "%CMVAR%"=="3" (
	call:BANNER
	powershell -command "Restart-Service -Name Audiosrv -Confirm:$false"
	echo [完成] 音频服务已重启
	>nul 2>&1 timeout /t 2
	goto:CHOICE_MENU
)

:BANNER
cls                                   
echo                           ________________
echo              ViPER4Windows 修复程序 v%APPVAR%   \__ 
echo       \\  作者 Metaspook 汉化 BecodReyes  /  \ 
echo        \\__________________________       \__/
echo.&echo.
goto:eof
