@echo off
SetLocal EnableDelayedExpansion

REM hardlink.bat
REM create hardlinks recursively for directory
REM
REM Author: Alex.wang
REM Create: 2013-02-25 13:25

set empty=
set src=%~1
set dest=%~2

REM check parmeters
if "%empty%"=="%src%" goto :HELP
if "%empty%"=="%dest%" goto :HELP
if not exist "%src%" goto :HELP

set full_src=%~f1
set full_dest=%~f2

REM check for same volume
if not %full_src:~0,1%==%full_dest:~0,1% (
	echo SOURCE and DEST is not on the same volume: %full_src:~0,1% %full_dest:~0,1%
	goto :END
)

REM copy directory structure
xcopy "%src%" "%dest%" /E /I /Q /T

REM create hardlinks
for /f "delims=" %%f in ('dir /s /b /a-d "%src%"') do (
	set parm=%%f
	fsutil hardlink create "!parm:%full_src%=%full_dest%!" "%%f"
)
goto :END


:HELP
echo %~nx0 - create hardlinks recursively for directory
echo.
echo Usage:
echo     %~nx0 SOURCE DEST
echo 	SOURCE	source directory
echo 	DEST	destination directory


:END
EndLocal
