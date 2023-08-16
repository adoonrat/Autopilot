Add-Type -AssemblyName PresentationCore, PresentationFramework

#Variable Section
$date = (Get-Date).ToString('yyyy-MM-dd')
$LogFilePath = $env:TEMP
$logfilename = "$LogFilePath\$date" + "_ImageApply.log"
$data = (get-volume | Where FileSystemLabel -eq "DATA").DriveLetter + ":"
$boot = (get-volume | Where FileSystemLabel -eq "BOOT").DriveLetter + ":"

#Apply Image

$imagefolder = ls "$data\OS"
$imagefile = $imagefolder.Name
$imagefile = "$data\OS\" + $imagefile

try {
    Write-Log "Applying Image"
    dism /Apply-Image /ImageFile:$imagefile /Index:6 /ApplyDir:W:\
}
catch {
    write-log "Ran into an issue: $PSItem" -fail
    exit
}

if (!(Test-Path "W:\Temp")) {
    mkdir "W:\Temp"
}


# Copy boot files to the System partition ==

try {
    Write-Log "Copying boot files"
    W:\Windows\System32\bcdboot W:\Windows /s S:
}
catch {
    write-log "Ran into an issue: $PSItem" -fail
    exit
}
