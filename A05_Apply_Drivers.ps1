Start-Transcript x:\A05_Apply_Drivers.log

#Add-Type -AssemblyName PresentationCore, PresentationFramework

#Variable Section
#$date = (Get-Date).ToString('yyyy-MM-dd')
#$LogFilePath = $env:TEMP
#$logfilename = "$LogFilePath\$date" + "_ImageApply.log"



#Apply Drivers

    try {
        Write-host "Applying Drivers"
        dism.exe /image:W:\ /Add-Driver /driver:"W:\Drivers" /recurse
    }
    catch {
        write-host "Ran into an issue: $PSItem" 
        exit
    }

Stop-Transcript
