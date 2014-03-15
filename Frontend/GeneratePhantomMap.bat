
cd %~dp0

set hr=%time:~0,2%
if "%hr:~0,1%" equ " " set hr=0%hr:~1,1%
set mpName=..\Output\Generated Heightmaps\Map_%date:~-4,4%%date:~-10,2%%date:~-7,2%_%hr%%time:~3,2%%time:~6,2%\HeightMap.pgm
set dirName=..\Output\Generated Heightmaps\Map_%date:~-4,4%%date:~-10,2%%date:~-7,2%_%hr%%time:~3,2%%time:~6,2%

set /a ran=(%random%*%random%)

md "%dirName%"

"..\Source Code\bin\GeoGen\geogen.exe" -s %ran% -i "..\Map Templates\Phantom Islands.nut" -n -o "%mpName%" 1025 1 1 0 3 6 8 1 0 -d "%dirName%"

md "..\Output\FA Maps\CGM-%ran%"
set outF=..\Output\FA Maps\CGM-%ran%\CGM-%ran%.scmap

"..\Source Code\bin\MapGenerator\Map Generator.exe" "%dirName%" 1024 1024 "%outF%" "..\Tilesets\TilesetData-8.xml" %ran%