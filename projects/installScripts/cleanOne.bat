if (%1)==() goto exit

del /Q %1\_bin\*.exe
del /Q %1\_bin\*.bpl
del /Q %1\_bin\*.dcp
del /Q %1\_dcu\*.dcu

:exit
