function Sync-XurrentShopArtikles
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
		$Items = Get-XurrentData -Type shop_articles -Environment $SourceEnvironment -ID $ID
		if ($script:SyncDependency -eq $true)
		{
			if ($null -ne $items.ui_extension.id)
			{
				Write-Verbose -Message "Dependency ui_extensions: $($items.ui_extension.id -join ",")"
				Sync-XurrentUIExtensions -SourceEnvironment $SourceEnvironment -DestinationEnvironment $DestinationEnvironment -ID $items.ui_extension.id
			}
		}
		# sync objects
		Sync-XurrentObject -Type shop_articles -SourceEnvironment $SourceEnvironment -DestinationEnvironment $DestinationEnvironment -ID $Items.id
	}
	catch
	{
		$_
		return
	}
	return
}