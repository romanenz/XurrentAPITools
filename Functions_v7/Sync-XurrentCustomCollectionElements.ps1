
function Sync-XurrentCustomCollectionElements
{
<#
.SYNOPSIS
    Synchronises custom collection elements from one Xurrent environment to another.

.DESCRIPTION
    Supports two modes: selection by IDs or by collection name (reference).

.PARAMETER SourceEnvironment
    The source connection name. Mandatory.

.PARAMETER DestinationEnvironment
    The destination connection name. Mandatory.

.PARAMETER ID
    IDs of the elements to synchronise. Mandatory in parameter set 'id'.

.PARAMETER CustomCollection
    Name(s) of the custom collection(s) whose elements should be synchronised.
    Mandatory in parameter set 'collection'.

.EXAMPLE
    Sync-XurrentCustomCollectionElements -SourceEnvironment $qa -DestinationEnvironment $prod -ID 200, 201

.EXAMPLE
    Sync-XurrentCustomCollectionElements -SourceEnvironment $qa -DestinationEnvironment $prod `
        -CustomCollection 'priority_matrix', 'regions'
#>
	[CmdletBinding(DefaultParameterSetName = 'id')]
	param (
		[Parameter(Mandatory = $true, ParameterSetName = 'id')]
		[Parameter(Mandatory = $true, ParameterSetName = 'collection')]
		[ValidateScript({ $null -ne $script:XurrentAuth.$_ })]
		[ArgumentCompleter({
				param ($cmd,
					$param,
					$wordToComplete)
				$script:XurrentAuth.keys -like "$wordToComplete*"
			})]
		[string]$SourceEnvironment,
		[Parameter(Mandatory = $true, ParameterSetName = 'id')]
		[Parameter(Mandatory = $true, ParameterSetName = 'collection')]
		[ValidateScript({ $null -ne $script:XurrentAuth.$_ })]
		[ArgumentCompleter({
				param ($cmd,
					$param,
					$wordToComplete)
				$script:XurrentAuth.keys -like "$wordToComplete*"
			})]
		[string]$DestinationEnvironment,
		[Parameter(Mandatory = $true, ParameterSetName = 'id')]
		[int[]]$ID,
		[Parameter(Mandatory = $true, ParameterSetName = 'collection')]
		[string[]]$CustomCollection
	)
	try
	{
		if ($PSCmdlet.ParameterSetName -eq 'id')
		{
			$Items = Get-XurrentData -Type custom_collection_elements -Environment $SourceEnvironment -ID $ID
		}
		else
		{
			$Items = Get-XurrentData -Type custom_collection_elements -Environment $SourceEnvironment -Parameter "custom_collection=$($CustomCollection -join ',')"
		}
		# sync objects
		Sync-XurrentObject -Type custom_collection_elements -SourceEnvironment $SourceEnvironment -DestinationEnvironment $DestinationEnvironment -ID $Items.id
	}
	catch
	{
		$_
		return
	}
	return
}