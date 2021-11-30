start taskmgr
SET "_cmd=cmd /k ping 127.0.0.1 -n 11 ^> NUL ^& \runner\run.cmd ^& shutdown -s -t 10"
where /q wt
IF ERRORLEVEL 1 (
	start %_cmd%
) ELSE (
	start wt nt %_cmd% ; nt
)
