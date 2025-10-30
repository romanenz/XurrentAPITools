function Resolve-XurrentCustomFieldsRelation
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