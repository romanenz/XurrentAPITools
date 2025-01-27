<#
.SYNOPSIS
Updates the source information for a specified record in the Xurrent system.

.DESCRIPTION
The `Set-XurrentSource` function updates the `source` and `sourceID` for a specified record in the Xurrent system. The function works with two modes: updating a single record or updating two records if a destination is also provided.

.PARAMETER Environment
Specifies the environment (such as "prod", "dev", etc.) in which the Xurrent record resides. The value must match a valid environment that exists within the global `$script:XurrentAuth` object.

.PARAMETER Type
Indicates the type of data to be updated. This value is validated against the `$script:XurrentDataTypes` array to ensure it's a valid type.

.PARAMETER ID
The identifier of the record to update. This is required for both the source and destination modes.

.PARAMETER DestinationID
When in the 'dest' parameter set, this specifies the ID of the destination record to also update with the same source information.

.PARAMETER DestinationEnvironment
Specifies the environment of the destination record when in 'dest' mode. This is validated against the global `$script:XurrentAuth` object to ensure it's a valid environment.

.EXAMPLES
# Example 1: Update the source of a record in the 'dev' environment.
Set-XurrentSource -Environment 'dev' -Type 'user' -ID 1234

# Example 2: Update the source of a record and another record in a different environment.
Set-XurrentSource -Environment 'prod' -Type 'transaction' -ID 5678 -DestinationID 91011 -DestinationEnvironment 'staging'

.NOTES
This function generates a new GUID for each invocation and assigns it as the `sourceID` in the updated record. The source is always set to `'XurrentAPITools'`.

.PARAMETERSETNAMES
- source: Updates a single record based on the provided ID.
- dest: Updates two records, one in the original environment and one in the destination environment.

.RETURNVALUE
Returns a custom object containing the new `source` and `sourceID` after successful execution.

.OUTPUTS
PSCustomObject: Returns an object with the updated `source` and `sourceID` values.

#>
function Set-XurrentSource
{
	[CmdletBinding(DefaultParameterSetName = 'source')]
	param (
		[Parameter(Mandatory = $true, ParameterSetName = 'source')]
		[Parameter(Mandatory = $true, ParameterSetName = 'dest')]
		[ValidateScript({ $null -ne $script:XurrentAuth.$_ })]
		[string]$Environment,
		[Parameter(Mandatory = $true, ParameterSetName = 'source')]
		[Parameter(Mandatory = $true, ParameterSetName = 'dest')]
		[ValidateScript({ $_ -in $script:XurrentDataTypes })]
		[string]$Type,
		[Parameter(Mandatory = $true, ParameterSetName = 'source')]
		[Parameter(Mandatory = $true, ParameterSetName = 'dest')]
		[int]$ID,
		[Parameter(Mandatory = $true, ParameterSetName = 'dest')]
		[int]$DestinationID,
		[Parameter(Mandatory = $true, ParameterSetName = 'dest')]
		[ValidateScript({ $null -ne $script:XurrentAuth.$_ })]
		[string]$DestinationEnvironment
		
	)
	$guid = [guid]::NewGuid()
	Write-Verbose -Message "update source of $($ID) to $($guid)"
	try
	{
		Update-XurrentRecord -Environment $Environment -Type $Type -ID $ID -Body @{ source = 'XurrentAPITools'; sourceID = $guid.ToString() }
		if ($PSCmdlet.ParameterSetName -eq 'dest')
		{
			Write-Verbose -Message "update sourceid of $($DestinationID) in $($DestinationEnvironment)"
			Update-XurrentRecord -Environment $DestinationEnvironment -Type $Type -ID $DestinationID -Body @{ source = 'XurrentAPITools'; sourceID = $guid.ToString() }
		}
	}
	catch
	{
		Write-Error $_
		return
	}
	
	
	return [PSCustomObject]::new(@{
			source = 'XurrentAPITools'
			SourceID = $guid.ToString()
		})
}