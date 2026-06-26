function ConvertFrom-XurrentCustomFields
{
<#
.SYNOPSIS
    Converts the Xurrent API custom fields format into a readable PSCustomObject.

.DESCRIPTION
    The Xurrent API returns custom fields as an array of @{id=...; value=...} objects.
    This function converts that format into a PSCustomObject where each custom field ID
    becomes a property with the corresponding value.

    Supports three input modes:
    - Array: Direct input of a custom fields array (e.g. $record.custom_fields).
    - Object: Input of an API response object; the custom_fields property is replaced
      in-place by the converted object.
    - DataFromExport: Input of an export CSV object; the 'Custom Fields' property
      (a JSON string) is parsed and replaced in-place.

.PARAMETER CustomFields
    The array of custom field entries (@{id=...; value=...}).
    Mandatory in parameter set 'Array'.

.PARAMETER Object
    A PSCustomObject from an API response or export CSV whose custom_fields /
    'Custom Fields' property should be converted.
    Mandatory in parameter sets 'Object' and 'json'.

.PARAMETER DataFromExport
    Switch indicating that the object originates from a CSV export and the
    'Custom Fields' property contains a JSON string.
    Mandatory in parameter set 'json'.

.OUTPUTS
    PSCustomObject (in parameter set 'Array') or nothing (in-place mutation in 'Object'/'json').

.EXAMPLE
    $flat = ConvertFrom-XurrentCustomFields -CustomFields $record.custom_fields
    # Result: PSCustomObject with property cf_priority = 'high' etc.

.EXAMPLE
    # In-place conversion of an API object
    ConvertFrom-XurrentCustomFields -Object $record
    # Afterwards $record.custom_fields is a PSCustomObject instead of an array.

.EXAMPLE
    # For CSV export data
    $csvRow | ConvertFrom-XurrentCustomFields -DataFromExport

.NOTES
    Alias: ConvertFrom-4meCustomFields
#>
	[CmdletBinding(DefaultParameterSetName = 'Array')]
	param (
		[Parameter(Mandatory = $true, ParameterSetName = 'Array', Position = 0)]
		[System.Array]$CustomFields,
		[Parameter(Mandatory = $true, ParameterSetName = 'Object', Position = 0)]
		[Parameter(Mandatory = $true, ParameterSetName = 'json', Position = 0)]
		[PSCustomObject]$Object,
		[Parameter(Mandatory = $true, ParameterSetName = 'json', Position = 1)]
		[switch]$DataFromExport
	)
	
	Write-Verbose -Message "ParameterSetName $($PSCmdlet.ParameterSetName)"
	
	if ($PSCmdlet.ParameterSetName -eq 'Object')
	{
		$CustomFields = $Object.custom_fields
	}
	elseif ($PSCmdlet.ParameterSetName -eq 'json')
	{
		$CustomFields = $Object.'Custom Fields' | ConvertFrom-Json
		
	}
	$data = [PSCustomObject]::new()
	foreach ($item in $CustomFields)
	{
		$data | Add-Member -MemberType NoteProperty -Name $item.id -Value $item.value
	}
	if ($PSCmdlet.ParameterSetName -eq 'Object')
	{
		$Object.custom_fields = $data
		return
	}
	elseif ($PSCmdlet.ParameterSetName -eq 'json')
	{
		$Object.'Custom Fields' = $data
		return
	}
	return $data
}