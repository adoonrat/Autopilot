Import-Module DellBIOSProvider
Add-Type -AssemblyName PresentationFramework
$SataMode = dir DellSmbios:\SystemConfiguration\EmbSataRaid | Select -ExpandProperty CurrentValue

function BIOSSetingMsgbox ()
{
    
  $msgBoxInput =  [System.Windows.MessageBox]::Show('Sata mode is not set to Ahci, please review BIOS settings before attempting to deploy. Press OK to restart.', 'Confirmation', 'OK','Error')

  switch  ($msgBoxInput) {

      'OK' {
          	## Action Here
            Write-Host "Sata mode not set to Ahci, review all BIOS settings. Rebooting...."
	          wpeutil reboot
            # Exit 69
          }
    }

}

If ($SataMode -ne "Ahci")
    {BIOSSetingMsgbox}

