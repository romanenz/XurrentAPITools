function Sync-XurrentShopArtikles
{
<#
.SYNOPSIS
    Synchronises shop articles (including UI extensions) between two Xurrent environments.

.DESCRIPTION
    Synchronises shop articles. When SyncDependency is enabled, also automatically
    synchronises associated UI extensions.

.PARAMETER SourceEnvironment
    The source connection name. Mandatory.

.PARAMETER DestinationEnvironment
    The destination connection name. Mandatory.

.PARAMETER ID
    IDs of the shop articles to synchronise. Mandatory.

.EXAMPLE
    Sync-XurrentShopArtikles -SourceEnvironment $qa -DestinationEnvironment $prod -ID 700, 701
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