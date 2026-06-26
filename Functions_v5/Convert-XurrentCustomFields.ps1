function Convert-XurrentCustomFields
{	
<#
.SYNOPSIS
    Converts a hashtable of custom field values into the Xurrent API format.

.DESCRIPTION
    The Xurrent REST API expects custom fields as an array of objects with the properties
    'id' (field name) and 'value' (field value). This function converts a simple PowerShell
    hashtable (@{ 'my_field' = 'value' }) into this array format.

    Used internally by New-XurrentRecord and Update-XurrentRecord when the
    -ConvertCustomFields switch is set.

.PARAMETER CustomFields
    A hashtable whose keys correspond to the custom field IDs and whose values
    correspond to the field contents. Mandatory.

.OUTPUTS
    System.Array – Array of hashtables with the keys 'id' and 'value'.

.EXAMPLE
    $fields = @{ 'cf_priority' = 'high'; 'cf_region' = 'EMEA' }
    $apiFields = Convert-XurrentCustomFields -CustomFields $fields

    Returns @(@{id='cf_priority';value='high'}, @{id='cf_region';value='EMEA'}).

.EXAMPLE
    # Usage with New-XurrentRecord
    New-XurrentRecord -Environment $env -Type requests -Body @{
        subject        = 'Test'
        custom_fields  = @{ 'cf_cost_center' = '4200' }
    } -ConvertCustomFields
#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[Hashtable]$CustomFields
		
	)
		$custom_fields = @()
		
		foreach ($entry in $CustomFields.GetEnumerator())
		{
			$custom_fields += @{
				id    = $entry.Key
				value = $entry.Value
			}
		}
	return $custom_fields
}