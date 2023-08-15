Write-Host "Downloading ADKsetup.exe..."
    $downloads = "$env:USERPROFILE\downloads"
    Invoke-WebRequest "https://go.microsoft.com/fwlink/?linkid=2120254" -OutFile $downloads\adksetup.exe
    
    Write-Host "Installing ADK for Windows 10"
    start-process -FilePath "$downloads\adksetup.exe" -ArgumentList "/quiet /features OptionId.DeploymentTools" -Wait
    
    Write-Host "Downloading ADKWinpesetup.exe..."
    Invoke-WebRequest "https://go.microsoft.com/fwlink/?linkid=2120253" -OutFile $downloads\adkwinpesetup.exe
    Write-Host "Installing ADK WinPE for Windows 10"
    start-process -FilePath "$downloads\adkwinpesetup.exe" -ArgumentList "/quiet /features OptionId.WindowsPreinstallationEnvironment" -Wait

    Write-Host "Installing OSDCloud Powershell Module"
    Install-Module OSD -Force
