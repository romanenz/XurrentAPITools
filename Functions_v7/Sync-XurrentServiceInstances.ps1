function Sync-XurrentServiceInstances
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
		$Items = Get-XurrentData -Type service_instances -Environment $SourceEnvironment -ID $ID
		if ($script:SyncDependency -eq $true)
		{
			Write-Verbose -Message "Dependency teams: $($items.first_line_team.id -join ","),$($items.support_team.id -join ",")"
			[int[]]$teams = @()
			$teams += $items.first_line_team.id
			$teams += $items.support_team.id
			Sync-XurrentTeams -SourceEnvironment $SourceEnvironment -DestinationEnvironment $DestinationEnvironment -ID @($teams | Select-Object -Unique)
			
			Write-Verbose -Message "Dependency services: $($items.service.id -join ",")"
			Sync-XurrentServices -SourceEnvironment $SourceEnvironment -DestinationEnvironment $DestinationEnvironment -ID $items.service.id
			
			Write-Verbose -Message "Dependency maintenance_window: $($items.maintenance_window.id -join ",")"
			Sync-XurrentCalendars -SourceEnvironment $SourceEnvironment -DestinationEnvironment $DestinationEnvironment -ID $items.maintenance_window.id
		}
		# sync objects
		Sync-XurrentObject -Type service_instances -SourceEnvironment $SourceEnvironment -DestinationEnvironment $DestinationEnvironment -ID $Items.id
	}
	catch
	{
		$_
		return
	}
	return
}