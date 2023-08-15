 $USBPartitions = Get-USBPartition
        if ($USBPartitions) {
            Write-host "Removing USB drive letters"

            
                foreach ($USBPartition in $USBPartitions) {
                    if($USBPartition.DriveLetter -ne $null)
                   {
                    $RemovePartitionAccessPath = @{
                        AccessPath = "$($USBPartition.DriveLetter):"
                        DiskNumber = $USBPartition.DiskNumber
                        PartitionNumber = $USBPartition.PartitionNumber
                    }

                    Remove-PartitionAccessPath @RemovePartitionAccessPath -ErrorAction Stop
                    Start-Sleep -Seconds 3
                }
                }
            }
        
 
Clear-LocalDisk -Force -NoResults -Confirm:$false -ErrorAction Stop
Write-host "New-OSDisk"

     
                Start-OSDDiskPart
                Write-Host "=========================================================================" -ForegroundColor Cyan
                Write-Host "| SYSTEM | MSR |                    WINDOWS                  | RECOVERY |" -ForegroundColor Cyan
                Write-Host "=========================================================================" -ForegroundColor Cyan
                $LocalVolumes = Get-Volume | Where-Object {$_.DriveType -eq "Fixed"}
                Write-Output $LocalVolumes
   
                    New-OSDisk -PartitionStyle GPT -Force -ErrorAction Stop
                    Write-Host "=========================================================================" -ForegroundColor Cyan
                    Write-Host "| SYSTEM | MSR |                    WINDOWS                  | RECOVERY |" -ForegroundColor Cyan
                    Write-Host "=========================================================================" -ForegroundColor Cyan
                    #Wait a few seconds to make sure the Disk is set
                    Start-Sleep -Seconds 5
                
            

            #Make sure that there is a PSDrive 
            if (-NOT (Get-PSDrive -Name 'C')) {
                Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) OSDCloud Failed"
                Write-Warning "New-OSDisk didn't work. There is no PSDrive FileSystem at C:\"
                Write-Warning "Press Ctrl+C to exit"
                Start-Sleep -Seconds 86400
                Exit
            }
        
        #endregion
        
        #region Add-PartitionAccessPath
        if ($USBPartitions) {
            Write-SectionHeader 'Restoring USB Drive Letters'

            if ($Global:OSDCloud.IsWinPE -eq $true) {
                foreach ($USBPartition in $USBPartitions) {

                    $ParamAddPartitionAccessPath = @{
                        AssignDriveLetter = $true
                        DiskNumber = $USBPartition.DiskNumber
                        PartitionNumber = $USBPartition.PartitionNumber
                    }
                    Add-PartitionAccessPath @ParamAddPartitionAccessPath; Start-Sleep -Seconds 5
                }
            }
        }
