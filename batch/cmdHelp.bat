@Echo off
SetLocal EnableDelayedExpansion


REM cmdHelp.bat
REM get all help of cmd's builtin command
REM
REM Author: Tommy
REM Create: 2010-12-17 21:36


for /f "tokens=1 skip=1" %%c in ('help') do (
	help %%c > %%c.txt
	if not ErrorLevel 1 del /f /q %%c.txt
)


EndLocal

