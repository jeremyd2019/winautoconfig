setlocal
set _confset=%1
if "%_confset%"=="" set _confset=confset

mkdir dataimage\Recovery\AutoApply\CustomizationFiles
mkdir dataimage\Windows\OEM\CustomizationFiles
mkdir dataimage\Windows\ConfigSetRoot\AutoUnattend_Files
mkdir dataimage\Windows\Panther

copy /y %_confset%\AutoUnattend.xml dataimage\Windows\Panther\Unattend.xml
copy /y %_confset%\AutoUnattend.xml dataimage\Recovery\AutoApply\Unattend.xml
xcopy /h/e %_confset%\AutoUnattend_Files dataimage\Windows\ConfigSetRoot\AutoUnattend_Files
copy /y "%_confset%\$OEM$\$$\OEM\CustomizationFiles\*.*" dataimage\Windows\OEM\CustomizationFiles
copy /y "%_confset%\$OEM$\$$\OEM\CustomizationFiles\*.*" dataimage\Recovery\AutoApply\CustomizationFiles

icacls dataimage\Recovery\Customizations /grant:r *S-1-5-32-544:(F) /T
icacls dataimage\Recovery\Customizations /inheritance:r /T
icacls dataimage\Recovery\Customizations /grant:r SYSTEM:(F) /T
icacls dataimage\Recovery\OEM /grant:r *S-1-5-32-544:(F) /T
icacls dataimage\Recovery\OEM /inheritance:r /T
icacls dataimage\Recovery\OEM /grant:r SYSTEM:(F) /T
icacls dataimage\Recovery\AutoApply /grant:r *S-1-5-32-544:(F) /T
icacls dataimage\Recovery\AutoApply /inheritance:r /T
icacls dataimage\Recovery\AutoApply /grant:r SYSTEM:(F) /T

dism /Capture-Image /ImageFile:dataimage.wim /CaptureDir:dataimage /Name:DataImage
