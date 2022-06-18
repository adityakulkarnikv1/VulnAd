# Scripts to deploy vulnerable Active Directory

## Machines
1. Windows server 2022 (core)
2. Windows 7 x64 (Workstation 01)
3. Windows 10 x64 (Workstation 02)

## Steps - using sconfig.cmd
* Change the computer name
* Setup static IP address for domain (XYZ.COM)
* Assign DNS server to itself (add secondary DNS server as 8.8.8.8 to access internet)
* Install Active DIrectory Windows feature
```powershell
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
Import-Module ADDSDeployment
Install-ADDSForest
```
* Provide Domain name and SafeModeAdministratorPassword
* Change DNS server IP address to interface address after reboot