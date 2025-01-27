
function Sync-XurrentCustomCollections
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