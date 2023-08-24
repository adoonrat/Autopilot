Start-Transcript x:\logs\A06_Finalization.log

<#
#Copying Unattend.xml
write-host "Copying Unattend.xml to c:\windows\system32\sysprep"
$unattend = "$boot\unattend.xml"
try {
      $Unattended = [xml]@"
<?xml version="1.0" encoding="utf-8"?>
<!--Version 2.3-->
<unattend xmlns="urn:schemas-microsoft-com:unattend">
    <settings pass="windowsPE">
        <component name="Microsoft-Windows-International-Core-WinPE" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <SetupUILanguage>
                <UILanguage>en-US</UILanguage>
            </SetupUILanguage>
            <InputLocale>en-US</InputLocale>
            <SystemLocale>en-US</SystemLocale>
            <UILanguage>en-US</UILanguage>
            <UserLocale>en-US</UserLocale>
        </component>
    </settings>
    <settings pass="specialize">
        <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <ComputerName>*</ComputerName>
            <RegisteredOrganization>Amadeus DTS</RegisteredOrganization>
            <RegisteredOwner>Amadeus DTS</RegisteredOwner>
            <WindowsFeatures>
                <ShowInternetExplorer>false</ShowInternetExplorer>
            </WindowsFeatures>
        </component>
        <component name="Microsoft-Windows-Deployment" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <RunSynchronous>
                <RunSynchronousCommand wcm:action="add">
                    <Description>UnfilterAdminToken</Description>
                    <Path>cmd /c reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v FilterAdministratorToken /t REG_DWORD /d 0 /f</Path>
                    <Order>1</Order>
                </RunSynchronousCommand>
                <RunSynchronousCommand wcm:action="add">
                    <Description>Disable consumer features</Description>
                    <Path>reg add HKLM\Software\Policies\Microsoft\Windows\CloudContent /v DisableWindowsConsumerFeatures /t REG_DWORD /d 1 /f</Path>
                    <Order>2</Order>
                </RunSynchronousCommand>
            </RunSynchronous>
        </component>
    </settings>
    <cpi:offlineImage cpi:source="wim:c:/temp/sw_dvd9_win_pro_10_21h2.4_64bit_english_pro_ent_edu_n_mlf_x23-08263/sources/install.wim#Windows 10 Enterprise" xmlns:cpi="urn:schemas-microsoft-com:cpi" />
</unattend>
"@

$Unattended.Save("x:\unattend.xml")
Copy-Item -Path x:\unattend.xml -Destination w:\windows\system32\sysprep\ -Force
}
catch {
    write-host "Ran into an issue: $PSItem"
    exit
}

#>
#Coping Log Files
try {
    write-host "Copying logs to C:\Temp\OSDLogs"
    if (!(Test-Path "W:\Temp\OSDLogs")) {
    mkdir "W:\Temp\OSDLogs"
}
    copy-item "x:\logs\*.log" "W:\Temp\OSDLogs"-Force -Recurse -ErrorAction Stop
}
catch {
    write-host "Ran into an issue: $PSItem" -fail
    exit
}

#wpeutil reboot
Stop-Transcript
