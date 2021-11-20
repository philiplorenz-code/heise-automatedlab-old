$start = Get-Date

# General:
$LabName = "TestLab"
$domain = 'test.lab'
$domainchild = 'de.test.lab'
$adminAcc = 'Administrator'
$adminPass = 'Password1'
$labsources = "C:\LabSources"

# Network Settings
New-LabDefinition -Name $LabName -DefaultVirtualizationEngine HyperV
Add-LabVirtualNetworkDefinition -Name $LabName -AddressSpace 192.168.123.0/24

# Domain definition with the domain admin account
Add-LabDomainDefinition -Name $domain -AdminUser $adminAcc -AdminPassword $adminPass
Add-LabDomainDefinition -Name $domainchild -AdminUser $adminAcc -AdminPassword $adminPass
Set-LabInstallationCredential -Username $adminAcc -Password $adminPass

# Basic Parameters
$PSDefaultParameterValues = @{
    'Add-LabMachineDefinition:Network' = $LabName
    'Add-LabMachineDefinition:ToolsPath'= "$labSources\Tools"
    'Add-LabMachineDefinition:IsDomainJoined'= $true
    'Add-LabMachineDefinition:DomainName'= $domainchild
    'Add-LabMachineDefinition:EnableWindowsFirewall'= $false
    'Add-LabMachineDefinition:OperatingSystem'= 'Windows Server 2019 Datacenter Evaluation (Desktop Experience)'
    'Add-LabMachineDefinition:Memory'= 3GB
    'Add-LabMachineDefinition:MinMemory'= 1GB
    'Add-LabMachineDefinition:MaxMemory'= 3GB
    'Add-LabMachineDefinition:Processors'= 1
}

# Root DC
Add-LabMachineDefinition -Name "DC01" -IpAddress 192.168.123.1 -DomainName $domain -Roles RootDC

# Child DC
$role = Get-LabMachineRoleDefinition -Role FirstChildDC @{
    ParentDomain = $domain
    NewDomain = 'de'
    SiteName = 'Mannheim'
    SiteSubnet = '192.168.123.0/24'
}

Add-LabMachineDefinition -Name "DEMADC01" -IpAddress 192.168.123.11 -Roles $role

# CA
$role = Get-LabMachineRoleDefinition -Role CaRoot @{
    CACommonName = "MyLabRootCA1"
    KeyLength = "2048"
    ValidityPeriod = "Weeks"
    ValidityPeriodUnits = "4"
}

Add-LabMachineDefinition -Name "DEMACA01" -IpAddress 192.168.123.12 -Roles $role

# Clients
### Schaun, ob Ordner erstellt!
$postInstallActivity = Get-LabPostInstallationActivity -ScriptFileName createusers.ps1 -DependencyFolder $labSources\PostInstallationActivities\Custom
Add-LabMachineDefinition -Name "DEMAC01" -IpAddress 192.168.123.13 -OperatingSystem 'Windows 10 Pro' -PostInstallationActivity $postInstallActivity


# Deployment
Install-Lab
Show-LabDeploymentSummary -Detailed


$end = Get-Date
Write-Output "Setting up the lab took $($end - $start)"