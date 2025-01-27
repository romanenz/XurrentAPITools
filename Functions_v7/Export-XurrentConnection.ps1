function Export-XurrentConnection
{
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