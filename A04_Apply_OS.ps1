#Apply Image - Enterprise is Index 3
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
