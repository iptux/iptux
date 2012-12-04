@Echo off
SetLocal EnableDelayedExpansion

REM smali_clean.bat
REM clean some smali code
REM
REM Author: Alex.wang
REM Create: 2012-11-14 18:35

set empty=

set apk=%~1
if "%apk%" equ "%empty%" goto :HELP
if not exist "%apk%" goto :END
shift

for %%a in (%*) do (
	for /f %%f in ('grep -E -R -l "%%a" %apk%\smali 2^>nul') do (
		echo sed -r -i -e "/invoke.*%%a/ s,^^,#," %%f
		sed -r -i -e "/invoke.*%%a/ s,^^,#," %%f 2>nul
	)
	grep -E -R -n "%%a" %apk%\smali 2>nul | grep -v -E ':#' 2>nul
)
GOTO :END


:HELP
echo smali_clean.bat - clean some smali code
echo Usage: smali_clean APK KEYWORD...
echo Example: smali_clean apk_dir com.umeng com.baidu
echo.


:END
EndLocal
Exit /b
