function Get-XurrentRateLimit
{
<#
.SYNOPSIS
    Queries the current rate limit status of the Xurrent API.

.DESCRIPTION
    Returns information about the current API rate limit, including remaining
    requests and the reset time. Corresponds to the endpoint GET /rate_limit.

.PARAMETER Environment
    The Xurrent connection name. Mandatory.

.OUTPUTS
    PSCustomObject with the rate limit resources of the API.

.EXAMPLE
    Get-XurrentRateLimit -Environment $env

    Shows the current rate limit status of the connected environment.
#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[ValidateScript({ $null -ne $script:XurrentAuth.$_ })]
		[string]$Environment
	)
	
	return (Invoke-RestMethod -Method get -Uri "$($script:XurrentAuth.$Environment.URL)/rate_limit" -Headers $script:XurrentAuth.$Environment.header).resources
}