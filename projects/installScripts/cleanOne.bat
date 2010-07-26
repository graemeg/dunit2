if (%1)==() goto exit

for %%i in (%1\_bin\*.exe,%1\_bin\*.bpl,%1\_bin\*.dcp,%1\_dcu\*.dcu) do if exist %%i del /Q %%i

:exit
