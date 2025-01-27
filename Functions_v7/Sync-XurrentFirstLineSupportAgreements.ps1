function Sync-XurrentFirstLineSupportAgreements
{
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[ValidateScript({ $null -ne $script:XurrentAuth.$_ })]
		[string]$SourceEnvironment,
		[Parameter(Mandatory = $true)]
		[ValidateScript({ $null -ne $script:XurrentAuth.$_ })]
		[string]$DestinationEnvironment,
		[Parameter(Mandatory = $true)]
		[int[]]$ID
	)
	try
	{
		$Items = Get-XurrentData -Type flsas -Environment $SourceEnvironment -ID $ID
		if ($script:SyncDependency -eq $true)
		{
			Write-Verbose -Message "Dependency support_hours: $($Items.support_hours.id -join ",")"
			Sync-XurrentCalendars -SourceEnvironment $SourceEnvironment -DestinationEnvironment $DestinationEnvironment -ID $Items.support_hours.id
			
			Write-Verbose -Message "Dependency support_hours: $($items.service_desk_team.id -join ",")"
			Sync-XurrentTeams -SourceEnvironment $SourceEnvironment -DestinationEnvironment $DestinationEnvironment -ID $items.service_desk_team.id
		}
		# sync objects
		Sync-XurrentObject -Type flsas -SourceEnvironment $SourceEnvironment -DestinationEnvironment $DestinationEnvironment -ID $Items.id
	}
	catch
	{
		$_
		return
	}
	return
}