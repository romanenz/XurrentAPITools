function Sync-XurrentServiceInstances
{
<#
.SYNOPSIS
    Synchronises service instances (including dependencies) between two Xurrent environments.

.DESCRIPTION
    Synchronises service instances. When SyncDependency is enabled, also automatically
    synchronises teams (first_line_team, support_team), services and optional maintenance
    windows (calendars).

.PARAMETER SourceEnvironment
    The source connection name. Mandatory.

.PARAMETER DestinationEnvironment
    The destination connection name. Mandatory.

.PARAMETER ID
    IDs of the service instances to synchronise. Mandatory.

.EXAMPLE
    Sync-XurrentServiceInstances -SourceEnvironment $qa -DestinationEnvironment $prod -ID 500
#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[ValidateScript({ $null -ne $script:XurrentAuth.$_ })]
		[ArgumentCompleter({
				param ($cmd,
					$param,
					$wordToComplete)
				$script:XurrentAuth.keys -like "$wordToComplete*"
			})]
		[string]$SourceEnvironment,
		[Parameter(Mandatory = $true)]
		[ValidateScript({ $null -ne $script:XurrentAuth.$_ })]
		[ArgumentCompleter({
				param ($cmd,
					$param,
					$wordToComplete)
				$script:XurrentAuth.keys -like "$wordToComplete*"
			})]
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
			if ($items.maintenance_window.id)
			{
				Write-Verbose -Message "Dependency maintenance_window: $($items.maintenance_window.id -join ",")"
				Sync-XurrentCalendars -SourceEnvironment $SourceEnvironment -DestinationEnvironment $DestinationEnvironment -ID $items.maintenance_window.id
			}
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