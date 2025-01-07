mkdir -force "$env:RUNNER_TEMP\_runner_hook_state" | Out-Null
copy "c:\msys64\etc\pacman.conf" "$env:RUNNER_TEMP\_runner_hook_state\"
copy "c:\msys64\etc\pacman.d\mirrorlist.*" "$env:RUNNER_TEMP\_runner_hook_state\"
c:\msys64\msys2_shell.cmd -defterm -no-start -msys2 -c 'pacman -Qq > "$RUNNER_TEMP/_runner_hook_state/original_pkglist"'
