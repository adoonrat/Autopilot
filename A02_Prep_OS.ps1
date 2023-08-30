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



$OSVersion = 'Windows 10'
$OSReleaseID = "22H2"

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
    
    
