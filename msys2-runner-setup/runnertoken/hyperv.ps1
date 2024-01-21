cd "C:\ProgramData\Microsoft\Windows\Virtual Hard Disks"
new-vhd -parentpath .\$($args[0]) -path "$($args[1]).vhdx"
new-vm -name $($args[1]) -memorystartupbytes 8GB -vhdpath .\$($args[1]).vhdx -switchname "Default Switch" | set-vm -processorcount 2 -checkpointtype disabled -passthru | add-vmdvddrive -path ${Env:USERPROFILE}\winautoconfig\msys2-runner-setup\setup.iso
