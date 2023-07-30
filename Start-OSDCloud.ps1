Start-OSDCloud -OSName 'Windows 10 22H2 x64' -OSLanguage en-us -OSEdition Enterprise -ZTI

mkdir c:\temp
copy c:\OSDCloud\Logs\*.log c:\temp\ /y
rmdir /s /q c:\OSDCloud
rmdir /s /q c:\Drivers

wpeutil reboot

#-OSBuild 22H2 

