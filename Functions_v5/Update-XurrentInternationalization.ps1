function Update-XurrentInternationalization
{
	[CmdletBinding(DefaultParameterSetName = 'Language')]
	param (
		[Parameter(Mandatory = $true, ParameterSetName = 'Language')]
		[string]$Language
	)
	
	try
	{
		$Enum = Invoke-RestMethod -Method get -Uri "https://api.xurrent.com/v1/enums" -Headers @{ "X-Xurrent-Language" = $Language }
		$Enum | ConvertTo-Json | Out-File -Encoding UTF8 -FilePath "$($script:InternationalizationPath)\$($Language).json" -Force
	}
	catch
	{
		Write-Error $_
	}
}