function Sync-XurrentServices
{
<#
.SYNOPSIS
    Synchronises services (including dependencies) between two Xurrent environments.

.DESCRIPTION
    Synchronises services. When SyncDependency is enabled, also automatically synchronises
    teams (first_line_team, support_team).

.PARAMETER SourceEnvironment
    The source connection name. Mandatory.

.PARAMETER DestinationEnvironment
    The destination connection name. Mandatory.

.PARAMETER ID
    IDs of the services to synchronise. Mandatory.

.EXAMPLE
    Sync-XurrentServices -SourceEnvironment $qa -DestinationEnvironment $prod -ID 400, 401
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
		$Items = Get-XurrentData -Type services -Environment $SourceEnvironment -ID $ID
		if ($script:SyncDependency -eq $true)
		{
			
			[int[]]$teams = @()
			$teams += $items.first_line_team.id
			$teams += $items.support_team.id
			Write-Verbose -Message "Dependency teams: $(@($teams | Select-Object -Unique) -join ",")"
			Sync-XurrentTeams -SourceEnvironment $SourceEnvironment -DestinationEnvironment $DestinationEnvironment -ID @($teams | Where-Object {$_ -ne 0} | Select-Object -Unique)
		}
		# sync objects
		Sync-XurrentObject -Type services -SourceEnvironment $SourceEnvironment -DestinationEnvironment $DestinationEnvironment -ID $Items.id
	}
	catch
	{
		$_
		return
	}
	return
}