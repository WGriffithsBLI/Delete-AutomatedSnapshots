#Script to sequentially take snapshots for a defined list of VMs based on a Ticket Number
#Developed by Will Griffiths Email: wgriffiths@huskynet.ca
#Version 1.0
#Sources used: https://christian.weblog.heimdaheim.de/2015/02/23/powercli-delete-all-snapshots-by-name/

#Specify vCenter
$VIServer = Read-Host -Prompt "Please specify target vCenter Server" 

#User prompted to provide Input and Output Files
$SnapshotName = Read-Host -Prompt "Please enter Ticket reference number"
$MaxTasks = Read-Host -Prompt "Please specify maximum concurrent tasks"

#Initiate Connection to Target vCenter
Connect-VIServer $VIserver

#Holds the script as a final go-don'tgo before proceeding to delete
Write-Warning "The task is about to begin and will proceed to delete all snapshots named $SnapshotName on $VIServer, with no more than $MaxTasks concurrent operations."
Write-Warning "Please ensure that a Ticket reference number is specified above, if not, please break this operation."
Write-Warning "Please press any key to continue. Press Ctrl+C to break. This operation is not reversible!"
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

#Finds all VMs with the snapshots with the named SNOW Reference Number
$Snapshots = Get-VM | Get-Snapshot | Where { $_.Name -like $SnapshotName }
 
$i = 0
while($i -lt $Snapshots.Count) {
	Remove-Snapshot -Snapshot $Snapshots[$i] -RunAsync -Confirm:$false
	$Tasks = Get-Task -Status "Running" | where {$_.Name -eq "RemoveSnapshot_Task"}
	while($Tasks.Count -gt ($maxtasks-1)) {
		sleep 30
		$tasks = Get-Task -Status "Running" | where {$_.Name -eq "RemoveSnapshot_Task"}
     }
     $i++
}