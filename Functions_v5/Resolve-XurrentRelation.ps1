function Resolve-XurrentRelation
{
<#
.SYNOPSIS
    Resolves destination IDs of objects based on source/sourceID between two environments.

.DESCRIPTION
    Maps objects from a source environment to the corresponding objects in a destination
    environment using the common fields 'source' and 'sourceID'. Returns a mapping object
    containing source ID and destination ID (plus additional metadata).

    Two modes:
    - id: Processes an explicit list of IDs.
    - all: Processes all objects in both environments via export (requires PS 7.2+).

    When -MatchMissingByName is set, objects without a sourceID match are additionally
    matched by name.

.PARAMETER Type
    The data type (XurrentDataTypes enum). Mandatory.

.PARAMETER SourceEnvironment
    The source connection name. Mandatory.

.PARAMETER DestinationEnvironment
    The destination connection name. Mandatory.

.PARAMETER ID
    IDs of the source objects. Mandatory in parameter set 'id'.

.PARAMETER All
    Processes all objects via export. Mandatory in parameter set 'all'. Requires PS 7.2+.

.PARAMETER MatchMissingByName
    When set, unmapped objects are additionally matched by name.

.OUTPUTS
    System.Collections.ArrayList of PSCustomObjects with: IDsource, IDdestination, SoruceID, source, name.

.EXAMPLE
    Resolve-XurrentRelation -Type services -SourceEnvironment $qa -DestinationEnvironment $prod -ID 101, 102

.EXAMPLE
    Resolve-XurrentRelation -Type teams -SourceEnvironment $qa -DestinationEnvironment $prod -All -MatchMissingByName
#>
	[CmdletBinding(DefaultParameterSetName = 'id')]
	param (
		[Parameter(Mandatory = $true, ParameterSetName = 'id')]
		[Parameter(Mandatory = $true, ParameterSetName = 'all')]
		[XurrentDataTypes]$Type,
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