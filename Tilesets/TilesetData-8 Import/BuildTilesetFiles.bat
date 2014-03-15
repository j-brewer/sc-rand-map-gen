@Echo Off
cd %~dp0
 
for /f %%f in ('dir /b *.lua') do call :PROCESSFILE %%f
goto END

:PROCESSFILE
@setlocal enableextensions enabledelayedexpansion
set str1=%1
if not x%str1:Props=%==x%str1% GOTO END
"..\..\Source Code\bin\TilesetUtility\TilesetUtillity.exe" "%1"

endlocal

:END