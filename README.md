# XurentAPITools

## Install
Install in PowerShell or downlaod from the newes release.
```powershell
Install-Module -Name XurrentAPITools -SkipPublisherCheck
```


## How To Use
Use `Connect-Xurrent` to Connect to a Xurrent Environmen. You can pass the API Token as parameter `Token` or interactive.

On PowerShell 7 it's possible to save and load connections with the commands `Export-XurrentConnection` and `Import-XurrentConnection`. The token is encrypted as `System.Security.Cryptography.ProtectedData` with an additional entropy and saved in `%appdata%\XurrentAPITools\connection`

```powershell
$Environment = Connect-Xurrent -Account wdc -Environment Demo -Region Global
```

Once Connected you can interact with the api like create, update, delete objects, copy data, synchronize objects between environments or export data.

```powershell
Get-XurrentData -Type requests -ID 123456789 -Environment $Environment
```
