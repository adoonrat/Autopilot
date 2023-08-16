#Apply Drivers

    try {
        Write-Log "Applying Drivers"
        dism.exe /image:W:\ /Add-Driver /driver:"W:\Drivers" /recurse
    }
    catch {
        write-log "Ran into an issue: $PSItem"  -fail
        exit
    }
