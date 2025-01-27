function New-XurrentRecord
{
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[ValidateScript({ $null -ne $script:XurrentAuth.$_ })]
		[string]$Environment,
		[Parameter(Mandatory = $true)]
		[ValidateScript({ $_ -in $script:XurrentDataTypes })]
		[string]$Type,
		[Parameter(Mandatory = $true)]
		[Hashtable]$Body,
		[Parameter(Mandatory = $false)]
		[switch]$EncodeNotes
		
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
	$ParesedBody = $Body | ConvertTo-Json
	$response = Invoke-RestMethod -Method POST  -URI "$($script:XurrentAuth.$Environment.URL)/$($Type)" -Headers $script:XurrentAuth.$Environment.header -Body $ParesedBody
	if ([string]::IsNullOrEmpty($response.id))
	{
		Write-Error -Message "creaton failed"
	}
	return $response
}