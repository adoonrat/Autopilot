



$OSVersion = 'Windows 10'
$OSReleaseID = "22H2"

$GetOSInfo = Get-FeatureUpdate -OSVersion $OSVersion -OSReleaseID $OSReleaseID -OSArchitecture x64 -OSActivation Volume -OSLanguage en-us | Select-Object -Property CreationDate,KBNumber,Title,UpdateOS,UpdateBuild,UpdateArch,FileName, @{Name='SizeMB';Expression={[int]($_.Size /1024/1024)}},FileUri,Hash,AdditionalHash

$FileUri = $GetOSInfo.FileUri.AbsoluteUri
$FileName = $GetOSInfo.FileName


$OSCacheLocation = "X:\OS"
If(!(Test-Path -Path $OSCacheLocation))
    {
        Mkdir $OSCacheLocation
    }
 

###Check OS file version####
$OSCache = ls C:\OSDCloud\OS\
If($FileName -eq $OSCache.Name)
    {Write-Host "Image cache is a good version"}
    Else
    {
        Remove-Item -Path X:\OS\
        Write-Host "Download Latest image"
        Save-WebFile -SourceUrl $FileUri -DestinationDirectory 'C:\temp\AMAOSDCloud\OS' -ErrorAction Stop
    }

$ParamNewItem = @{
            Path = 'C:\OSDCloud\Temp'
            ItemType = 'Directory'
            Force = $true
            ErrorAction = 'Stop'
        }
        if (-NOT (Test-Path 'C:\OSDCloud\Temp')) {
            Write-DarkGrayHost -Message 'Creating ScratchDirectory C:\OSDCloud\Temp'
            $null = New-Item @ParamNewItem
        }

        $ExpandWindowsImage = @{
            ApplyPath = 'C:\'
            ImagePath = $Global:OSDCloud.ImageFileDestination.FullName
            Index = $Global:OSDCloud.OSImageIndex
            ScratchDirectory = 'C:\OSDCloud\Temp'
            ErrorAction = 'Stop'
        }
        $Global:OSDCloud.ExpandWindowsImage = $ExpandWindowsImage
        if ($Global:OSDCloud.IsWinPE -eq $true) {
            Write-DarkGrayHost -Message 'Expand-WindowsImage'
            Expand-WindowsImage @ExpandWindowsImage
        }
