# Netwerk wird auch ohne direkte Angabe mit Default-Settings erstellt (Switch wird erstellt by increment 192.168.1.0)

# General:
$LabName = "TestLab"

# Eigenes Netzwerk:
New-LabDefinition -Name $LabName -DefaultVirtualizationEngine HyperV
Add-LabVirtualNetworkDefinition -Name $LabName -AddressSpace 192.168.123.0/24

Install-Lab
Show-LabDeploymentSummary -Detailed

# Show Labs
Get-Lab -List

# Remove Lab
Remove-Lab $LabName
