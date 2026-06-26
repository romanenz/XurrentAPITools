function Sync-XurrentProjectCategories
{
<#
.SYNOPSIS
    Synchronises project categories between two Xurrent environments.

.PARAMETER SourceEnvironment
    The source connection name. Mandatory.

.PARAMETER DestinationEnvironment
    The destination connection name. Mandatory.

.PARAMETER ID
    IDs of the project categories to synchronise. Mandatory.

.EXAMPLE
    Sync-XurrentProjectCategories -SourceEnvironment $qa -DestinationEnvironment $prod -ID 1, 2, 3
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
		$Items = Get-XurrentData -Type project_categories -Environment $SourceEnvironment -ID $ID
		
		# sync objects
		Sync-XurrentObject -Type project_categories -SourceEnvironment $SourceEnvironment -DestinationEnvironment $DestinationEnvironment -ID $Items.id
	}
	catch
	{
		$_
		return
	}
	return
}