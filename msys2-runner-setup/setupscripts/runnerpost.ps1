TASKKILL /F /FI "MODULES eq msys-2.0.dll"
if (test-path c:\msys64\var\lib\pacman\db.lck) {
  rm -fo c:\msys64\var\lib\pacman\db.lck
}
c:\msys64\msys2_shell.cmd -defterm -no-start -msys2 -c 'pacman --noconfirm --noprogressbar -Syuu'
c:\msys64\msys2_shell.cmd -defterm -no-start -msys2 -c 'pacman --noconfirm --noprogressbar -Suu'
c:\msys64\msys2_shell.cmd -defterm -no-start -msys2 -c 'set -x; pacman --noconfirm --noprogressbar -Rnu $(pacman -Qq | grep -xvFf "$RUNNER_TEMP/_original_pkglist")'
# clean up some trash under USERPROFILE
if (test-path "$env:USERPROFILE\.cache") { rm -r -fo "$env:USERPROFILE\.cache" }
if (test-path "$env:USERPROFILE\.cargo") { rm -r -fo "$env:USERPROFILE\.cargo" }
if (test-path "$env:USERPROFILE\go") { rm -r -fo "$env:USERPROFILE\go" }
