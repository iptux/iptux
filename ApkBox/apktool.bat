@Echo off
REM SetLocal EnableDelayedExpansion

REM apktool.bat
REM call apktool
REM
REM Author: Alex.wang
REM Create: 2012-11-14 16:41

java -jar "%~dp0apktool.jar" %*

REM EndLocal
Exit /b
