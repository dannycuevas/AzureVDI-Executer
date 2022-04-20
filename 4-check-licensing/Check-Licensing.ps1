# Get the VM and check license type
$vm = Get-AzVM -ResourceGroup RG_NAME -Name VM_NAME
$vm | Select-Object LicenseType

# Update the license type if you don't see Windows_Server or Windows_Client
$vm.LicenseType = "Windows_Client"
Update-AzVM -ResourceGroupName $vm.ResourceGroupName -VM $vm

# Check all VMs in your subscription
$vms = Get-AzVM
$vms | Where-Object {$_.LicenseType -like "Windows_Client"} | Select-Object ResourceGroupName, Name, LicenseType