function Resolve-XurrentRelation
{
	[CmdletBinding(DefaultParameterSetName = 'id')]
	param (
		[Parameter(Mandatory = $true, ParameterSetName = 'id')]
		[Parameter(Mandatory = $true, ParameterSetName = 'all')]
		[ValidateScript({ $_ -in $script:XurrentDataTypes })]
		[string]$Type,
		[Parameter(Mandatory = $true, ParameterSetName = 'id')]
		[Parameter(Mandatory = $true, ParameterSetName = 'all')]
		[ValidateScript({ $null -ne $script:XurrentAuth.$_ })]
		[string]$SourceEnvironment,
		[Parameter(Mandatory = $true, ParameterSetName = 'id')]
		[Parameter(Mandatory = $true, ParameterSetName = 'all')]
		[ValidateScript({ $null -ne $script:XurrentAuth.$_ })]
		[string]$DestinationEnvironment,
		[Parameter(Mandatory = $true, ParameterSetName = 'id')]
		[int[]]$ID,
		[Parameter(Mandatory = $true, ParameterSetName = 'all')]
		[ValidateScript({ $PSVersionTable.PSVersion -ge $Script:MinimalV7Version })]
		[switch]$All,
		[Parameter(Mandatory = $false, ParameterSetName = 'all')]
		[switch]$MatchMissingByName
	)
	try
	{
		if ($All)
		{
			$SourceData = Export-XurrentData -Environment $SourceEnvironment -Type $Type | Import-Csv | Select-Object name, ID, @{ l = "source"; e = { $_."Source" } }, @{ l = "sourceID"; e = { $_."Source ID" } }
			$DestinationData = Export-XurrentData -Environment $DestinationEnvironment -Type $Type | Import-Csv | Select-Object name, ID, @{ l = "source"; e = { $_."Source" } }, @{ l = "sourceID"; e = { $_."Source ID" } }
		}
		else
		{
			$SourceData = Get-XurrentData -Type $Type -Environment $SourceEnvironment -ID $ID -Parameter "fields=id, source, sourceID"
			$DestinationData = @()
			foreach ($Item in $SourceData)
			{
				$DestinationData += Get-XurrentData -Type $Type -Environment $DestinationEnvironment -Parameter "source=$($Item.source)&sourceID=$($Item.sourceID)&fields=id, source, sourceID"
			}
		}
		[System.Collections.ArrayList]$RelationData = @()
		
		foreach ($Item in $SourceData)
		{
			$null = $RelationData.add([PSCustomObject]@{
					IDsource	  = $Item.id
					IDdestination = if (-not ([string]::IsNullOrEmpty($Item.sourceID))) { ($DestinationData | Where-Object { $_.source -eq $Item.source -and $_.sourceID -eq $Item.sourceID }).id }else { $null }
					SoruceID	  = $Item.sourceID
					source	      = $Item.source
					name		  = $Item.name
				})
		}
		if ($MatchMissingByName)
		{
			foreach ($Item in ($RelationData | Where-Object { $_.IDdestination -eq $null }))
			{
				$Item.IDdestination = ($DestinationData | Where-Object {
						$_.name -eq $Item.name
					}).id
			}
		}
		return $RelationData
	}
	catch
	{
		Write-Error $_
	}
}