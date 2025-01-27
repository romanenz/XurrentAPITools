
function Sync-XurrentCustomCollectionElements
{
	[CmdletBinding(DefaultParameterSetName = 'id')]
	param (
		[Parameter(Mandatory = $true, ParameterSetName = 'id')]
		[Parameter(Mandatory = $true, ParameterSetName = 'collection')]
		[ValidateScript({ $null -ne $script:XurrentAuth.$_ })]
		[string]$SourceEnvironment,
		[Parameter(Mandatory = $true, ParameterSetName = 'id')]
		[Parameter(Mandatory = $true, ParameterSetName = 'collection')]
		[ValidateScript({ $null -ne $script:XurrentAuth.$_ })]
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