
function Sync-XurrentCustomViews
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
		Sync-XurrentObject -Type custom_views -SourceEnvironment $SourceEnvironment -DestinationEnvironment $DestinationEnvironment -ID $ID
	}
	catch
	{
		$_
		return
	}
	return
}