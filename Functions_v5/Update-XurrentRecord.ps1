function Update-XurrentRecord
{
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
		[ValidateScript({ $_ -in $script:XurrentDataTypes })]
		[string]$Type,
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
	return
}