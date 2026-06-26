function Update-XurrentRecord
{
<#
.SYNOPSIS
    Updates an existing Xurrent record or moves it to the trash or archive.

.DESCRIPTION
    Supports three operating modes:
    - body (default): Updates fields of a record via HTTP PATCH.
    - trash: Moves the record to the trash (POST /trash).
    - archive: Archives the record (POST /archive).

    Optional pre-processing as with New-XurrentRecord:
    - Notes can be ASCII-encoded via -EncodeNotes.
    - Custom fields in hashtable format are converted via -ConvertCustomFields.

.PARAMETER Environment
    The Xurrent connection name. Mandatory in all parameter sets.

.PARAMETER Type
    The data type (XurrentDataTypes enum). Mandatory.

.PARAMETER ID
    The ID of the record to update. Mandatory.

.PARAMETER Body
    Hashtable with the fields and values to update. Mandatory in parameter set 'body'.

.PARAMETER EncodeNotes
    ASCII-encodes umlauts in Body.note. Optional.

.PARAMETER ConvertCustomFields
    Converts custom_fields from hashtable format to the API array format. Optional.

.PARAMETER Trash
    Moves the record to the trash. Mandatory in parameter set 'trash'.

.PARAMETER Archive
    Archives the record. Mandatory in parameter set 'archive'.

.OUTPUTS
    PSCustomObject – The updated object returned by the API.

.EXAMPLE
    Update-XurrentRecord -Environment $env -Type requests -ID 123456 -Body @{
        status = 'completed'
    }

.EXAMPLE
    Update-XurrentRecord -Environment $env -Type requests -ID 123456 -Trash

    Moves request 123456 to the trash.

.EXAMPLE
    Update-XurrentRecord -Environment $env -Type tasks -ID 9876 -Body @{
        note          = 'Done'
        custom_fields = @{ 'cf_resolution' = 'fixed' }
    } -ConvertCustomFields

.NOTES
    Alias: Update-4meRecord
#>
	[CmdletBinding(DefaultParameterSetName = 'body')]
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true, ParameterSetName = 'body')]
		[Parameter(Mandatory = $true, ParameterSetName = 'trash')]
		[Parameter(Mandatory = $true, ParameterSetName = 'archive')]
		[ValidateScript({ $null -ne $script:XurrentAuth.$_ })]
		[string]$Environment,
		[Parameter(Mandatory = $true, ParameterSetName = 'body')]
		[Parameter(Mandatory = $true, ParameterSetName = 'trash')]
		[Parameter(Mandatory = $true, ParameterSetName = 'archive')]
		[XurrentDataTypes]$Type,
		[Parameter(Mandatory = $true, ParameterSetName = 'body')]
		[Parameter(Mandatory = $true, ParameterSetName = 'trash')]
		[Parameter(Mandatory = $true, ParameterSetName = 'archive')]
		[int]$ID,
		[Parameter(Mandatory = $true, ParameterSetName = 'body')]
		[Hashtable]$Body,
		[Parameter(Mandatory = $false, ParameterSetName = 'body')]
		[switch]$EncodeNotes,
		[Parameter(Mandatory = $false, ParameterSetName = 'body')]
		[switch]$ConvertCustomFields,
		[Parameter(Mandatory = $true, ParameterSetName = 'trash')]
		[switch]$Trash,
		[Parameter(Mandatory = $true, ParameterSetName = 'archive')]
		[switch]$Archive
		
	)
	if ($PSCmdlet.ParameterSetName -eq 'body')
	{
		if (-not [string]::IsNullOrEmpty($Body.note) -and $EncodeNotes)
		{
			$Body.note = [Text.Encoding]::ASCII.GetString([Text.Encoding]::GetEncoding("x-IA5-German").GetBytes($Body.note.replace('ä', 'ae').replace('ö', 'oe').replace('ü', 'ue')))
		}
		
		if (-not [string]::IsNullOrEmpty($Body.custom_fields) -and $ConvertCustomFields)
		{
			$Body.custom_fields = Convert-XurrentCustomFields -CustomFields $Body.custom_fields
		}
		$ParesedBody = $Body | ConvertTo-Json
		Write-Verbose -Message "update $($script:XurrentAuth.$Environment.URL)/$($Type)/$($ID)"
		$response = Invoke-RestMethod -Method Patch -URI "$($script:XurrentAuth.$Environment.URL)/$($Type)/$($ID)" -Headers $script:XurrentAuth.$Environment.header -Body $ParesedBody -Verbose:$false
	}
	elseif ($PSCmdlet.ParameterSetName -eq 'trash')
	{
		Write-Verbose -Message "trash $($script:XurrentAuth.$Environment.URL)/$($Type)/$($ID)/trash"
		$response = Invoke-RestMethod -Method Post -URI "$($script:XurrentAuth.$Environment.URL)/$($Type)/$($ID)/trash" -Headers $script:XurrentAuth.$Environment.header -Verbose:$false
		
	}
	elseif ($PSCmdlet.ParameterSetName -eq 'archive')
	{
		Write-Verbose -Message "archive $($script:XurrentAuth.$Environment.URL)/$($Type)/$($ID)/archive"
		$response = Invoke-RestMethod -Method Post -URI "$($script:XurrentAuth.$Environment.URL)/$($Type)/$($ID)/archive" -Headers $script:XurrentAuth.$Environment.header -Verbose:$false
		
	}
	if ([string]::IsNullOrEmpty($response.id))
	{
		Write-Error -Message "update failed"
	}
	return $response
}
