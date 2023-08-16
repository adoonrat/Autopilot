 $USBPartitions = Get-USBPartition
        if ($USBPartitions) {
            Write-host "Removing USB drive letters"

            
                foreach ($USBPartition in $USBPartitions) {
                   
                    $RemovePartitionAccessPath = @{
                        AccessPath = "$($USBPartition.DriveLetter):"
                        DiskNumber = $USBPartition.DiskNumber
                        PartitionNumber = $USBPartition.PartitionNumber
                    }

                    Remove-PartitionAccessPath @RemovePartitionAccessPath -ErrorAction Stop
                    Start-Sleep -Seconds 3
                }
                
            }



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
assign letter="C"
create partition primary
format quick fs=ntfs label="Recovery"
assign letter="R"
set id="de94bba4-06d1-4d40-a16a-bfd50179d6ac"
gpt attributes=0x8000000000000001
list volume
exit
"@
$command | Diskpart


        #region Add-PartitionAccessPath
        if ($USBPartitions) {
           # Write-SectionHeader 'Restoring USB Drive Letters'

         
                foreach ($USBPartition in $USBPartitions) {

                    $ParamAddPartitionAccessPath = @{
                        AssignDriveLetter = $true
                        DiskNumber = $USBPartition.DiskNumber
                        PartitionNumber = $USBPartition.PartitionNumber
                    }
                    Add-PartitionAccessPath @ParamAddPartitionAccessPath; Start-Sleep -Seconds 5
                }
            
        }
