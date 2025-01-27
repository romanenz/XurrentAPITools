function Connect-Xurrent
{
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