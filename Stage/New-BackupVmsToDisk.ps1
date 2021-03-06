###
# Discovers all VMs. Takes snapshots of those VMs. 
# Builds disks based on those snapshots; putting them in 
# Author: aharri@microsoft.com
##

param(
    # resourceGroupName
    [Parameter(Mandatory=$true)]
    [string]
    $ResourceGroupName,

    # Destination RG; where snapshots/images will be placed
    [Parameter(Mandatory=$true)]
    [string]
    $DestinationResourceGroupName,

    # location
    [Parameter(Mandatory=$true)]
    [string]
    $Location,

    # Force stop?
    [Parameter(Mandatory=$false)]
    [bool]
    $StopVm = $true
)
Write-Host "[!] Starting backup process for $ResourceGroupName, Location: $Location" -ForegroundColor Yellow

$vms = Get-AzVm -ResourceGroupName $ResourceGroupName
#$date = Get-Date -Format yyyyMMdd

# stop VMs
if ($StopVm){
    Write-Host "[!] Stopping VMs to prepare them to be Snapshotted" -Foreground Yellow
    foreach ($vm in $vms){
        $vm | Stop-AzVm -Force -AsJob -StayProvisioned | Out-Null
        Write-Host "`t[ ] Stopping VM: $($vm.Name)" -ForegroundColor Cyan
    }
    Get-Job | Wait-Job
    Write-Host "[+] All VMs Stopped... proceeding" -ForegroundColor Green
}
else {
    Write-Host "[ ] Continuing to build snapshots without turning off VMs; use -ForceVmStop if want them stopped first" -Foreground Yellow
}

Write-Host "[ ] Taking snapshots of $($vms.Count) VMs" -ForegroundColor Yellow
foreach ($vm in $vms){
    Write-Host "`t[$($vm.Name)] Taking snapshot" -ForegroundColor Cyan
#   $snapshotName = "$($vm.Name)$date"
    $snapshotName = "$($vm.Name)"

    $disk = Get-AzDisk -ResourceGroupName $ResourceGroupName -DiskName $vm.StorageProfile.OsDisk.Name

    $snapshotConfig = New-AzSnapshotConfig -SourceUri $disk.Id `
        -OsType $disk.OsType `
        -CreateOption Copy `
        -Location $location `
        -AccountType Premium_LRS `
        -EncryptionSettingsEnabled $false `
        -DiskSizeGB $disk.DiskSizeGB
    $snapshot = New-AzSnapshot -Snapshot $snapshotConfig -SnapshotName $snapshotName -ResourceGroupName $DestinationResourceGroupName
    Write-Host "`t[$($vm.Name)]` Snapshot complete" -ForegroundColor Green

    Write-Host "`t[$($vm.Name)]` Converting snapshot to disk" -ForegroundColor Cyan
    $osDisk = New-AzDisk -DiskName "${snapshotName}d" `
        -Disk (New-AzDiskConfig -Location $Location -CreateOption Copy -SourceResourceId $snapshot.Id) `
        -ResourceGroupName $DestinationResourceGroupName
    Write-Host "[+] [$($vm.Name)]`t Successfully converted @ $($osDisk.Id)" -ForegroundColor Green
}
Write-Host "[!] Starting VMs back up" -ForegroundColor Yellow

foreach ($vm in $vms){
    $vm | Start-AzVM -AsJob -NoWait | Out-Null
    Write-Host "`t[ ] Starting VM: $($vm.Name)" -ForegroundColor Cyan
}
Get-Job | Wait-Job
Write-Host "[+] All VMs up and running again in $ResourceGroupName" -ForegroundColor Green