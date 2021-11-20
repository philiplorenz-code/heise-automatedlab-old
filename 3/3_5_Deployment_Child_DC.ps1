# Eigenes Netzwerk:
$LabName = "TestLab"
$installationCredential = New-Object PSCredential('Administrator', ('Password1' | ConvertTo-SecureString -AsPlainText -Force)) # nicht sicher!
$domain = 'de.test.lab'
$adminAcc = 'Administrator'
$adminPass = 'YourPasswordHere'
$labsources = "C:\LabSources"

# Network Settings
New-LabDefinition -Name $LabName -DefaultVirtualizationEngine HyperV
Add-LabVirtualNetworkDefinition -Name $LabName -AddressSpace 192.168.123.0/24

# Domain definition with the domain admin account
Add-LabDomainDefinition -Name $domain -AdminUser $adminAcc -AdminPassword $adminPass
Set-LabInstallationCredential -Username $adminAcc -Password $adminPass

# Basic Parameters
$PSDefaultParameterValues = @{
    'Add-LabMachineDefinition:Network' = $LabName
    'Add-LabMachineDefinition:ToolsPath'= "$labSources\Tools"
    'Add-LabMachineDefinition:IsDomainJoined'= $true
    'Add-LabMachineDefinition:DomainName'= $domain
    'Add-LabMachineDefinition:EnableWindowsFirewall'= $false
    'Add-LabMachineDefinition:OperatingSystem'= 'Windows Server 2019 Datacenter Evaluation (Desktop Experience)'
    'Add-LabMachineDefinition:Memory'= 2GB
    'Add-LabMachineDefinition:MinMemory'= 1GB
    'Add-LabMachineDefinition:MaxMemory'= 2GB
    'Add-LabMachineDefinition:Processors'= 1
    'Add-LabMachineDefinition:InstallationUserCredential'= $installationCredential
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