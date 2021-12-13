# Lab importieren - nach Neustart oder in anderer PS-Session:
Import-Lab TestLab

# Status
# https://automatedlab.org/en/latest/AutomatedLab/en-us/Get-LabVMStatus/
Get-LabVMStatus -ComputerName DEMADC01

# Enable Remoting
# https://automatedlab.org/en/latest/AutomatedLab/en-us/Enable-LabVMRemoting/
Enable-LabVMRemoting -ComputerName DEMACA01
Enter-PSSession -ComputerName DEMACA01 -Credential (Get-Credential)


# Remove VM
# https://automatedlab.org/en/latest/AutomatedLab/en-us/Remove-LabVM/
Remove-LabVM -Name DEMACA01

# Get Snapshot
# https://automatedlab.org/en/latest/AutomatedLab/en-us/Get-LabVMSnapshot/
Get-LabVMSnapshot -ComputerName DEMACL01
Restore-LabVMSnapshot -ComputerName DEMADC01 -SnapshotName XYZ
Remove-LabVMSnapshot -ComputerName DEMADC01

# Get RDP Files
# https://automatedlab.org/en/latest/AutomatedLab/en-us/Get-LabVMRdpFile/
Get-LabVMRdpFile -UseLocalCredential -All -Path "./"

# Get UpTime
# https://automatedlab.org/en/latest/AutomatedLab/en-us/Get-LabVMUptime/
Get-LabVMUptime -ComputerName DEMADC01

# Install Windows Feature
# https://automatedlab.org/en/latest/AutomatedLab/en-us/Get-LabWindowsFeature/
Get-LabWindowsFeature DEMACL01 -FeatureName RSAT-AD-Tools

# GET UAC Status
# https://automatedlab.org/en/latest/AutomatedLab/en-us/Get-LabVMUacStatus/
Get-LabVMUacStatus DEMACL01, DEMADC01

# Start VM
# https://automatedlab.org/en/latest/AutomatedLab/en-us/Start-LabVM/
Start-LabVM DC01

# Stop VM
# https://automatedlab.org/en/latest/AutomatedLab/en-us/Stop-LabVM/
Stop-LabVM DC01