function Sync-XurrentFirstLineSupportAgreements
{
<#
.SYNOPSIS
    Synchronises first line support agreements (FLSAs) between two Xurrent environments.

.DESCRIPTION
    Synchronises FLSAs and, when SyncDependency is enabled, automatically also synchronises
    dependent calendars (support_hours) and teams (service_desk_team).

.PARAMETER SourceEnvironment
    The source connection name. Mandatory.

.PARAMETER DestinationEnvironment
    The destination connection name. Mandatory.

.PARAMETER ID
    IDs of the FLSAs to synchronise. Mandatory.

.EXAMPLE
    Sync-XurrentFirstLineSupportAgreements -SourceEnvironment $qa -DestinationEnvironment $prod -ID 7
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