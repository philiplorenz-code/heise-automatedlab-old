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

# WebServer
### Prüfen, ob installiert wurde
Add-LabMachineDefinition -Name "DEMAWS01" -Roles WebServer



# Clients
### Schaun, ob Ordner erstellt!
$postInstallActivity = Get-LabPostInstallationActivity -ScriptFileName createusers.ps1 -DependencyFolder $labSources\PostInstallationActivities\Custom
Add-LabMachineDefinition -Name "DEMAC01" -IpAddress 192.168.123.13 -OperatingSystem 'Windows 10 Pro' -PostInstallationActivity $postInstallActivity

# Linux
### Schauen, ob Linux VM ordentlich installiert
Add-LabMachineDefinition -Name "DEMALIN01" -IpAddress 192.168.123.14 -OperatingSystem 'CentOS-7' 

# Deployment
Install-Lab


#Install software to all lab machines
### HIER noch Software hinzufügen!
#$packs = @()
#$packs += Get-LabSoftwarePackage -Path $labSources\SoftwarePackages\Notepad++.exe -CommandLine /S
#$packs += Get-LabSoftwarePackage -Path $labSources\SoftwarePackages\winrar.exe -CommandLine /S
#Install-LabSoftwarePackages -Machine (Get-LabVM -All) -SoftwarePackage $packs


# WebServer Certificate
### Schauen, ob Zertifikat gemapped wurde
Enable-LabCertificateAutoenrollment -Computer -User -CodeSigning
$cert = Request-LabCertificate -Subject "CN=demaws01.de.test.lab" -TemplateName "WebServer" -ComputerName "DEMAWS01" -PassThru

Invoke-LabCommand -ActivityName 'Setup SSL Binding' -ComputerName "DEMAWS01" -ScriptBlock {
    New-WebBinding -Name "Default Web Site" -IP "*" -Port 443 -Protocol https
    Import-Module -Name WebAdministration
    Get-Item -Path "Cert:\LocalMachine\My\$($args[0].Thumbprint)" | New-Item -Path IIS:\SslBindings\0.0.0.0!443
} -ArgumentList $cert

Show-LabDeploymentSummary -Detailed


$end = Get-Date
Write-Output "Setting up the lab took $($end - $start)"