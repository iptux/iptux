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
echo 6. install apk to device
echo 7. install framework-res.apk
echo 8. clean workspace
echo 0. exit
set /p choose=enter your choise:
if "%choose%"=="1" set /p apk=enter apk name:
if "%choose%"=="2" if "%apk%" neq "%empty%" call :DECODE "%apk%"
if "%choose%"=="3" if "%apk%" neq "%empty%" call :BUILD "%apk%"
if "%choose%"=="4" if "%apk%" neq "%empty%" call :SIGN "out\%apk%b.apk"
if "%choose%"=="5" if "%apk%" neq "%empty%" call :BUILDANDSIGN "%apk%"
if "%choose%"=="6" if exist "out\%apk%bs.apk" adb install -r "out\%apk%bs.apk"
if "%choose%"=="7" if exist framework-res.apk call :FRAMEWORK framework-res.apk
if "%choose%"=="8" if "%apk%" neq "%empty%" rmdir /s /q "%apk%"
if "%choose%"=="0" goto :END
GOTO :MENU


:UNPACKANDUNDEX
echo unpack: "%~1.apk"
unzip "%~1.apk" classes.dex -d "%~1"
echo undex: "%~1/classes.dex"
java -jar baksmali.jar --output "%~1/smali" "%~1/classes.dex"
GOTO :END


:REDEXANDREPACK
echo redex: "%~1/smali"
java -jar smali.jar --output "%~1/classes.dex" -- "%~1/smali"

echo pack: "out/%~1b.apk"
copy /y "%~1.apk" "out/%~1b.zip"
cd "%~1"
zip -u "../out/%~1b.zip" classes.dex
cd ..
move /y "out/%~1b.zip" "out/%~1b.apk"
GOTO :END


:BUILDANDSIGN
REM subcommand: build and sign
call :BUILD "%~1"
call :SIGN "out\%~1b.apk"
GOTO :END


:DECODE
echo decode apk: "%~1.apk"
call apktool decode -f --keep-broken-res "%~1.apk" "%~1"
if not exist "%~1/apktool.yml" call :UNPACKANDUNDEX "%~1"
GOTO :END


:BUILD
echo build apk: "out\%~1b.apk"
if exist "%~1/apktool.yml" (
	call apktool build "%~1" "out\%~1b.apk"
) else (
	call :REDEXANDREPACK "%~1"
)
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
