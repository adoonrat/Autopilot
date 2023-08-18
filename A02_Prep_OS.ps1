$version = "1.5"
Add-Type -AssemblyName PresentationCore, PresentationFramework

#Variable Section
$date = (Get-Date).ToString('yyyy-MM-dd')
$LogFilePath = $env:TEMP
$logfilename = "$LogFilePath\$date" + "_ImageApply.log"
$dest = "C:\Dell"
$stopwatch = [system.diagnostics.stopwatch]::StartNew()

$FindUSBVolume = Get-Volume | Where FileSystemLabel -eq "DATA"
	if (Test-Path ($FindUSBVolume.DriveLetter+":")
 		{
			$data = (get-volume | Where FileSystemLabel -eq "DATA").DriveLetter + ":"
			$boot = (get-volume | Where FileSystemLabel -eq "BOOT").DriveLetter + ":"
   		}
	Else
 		{
			$data = "W:"
   		}

#$data = (get-volume | Where FileSystemLabel -eq "DATA").DriveLetter + ":"
#$boot = (get-volume | Where FileSystemLabel -eq "BOOT").DriveLetter + ":"

$imagefolder = ls "$data\OS"
$imagefile = $imagefolder.Name
$imagefile = "$data\OS\" + $imagefile

#Functions
function Write-Log {

    Param (
        [Parameter(Mandatory = $true)]
        [string]$Message,
        [switch]$fail
    )
	
    If ((Test-Path $LogFilePath) -eq $false) {
        mkdir $LogFilePath
    }
	
    $time = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $time + '...' + $Message | Out-File -FilePath $logfilename -Append
    if ($fail) {
        Write-Host $Message -ForegroundColor Red
    }
    else {
        Write-Host $Message
    }

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
    {Write-Host "Cache Image is a good version"}
    Else
    {
        Remove-Item -Path $OSCacheLocation -Recurse -Force
        Write-Host "Download Latest image"
        Save-WebFile -SourceUrl $FileUri -DestinationDirectory $OSCacheLocation -DestinationName $FileName -ErrorAction Stop
    }
