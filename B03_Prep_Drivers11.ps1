Start-Transcript x:\logs\A03_Prep_Drivers.log

$data = (get-volume | Where FileSystemLabel -eq "DATA").DriveLetter + ":"
$boot = (get-volume | Where FileSystemLabel -eq "BOOT").DriveLetter + ":"


function Driver-Download {
    #Download Catalog file

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
     
    $source = "http://downloads.dell.com/catalog/DriverPackCatalog.cab"
    $catalog = "$data\Dell\DriverPackCatalog.cab"
    Write-host "Downloading driver catalog file from $source"
    if (!(Test-Path "$data\Dell\")) {
        mkdir "$data\Dell\"
    }
    try {
        Invoke-WebRequest -URi $source -OutFile $catalog -Verbose
    }
    catch {
        Write-host -Message "Error downloading dell catalog file. Error: $PSItem " -ForegroundColor Red
        exit
                
    }
    #parse Catalog file
    $catalogXMLFile = "$data\Dell\DriverPackCatalog.xml"
    Write-host "Expanding catalog cab file..."
    try {
        EXPAND $catalog $catalogXMLFile
    }
    catch {
        Write-host "Error Expanding catalog cab file. Error: $PSItem" -ForegroundColor Red
        exit
    }


    #Find Model Info
    [xml]$catalogXMLDoc = Get-Content $catalogXMLFile
    $Model = $((Get-WmiObject -Class Win32_ComputerSystem).Model).Trim()
    Write-host "Model: $model" -ForegroundColor Yellow
    Write-host "Parsing catalog xml to get model specific driver CAB and download URL"  -ForegroundColor Yellow
    $cabSelected = $catalogXMLDoc.DriverPackManifest.DriverPackage | ? { ($_.SupportedSystems.Brand.Model.name -eq "$model") -and ($_.type -eq "Win") -and ($_.SupportedOperatingSystems.OperatingSystem.osCode -eq "Windows11" ) } | sort type

    #Cab Information
    $cabsource = "http://" + $catalogXMLDoc.DriverPackManifest.baseLocation + "/" + $cabSelected.path
    Write-host "Source Cab download location: $cabsource" -ForegroundColor Yellow
    $Filename = [System.IO.Path]::GetFileName($cabsource)

    $folder = $data + "\Dell\$model"
    $destination = $data + "\Dell\$model\" + $Filename

    Write-host "Destination download location: $destination"  -ForegroundColor Yellow

    if (Test-Path $destination) {
        Write-host "$destination file already exists. Checking file hash ..." -ForegroundColor Yellow
        $hash = Get-FileHash $destination -Algorithm MD5
        Write-host "Original MD5 hash: $(@($cabSelected.hashMD5))" -ForegroundColor Yellow
        Write-host "Current MD5 file hash: $(@($hash.hash))" -ForegroundColor Yellow

        if ($hash.hash -ne $cabSelected.hashMD5) {
            try {
                Write-host "Hashes don't match, redownloading Dell Driver pack for $model to $folder..." -ForegroundColor Red
		#rd $folder /s /q
  		Remove-Item $folder -Recurse -force
                Invoke-WebRequest -URi $cabsource -OutFile $destination -UseBasicParsing
		#Save-WebFile -SourceUrl $cabsource -DestinationDirectory $folder -ErrorAction Stop
                $hash = Get-FileHash $destination -Algorithm MD5
                Write-host "Updated file hash: $(@($hash.hash))"  -ForegroundColor Yellow
            }
            catch {
                Write-host "Ran into an issue: $PSItem"  -ForegroundColor Red
                exit
            }

        }
        else {
            Write-host "Hashes match. No need to re-download." -ForegroundColor Green
        }

    }
    else {
        if (!(Test-Path $folder)) {
            mkdir $folder
        }
        try {
            Write-host "Driver cab missing from USB. Downloading Dell Driver pack for $model..."
            #Invoke-WebRequest -URi $cabsource -OutFile $destination -UseBasicParsing
	    Save-WebFile -SourceUrl $cabsource -DestinationDirectory $folder -ErrorAction Stop
        }
        catch {
            Write-host "Ran into an issue: $PSItem" -ForegroundColor Red
            exit
        }


    }


    $global:foldermodel = "W:\Drivers"
    if (!(test-path "$global:foldermodel")) {
        Write-host "Extracting Dell Cab to W:\Drivers" -ForegroundColor Yellow
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
