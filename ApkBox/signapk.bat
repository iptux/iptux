@Echo off
REM SetLocal EnableDelayedExpansion

REM signapk.bat
REM call signapk
REM
REM Author: Alex.wang
REM Create: 2012-11-14 16:44

set empty=

if "%~1" equ "%empty%" GOTO :HELP
if /i "%~x1" neq ".apk" GOTO :HELP
if "%~2" equ "%empty%" GOTO :HELP
if /i "%~x2" neq ".apk" GOTO :HELP

set dir=%~dp0signapk

java -jar "%dir%\signapk.jar" -w "%dir%\testkey.x509.pem" "%dir%\testkey.pk8" "%~1" "%~2"
GOTO :END


:HELP
echo signapk.bat
echo Usage: signapk.bat input_tobesigned.apk output_signed.apk
echo.


:END
REM EndLocal
Exit /b
