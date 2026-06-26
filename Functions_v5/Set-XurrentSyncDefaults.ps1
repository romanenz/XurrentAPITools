function Set-XurrentSyncDefaults
{
<#
.SYNOPSIS
    Configures the default source and destination environments for sync functions.

.DESCRIPTION
    Sets the global default values for -SourceEnvironment and -DestinationEnvironment
    for all *-Xurrent* commands. Expects that both a QualityAssurance and a Production
    connection are active for the specified account.

    Two directions:
    - QaToProd: QualityAssurance as source, Production as destination.
    - ProdToQa: Production as source, QualityAssurance as destination.

.PARAMETER Account
    The Xurrent account identifier (e.g. 'wdc'). Exactly two connections must exist
    for this account (QA and Production). Mandatory.

.PARAMETER QaToProd
    Sets QualityAssurance as source and Production as destination.
    Mandatory in parameter set 'qa2prod'.

.PARAMETER ProdToQa
    Sets Production as source and QualityAssurance as destination.
    Mandatory in parameter set 'prod2qa'.

.EXAMPLE
    Set-XurrentSyncDefaults -Account 'wdc' -QaToProd

    Configures the default sync from QA to Production for account 'wdc'.

.EXAMPLE
    Set-XurrentSyncDefaults -Account 'wdc' -ProdToQa

    Configures the default sync from Production to QA.
#>
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