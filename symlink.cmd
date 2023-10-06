@echo off
set dir_cfg=C:\Program Files (x86)\Steam\steamapps\common\Counter-Strike Global Offensive\game\csgo\cfg

echo Cfg dir is "%dir_cfg%"?
set /p dir_cfg_input=[ Y / other dir ]: 

if "%dir_cfg_input%"=="" goto Symlink
if /i "%dir_cfg_input%"=="y" goto Symlink
if /i "%dir_cfg_input%"=="yes" goto Symlink

set dir_cfg=%dir_cfg_input%

:Symlink

if not exist "%dir_cfg%" (
	echo Not exist: "%dir_cfg%"
	goto End
)

mklink /D "%dir_cfg%\moeshin" "%~dp0"

:End

pause
