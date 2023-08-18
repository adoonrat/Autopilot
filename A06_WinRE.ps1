# Copy the Windows RE image to the    Windows RE Tools partition
try {
    Write-Log "Copying WinRE" 
    md R:\Recovery\WindowsRE
    xcopy /h W:\Windows\System32\Recovery\Winre.wim R:\Recovery\WindowsRE\
}
catch {
    write-log "Ran into an issue: $PSItem" -fail
    exit
}

# Register the location of the recovery tools 
try {
    Write-Log "Setting location of recovery tools"
    W:\Windows\System32\Reagentc /Setreimage /Path R:\Recovery\WindowsRE /Target W:\Windows | out-null
}
catch {
    write-log "Ran into an issue: $PSItem" -fail
    exit
}



#Copying Unattend.xml
Write-Log "Copying Unattend.xml to c:\windows\system32\sysprep"
$unattend = "$boot\unattend.xml"
try {
      Copy-Item -Path $unattend -Destination "W:\windows\system32\sysprep" -Force -ErrorAction Stop
}
catch {
    write-log "Ran into an issue: $PSItem" -fail
    exit
}


$stopwatch.Stop()
$ts = $stopwatch.Elapsed
$elapsedTime = [string]::Format( "{0:00} min. {1:00}.{2:00} sec.", $ts.Minutes, $ts.Seconds, $ts.Milliseconds / 10 )
Write-log "Time Elapsed:  $elapsedTime"


#Coping Log Files
try {
    Write-Log "Copying logs to C:\Temp"
    copy-item "$env:TEMP\*" "W:\Temp"-Force -Recurse -ErrorAction Stop
}
catch {
    write-log "Ran into an issue: $PSItem" -fail
    exit
}

wpeutil reboot
