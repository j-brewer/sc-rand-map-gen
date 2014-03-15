@Echo OFf
set hr=%time:~0,2%
if "%hr:~0,1%" equ " " set hr=0%hr:~1,1%
set mpName=Maps\Map_%date:~-4,4%%date:~-10,2%%date:~-7,2%_%hr%%time:~3,2%%time:~6,2%\HeightMap.pgm
set dirName=Maps\Map_%date:~-4,4%%date:~-10,2%%date:~-7,2%_%hr%%time:~3,2%%time:~6,2%

set /a ran=(%random%*%random%)

cd "C:\Users\Jonathan\Desktop\FA Modding\Workspace\Random Map Generation\GeoGen\bin\"
md "..\..\%dirName%"

REM geogen.exe -i "..\examples\voronoi.nut" -o "..\..\%mpName%" 513 513 3 4 0 0 0 1 
REM geogen.exe -i "..\examples\clutch.nut" -o "..\..\%mpName%" 513 513 1 0 0
REM geogen.exe -i "..\examples\Truchet 2.nut" -o "..\..\%mpName%" 1025 1025 2 2 1 2 -d "..\..\%dirName%"
REM geogen.exe -i "..\examples\Moonscape.nut" -o "..\..\%mpName%" 1025 1025 1 2 2 1 -d "..\..\%dirName%"
REM geogen.exe -s %ran% -i "..\examples\Phantom Islands.nut" -n -o "..\..\%mpName%" 1025 1 2 0 1 6 8 0 -d "..\..\%dirName%"
REM geogen.exe -s %ran% -i "..\examples\Phantom Islands.nut" -n -o "..\..\%mpName%" 1025 1 1 1 1 6 10 1 -d "..\..\%dirName%"

REM geogen.exe -s %ran% -i "..\examples\Phantom Islands.nut" -n -o "..\..\%mpName%" 1025 1 1 1 3 6 10 1 -d "..\..\%dirName%"
geogen.exe -s %ran% -i "..\..\MapTemplates\Phantom Islands.nut" -n -o "..\..\%mpName%" 1025 1 1 0 3 6 8 1 0 -d "..\..\%dirName%"
cd ..
cd ..

REM set inF=C:\Users\Jonathan\Desktop\FA Modding\Workspace\Random Map Generation\EditTest\SCMP_015.scmap

md "C:\Users\Jonathan\Documents\My Games\Gas Powered Games\Supreme Commander Forged Alliance\Maps\CGM-%ran%"
set outF=C:\Users\Jonathan\Documents\My Games\Gas Powered Games\Supreme Commander Forged Alliance\Maps\CGM-%ran%\CGM-%ran%.scmap

REM "C:\Users\Jonathan\Documents\Visual Studio 2010\Projects\BuildFAMap\BuildFAMap\bin\Debug\BuildFAMap.exe" "%dirName%" 1024 1024 "%outF%" "C:\Users\Jonathan\Desktop\FA Modding\Workspace\Random Map Generation\Tilesets\TilesetData.xml" %ran%
"C:\Users\Jonathan\Documents\Visual Studio 2010\Projects\BuildFAMap\BuildFAMap\bin\Debug\BuildFAMap.exe" "%dirName%" 1024 1024 "%outF%" "C:\Users\Jonathan\Desktop\FA Modding\Workspace\Random Map Generation\Tilesets\TilesetData-8.xml" %ran%

set s1=C:\Users\Jonathan\Documents\My Games\Gas Powered Games\Supreme Commander Forged Alliance\Maps\CGM-%ran%\*.*
set d1=C:\Program Files (x86)\THQ\Gas Powered Games\Supreme Commander\maps\CGM-%ran%
md "%d1%"
copy "%s1%" "%d1%" /Y