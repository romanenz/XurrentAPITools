function Resolve-XurrentCustomFieldsRelation
{
<#
.SYNOPSIS
    Updates custom field values that reference object IDs for a destination environment.

.DESCRIPTION
    When synchronising objects between environments, custom fields often contain IDs
    that are only valid in the source environment. This function resolves such references:
    it reads the custom field values of the source objects, determines the corresponding
    IDs in the destination environment via Resolve-XurrentRelation, and updates the
    destination objects accordingly.

    Optionally a mapping table can be provided for static ID assignments.

.PARAMETER Type
    The data type of the objects to process (XurrentDataTypes enum). Mandatory.

.PARAMETER SourceEnvironment
    The source connection name. Mandatory.

.PARAMETER DestinationEnvironment
    The destination connection name. Mandatory.

.PARAMETER ID
    IDs of the source objects whose custom fields need to be updated. Mandatory.

.PARAMETER CustomField
    Array of custom field IDs (field names) that contain referenced IDs. Mandatory.

.PARAMETER CustomFieldType
    Array of types that the custom fields reference (order matches -CustomField).
    Must have the same number of entries as -CustomField. Mandatory.

.PARAMETER MappingTable
    Optional PSCustomObject with manual ID mappings when the type is 'MappingTable'.

.EXAMPLE
    Resolve-XurrentCustomFieldsRelation `
        -Type requests `
        -SourceEnvironment $src `
        -DestinationEnvironment $dest `
        -ID 1001, 1002 `
        -CustomField 'cf_related_service' `
        -CustomFieldType 'services'
#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[XurrentDataTypes]$Type,
		[Parameter(Mandatory = $true)]
		[ValidateScript({ $null -ne $script:XurrentAuth.$_ })]
		[string]$SourceEnvironment,
		[Parameter(Mandatory = $true)]
		[ValidateScript({ $null -ne $script:XurrentAuth.$_ })]
		[string]$DestinationEnvironment,
		[Parameter(Mandatory = $true)]
		[int[]]$ID,
		[Parameter(Mandatory = $true)]
		[string[]]$CustomField,
		[Parameter(Mandatory = $true)]
		[string[]]$CustomFieldType,
		[Parameter(Mandatory = $false)]
		[PSCustomObject]$MappingTable
	)
	try
	{
		if ($CustomField.count -ne $CustomFieldType.count) { Write-Error "CustomFiels not matches CustomFieldType"; return}
		$SourceData = Get-XurrentData -Type $Type -Environment $SourceEnvironment -ID $ID -Parameter "fields=id,source,sourceID,custom_fields"
		for ($i = 0; $i -lt $CustomField.count; $i++)
		{
			if ($CustomFieldType[$i] -eq "MappingTable" -and "$($CustomField[$i])_id" -notin $MappingTable[0].PSObject.Properties.Name)
			{
				Write-Error "missing MappingTable Field $($CustomField[$i])_id"
			}
		}
		foreach ($Item in $SourceData)
		{
			Write-Verbose -Message "get relation from object $($Item.ID)"
			$Update = @{ custom_fields = @{ } }
			for ($i = 0; $i -lt $CustomField.count; $i++)
			{
				$Relation = Resolve-XurrentRelation -Type $CustomFieldType[$i] -SourceEnvironment $SourceEnvironment -DestinationEnvironment $DestinationEnvironment -ID $item.custom_fields.($CustomField[$i])
				Write-Debug -Message "get related $($CustomFieldType[$i]) for $($CustomField[$i])"
				$Update.custom_fields.Add($CustomField[$i], $Relation.IDdestination)
			}
			Convert-XurrentCustomFields $Update.custom_fields
			$DestITem = Resolve-XurrentRelation -Type $Type -SourceEnvironment $SourceEnvironment -DestinationEnvironment $DestinationEnvironment -ID $item.ID
			$null = Update-XurrentRecord -Environment $DestinationEnvironment -Type $Type -ID $DestITem.IDdestination -Body $Update -ConvertCustomFields
		}
		return $RelationData
	}
	catch
	{
		Write-Error $_
	}
}