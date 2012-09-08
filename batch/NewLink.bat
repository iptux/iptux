@Echo off
SetLocal EnableDelayedExpansion


REM NewLink.bat
REM 创建命令行下的快捷方式（.bat文件）
REM
REM licence: GNU GPL 2.0
REM 版本: 0.11
REM 作者: Tommy(seed12@163.com)
REM
REM TODO:
REM   检查环境变量 %path%
REM   简化 start 变量生成逻辑
REM
REM Change Log:
REM Update: 2010-09-16 22:39 (from v0.10)
REM   1. never use 'exit' in outfile
REM   2. add 'generate' information in outfile
REM   3. backup logfile in -r option.
REM
REM 升级: 2010-01-03 02:26 (from v0.09)
REM   1. 修复了 -d 选项失效的问题。
REM
REM 升级：2010-01-02 22:31 (from v0.08)
REM   1. 将注释，输出等由英文改为中文，并添加了部分注释。
REM   2. 增加 -r 选项。
REM   3. 设置退出代码 %exit% (可供 -r 选项使用)。
REM
REM 升级: 2009-12-30 00:02 (from v0.07)
REM   1. 输出增加 'SetLocal' 和 'EndLocal' 命令以防止产生 %prog% 环境变量。
REM   2. Vim 的 .bat(evim, gview, gvim, gvimdiff, view, vim, vimdiff, vimtutor) 升级到v7.2 (来自官方安装包)。
REM
REM 升级: 2009-12-09 19:54 (from v0.06)
REM   1. 增加了日志特性。日志文件可用来恢复全部快捷方式。
REM
REM 升级: 2009-09-06 22:02 (from v0.05)
REM   1. 在 .bat 中检查 %prog% 是否存在。
REM
REM 升级: 2009-09-05 10:41 (from v0.04)
REM   1. 修复了 %dirctory% 中包含空格时 .bat 不能正确启动的错误。
REM   2. 增加了 -d 选项。
REM
REM 升级: 2009-08-24 14:29 (from v0.03)
REM   1. 增加了 -o 选项。
REM   2. 增强了选项的处理。
REM
REM 升级: 2009-08-23 20:52 (from v0.02)
REM   1. 检查 D:\Bat\ (默认 .bat 输出文件夹)是否存在。
REM   2. 设置 GUI 程序的起始目录(%dirctory%)。
REM
REM 升级: 2009-08-23 01:34 (from v0.01)
REM   1. 在参数检查中使用 "%~1" 替代 "%1"。
REM      此特性避免了 PROGRAME 包含空格而必须使用 '"' 而产生的启动失败的错误。
REM
REM 创建: 2009-08-22 23:08 版本v0.01


REM 预定义变量
REM 空字符串
Set empty=
REM will be 'start "" /D"DIRECTORY"' if GUI application
Set start=
REM 放置快捷方式的地方（默认为当前文件夹，v0.08前默认为D:\Bat\）
Set dir=%~dp0
REM 日志文件（默认为NewLink.log）
Set log=%~dpn0.log
REM 脚本名，输出错误信息时使用
Set my=%~nx0
REM 版本信息
Set version=0.11
REM 目标文件
Set prog=
REM 退出代码 0-正常 1-命令行参数错误 2-其他错误
Set exit=0

:: Echo %path% | Findstr /i "%dir%">nul
:: if ErrorLevel 1 (
:: 	Echo %my%: 警告：%dir% 不在 %%path%% 变量中，可能造成如下错误：
:: 	Echo 'XXX' 不是内部或外部命令，也不是可运行的程序或批处理文件。
:: )

REM 检查命令行选项
if "%~1" EQU "%empty%" Goto USAGE

:LOOP
REM 与上句的不同是：此处全部选项已经检查完毕
if "%~1" EQU "%empty%" Goto START

REM 显示帮助
if /I "%~1" EQU "--help" Goto USAGE
if /I "%~1" EQU "-h" Goto USAGE
if /I "%~1" EQU "/?" Goto USAGE

REM 显示版本信息
if /I "%~1" EQU "--version" Goto VERSION
if /I "%~1" EQU "-v" Goto VERSION

REM 选项 -g 的处理
if /I "%~1" EQU "-g" (
	if "%start%" EQU "%empty%" (
		Set start=start ""
		shift
		Goto LOOP
	) Else (
		Echo %my%: 选项 -c 和 -g 不能同时使用
		Set exit=1
		Goto EOF
	)
)

REM 选项 -c 的处理
if /I "%~1" EQU "-c" (
	if "%start%" NEQ "%empty%" (
		Echo %my%: 选项 -g 和 -c 不能同时使用
		Set exit=1
		Goto EOF
	)
	Set start=
	shift
	Goto LOOP
)

REM 选项 -o 的处理
if /I "%~1" EQU "-o" (
	if /I "%~x2" NEQ "%empty%" if /I "%~x2" NEQ ".bat" (
		Echo %my%: 输出文件的扩展名必须是 .bat
		Set exit=1
		Goto EOF
	)
	Set outfile=%dir%%~n2.bat
	shift
	shift
	Goto LOOP
)

REM 选项 -d 的处理
REM 如 MATLAB 等软件的起始目录应设置为 %MATLAB%\work
if /I "%~1" EQU "-d" (
	Echo %~2 | Findstr ":">nul && Echo %~2 | Findstr "\\">nul
	if ErrorLevel 1 (
		Echo %my%: 非法起始目录: %~2
		Set exit=1
		Goto EOF
	)
	rem if "%dirctory%" EQU "%empty%" Echo %~2 | Set /p dirctory=
	if not Exist "%~2" (
		Echo %my%: 起始目录: "%~2" 不存在
		Set exit=1
		Goto EOF
	)
	set dirctory=%~2
	shift
	shift
	Goto LOOP
)

