New-Item -ItemType Directory -Name 'MyWebsite' -Path 'C:\'
New-IISSite -Name 'MyWebsite' -PhysicalPath 'C:\MyWebsite\' -BindingInformation "*:8088:"

