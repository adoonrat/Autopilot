Add-Type -AssemblyName PresentationCore, PresentationFramework

#Variable Section
$date = (Get-Date).ToString('yyyy-MM-dd')
$LogFilePath = $env:TEMP
$logfilename = "$LogFilePath\$date" + "_ImageApply.log"
# $dest = "C:\Dell"
$stopwatch = [system.diagnostics.stopwatch]::StartNew()
$data = (get-volume | Where FileSystemLabel -eq "DATA").DriveLetter + ":"
$boot = (get-volume | Where FileSystemLabel -eq "BOOT").DriveLetter + ":"

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



function Driver-Download {
    #Download Catalog file
    #ipconfig

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
    #$data = (get-volume | Where FileSystemLabel -eq "DATA").DriveLetter + ":"
    $source = "http://downloads.dell.com/catalog/DriverPackCatalog.cab"
    $catalog = "$data\Dell\DriverPackCatalog.cab"
    Write-Log "Downloading driver catalog file from $source"
    if (!(Test-Path "$data\Dell\")) {
        mkdir "$data\Dell\"
    }
    try {
        Invoke-WebRequest -URi $source -OutFile $catalog -Verbose
    }
    catch {
        Write-Log -Message "Error downloading dell catalog file. Error: $PSItem " -fail
        exit
                
    }
    #parse Catalog file
    $catalogXMLFile = "$data\Dell\DriverPackCatalog.xml"
    Write-Log "Expanding catalog cab file..."
    try {
        EXPAND $catalog $catalogXMLFile
    }
    catch {
        Write-Log "Error Expanding catalog cab file. Error: $PSItem" -fail
        exit
    }


    #Find Model Info
    [xml]$catalogXMLDoc = Get-Content $catalogXMLFile
    $Model = $((Get-WmiObject -Class Win32_ComputerSystem).Model).Trim()
    Write-Log "Model: $model"
    write-Log "Parsing catalog xml to get model specific driver CAB and download URL"
    $cabSelected = $catalogXMLDoc.DriverPackManifest.DriverPackage | ? { ($_.SupportedSystems.Brand.Model.name -eq "$model") -and ($_.type -eq "Win") -and ($_.SupportedOperatingSystems.OperatingSystem.osCode -eq "Windows10" ) } | sort type

    #Cab Information
    $cabsource = "http://" + $catalogXMLDoc.DriverPackManifest.baseLocation + "/" + $cabSelected.path
    Write-Log "Source Cab download location: $cabsource"
    $Filename = [System.IO.Path]::GetFileName($cabsource)

    $folder = $data + "\Dell\$model"
    $destination = $data + "\Dell\$model\" + $Filename

    Write-Log "Destination download location: $destination"

    if (Test-Path $destination) {
        Write-Log "$destination file already exists. Checking file hash"
        $hash = Get-FileHash $destination -Algorithm MD5
        Write-Log "Original MD5 hash: $(@($cabSelected.hashMD5))"
        Write-Log "Current MD5 file hash: $(@($hash.hash))"

        if ($hash.hash -ne $cabSelected.hashMD5) {
            try {
                Write-Log "Hashes don't match, redownloading Dell Driver pack for $model to $folder..."
		rd $folder /s /q
                #Invoke-WebRequest -URi $cabsource -OutFile $destination -UseBasicParsing
		Save-WebFile -SourceUrl $cabsource -DestinationDirectory $folder -ErrorAction Stop
                $hash = Get-FileHash $destination -Algorithm MD5
                Write-Log "Updated file hash: $(@($hash.hash))"
            }
            catch {
                write-log "Ran into an issue: $PSItem" -fail
                exit
            }

        }
        else {
            Write-Log "Hashes match. No need to re-download."
        }

    }
    else {
        if (!(Test-Path $folder)) {
            mkdir $folder
        }
        try {
            Write-Log "Driver cab missing from USB. Downloading Dell Driver pack for $model..."
            #Invoke-WebRequest -URi $cabsource -OutFile $destination -UseBasicParsing
	    Save-WebFile -SourceUrl $cabsource -DestinationDirectory $folder -ErrorAction Stop
        }
        catch {
            write-log "Ran into an issue: $PSItem" -fail
            exit
        }


    }

    <#     Write-Log "Copying cab file to OS drive"
    try {
        echo f | xcopy $destination 'W:\Dell\DriverPack.cab' /f /s /y
    }
    catch {
        Write-log "Error copy cab file"
    } #>
    $global:foldermodel = "W:\Drivers"
    if (!(test-path "$global:foldermodel")) {
        Write-Log "Extracting Dell Cab to W:\Drivers" #Note it's W:\ in WinPE
        mkdir $global:foldermodel | out-null
        EXPAND $destination -F:* $global:foldermodel | Out-Null
    }
    if ($destination.contains(".exe")) {
        start-process -filepath $destination -argumentlist "/s /e=$global:foldermodel" -Wait
    	}

}

###### END Driver-Download Function


Driver-Download


Stop-Transcript
