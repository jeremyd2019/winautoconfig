@ECHO OFF
SETLOCAL EnableDelayedExpansion
FOR /F %%g IN ('mountvol ^| FINDSTR /E [A-Z]:\\') DO (
	VOL %%~dg >NUL 2>NUL
	IF NOT ERRORLEVEL 1 IF EXIST %%gSETUP.CMD CALL %%gSETUP.CMD
)
