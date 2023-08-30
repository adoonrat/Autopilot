Start-Transcript x:\logs\A05_Apply_Drivers.log

    try {
        Write-host "Applying Drivers" -ForegroundColor Yellow
        dism.exe /image:W:\ /Add-Driver /driver:"W:\Drivers" /recurse
    }
    catch {
        write-host "Ran into an issue: $PSItem" -ForegroundColor Red
        exit
    }

Stop-Transcript
