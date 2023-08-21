#Add-Type -AssemblyName PresentationCore, PresentationFramework
Start-Transcript x:\A04_Apply_OS.log
#Variable Section
#$date = (Get-Date).ToString('yyyy-MM-dd')
#$LogFilePath = $env:TEMP
#$logfilename = "$LogFilePath\$date" + "_ImageApply.log"
#$data = (get-volume | Where FileSystemLabel -eq "DATA").DriveLetter + ":"
#$boot = (get-volume | Where FileSystemLabel -eq "BOOT").DriveLetter + ":"



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
    Write-host "Applying Image"
    dism /Apply-Image /ImageFile:$imagefile /Index:6 /ApplyDir:W:\
}
catch {
    Write-host "Ran into an issue: $PSItem" -fail
    exit
}

if (!(Test-Path "W:\Temp")) {
    mkdir "W:\Temp"
}


# Copy boot files to the System partition ==

try {
    Write-host "Copying boot files"
    W:\Windows\System32\bcdboot W:\Windows /s S:
}
catch {
    Write-host "Ran into an issue: $PSItem" -fail
    exit
}

Stop-Transcript
