function Sync-XurrentTeams
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