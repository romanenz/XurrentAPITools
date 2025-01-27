function Find-XurrentEnvironment
{
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