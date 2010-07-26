rem @echo off
set log=cleanAll.log
if exist %log% del %log%
for /d %%i in (..\D*) do call .\cleanOne.bat "%%i" >> %log%
more < %log%
pause