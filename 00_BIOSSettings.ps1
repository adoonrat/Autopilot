Import-Module DellBIOSProvider
Add-Type -AssemblyName PresentationFramework
$SataMode = dir DellSmbios:\SystemConfiguration\EmbSataRaid | Select -ExpandProperty CurrentValue

function Msgbox ($msg)
{
    
  $msgBoxInput =  [System.Windows.MessageBox]::Show($msg, 'Confirmation', 'OK','Error')

  switch  ($msgBoxInput) {

      'OK' {
          	## Action Here
            Write-Host "Sata mode not set to Ahci, review all BIOS settings. Rebooting...."
	          #wpeutil reboot
            # Exit 69
          }
    }

}


$SupportModels = @(
"Latitude 5410",
"Latitude 5420",
"Latitude 5430",
"Latitude 5440",
"Latitude 7330",
"Latitude 7340",
"Precision 3550",
#"Precision 3560",
"Precision 3570",
"Precision 3571",
"Precision 3580"

)


$Model = $((Get-WmiObject -Class Win32_ComputerSystem).Model).Trim()

if(-not($Model -in $SupportModels))
	{
 		Msgbox("This device is not a support model. Press OK to acknowledge and shutdown.")
		wpeutil shutdown
	}


If ($SataMode -ne "Ahci")
    	{
    		Msgbox("Sata mode is not set to Ahci, please review BIOS settings before attempting to deploy. Press OK to restart.")
    		wpeutil reboot
	}

