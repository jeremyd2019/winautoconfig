set DRIVE=%1

REM DISM /Apply-Image /ImageFile:dataimage_arm64.wim /Index:1 /ApplyDir:%DRIVE%
DISM /Image:%DRIVE% /Add-Driver /Driver:"%DRIVE%Windows\ConfigSetRoot\AutoUnattend_Files\winautoconfig\dist\Out-of-Box Drivers\arm64" /Recurse /ForceUnsigned
REM DISM /Image:%DRIVE% /Add-Capability /CapabilityName:OpenSSH.Server~~~~0.0.1.0 /Source:"%DRIVE%Windows\ConfigSetRoot\AutoUnattend_Files\dist\Packages\OnDemandPack\arm64_OpenSSH-Server-Package_10.0.22000.1_neutral_31bf3856ad364e35_"
