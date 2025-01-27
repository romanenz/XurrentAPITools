function Get-XurrentRateLimit
{
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[ValidateScript({ $null -ne $script:XurrentAuth.$_ })]
		[string]$Environment
	)
	
	return (Invoke-RestMethod -Method get -Uri "$($script:XurrentAuth.$Environment.URL)/rate_limit" -Headers $script:XurrentAuth.$Environment.header).resources
}