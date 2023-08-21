# Copy the Windows RE image to the    Windows RE Tools partition
try {
    Write-Log "Copying WinRE" 
    md R:\Recovery\WindowsRE
    xcopy /h W:\Windows\System32\Recovery\Winre.wim R:\Recovery\WindowsRE\
}
catch {
    write-log "Ran into an issue: $PSItem" -fail
    exit
}

# Register the location of the recovery tools 
try {
    Write-Log "Setting location of recovery tools"
    W:\Windows\System32\Reagentc /Setreimage /Path R:\Recovery\WindowsRE /Target W:\Windows | out-null
}
catch {
    write-log "Ran into an issue: $PSItem" -fail
    exit
}

<#

#Copying Unattend.xml
Write-Log "Copying Unattend.xml to c:\windows\system32\sysprep"
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
                <RunSynchronousCommand wcm:action="add">
                    <Description>DISABLE_UAC_EnableLUA</Description>
                    <Path>cmd /c reg ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v EnableLUA /t REG_DWORD /d 0 /f</Path>
                    <Order>3</Order>
                </RunSynchronousCommand>
                <!--RunSynchronousCommand wcm:action="add">
                    <Path>Dism /online /enable-feature /featurename:NetFX3 /All /Source:C:\Temp\sxs /LimitAccess</Path>
                    <Order>4</Order>
                    <Description>DISM .net</Description>
                </RunSynchronousCommand-->
            </RunSynchronous>
        </component>
    </settings>
    <cpi:offlineImage cpi:source="wim:c:/temp/sw_dvd9_win_pro_10_21h2.4_64bit_english_pro_ent_edu_n_mlf_x23-08263/sources/install.wim#Windows 10 Enterprise" xmlns:cpi="urn:schemas-microsoft-com:cpi" />
</unattend>
"@

$Unattended.Save("w:\windows\system32\sysprep\unattend.xml")
}
catch {
    write-log "Ran into an issue: $PSItem" -fail
    exit
}

#>

$stopwatch.Stop()
$ts = $stopwatch.Elapsed
$elapsedTime = [string]::Format( "{0:00} min. {1:00}.{2:00} sec.", $ts.Minutes, $ts.Seconds, $ts.Milliseconds / 10 )
Write-log "Time Elapsed:  $elapsedTime"


#Coping Log Files
try {
    Write-Log "Copying logs to C:\Temp"
    copy-item "$env:TEMP\*" "W:\Temp"-Force -Recurse -ErrorAction Stop
}
catch {
    write-log "Ran into an issue: $PSItem" -fail
    exit
}

#wpeutil reboot
