@Echo off
SetLocal EnableDelayedExpansion


REM 8684bus.bat
REM Download 8684 bus database from 8684.cn
REM
REM Author: Tommy Alex
REM Create: 2011-12-17 13:49
REM
REM After download, move 8684 directory to SD card and enjoy!


REM XXX: this URL may change, check it on http://mobile.8684.cn
set url=http://update1.8684.cn/down/
set outdir=8684

if not exist %outdir% mkdir %outdir%


REM download
for /f %%c in (8684bus.lst) do (
	if not exist "%outdir%\%%c" call wget -O "%outdir%\%%c" "%url%%%c"
)

REM not a wise way to get the date
for /f %%d in ("!date!") do (
	REM make a backup
	set mydate=%%d
	set mydate=!mydate:-=!
	zip -9 -r 8684bus-!mydate!.zip .
)


:END
EndLocal
Exit /b

