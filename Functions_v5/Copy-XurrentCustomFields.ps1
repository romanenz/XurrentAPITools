function Copy-XurrentCustomFields
{
<#
.SYNOPSIS
    Copies custom fields from one Xurrent object to another.

.DESCRIPTION
    Reads the custom fields of a source object and transfers them to a destination object.
    Both objects can be of the same or different types, but must reside in the same
    environment. Useful when custom field values need to be carried over from one
    record to another.

.PARAMETER Environment
    The Xurrent connection name. Mandatory.

.PARAMETER SourceID
    The ID of the source object whose custom fields are read. Mandatory.

.PARAMETER SourceType
    The data type of the source object (e.g. 'requests', 'tasks'). Mandatory.
    Must be a valid XurrentDataTypes value.

.PARAMETER DestinationID
    The ID of the destination object to which the custom fields are written. Mandatory.

.PARAMETER DestinationType
    The data type of the destination object. Optional; defaults to the value of -SourceType.
    Must be a valid XurrentDataTypes value.

.EXAMPLE
    Copy-XurrentCustomFields -Environment $env -SourceID 1234 -SourceType requests -DestinationID 5678

    Copies the custom fields from request 1234 to request 5678.

.EXAMPLE
    Copy-XurrentCustomFields -Environment $env -SourceID 1234 -SourceType requests `
        -DestinationID 9999 -DestinationType tasks

    Copies custom fields from a request to a task.
#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[ValidateScript({ $null -ne $script:XurrentAuth.$_ })]
		[string]$Environment,
		[Parameter(Mandatory = $true)]
		[int]$SourceID,
		[Parameter(Mandatory = $true)]
		[ValidateScript({ $_ -in $script:XurrentDataTypes })]
		[string]$SourceType,
		[Parameter(Mandatory = $true)]
		[int]$DestinationID,
		[Parameter(Mandatory = $false)]
		[ValidateScript({ $_ -in $script:XurrentDataTypes })]
		[string]$DestinationType
		
	)
	if ([string]::IsNullOrEmpty($DestinationType))
	{
		$DestinationType = $SourceType
	}
	$SourceItem = Get-XurrentData -Type $DestinationType -Environment $Environment -ID $SourceID -Full -ConvertCustomFields:$fale
	$body = @{
		custom_fields = $SourceItem.custom_fields
	}
	Update-XurrentRecord -Environment $Environment -Type $SourceType -ID $DestinationID -Body $body
}