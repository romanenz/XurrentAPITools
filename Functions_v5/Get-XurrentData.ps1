function Get-XurrentData
{
	[CmdletBinding(DefaultParameterSetName = 'param')]
	param (
		[Parameter(Mandatory = $true, ParameterSetName = 'id')]
		[Parameter(Mandatory = $true, ParameterSetName = 'param')]
		[Parameter(Mandatory = $true, ParameterSetName = 'export')]
		[ValidateScript({ $null -ne $script:XurrentAuth.$_ })]
		[string]$Environment,
		[Parameter(Mandatory = $true, ParameterSetName = 'id')]
		[Parameter(Mandatory = $true, ParameterSetName = 'param')]
		[Parameter(Mandatory = $true, ParameterSetName = 'export')]
		[ValidateScript({ $_ -in $script:XurrentDataTypes })]
		[string]$Type,
		[Parameter(Mandatory = $false, ParameterSetName = 'id')]
		[string]$SubType,
		[Parameter(Mandatory = $false, ParameterSetName = 'id')]
		[Parameter(Mandatory = $false, ParameterSetName = 'param')]
		[switch]$Full = $false,
		[Parameter(Mandatory = $false, ParameterSetName = 'id')]
		[Parameter(Mandatory = $false, ParameterSetName = 'param')]
		[string]$Parameter,
		[Parameter(Mandatory = $true, ParameterSetName = 'id')]
		[int[]]$ID,
		[Parameter(Mandatory = $false, ParameterSetName = 'id')]
		[Parameter(Mandatory = $false, ParameterSetName = 'param')]
		[ValidateScript({ $PSBoundParameters.full -eq $true })]
		[switch]$ConvertCustomFields = $true,
		[Parameter(Mandatory = $false, ParameterSetName = 'export')]
		[switch]$ConvertCustomFieldJson = $true,
		[Parameter(Mandatory = $true, ParameterSetName = 'export')]
		[ValidateScript({ $PSVersionTable.PSVersion -ge $Script:MinimalV7Version})]
		[switch]$Export
	)
	$url = "$($script:XurrentAuth.$Environment.URL)/$($Type)"
	$InitialURL = $null
	if ($PSCmdlet.ParameterSetName -eq 'id')
	{
		$data = @()
		foreach ($item in $ID) { $data += @{ id = $item } }
	}
	elseif ($PSCmdlet.ParameterSetName -eq 'export')
	{
		$data = @()
		Write-Verbose -Message "get data from export"
		foreach ($tmp in (Import-Csv -Path (Export-XurrentData -Environment $Environment -Type $Type)))
		{
			if ($ConvertCustomFieldJson -and $null -ne $tmp.'Custom Fields')
			{
				Write-Verbose -Message "convert custom fields"
				ConvertFrom-XurrentCustomFields -Object $tmp -DataFromExport
			}
			$data += $tmp
		}
		return $data
	}
	else
	{
		if (-not [string]::IsNullOrEmpty($Parameter))
		{
			$InitialURL = $url + "?" + $Parameter
		}
		else
		{
			$InitialURL = $url
		}
		Write-Verbose -Message "get data from $($InitialURL)"
		$tempdata = Invoke-WebRequest -Method get -Uri $InitialURL -Headers $script:XurrentAuth.$Environment.header -UseBasicParsing -Verbose:$false
		
		if ($tempdata.Headers."X-Pagination-Total-Pages" -gt 1)
		{
			$data = @()
			Write-Verbose -Message "total pages: $($tempdata.Headers."X-Pagination-Total-Pages")"
			$data += $tempdata.Content | ConvertFrom-Json
			while ($tempdata.Headers.'X-Pagination-Current-Page' -ne $tempdata.Headers."X-Pagination-Total-Pages")
			{
				$nextURL = ($tempdata.Headers.link.Split(",") | Where-Object { $_ -match 'next' }).Split(";")[0].trim("<> ")
				$tempdata = Invoke-WebRequest -Method get -Uri $nextURL -Headers $script:XurrentAuth.$Environment.header -UseBasicParsing -Verbose:$false
				$data += $tempdata.Content | ConvertFrom-Json
			}
		}
		elseif ($null -ne $tempdata)
		{
			$data = $tempdata.Content | ConvertFrom-Json
		}
		if ($Full -eq $false)
		{
			return $data
		}
	}
	Write-Verbose -Message "get full data"
	$FullData = @()
	foreach ($id in $data.id)
	{
		$tmpURL = $url + "/" + $id
		if (-not [string]::IsNullOrEmpty($SubType))
		{
			$tmpURL = $tmpURL + "/" + $SubType
		}
		if (-not [string]::IsNullOrEmpty($Parameter))
		{
			$tmpURL = $tmpURL + "?" + $Parameter
		}
		Write-Verbose "get data from $($tmpURL)"
		$tmp = Invoke-RestMethod -Method get -Uri $tmpURL -Headers $script:XurrentAuth.$Environment.header -Verbose:$false
		Write-Verbose "$($tmp.custom_fields.count)"
		if ($ConvertCustomFields -and $null -ne $tmp.custom_fields -and [string]::IsNullOrEmpty($SubType))
		{
			Write-Verbose -Message "convert custom fields"
			ConvertFrom-XurrentCustomFields -Object $tmp
		}
		$FullData += $tmp
	}
	return $FullData
}