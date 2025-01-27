function Sync-XurrentRequestTemplates
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
		$Items = Get-XurrentData -Type request_templates -Environment $SourceEnvironment -ID $ID
		
		if ($null -ne $items.ui_extension.id -and $script:SyncDependency -eq $true)
		{
			Write-Verbose -Message "Dependency ui_extensions: $($items.ui_extension.id -join ",")"
			Sync-XurrentUIExtensions -SourceEnvironment $SourceEnvironment -DestinationEnvironment $DestinationEnvironment -ID $items.ui_extension.id
		}
		
		# sync objects
		Sync-XurrentObject -Type request_templates -SourceEnvironment $SourceEnvironment -DestinationEnvironment $DestinationEnvironment -ID $Items.id
		if ($script:SyncDependency -eq $true)
		{
			Sync-XurrentRequestTemplatesAutomationRules -SourceEnvironment $SourceEnvironment -DestinationEnvironment $DestinationEnvironment -Templates $items.id
		}
	}
	catch
	{
		$_
		return
	}
	return
}