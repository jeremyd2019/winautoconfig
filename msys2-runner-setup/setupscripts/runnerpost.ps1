TASKKILL /F /FI "MODULES eq msys-2.0.dll"
if (test-path c:\msys64\var\lib\pacman\db.lck) {
  rm -fo c:\msys64\var\lib\pacman\db.lck
}
copy -force "$env:RUNNER_TEMP\_runner_hook_state\pacman.conf" "c:\msys64\etc\pacman.conf"
copy -force "$env:RUNNER_TEMP\_runner_hook_state\mirrorlist.*" "c:\msys64\etc\pacman.d\"
c:\msys64\msys2_shell.cmd -defterm -no-start -msys2 -c 'set -x; pacman --noconfirm --noprogressbar -Rnu $(pacman -Qq | grep -xvFf "$RUNNER_TEMP/_runner_hook_state/original_pkglist")'
c:\msys64\msys2_shell.cmd -defterm -no-start -msys2 -c 'pacman --noconfirm --noprogressbar -Syuu'
c:\msys64\msys2_shell.cmd -defterm -no-start -msys2 -c 'pacman --noconfirm --noprogressbar -Suu'
# clean up some trash under USERPROFILE
if (test-path "$env:USERPROFILE\.cache") { cmd /c "rmdir /s/q `"$env:USERPROFILE\.cache`"" }
if (test-path "$env:USERPROFILE\.cargo") { cmd /c "rmdir /s/q `"$env:USERPROFILE\.cargo`"" }
if (test-path "$env:USERPROFILE\go") { cmd /c "rmdir /s/q `"$env:USERPROFILE\go`"" }
