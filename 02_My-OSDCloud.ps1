$OSVersion = 'Windows 10'
$OSReleaseID = "22H2"

$GetOSInfo = Get-FeatureUpdate -OSVersion $OSVersion -OSReleaseID $OSReleaseID -OSArchitecture x64 -OSActivation Volume -OSLanguage en-us | Select-Object -Property CreationDate,KBNumber,Title,UpdateOS,UpdateBuild,UpdateArch,FileName, @{Name='SizeMB';Expression={[int]($_.Size /1024/1024)}},FileUri,Hash,AdditionalHash

$FileUri = $GetOSInfo.FileUri.AbsoluteUri
$FileName = $GetOSInfo.FileName


$OSCacheLocation = "E:\OS\"
If(!(Test-Path -Path $OSCacheLocation))
    {
        Mkdir $OSCacheLocation
    }
 

###Check OS file version####
$OSCache = ls $OSCacheLocation

$ImagePath = "$OSCacheLocation"+"$FileName"
Write-Host $ImagePath

If($FileName -eq $OSCache.Name)
    {Write-Host "Image cache is a good version"}
    Else
    {
        Remove-Item -Path $OSCacheLocation -Recurse -Force
        Write-Host "Download Latest image"
        Save-WebFile -SourceUrl $FileUri -DestinationDirectory $OSCacheLocation -DestinationName $FileName -ErrorAction Stop
        
        
    }



Expand-WindowsImage -ApplyPath "C:\" -ImagePath $ImagePath -Index 6 -ScratchDirectory "C:\OSDCloud\Temp"
