if (%1)==() goto exit

for %%i in (%1\_bin\*.exe,%1\_bin\*.bpl,%1\_bin\*.dcp,%1\_dcu\*.dcu) do del /Q %%i

:exit
