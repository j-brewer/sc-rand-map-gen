@ECHO OFF
cd %~dp0
robocopy %1\config %2\config /MIR /R:0
if errorlevel 16 EXIT 16
if errorlevel 15 EXIT 15
if errorlevel 14 EXIT 14
if errorlevel 13 EXIT 13
if errorlevel 12 EXIT 12
if errorlevel 11 EXIT 11
if errorlevel 10 EXIT 10
if errorlevel 9 EXIT 9
if errorlevel 8 EXIT 8

robocopy %1\overlays %2\overlays /MIR /IS /R:0
if errorlevel 16 EXIT 16
if errorlevel 15 EXIT 15
if errorlevel 14 EXIT 14
if errorlevel 13 EXIT 13
if errorlevel 12 EXIT 12
if errorlevel 11 EXIT 11
if errorlevel 10 EXIT 10
if errorlevel 9 EXIT 9
if errorlevel 8 EXIT 8

robocopy %1\examples %2\examples /MIR /IS /R:0
if errorlevel 16 EXIT 16
if errorlevel 15 EXIT 15
if errorlevel 14 EXIT 14
if errorlevel 13 EXIT 13
if errorlevel 12 EXIT 12
if errorlevel 11 EXIT 11
if errorlevel 10 EXIT 10
if errorlevel 9 EXIT 9
if errorlevel 8 EXIT 8
EXIT 0