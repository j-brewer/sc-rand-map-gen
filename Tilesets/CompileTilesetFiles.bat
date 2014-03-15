@Echo Off
cd %~dp0
cd "TilesetData-8 Import"
 
for /f %%f in ('dir /b *.xml') do call :PROCESSFILE %%f
pause
goto END

:PROCESSFILE
"..\..\Source Code\bin\TilesetUtility\TilesetUtillity.exe" -combinetilesets "%1" "..\TilesetData-8.xml"

:END