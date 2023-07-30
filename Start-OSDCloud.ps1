Start-OSDCloud -OSName 'Windows 10 22H2 x64' -OSLanguage en-us -OSEdition Enterprise -SkipAutopilot -ZTI

if (!(Test-Path c:\temp)){New-Item -ItemType Directory -Force -Path "C:\temp"}
Copy-Item -Path c:\OSDCloud\Logs\*.log -Destination c:\temp\ -Force
Remove-Item -Path C:\OSDCloud\ -Recurse
Remove-Item -Path C:\Drivers\ -Recurse

wpeutil reboot


