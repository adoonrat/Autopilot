$date = (Get-Date).ToString('yyyy-MM-dd')
$LogFilePath = $env:TEMP
$logfilename = "$LogFilePath\$date" + "_ImageApply.log"
$dest = "C:\Dell"
$stopwatch = [system.diagnostics.stopwatch]::StartNew()
$data = (get-volume | Where FileSystemLabel -eq "DATA").DriveLetter + ":"
$boot = (get-volume | Where FileSystemLabel -eq "BOOT").DriveLetter + ":"
$imagefile = $data + "\sources\install.wim"

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

#Set High Perf
try {
    Write-Log "Setting high performance mode"
    powercfg /s 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
}
catch {
    write-log "Ran into an issue: $PSItem" -fail
    exit
}

#https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/oem-deployment-of-windows-desktop-editions-sample-scripts?preserve-view=true&view=windows-10#-createpartitions-uefitxt
Write-Host "Formatting Drive"
$command = @"
select disk 0
clean
convert gpt
create partition efi size=100
format quick fs=fat32 label="System"
assign letter="S"
create partition msr size=16
create partition primary 
shrink minimum=700
format quick fs=ntfs label="Windows"
assign letter="W"
create partition primary
format quick fs=ntfs label="Recovery"
assign letter="R"
set id="de94bba4-06d1-4d40-a16a-bfd50179d6ac"
gpt attributes=0x8000000000000001
list volume
exit
"@
$command | Diskpart
