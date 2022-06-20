
cd %~dp0

set hr=%time:~0,2%
if "%hr:~0,1%" equ " " set hr=0%hr:~1,1%
set mpName=..\Output\Generated Heightmaps\Map_%date:~-4,4%%date:~-10,2%%date:~-7,2%_%hr%%time:~3,2%%time:~6,2%\HeightMap.shd
set dirName=..\Output\Generated Heightmaps\Map_%date:~-4,4%%date:~-10,2%%date:~-7,2%_%hr%%time:~3,2%%time:~6,2%

set /a ran=(%random%*%random%)

md "%dirName%"

"..\Source Code\bin\GeoGen\bin\geogen.exe" -s %ran% -i "..\Map Templates\Rivers.nut" -n -o "%mpName%" 1025 6 -d "%dirName%" -a

md "..\Output\FA Maps\CGM-%ran%"
set outF=..\Output\FA Maps\CGM-%ran%\CGM-%ran%.scmap

"..\Source Code\bin\MapGenerator\Map Generator.exe" "%dirName%" 1024 1024 "%outF%" "..\Tilesets\TilesetData-8.xml" %ran%
pause