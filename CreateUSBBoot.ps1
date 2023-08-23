<#
    .NOTES
    USB preparation for PCLifecycle - Woob
    October 2022 - Santiago Pastor
    Original credit: Brooks Peppin, www.brookspeppin.com
    .DESCRIPTION
    Detect USB and prepare partitions to boot UEFI with Secure Boot

#>

If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
	# Relaunch as an elevated process:
	Start-Process powershell.exe "-File", ('"{0}"' -f $MyInvocation.MyCommand.Path) -Verb RunAs
	exit
}

Write-host "Detecting USB drives..."
Get-Disk | where({ $_.BusType -eq 'USB' }) | select Number, FriendlyName, Model, @{ Name = "TotalSize"; Expression = { "{0:N2}" -f ($_.Size/1GB) } } | out-host #Listing drives that ARE USB
Write-host "Please select the correct drive number to format (enter drive number only). For example: 1"
$drivenumber = Read-Host

if($drivenumber -eq "0")
{
	Write-Host "You have selected drive 0, which is generally your internal HD. Double-check to make sure this is correct." -foreground "red"
	Get-Disk | where({ $_.BusType -eq 'USB' }) | select Number, FriendlyName, Model, @{ Name = "TotalSize"; Expression = { "{0:N2}" -f ($_.Size/1GB) } } | out-host #Listing drives that ARE USB
Write-host "Please select the correct drive to USB drive to format (enter drive number only). Enter disk number only. For example: 1 "
	$drivenumber = Read-Host
	
}
Write-host "You have selected the following drive to format."
Write-Host  "Please ensure this is correct as the drive will be completely formatted! " -ForegroundColor Red
Get-Disk $drivenumber | select Number, FriendlyName, Model, @{ Name = "TotalSize"; Expression = { "{0:N2}" -f ($_.Size/1GB) } } | out-host
Write-Host "Is this correct? (y/n)" -foreground "yellow"
$confirmation = Read-Host
if ($confirmation -eq 'y')
{
	write-host "Drive $drivenumber confirmed. Continuing..."
}
else
{
	exit
}
	
	$command = @"
select disk $drivenumber
clean
convert mbr
create partition primary size=1000
create partition primary
select partition 1
online volume
format fs=fat32 quick label=BOOT
assign 
active
select partition 2
format fs=ntfs quick label=DATA
assign  
exit
"@
	$command | Diskpart
