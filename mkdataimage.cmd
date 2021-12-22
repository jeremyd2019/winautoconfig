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

CALL wimcapture.cmd dataimage dataimage.wim DataImage --no-acls
