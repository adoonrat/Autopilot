Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force

Import-Module DellBIOSProvider
Import-Module OSD

If(!(Test-Path -Path "X:\logs"))
    {
        Mkdir "X:\logs"
    }
    


Start-Transcript x:\logs\A00_Prerequisite.log

Add-Type -AssemblyName PresentationFramework
$SataMode = dir DellSmbios:\SystemConfiguration\EmbSataRaid | Select -ExpandProperty CurrentValue

function Msgbox ($msg,$Type)
{
    
  $msgBoxInput =  [System.Windows.MessageBox]::Show($msg, 'Notification', 'OK',$Type)

}

$BootVersionFile = 'X:\BootVersion.txt'
$Version = 'Ver=13092023'

If (Test-Path $BootVersionFile)
    {
        $BootVersion = Get-Content $BootVersionFile
        If($BootVersion -ne $Version)
        {
            ###PROMPT####
            Msgbox("A new USB Boot file is available. Kindly proceed to update the USB Boot file. You may resume the deployment by clicking the OK button.") ("Warning")
        }
    }
    Else
    {

    ###PROMPT####
    Msgbox("A new USB Boot file is available. Kindly proceed to update the USB Boot file. You may resume the deployment by clicking the OK button.") ("Warning")
    }


$SupportModels = @(
"Latitude 7390",
"Latitude 5410",
"Latitude 5420",
"Latitude 5430",
"Latitude 5440",
"Latitude 7330",
"Latitude 7340",
"Precision 3550",
"Precision 3560",
"Precision 3570",
"Precision 3571",
"Precision 3580"

)


$Model = $((Get-WmiObject -Class Win32_ComputerSystem).Model).Trim()

if(-not($Model -in $SupportModels))
	{
 		Msgbox("This device $Model is not supported. Press OK to acknowledge and initiate a shutdown.") ("Error")
		wpeutil shutdown
	}


If ($SataMode -ne "Ahci")
    	{
     		If ($SataMode -ne $null)
		{
    		Msgbox("Sata mode is not set to Ahci, please review BIOS settings by follow Bios Configuration document before attempting to deploy. Press OK to restart.") ("Error")
    		wpeutil reboot
      		}
	}

