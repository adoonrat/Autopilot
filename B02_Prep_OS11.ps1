Start-Transcript x:\logs\A02_Prep_OS.log

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
  		}
}
$OSVersion = 'Windows 11'
$OSReleaseID = "23H2"

$GetOSInfo = Get-FeatureUpdate -OSVersion $OSVersion -OSReleaseID $OSReleaseID -OSArchitecture x64 -OSActivation Volume -OSLanguage en-us | Select-Object -Property CreationDate,KBNumber,Title,UpdateOS,UpdateBuild,UpdateArch,FileName, @{Name='SizeMB';Expression={[int]($_.Size /1024/1024)}},FileUri,Hash,AdditionalHash

$FileUri = $GetOSInfo.FileUri.AbsoluteUri
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
       	$CacheSize = ($OSCache.Length)/1MB
	$CacheSize = [math]::Round($CacheSize)
 	$CloudSize = $GetOSInfo.SizeMB
	  	
   	If($CacheSize -gt $CloudSize)
   		{$Dif = $CacheSize - $CloudSize}
    	Else
     		{$Dif = $CloudSize - $CacheSize}
    	
     	If($Dif -lt 1)
    	{
     		Write-Host "Cache Image is a good version" -ForegroundColor Green
       	}
    	Else
    	{
     		Write-Host "Delete an old image" -ForegroundColor Yellow
        	Remove-Item -Path $OSCacheLocation -Recurse -Force
        	Write-Host "Download Latest image" -ForegroundColor Yellow
        	#Save-WebFile -SourceUrl $FileUri -DestinationDirectory $OSCacheLocation -DestinationName $FileName -ErrorAction Stop
	 	$File = "$OSCacheLocation\$FileName"
	 	Invoke-WebRequest -URi $FileUri -OutFile $File -UseBasicParsing
   	}
    }
Else
    {
	Write-Host "No OS image in cache or not a good version" -ForegroundColor Yellow
	Remove-Item -Path $OSCacheLocation -Recurse -Force
	Write-Host "Download Latest image" -ForegroundColor Yellow
	#Save-WebFile -SourceUrl $FileUri -DestinationDirectory $OSCacheLocation -DestinationName $FileName -ErrorAction Stop
 	$File = "$OSCacheLocation\$FileName"
	Invoke-WebRequest -URi $FileUri -OutFile $File -UseBasicParsing
   	}
    
    
