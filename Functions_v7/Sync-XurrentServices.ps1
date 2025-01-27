function Sync-XurrentServices
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