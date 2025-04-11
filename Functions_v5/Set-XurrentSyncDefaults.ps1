function Set-XurrentSyncDefaults
{
	[CmdletBinding(DefaultParameterSetName = 'qa2prod')]
	param (
		[Parameter(Mandatory = $true, ParameterSetName = 'qa2prod')]
		[Parameter(Mandatory = $true, ParameterSetName = 'prod2qa')]
		[ValidateScript({ (Get-XurrentEnvironments -Search $_).count -eq 2 })]
		[string]$Account,
		[Parameter(Mandatory = $true, ParameterSetName = 'qa2prod')]
		[switch]$QaToProd,
		[Parameter(Mandatory = $true, ParameterSetName = 'prod2qa')]
		[switch]$ProdToQa
	)
	if ($QaToProd)
	{
		$source = (Get-XurrentEnvironments -Search "$($Account)_QualityAssurance").name
		$destination = (Get-XurrentEnvironments -Search "$($Account)_Production").name
	}elseif ($ProdToQa) {
		$destination = (Get-XurrentEnvironments -Search "$($Account)_QualityAssurance").name
		$source = (Get-XurrentEnvironments -Search "$($Account)_Production").name		
	}
	else
	{
		return
	}
	Set-XurrentAPITools -DefaultSourceEnvironment $source -DefaultDestinationEnvironment $destination
}