function Connect-Xurrent
{
	<#
.SYNOPSIS
    Establishes a connection to the Xurrent API and stores the authentication data.

.DESCRIPTION
    Builds an authenticated connection to the Xurrent REST API. The connection data
    (URL, Bearer token, account header) is stored in the module scope under
    $script:XurrentAuth and is automatically used by all other functions.

    The connection can be established either via Environment + Region (parameter set 'build')
    or via a direct API URL (parameter set 'url'). After connecting, the account
    reachability is verified by default.

    The returned name (e.g. 'wdc_Production_Global') serves as the -Environment value
    for all further module functions.

.PARAMETER Account
    The Xurrent account identifier (e.g. 'wdc', 'my-company'). Mandatory.

.PARAMETER Token
    The API Bearer token (112-character alphanumeric string). Mandatory.

.PARAMETER Environment
    The target environment. Valid values: Production, QualityAssurance, Demo.
    Mandatory in parameter set 'build'.

.PARAMETER Region
    The API region. Valid values: Global, Australia, UnitedKingdom, Switzerland, 'United States'.
    Mandatory in parameter set 'build'.

.PARAMETER URL
    Direct API base URL (e.g. 'https://api.4me.com/v1').
    Mandatory in parameter set 'url', as an alternative to Environment + Region.

.PARAMETER SkipValidation
    When set, no connection test is performed. Missing permissions will then produce
    a warning instead of a terminating error.

.OUTPUTS
    System.String – The generated connection name in the format '<Account>_<Environment>_<Region>'.

.EXAMPLE
    $env = Connect-Xurrent -Account 'wdc' -Environment 'Demo' -Region 'Global' -Token '<token>'

    Connects to the global Demo environment. The returned value is used as
    the -Environment parameter for subsequent commands.

.EXAMPLE
    $env = Connect-Xurrent -Account 'wdc' -URL 'https://api.ch.4me.com/v1' -Token '<token>' -SkipValidation

    Connects directly via a URL without validating the account.

.NOTES
    Alias: Connect-4me
#>
	[CmdletBinding(DefaultParameterSetName = 'build')]
	param (
		[Parameter(Mandatory = $true)]
		[string]$Account,
		[Parameter(Mandatory = $true)]
		[ValidatePattern('[a-zA-Z0-9]{112}')]
		[string]$Token,
		[Parameter(Mandatory = $true, ParameterSetName = 'url')]
		[ValidateSet('https://api.4me.com/v1', 'https://api.au.4me.com/v1', 'https://api.uk.4me.com/v1', 'https://api.ch.4me.com/v1', 'https://api.us.4me.com/v1', 'https://api.4me.qa/v1', 'https://api.au.4me.qa/v1', 'https://api.uk.4me.qa/v1', 'https://api.ch.4me.qa/v1', 'https://api.us.4me.qa/v1', 'https://api.4me-demo.com/v1')]
		[string]$URL,		
		[Parameter(Mandatory = $true, ParameterSetName = 'build')]
		[ValidateSet('Production', 'QualityAssurance', 'Demo')]
		[string]$Environment,
		[Parameter(Mandatory = $true, ParameterSetName = 'build')]
		[ValidateSet('Global', 'Australia', 'UnitedKingdom', 'Switzerland', 'United States')]
		[string]$Region,
		[Parameter(Mandatory = $false)]
		[switch]$SkipValidation
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
	
	if ($PSCmdlet.ParameterSetName -eq 'build')
	{
		$Instance = $Data | Where-Object { $_.Environment -eq $Environment -and $_.Region -eq $Region }
		if ($null -eq $Instance)
		{
			Write-Error "no insance found"
			return
		}
	}
	else
	{
		$Instance = $Data | Where-Object { $_.Instance -eq $URL }
	}
	
	$Name = "$($Account)_$($Instance.Environment)_$($Instance.Region)"
	if ($null -ne $script:XurrentAuth.$Name)
	{
		$script:XurrentAuth.Remove($Name)
	}
	$script:XurrentAuth.Add($Name, @{ })
	
	$script:XurrentAuth.$Name.Add('URL', $Instance.Instance.TrimEnd('/'))
	$script:XurrentAuth.$Name.Add('header', @{
			Authorization   = "Bearer $($Token)"
			"Content-Type"  = "application/json"
			"X-4me-Account" = $Account
		})
	try
	{
		$Account = Invoke-RestMethod -Method GET -Uri "$($script:XurrentAuth.$Name.URL)/account" -Headers $script:XurrentAuth.$Name.header -ErrorAction SilentlyContinue
	}
	catch
	{
		$global:Error.RemoveAt(0)
		if ($SkipValidation)
		{
			Write-Warning -Message "unable to get account information please verify permissions"
		}
		else
		{
			Write-Error -Message "unable to get account information please verify permissions" -ErrorAction Stop
		}
	}
	return $Name
}