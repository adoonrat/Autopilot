Start-Transcript x:\logs\A01_ClearDisk.log
        
Write-Host "Formatting Drive" -ForegroundColor Yellow
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

Stop-Transcript
