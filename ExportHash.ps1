Set-ExecutionPolicy -ExecutionPolicy Unrestricted
Install-Script -Name Get-WindowsAutopilotInfo -Force
$SN = ((wmic bios get serialnumber)[2]).split(" ")[0]
If(!(Test-Path -Path C:\temp\))
{mkdir C:\temp}
Get-WinDowsAutopilotInfo.ps1 -GroupTag WOOB -OutputFile C:\temp\Hash-$SN.csv
