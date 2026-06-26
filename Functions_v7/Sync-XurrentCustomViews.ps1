
function Sync-XurrentCustomViews
{
<#
.SYNOPSIS
    Synchronises custom views between two Xurrent environments.

.PARAMETER SourceEnvironment
    The source connection name. Mandatory.

.PARAMETER DestinationEnvironment
    The destination connection name. Mandatory.

.PARAMETER ID
    IDs of the custom views to synchronise. Mandatory.

.EXAMPLE
    Sync-XurrentCustomViews -SourceEnvironment $qa -DestinationEnvironment $prod -ID 30
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
		# sync objects
		Sync-XurrentObject -Type custom_views -SourceEnvironment $SourceEnvironment -DestinationEnvironment $DestinationEnvironment -ID $ID
	}
	catch
	{
		$_
		return
	}
	return
}