
function Sync-XurrentCustomCollections
{
<#
.SYNOPSIS
    Synchronises custom collections (including their elements) between two Xurrent environments.

.DESCRIPTION
    First synchronises the collection objects, then – if $script:SyncDependency = $true –
    automatically synchronises all associated custom collection elements as well.

.PARAMETER SourceEnvironment
    The source connection name. Mandatory.

.PARAMETER DestinationEnvironment
    The destination connection name. Mandatory.

.PARAMETER ID
    IDs of the custom collections to synchronise. Mandatory.

.EXAMPLE
    Sync-XurrentCustomCollections -SourceEnvironment $qa -DestinationEnvironment $prod -ID 5, 6
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
		Sync-XurrentObject -Type custom_collections -SourceEnvironment $SourceEnvironment -DestinationEnvironment $DestinationEnvironment -ID $ID
		if ($script:SyncDependency -eq $true)
		{
			$Items = Get-XurrentData -Type custom_collections -Environment $SourceEnvironment -ID $ID
			Sync-XurrentCustomCollectionElements -SourceEnvironment $SourceEnvironment -DestinationEnvironment $DestinationEnvironment -CustomCollection $Items.reference
		}
	}
	catch
	{
		$_
		return
	}
	return
}