function Set-XurrentSource
{
<#
.SYNOPSIS
    Sets the 'source' and 'sourceID' fields of one or two Xurrent records.

.DESCRIPTION
    Generates a new GUID and sets the 'source' field (='XurrentAPITools') and
    'sourceID' field (=GUID) on an existing record. Optional mode: simultaneously
    update a destination object in another environment with the same GUID.

    Used internally by Sync-XurrentObject to set missing source anchors.

.PARAMETER Environment
    The Xurrent connection name of the source object. Mandatory.

.PARAMETER Type
    The data type (XurrentDataTypes enum). Mandatory.

.PARAMETER ID
    The ID of the object to update. Mandatory.

.PARAMETER DestinationID
    The ID of the destination object (different environment).
    Mandatory in parameter set 'dest'.

.PARAMETER DestinationEnvironment
    The connection name of the destination environment.
    Mandatory in parameter set 'dest'.

.OUTPUTS
    PSCustomObject with the properties 'source' and 'SourceID'.

.EXAMPLE
    Set-XurrentSource -Environment $env -Type requests -ID 12345

    Sets source and sourceID for request 12345.

.EXAMPLE
    Set-XurrentSource -Environment $qa -Type services -ID 100 `
        -DestinationID 200 -DestinationEnvironment $prod

    Sets the same GUID for service 100 in QA and service 200 in Production.
#>
	[CmdletBinding(DefaultParameterSetName = 'source')]
	param (
		[Parameter(Mandatory = $true, ParameterSetName = 'source')]
		[Parameter(Mandatory = $true, ParameterSetName = 'dest')]
		[ValidateScript({ $null -ne $script:XurrentAuth.$_ })]
		[string]$Environment,
		[Parameter(Mandatory = $true, ParameterSetName = 'source')]
		[Parameter(Mandatory = $true, ParameterSetName = 'dest')]
		[XurrentDataTypes]$Type,
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
		$null = Update-XurrentRecord -Environment $Environment -Type $Type -ID $ID -Body @{ source = 'XurrentAPITools'; sourceID = $guid.ToString() }
		if ($PSCmdlet.ParameterSetName -eq 'dest')
		{
			Write-Verbose -Message "update sourceid of $($DestinationID) in $($DestinationEnvironment)"
			$null = Update-XurrentRecord -Environment $DestinationEnvironment -Type $Type -ID $DestinationID -Body @{ source = 'XurrentAPITools'; sourceID = $guid.ToString() }
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