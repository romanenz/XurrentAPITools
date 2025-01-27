function Resolve-XurrentRelation
{
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[ValidateScript({ $_ -in $script:XurrentDataTypes })]
		[string]$Type,
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
		$SourceData = Get-XurrentData -Type $Type -Environment $SourceEnvironment -ID $ID -Parameter "fields=id, source, sourceID"
		[System.Collections.ArrayList]$RelationData = @()
		
		foreach ($Item in $SourceData)
		{
			$null = $RelationData.add([PSCustomObject]@{
						IDsource	  = $Item.id
						SoruceID	  = $Item.sourceID
						source	      = $Item.source
						IDdestination = (Get-XurrentData -Type $Type -Environment $DestinationEnvironment -Parameter "source=$($Item.source)&sourceID=$($Item.sourceID)&fields=id, source, sourceID").id
					})
		}
		return $RelationData
	}
	catch
	{
		Write-Error $_
	}
}