Start-Transcript x:\logs\A04_Apply_OS.log

#Apply Image
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
     
$imagefolder = ls "$data\OS"
$imagefile = $imagefolder.Name
$imagefile = "$data\OS\" + $imagefile

try {
    Write-host "Applying Image" -ForegroundColor Yellow
    dism /Apply-Image /ImageFile:$imagefile /Index:6 /ApplyDir:W:\
}
catch {
    Write-host "Ran into an issue: $PSItem" -ForegroundColor Red
    exit
}

if (!(Test-Path "W:\Temp")) {
    mkdir "W:\Temp"
}


# Copy boot files to the System partition ==

try {
    Write-host "Copying boot files" -ForegroundColor Yellow
    W:\Windows\System32\bcdboot W:\Windows /s S:
}
catch {
    Write-host "Ran into an issue: $PSItem" -ForegroundColor Red
    exit
}

try {
    write-host "Copying WinRE" -ForegroundColor Yellow
    md R:\Recovery\WindowsRE
    xcopy /h W:\Windows\System32\Recovery\Winre.wim R:\Recovery\WindowsRE\
}
catch {
    write-host "Ran into an issue: $PSItem" -ForegroundColor Red
    exit
}

# Register the location of the recovery tools 
try {
    write-host "Setting location of recovery tools" -ForegroundColor Yellow
    W:\Windows\System32\Reagentc /Setreimage /Path R:\Recovery\WindowsRE /Target W:\Windows | out-null
}
catch {
    write-host "Ran into an issue: $PSItem" -ForegroundColor Red
    exit
}

Stop-Transcript
