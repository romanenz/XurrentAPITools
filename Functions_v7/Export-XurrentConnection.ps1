function Export-XurrentConnection
{
<#
.SYNOPSIS
    Saves the active Xurrent connections in encrypted form to the file system.

.DESCRIPTION
    Exports all active connections from $script:XurrentAuth to an encrypted file.
    Encryption is performed using Windows DPAPI (ProtectedData) in the CurrentUser scope
    with an additional password as entropy. The file can subsequently be loaded with
    Import-XurrentConnection.

    Default storage location: %appdata%\XurrentAPITools\connection
    The directory is created automatically if it does not already exist.

.PARAMETER FilePath
    Optional custom file path. Default: %appdata%\XurrentAPITools\connection.

.PARAMETER Force
    Overwrites an existing file. Without this switch, an error is thrown if the
    file already exists.

.EXAMPLE
    Export-XurrentConnection

    Saves all active connections to the default location. Password is prompted interactively.

.EXAMPLE
    Export-XurrentConnection -FilePath 'D:\backup\xurrent_conn' -Force

    Saves to a custom path and overwrites an existing file.

.NOTES
    Requires PowerShell 7.2+ (DPAPI support).
    Only works on Windows (CurrentUser DPAPI scope).
#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $false, Position = 0)]
		[string]$FilePath = [system.Environment]::ExpandEnvironmentVariables("%appdata%\XurrentAPITools\connection"),
		[Parameter(Mandatory = $false, Position = 0)]
		[switch]$Force
	)
	if ($false -eq (Test-Path ([system.IO.Path]::GetDirectoryName($filepath))))
	{
		if ($FilePath -eq [system.Environment]::ExpandEnvironmentVariables("%appdata%\XurrentAPITools\connection"))
		{
			Write-Verbose -Message "create path: %appdata%\XurrentAPITools\"
			$null = New-Item -Path $env:APPDATA -Name 'XurrentAPITools' -ItemType Directory
		}
		else
		{
			Write-Error -Message 'path not exists'
			return
		}
	}
	if ($true -eq (Test-Path $filepath) -and -not $Force)
	{
		Write-Error -Message "file alredy exists, use force parameter to overwrite"
		return
	}
	
	$str = $script:XurrentAuth | ConvertTo-Json
	
	$additionalEntropy = [System.Text.Encoding]::UTF8.GetBytes((Read-Host -Prompt "Password" -MaskInput))
	#encryption
	$byte = [System.Security.Cryptography.ProtectedData]::Protect([System.Text.Encoding]::UTF8.GetBytes($str), $additionalEntropy, [System.Security.Cryptography.DataProtectionScope]::CurrentUser)
	$b64 = [System.Convert]::ToBase64String($byte)
	
	$b64 | Out-File -FilePath $FilePath -Encoding UTF8
}