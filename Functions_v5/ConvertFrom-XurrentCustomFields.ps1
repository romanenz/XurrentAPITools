function ConvertFrom-XurrentCustomFields
{
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