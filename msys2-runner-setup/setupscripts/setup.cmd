@ECHO OFF
SETLOCAL

SET MYDIR="%~dp0"
CALL "%MYDIR%\vars.cmd"

CALL :parsegitver

CD /D "%TEMP%"

curl -Lo terminal-preinstall.zip https://github.com/microsoft/terminal/releases/download/v%WINTERMVERSION%/Microsoft.WindowsTerminal_%WINTERMVERSION%_8wekyb3d8bbwe.msixbundle_Windows10_PreinstallKit.zip
MKDIR term
tar -C term -xvf terminal-preinstall.zip
FOR %%i IN (term\*.msixbundle) DO SET MSIX=%%i
FOR %%i IN (term\*_License1.xml) DO SET LIC=%%i
DISM /Online /Add-ProvisionedAppxPackage /PackagePath:%MSIX% /LicensePath:%LIC%

curl -Lo git64.exe "https://github.com/git-for-windows/git/releases/download/%GITTAGVERSION%/Git-%GITVERSION%-64-bit.exe"
START /wait git64.exe /VERYSILENT /NORESTART /NOCANCEL /SP- /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS /LOADINF="%MYDIR%\git64.inf"

curl -Lo msys2-base-x86_64.sfx.exe "https://github.com/msys2/msys2-installer/releases/download/%MSYS2VERSION%/msys2-base-x86_64-%MSYS2VERSION:-=%.sfx.exe"
"%TEMP%\msys2-base-x86_64.sfx.exe" -y -oC:\
CALL C:\msys64\msys2_shell.cmd -defterm -no-start -c "/usr/bin/sed -i -e 's/^\(SigLevel\s\+=\s\+Required\)\s*$/\1 DatabaseNever/' /etc/pacman.conf"
CALL C:\msys64\msys2_shell.cmd -defterm -no-start -c "pacman --noconfirm --overwrite '*' -Syuu && true"
CALL C:\msys64\msys2_shell.cmd -defterm -no-start -c "mv -f /etc/pacman.conf.pacnew /etc/pacman.conf && sed -i -e 's/^\(SigLevel\s\+=\s\+Required\)\s*$/\1 DatabaseNever/' /etc/pacman.conf"
CALL C:\msys64\msys2_shell.cmd -defterm -no-start -c "pacman --noconfirm --overwrite '*' -Suu"
CALL C:\msys64\msys2_shell.cmd -defterm -no-start -c "sed -i -e '/\[msys\]/i [clang32]\nInclude = /etc/pacman.d/mirrorlist.mingw\n\n[clangarm64]\nInclude = /etc/pacman.d/mirrorlist.mingw\n' /etc/pacman.conf"
CALL C:\msys64\msys2_shell.cmd -defterm -no-start -c "pacman --noconfirm --overwrite '*' -Sy --needed base-devel git mingw-w64-clang-aarch64-toolchain procps-ng psmisc zip unzip etc-update"
CALL C:\msys64\msys2_shell.cmd -defterm -no-start -c "pacman --noconfirm -Scc"

curl -Lo actions-runner-arm64.zip "https://github.com/jeremyd2019/runner/releases/download/v%RUNNERVERSION%/actions-runner-win-arm64-%RUNNERVERSION%.zip"
MKDIR C:\runner
CALL C:\msys64\msys2_shell.cmd -defterm -no-start -here -c "unzip -o actions-runner-arm64.zip -d /c/runner"
CD /D C:\runner
CALL config.cmd --unattended --url %RUNNERREGURL% --token %RUNNERREGTOKEN% --replace --ephemeral

COPY /Y "%MYDIR%\shell.cmd" "%USERPROFILE%\shell.cmd"
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
