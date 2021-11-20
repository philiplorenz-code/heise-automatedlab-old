# Eigenes Netzwerk:
$LabName = "TestLab"
New-LabDefinition -Name $LabName -DefaultVirtualizationEngine HyperV
Add-LabVirtualNetworkDefinition -Name $LabName -AddressSpace 192.168.123.0/24


# VM Settings:
# ISO-Lookup: 
# Get-LabAvailableOperatingSystem -Path C:\LabSources

Set-LabInstallationCredential -Username pInstall -Password Somepass1

$PSDefaultParameterValues = @{
    'Add-LabMachineDefinition:Network' = $LabName
    'Add-LabMachineDefinition:OperatingSystem'= 'Windows Server 2019 Datacenter Evaluation (Desktop Experience)'
    'Add-LabMachineDefinition:Memory'= 2GB
    'Add-LabMachineDefinition:MinMemory'= 1GB
    'Add-LabMachineDefinition:MaxMemory'= 2GB
    'Add-LabMachineDefinition:Processors'= 1
}


# Root DC
Add-LabMachineDefinition -Name "DC01" -IpAddress 192.168.123.1 -DomainName test.lab -Roles RootDC


# Child DC
$role = Get-LabMachineRoleDefinition -Role FirstChildDC @{
    ParentDomain = 'test.lab'
    NewDomain = 'de'
    SiteName = 'Mannheim'
    SiteSubnet = '192.168.123.0/24'

}
Add-LabMachineDefinition -Name "DEMADC01" -IpAddress 192.168.123.11 -DomainName de.test.lab -Roles $role



# Deployment
Install-Lab
Show-LabDeploymentSummary -Detailed