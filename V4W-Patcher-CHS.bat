:: ViPER4Windows Patcher.
:: Version: 2.1
:: Written by Metaspook
:: License: <http://opensource.org/licenses/MIT>
:: Copyright (c) 2019-2022 Metaspook.
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
set APPVAR=2.1
for /f "tokens=2*" %%X in ('REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\ViPER4Windows" /v ConfigPath') do set PAPPDIR=%%Y
set APPDIR=%PAPPDIR:\DriverComm=%
set APOSubPath="AudioEngine\AudioProcessingObjects\{DA2FB532-3014-4B93-AD05-21B2C620F9C2}"
set AppCompatFlagsLayers="SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"
mode con: cols=56 lines=20

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
echo       按照顺序执行，不需要重启电脑
echo.
set CMVAR=
set /p "CMVAR=请选择: "
if "%CMVAR%"=="0" exit
if exist "%AppDir%\ViPER4WindowsCtrlPanel.exe" (
	if "%CMVAR%"=="1" call:PATCH_REGISTRY
	if "%CMVAR%"=="2" call:LAUNCH_CONFIGURATOR
	if "%CMVAR%"=="3" (
		call:BANNER
		call:RESTART_AUDIO_SERVICE
	)
) else (
	call:BANNER
	echo [失败!] ViPER4Windows 未安装.
	>nul 2>&1 timeout /t 2
	goto:CHOICE_MENU
)

:PATCH_REGISTRY
call:BANNER
if exist "%~dp0psexec.exe" (
	>nul 2>&1 reg add "HKLM\%AppCompatFlagsLayers%" /v "%AppDir%\ViPER4WindowsCtrlPanel.exe" /t REG_SZ /d "RUNASADMIN" /f
	>nul 2>&1 reg add "HKCU\%AppCompatFlagsLayers%" /v "%AppDir%\ViPER4WindowsCtrlPanel.exe" /t REG_SZ /d "RUNASADMIN" /f
	for %%a in (HKLM\SOFTWARE\Classes HKCR) do (
		>nul 2>&1 .\psexec.exe -i -d -s -accepteula -nobanner reg delete "%%a\AudioEngine\AudioProcessingObjects" /f
		>nul 2>&1 reg add "%%a\%APOSubPath%" /v "FriendlyName" /t REG_SZ /d "ViPER4Windows" /f
		>nul 2>&1 reg add "%%a\%APOSubPath%" /v "Copyright" /t REG_SZ /d "Copyright (C) 2013, vipercn.com" /f
		>nul 2>&1 reg add "%%a\%APOSubPath%" /v "MajorVersion" /t REG_DWORD /d "1" /f
		>nul 2>&1 reg add "%%a\%APOSubPath%" /v "MinorVersion" /t REG_DWORD /d "0" /f
		>nul 2>&1 reg add "%%a\%APOSubPath%" /v "Flags" /t REG_DWORD /d "13" /f
		>nul 2>&1 reg add "%%a\%APOSubPath%" /v "MinInputConnections" /t REG_DWORD /d "1" /f
		>nul 2>&1 reg add "%%a\%APOSubPath%" /v "MaxInputConnections" /t REG_DWORD /d "1" /f
		>nul 2>&1 reg add "%%a\%APOSubPath%" /v "MinOutputConnections" /t REG_DWORD /d "1" /f
		>nul 2>&1 reg add "%%a\%APOSubPath%" /v "MaxOutputConnections" /t REG_DWORD /d "1" /f
		>nul 2>&1 reg add "%%a\%APOSubPath%" /v "MaxInstances" /t REG_DWORD /d "4294967295" /f
		>nul 2>&1 reg add "%%a\%APOSubPath%" /v "NumAPOInterfaces" /t REG_DWORD /d "1" /f
		>nul 2>&1 reg add "%%a\%APOSubPath%" /v "APOInterface0" /t REG_SZ /d "{FD7F2B29-24D0-4B5C-B177-592C39F9CA10}" /f
	)
	if %ERRORLEVEL% NEQ 0 (
		call:BANNER
		echo [失败!] 注册表修复失败.
		>nul 2>&1 timeout /t 2
		goto:CHOICE_MENU
	) else (
		call:BANNER
		echo [提示] 注册表修复成功.
	)
) else (
	mode con: cols=86 lines=20
	call:BANNER
	echo [警告!] psexec.exe 不存在，这可能会导致修复程序在 Windows 11 中失效
	echo [警告!] 请前往 https://docs.microsoft.com/en-us/sysinternals/downloads/psexec 下载
	echo [警告!] 然后将 psexec.exe 放置于修复程序同目录中，然后重新打开修复程序
	echo [警告!] 10秒后尝试旧版修复方法
	>nul 2>&1 timeout /t 10
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
	mode con: cols=56 lines=20
	if %ERRORLEVEL% NEQ 0 (
		call:BANNER
		echo [失败!] 注册表修复失败.
		>nul 2>&1 timeout /t 2
		goto:CHOICE_MENU
	) else (
		call:BANNER
		echo [提示] 注册表尝试修复成功！
		echo [提示] 由于 'psexec.exe' 丢失，请手动确认修复是否成功！
		>nul 2>&1 timeout /t 5
		goto:CHOICE_MENU
	)
)

:LAUNCH_CONFIGURATOR
if exist "%AppDir%\Configurator.exe" (
	start "" "%AppDir%\Configurator.exe"
	goto:CHOICE_MENU
) else (
	call:BANNER
	echo [失败!] ViPER4Windows 配置程序未找到.
	>nul 2>&1 timeout /t 2
	goto:CHOICE_MENU
)

:RESTART_AUDIO_SERVICE
powershell -command "Restart-Service -Name Audiosrv -Confirm:$false -Force"
echo [完成] 音频服务已重启
>nul 2>&1 timeout /t 2
goto:CHOICE_MENU

:BANNER
cls                                   
echo                           ________________
echo              ViPER4Windows 修复程序 v%APPVAR%   \__ 
echo       \\  作者 Metaspook 汉化 BecodReyes  /  \ 
echo        \\__________________________       \__/
echo.&echo.
goto:eof
