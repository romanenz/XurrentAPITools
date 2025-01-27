function Convert-XurrentCustomFields
{
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