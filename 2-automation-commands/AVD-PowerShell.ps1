# These series of PowerShell commands operate using a lot of different
# variables, and running one command after the other


# Install the PowerShell module if you don't already have it
Install-Module Az.DesktopVirtualization

# Start by setting the resource group and host pool names
$AVDResourceGroupName = "W10-MS" # W10-MS
$AVDHostPoolName = "W10-MS" # W10-MS
$AVDRegion = "westus" # westus
$AVDWorkspaceName = "W10-MS-west" # W10-MS-west

# Get information about your current host pool
Get-AzWvdHostPool -Name $AVDHostPoolName -ResourceGroupName $AVDResourceGroupName | Format-List

# Update the current host pool to use DepthFirst for the load balancing algorithm
Update-AzWvdHostPool -Name $AVDHostPoolName -ResourceGroupName $AVDResourceGroupName -LoadBalancerType 'DepthFirst'

# Create a new persistent host pool without any hosts
$PersistentHostPoolName = "W10-D" # W10-D
$PersistentResourceGroupName = "W10-D" # W10-D

New-AzResourceGroup -Name $PersistentResourceGroupName -Location $AVDRegion

New-AzWvdHostPool -ResourceGroupName $PersistentResourceGroupName `
    -Name $PersistentHostPoolName `
    -Location $AVDRegion `
    -HostPoolType 'Personal' `
    -LoadBalancerType 'Persistent' `
    -Description "Personal Desktops for the $AVDRegion region" `
    -PersonalDesktopAssignmentType 'Automatic' `
    -PreferredAppGroupType 'Desktop'

# Retrieve the host pool information for the pool we just created
$hostPool = Get-AzWvdHostPool -Name $PersistentHostPoolName -ResourceGroupName $PersistentResourceGroupName

# Create an Application group for the host pool
$AppGroupName = "$PersistentHostPoolName-DAG"
New-AzWvdApplicationGroup -ResourceGroupName $PersistentResourceGroupName `
    -Name $AppGroupName `
    -Location $AVDRegion `
    -FriendlyName $AppGroupName `
    -Description 'Persistent Desktop App Group' `
    -HostPoolArmPath $hostPool.Id `
    -ApplicationGroupType 'Desktop'

# Get the application group information and add it to the workspace information
$appGroup = Get-AzWvdApplicationGroup -Name $AppGroupName -ResourceGroupName $PersistentResourceGroupName
$workspace = Get-AzWvdWorkspace -Name $AVDWorkspaceName -ResourceGroupName $AVDResourceGroupName
$newAppRef = $workspace.ApplicationGroupReference + $appGroup.Id

# Update the workspace to include the new application group
Update-AzWvdWorkspace -ResourceGroupName $AVDResourceGroupName `
    -Name $AVDWorkspaceName `
    -ApplicationGroupReference $newAppRef