REM 选项 -r 的处理
if /I "%~1" EQU "-r" (
	REM if no other option found
	if "%~2" EQU "%empty%" if "%dirctory%" EQU "%empty%" if "%start%" EQU "%empty%" if "%prog%" EQU "%empty%" if "%outfile%" EQU "%empty%" (
		if not exist %log% ( Echo %my%: 没有什么可恢复的。 ) && Goto EOF

		REM backup logfile, only backup once a day
		for /f %%i in ("%date%") do Set backup=%%i
		if not exist %log%.!backup! ( Copy /y %log% %log%.!backup! > NUL )

		move %log% %~dpn0.txt
		set NewLinkForce=1
		REM FIXME: if call fail, the line will not appear in new logfile
		for /f "delims=" %%i in (%~dpn0.txt) do call %0 %%i
		del /f /q /a %~dpn0.txt
		Goto EOF
	)
	Echo %my%: -r 选项不能和其他选项同时使用
	Set exit=1
	Goto EOF
)

REM 检查其他选项
Set tmp=%~1
if /I "%tmp:~0,1%" EQU "-" (
	Echo %my%: 未知选项: %1
	Set exit=1
	Goto EOF
)

REM 现在 %1 应该是目标文件 PROGRAME
if "%prog%" NEQ "%empty%" (
	Echo %my%: 多余的参数: %1
	Set exit=1
	Goto EOF
)

REM 有效路径检查
Echo %~1 | Findstr ":">nul && Echo %~1 | Findstr "\\">nul
if ErrorLevel 1 (
	Echo %my%: 无效的完整路径: %~1
	Set exit=1
	Goto EOF
)

REM .exe 扩展名检查
if /I "%~x1" NEQ ".exe" (
	Echo %my%: %1 不是一个 .exe 文件
	Set exit=1
	Goto EOF
)

REM 目标文件有效性检查
Set prog=%~dpnx1
if Not Exist "%prog%" (
	Echo %my%: 目标文件 "%prog%" 不存在
	REM Echo Why would you want to link to a nonexistent file?
	Set exit=1
	Goto EOF
)

if "%outfile%" EQU "%empty%" Set outfile=%dir%%~n1.bat
Set exe=%~n1
REM 设置起始目录
if "%dirctory%" NEQ "%empty%" (
	if "%start%" EQU " " (
		Echo %my%: 选项 -d 与 -c 不能同时使用
		Set exit=1
		Goto EOF
	)
	if "%dirctory%" NEQ "%~dp1" Set start=start ""
) else if "%start%" NEQ " " if "%start%" NEQ "%empty%" Set dirctory=%~dp1
shift

REM 循环检查所有参数
Goto LOOP


REM 所有参数已检查完毕
REM 一切 ok，准备创建快捷方式

:START
if "!dirctory!" NEQ "!empty!" Set start=!start! /D"!dirctory!"

REM 检查将输出文件是否已存在
if not defined NewLinkForce if Exist %outfile% (
	Echo %my%: 快捷方式 %outfile% 已经存在。
	Set exit=2
	Goto EOF
)

REM This is a buildin feature of cmd.exe
REM 获取日期和时间
REM Date /T | Set date=
REM Time /T | Set time=

REM v0.09 版后输出目录是此文件所在目录，可不检查
REM 检查输出目录是否存在
REM If Not Exist %dir% mkdir %dir%

REM 开始创建快捷方式
REM use > instead of >> will overwrite exist file
Echo @Echo off> %outfile%
Echo SetLocal EnableDelayedExpansion>> %outfile%
Echo.>> %outfile%
Echo REM 命令行下启动 %exe% >> %outfile%
Echo REM>> %outfile%
REM Echo REM 作者: Tommy>> %outfile%
Echo REM Generated by: %my% %version%>> %outfile%
Echo REM 时间: %date% %time%>> %outfile%
Echo.>> %outfile%
Echo Set prog=%prog%>> %outfile%
Echo.>> %outfile%
Echo If Not Exist "%%prog%%" (>> %outfile%
Echo 	Echo %%~nx0: 文件不存在: "%%prog%%">> %outfile%
Echo 	Goto EOF>> %outfile%
Echo )>> %outfile%
Echo.>> %outfile%
Echo %start% "%%prog%%" %%*>> %outfile%
Echo.>> %outfile%
Echo :EOF>> %outfile%
Echo EndLocal>> %outfile%
REM Don't do that
REM Echo Exit /b>> %outfile%
Echo.>> %outfile%
Echo 已经为 "%prog%" 创建了快捷方式：%outfile%
Echo %* >> %log%
Goto EOF


:USAGE
Echo Usage: %~nx0 [OPTION] [PROGRAME]
Echo 创建命令行下的快捷方式(.bat文件)
Echo.
Echo   PROGRAME	目标文件的完整路径
Echo   -c		指定 PROGRAME 是一个命令行界面的程序(默认)
Echo   -d DIR	将起始目录设置成 DIR (暗含 -g)
Echo   -g		指定 PROGRAME 是一个图形界面程序
Echo   -o NAME[.bat]	设置输出文件名(i.e. out.bat)
Echo   -r		从日志文件中恢复所有快捷方式(不能与其他选项同时使用)
Echo   --help	显示帮助信息
Echo   --version	显示版本信息
Goto EOF


:VERSION
Echo %~nx0 %version%
Echo 创建命令行下的快捷方式(.bat文件)
Echo Licence: GNU GPL 2.0 (具体见 license.txt)
Goto EOF


:EOF
EndLocal
Exit /b %exit%
