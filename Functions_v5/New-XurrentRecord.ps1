function New-XurrentRecord
{
<#
.SYNOPSIS
    Creates a new record via the Xurrent REST API.

.DESCRIPTION
    Sends an HTTP POST request to the Xurrent API endpoint of the specified type,
    creating a new record. Automatically sets source and sourceID if they are not
    provided in the body.

    Optional pre-processing:
    - Notes can be ASCII-encoded for special characters (ä, ö, ü) via -EncodeNotes.
    - Custom fields in hashtable format are automatically converted to the API format
      via -ConvertCustomFields.

.PARAMETER Environment
    The Xurrent connection name. Mandatory.

.PARAMETER Type
    The target data type (XurrentDataTypes enum, e.g. 'requests', 'tasks'). Mandatory.

.PARAMETER Body
    A hashtable with the fields and values to set. Mandatory.

.PARAMETER EncodeNotes
    When set, umlauts in Body.note are ASCII-encoded for compatibility.

.PARAMETER ConvertCustomFields
    When set, custom_fields are converted from hashtable format to the API array format.

.OUTPUTS
    PSCustomObject – The newly created object returned by the API.

.EXAMPLE
    New-XurrentRecord -Environment $env -Type requests -Body @{
        subject  = 'New Request'
        category = 'incident'
    }

.EXAMPLE
    New-XurrentRecord -Environment $env -Type requests -Body @{
        subject       = 'Request with Custom Field'
        custom_fields = @{ 'cf_cost_center' = '4200' }
    } -ConvertCustomFields

.NOTES
    Alias: New-4meRecord
    If creation fails, an error is written.
#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[ValidateScript({ $null -ne $script:XurrentAuth.$_ })]
		[string]$Environment,
		[Parameter(Mandatory = $true)]
		[XurrentDataTypes]$Type,
		[Parameter(Mandatory = $true)]
		[Hashtable]$Body,
		[Parameter(Mandatory = $false)]
		[switch]$EncodeNotes,
		[Parameter(Mandatory = $false)]
		[switch]$ConvertCustomFields
		
	)
	if (-not [string]::IsNullOrEmpty($Body.note) -and $EncodeNotes)
	{
		$Body.note = [Text.Encoding]::ASCII.GetString([Text.Encoding]::GetEncoding("x-IA5-German").GetBytes($Body.note.replace('ä', 'ae').replace('ö', 'oe').replace('ü', 'ue')))
	}
	if (-not ($Body.ContainsKey("source") -and $Body.ContainsKey("sourceID")))
	{
		$body['source'] = 'XurrentAPITools'
		$body['sourceID'] = [guid]::NewGuid()
	}
	if (-not [string]::IsNullOrEmpty($Body.custom_fields) -and $ConvertCustomFields)
	{
		$Body.custom_fields = Convert-XurrentCustomFields -CustomFields $Body.custom_fields
	}
	$ParsedBody = $Body | ConvertTo-Json
	$response = Invoke-RestMethod -Method POST -URI "$($script:XurrentAuth.$Environment.URL)/$($Type)" -Headers $script:XurrentAuth.$Environment.header -Body $ParsedBody
	if ([string]::IsNullOrEmpty($response.id))
	{
		Write-Error -Message "creaton failed"
	}
	return $response
}