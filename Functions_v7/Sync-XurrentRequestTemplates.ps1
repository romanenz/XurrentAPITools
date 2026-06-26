function Sync-XurrentRequestTemplates
{
<#
.SYNOPSIS
    Synchronises request templates (including dependencies) between two Xurrent environments.

.DESCRIPTION
    Synchronises request templates and, when SyncDependency is enabled, also synchronises
    dependent UI extensions and the associated automation rules.

.PARAMETER SourceEnvironment
    The source connection name. Mandatory.

.PARAMETER DestinationEnvironment
    The destination connection name. Mandatory.

.PARAMETER ID
    IDs of the request templates to synchronise. Mandatory.

.EXAMPLE
    Sync-XurrentRequestTemplates -SourceEnvironment $qa -DestinationEnvironment $prod -ID 800, 801
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