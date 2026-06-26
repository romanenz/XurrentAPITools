function Sync-XurrentTeams
{
<#
.SYNOPSIS
    Synchronises teams between two Xurrent environments.

.DESCRIPTION
    Synchronises teams. Without -IncludePeople, person-related fields
    (Coordinator, Manager, Configuration Manager, Members) are excluded by default.

.PARAMETER SourceEnvironment
    The source connection name. Mandatory.

.PARAMETER DestinationEnvironment
    The destination connection name. Mandatory.

.PARAMETER ID
    IDs of the teams to synchronise. Mandatory.

.PARAMETER IncludePeople
    When set, person-related fields are also synchronised.

.EXAMPLE
    Sync-XurrentTeams -SourceEnvironment $qa -DestinationEnvironment $prod -ID 60, 61

.EXAMPLE
    Sync-XurrentTeams -SourceEnvironment $qa -DestinationEnvironment $prod -ID 60 -IncludePeople
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
		[int[]]$ID,
		[Parameter(Mandatory = $false)]
		[switch]$IncludePeople
	)
	try
	{
		$Items = Get-XurrentData -Type teams -Environment $SourceEnvironment -ID $ID
		
		# sync objects
		if ($IncludePeople)
		{
			Sync-XurrentObject -Type teams -SourceEnvironment $SourceEnvironment -DestinationEnvironment $DestinationEnvironment -ID $Items.id
		}
		else
		{
			Sync-XurrentObject -Type teams -SourceEnvironment $SourceEnvironment -DestinationEnvironment $DestinationEnvironment -ID $Items.id -ExcludeFields 'Coordinator', 'Manager', 'Configuration Manager', 'Members'
		}
		
	}
	catch
	{
		$_
		return
	}
	return
}