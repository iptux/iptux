@Echo off
SetLocal EnableDelayedExpansion

REM apk.bat
REM apk decode and rebuild tool
REM
REM Author: Alex.wang
REM Create: 2012-11-14 16:57


set empty=
set apk=

if not exist out mkdir out


if "%~1" equ "%empty%" GOTO :MENU
for %%a in (%*) do (
	if exist %%a (
		call :BUILD "%%a"
		call :SIGN "out\%%ab.apk"
	) else if exist %%a.apk (
		call :DECODE %%a
	)
)
GOTO :END


:MENU
echo.
echo apk name: %apk%
REM show main menu
echo 1. set apk name
echo 2. decode apk
echo 3. rebuild apk
echo 4. sign apk
echo 5. rebuild and sign apk
echo 6. install framework-res.apk
echo 7. clean workspace
echo 0. exit
set /p choose=enter your choise:
if "%choose%"=="1" set /p apk=enter apk name:
if "%choose%"=="2" if "%apk%" neq "%empty%" call :DECODE "%apk%"
if "%choose%"=="3" if "%apk%" neq "%empty%" call :BUILD "%apk%"
if "%choose%"=="4" if "%apk%" neq "%empty%" call :SIGN "out\%apk%b.apk"
if "%choose%"=="5" if "%apk%" neq "%empty%" call :BUILDANDSIGN "%apk%"
if "%choose%"=="6" if exist framework-res.apk call :FRAMEWORK framework-res.apk
if "%choose%"=="7" if "%apk%" neq "%empty%" rmdir /s /q "%apk%"
if "%choose%"=="0" goto :END
GOTO :MENU


:BUILDANDSIGN
REM subcommand: build and sign
call :BUILD "%~1"
call :SIGN "out\%~1b.apk"
GOTO :MENU


:DECODE
echo decode apk: "%~1.apk"
call apktool decode -f --keep-broken-res "%~1.apk" "%~1"
REM exit
GOTO :END


:BUILD
echo build apk: "out\%~1b.apk"
call apktool build "%~1" "out\%~1b.apk"
GOTO :END


:FRAMEWORK
echo install framework: %*
call apktool install-framework %*
GOTO :END


:SIGN
if exist "%~1" (
	echo signing apk: "%~1"
	call signapk "%~f1" "%~dpn1s%~x1
)
GOTO :END


:END
EndLocal
Exit /b
