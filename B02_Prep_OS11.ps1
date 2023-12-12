Start-Transcript x:\logs\A02_Prep_OS.log
 
Add-Type -AssemblyName PresentationFramework
 
function Msgbox ($msg,$Type)
{
  $msgBoxInput =  [System.Windows.MessageBox]::Show($msg, 'Notification', 'OK',$Type)
 
}
 
 
$FindUSBVolume = Get-Volume | Where FileSystemLabel -eq "DATA"
	if($FindUSBVolume -ne $null)
		{
   			$FindUSBVolume = ($FindUSBVolume.DriveLetter+":")
      		}
	Else
		{
			$FindUSBVolume = $False
   		}
 
	if ($FindUSBVolume -ne $False)
		{
			$data = (get-volume | Where FileSystemLabel -eq "DATA").DriveLetter + ":"
			$boot = (get-volume | Where FileSystemLabel -eq "BOOT").DriveLetter + ":"
   		}
	Else
		{
			$data = "W:"
   		}
 
### Check Remaining space ###
If($data -ne "W:")
{
	$RemainSpace = ((Get-Volume $data.Substring(0,1) | Select-Object SizeRemaining).SizeRemaining)/1GB
	If($RemainSpace -lt 2)
		{
			Write-Host "USB DATA partition Remaining Space is low, you may encounter issue downloading OS Image or new drivers. Please consider to clear some unused Drivers in folder Dell." -ForegroundColor Red
       Msgbox("USB DATA partition Remaining Space is low, you may encounter issue downloading OS Image or new drivers. Please consider to clear some unused Drivers in folder Dell.") ("Warning")
  		}
}
$OSVersion = 'Windows 11'
$OSReleaseID = "23H2"
 
$GetOSInfo = Get-FeatureUpdate -OSVersion $OSVersion -OSReleaseID $OSReleaseID -OSArchitecture x64 -OSActivation Volume -OSLanguage en-us
 
$FileUri = $GetOSInfo.Url
$FileName = $GetOSInfo.FileName
 
 
$OSCacheLocation = "$data\OS\"
If(!(Test-Path -Path $OSCacheLocation))
    {
        Mkdir $OSCacheLocation
    }

 
###Check OS file version####
$OSCache = ls $OSCacheLocation
 
If($FileName -eq $OSCache.Name)
    {
	   $onlieHash = $GetOSInfo.SHA1.ToUpper()
       $localHash = (Get-FileHash -Path "$OSCacheLocation\$OSCache" -Algorithm SHA1).Hash.ToUpper()
     	If($onlieHash -eq $localHash)
    	{
     		Write-Host "Cache Image is a good version" -ForegroundColor Green
       	}
    	Else
    	{
     		Write-Host "Delete an old image" -ForegroundColor Yellow
        	Remove-Item -Path $OSCacheLocation -Recurse -Force
        	Write-Host "Download Latest image" -ForegroundColor Yellow
        	Save-WebFile -SourceUrl $FileUri -DestinationDirectory $OSCacheLocation -DestinationName $FileName -ErrorAction Stop
   	}
    }
Else
    {
	Write-Host "No OS image in cache or not a good version" -ForegroundColor Yellow
	Remove-Item -Path $OSCacheLocation -Recurse -Force
	Write-Host "Download Latest image" -ForegroundColor Yellow
	Save-WebFile -SourceUrl $FileUri -DestinationDirectory $OSCacheLocation -DestinationName $FileName -ErrorAction Stop
   	}
