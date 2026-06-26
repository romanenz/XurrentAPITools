function Find-XurrentEnvironment
{
<#
.SYNOPSIS
    Resolves environment metadata (Environment, Region, API URL) from a URL or
    an Environment/Region combination.

.DESCRIPTION
    Returns the matching entry from the internal instance table. Used internally by
    ConvertFrom-XurrentWebHookPayload to determine environment metadata from a
    webhook issuer URL.

    Supports two modes:
    - url: Finds the environment via wildcard URL matching.
    - env: Finds the environment by Environment and Region.

.PARAMETER AccountURL
    A URL of a Xurrent account (e.g. 'https://wdc.4me.com').
    Mandatory in parameter set 'url'.

.PARAMETER Environment
    Environment name (e.g. 'Production', 'QualityAssurance').
    Mandatory in parameter set 'env'.

.PARAMETER Region
    Region name (e.g. 'Global', 'Switzerland').
    Mandatory in parameter set 'env'.

.OUTPUTS
    PSCustomObject with the properties Instance, Environment and Region.

.EXAMPLE
    Find-XurrentEnvironment -AccountURL 'https://wdc.4me.com'

.EXAMPLE
    Find-XurrentEnvironment -Environment 'Production' -Region 'Switzerland'
#>
	[CmdletBinding(DefaultParameterSetName = 'url')]
	param (
		[Parameter(Mandatory = $true, ParameterSetName = 'url')]
		[string]$AccountURL,
		[Parameter(Mandatory = $true, ParameterSetName = 'env')]
		[string]$Environment,
		[Parameter(Mandatory = $true, ParameterSetName = 'env')]
		[string]$Region
	)
	$Data = @"
Instance	Environment	Region
https://api.4me.com/v1	Production	Global
https://api.au.4me.com/v1	Production	Australia
https://api.uk.4me.com/v1	Production	UnitedKingdom
https://api.ch.4me.com/v1	Production	Switzerland
https://api.us.4me.com/v1	Production	United States
https://api.4me.qa/v1	QualityAssurance	Global
https://api.au.4me.qa/v1	QualityAssurance	Australia
https://api.uk.4me.qa/v1	QualityAssurance	UnitedKingdom
https://api.ch.4me.qa/v1	QualityAssurance	Switzerland
https://api.us.4me.qa/v1	QualityAssurance	UnitedStates
https://api.4me-demo.com/v1	Demo	Global
"@ | ConvertFrom-Csv -Delimiter '	'
	if ($PSCmdlet.ParameterSetName -eq 'url')
	{
	foreach ($item in $data)
	{
		$item | Add-Member -Name 'URLMatch' -MemberType NoteProperty -Value ('https:\/\/(\w|-)+\.' + [regex]::Escape(($item.Instance.Split('/')[2] -split "\.", 2)[1]))
	}
	return $Data | Where-Object { $AccountURL -match $_.URLMatch }
	}
	else
	{
		return $Data | Where-Object { $_.Environment -eq $Environment -and $_.Region -eq $Region}
	}
}