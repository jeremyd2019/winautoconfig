@ECHO OFF
SETLOCAL

SET MYDIR="%~dp0"
CALL "%MYDIR%\vars.cmd"

CALL :parsegitver

REM TODO put this in Unattend.xml at some point
sc config WSearch start= disabled

CD /D "%TEMP%"

curl -Lo terminal-preinstall.zip https://github.com/microsoft/terminal/releases/download/v%WINTERMVERSION%/Microsoft.WindowsTerminal_%WINTERMVERSION%_8wekyb3d8bbwe.msixbundle_Windows10_PreinstallKit.zip
MKDIR term
tar -C term -xvf terminal-preinstall.zip
CALL :installterminal

curl -Lo git64.exe "https://github.com/git-for-windows/git/releases/download/%GITTAGVERSION%/Git-%GITVERSION%-64-bit.exe"
START /wait git64.exe /VERYSILENT /NORESTART /NOCANCEL /SP- /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS /LOADINF="%MYDIR%\git64.inf"

SET MSYS2URL=https://github.com/msys2/msys2-installer/releases/download
IF [%MSYS2VERSION%]==[nightly] (
	SET MSYS2URL=%MSYS2URL%/nightly-x86_64/msys2-base-x86_64-latest.sfx.exe
) ELSE (
	SET MSYS2URL=%MSYS2URL%/%MSYS2VERSION%/msys2-base-x86_64-%MSYS2VERSION:-=%.sfx.exe
)
curl -Lo msys2-base-x86_64.sfx.exe "%MSYS2URL%"
"%TEMP%\msys2-base-x86_64.sfx.exe" -y -oC:\
CALL C:\msys64\msys2_shell.cmd -defterm -no-start -c "true"
CALL C:\msys64\msys2_shell.cmd -defterm -no-start -c "pacman --noconfirm --overwrite '*' -Syuu && true"
CALL C:\msys64\msys2_shell.cmd -defterm -no-start -c "mv -f /etc/pacman.conf.pacnew /etc/pacman.conf"
CALL C:\msys64\msys2_shell.cmd -defterm -no-start -c "pacman --noconfirm --overwrite '*' -Syuu"
CALL C:\msys64\msys2_shell.cmd -defterm -no-start -c "pacman --noconfirm --overwrite '*' -Sy --needed base-devel mingw-w64-clang-aarch64-toolchain procps-ng psmisc vim etc-update"
CALL C:\msys64\msys2_shell.cmd -defterm -no-start -c "pacman --noconfirm -Scc"
CALL C:\msys64\msys2_shell.cmd -defterm -no-start -c "echo export EDITOR=vim >> ~/.bash_profile"

curl -Lo actions-runner-arm64.zip "https://github.com/actions/runner/releases/download/v%RUNNERVERSION%/actions-runner-win-arm64-%RUNNERVERSION%.zip"
MKDIR C:\runner
tar -C C:\runner -xvf actions-runner-arm64.zip
CD /D C:\runner
CALL config.cmd --unattended --url %RUNNERREGURL% --token %RUNNERREGTOKEN% --replace --labels "%RUNNERLABELS%" --runnergroup "%RUNNERGROUP%"

COPY /Y "%MYDIR%\shell.cmd" "%USERPROFILE%\shell.cmd"
COPY /Y "%MYDIR%\msys2.cmd" "%USERPROFILE%\msys2.cmd"
COPY /Y "%MYDIR%\wkill.sh" "C:\msys64\home\%USERNAME%\wkill.sh"
COPY /Y "%MYDIR%\runner.env" "C:\runner\.env"
COPY /Y "%MYDIR%\runnerpre.ps1" "C:\"
COPY /Y "%MYDIR%\runnerpost.ps1" "C:\"

REG ADD "HKCU\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v Shell /t REG_SZ /d "%USERPROFILE%\shell.cmd" /f

ECHO Done

shutdown /r /t 10

GOTO :eof

:parsegitver
SETLOCAL EnableDelayedExpansion
SET _count=1
FOR %%v IN (%GITVERSION:.= %) DO (
	IF !_count! EQU 1 (
		SET GITTAGVERSION=v%%v
	) ELSE IF !_count! LEQ 3 (
		SET GITTAGVERSION=!GITTAGVERSION!.%%v
	) ELSE (
		SET GITTAGVERSION=!GITTAGVERSION!.windows.%%v
	)
	SET /a _count+=1
)
IF %_count% LEQ 4 SET GITTAGVERSION=%GITTAGVERSION%.windows.1
ENDLOCAL & SET GITTAGVERSION=%GITTAGVERSION%
GOTO :eof

:installterminal
SETLOCAL EnableDelayedExpansion

REM Windows 11 24H2 doesn't like the 32-bit arm Xaml package
CALL :getbuild
IF %BUILD% GEQ 26100 DEL term\*_arm_*.appx

FOR %%i IN (term\*.msixbundle) DO SET MSIX=%%i
FOR %%i IN (term\*_License1.xml) DO SET LIC=%%i
SET DEPS=
FOR %%i in (term\*.appx) DO SET DEPS=!DEPS! /DependencyPackagePath:%%i

DISM /Online /Add-ProvisionedAppxPackage /PackagePath:%MSIX% /LicensePath:%LIC% %DEPS%

ENDLOCAL
GOTO :eof

:getbuild
SETLOCAL
FOR /F "tokens=6 delims=[]. " %%i IN ('ver') DO SET BUILD=%%i
ENDLOCAL & SET BUILD=%BUILD%
GOTO :eof
