function Import-XurrentConnection
{
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $false, Position = 0)]
		[string]$FilePath = [system.Environment]::ExpandEnvironmentVariables("%appdata%\XurrentAPITools\connection"),
		[Parameter(Mandatory = $false)]
		[switch]$SkipValidation
	)
	
	if ($false -eq (Test-Path $FilePath))
	{
		Write-Error -Message "importfile not found"
		break
	}
	
	$b64 = Get-Content -Path $FilePath -Encoding UTF8
	
	#decryption
	try
	{
		$additionalEntropy = [System.Text.Encoding]::UTF8.GetBytes((Read-Host -Prompt "Password" -MaskInput))
		$byte2 = [System.Convert]::FromBase64String($b64)
		$data = [System.Text.Encoding]::UTF8.GetString([System.Security.Cryptography.ProtectedData]::Unprotect($byte2, $additionalEntropy, [System.Security.Cryptography.DataProtectionScope]::CurrentUser)) | ConvertFrom-Json
	}
	catch
	{
		Write-Error -Message "unable to import connection"
	}
	
	foreach ($item in $data.psobject.Properties)
	{
		Write-Verbose "import connection $($item.name)"
		
		Connect-Xurrent -Account $item.value.header.'X-4me-Account' -Token $item.value.header.Authorization.TrimStart("Bearer ") -URL $item.value.url -SkipValidation:$SkipValidation
	}
}