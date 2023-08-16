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


#Apply Drivers

    try {
        Write-Log "Applying Drivers"
        dism.exe /image:W:\ /Add-Driver /driver:"W:\Drivers" /recurse
    }
    catch {
        write-log "Ran into an issue: $PSItem"  -fail
        exit
    }
