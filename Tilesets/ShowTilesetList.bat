@Echo Off
cd %~dp0
 
for /f %%f in ('dir /b *.xml') do call :PROCESSFILE %%f
pause
goto END

:PROCESSFILE
"..\Source Code\bin\TilesetUtility\TilesetUtillity.exe" -gettilesetlist "%1"

:END