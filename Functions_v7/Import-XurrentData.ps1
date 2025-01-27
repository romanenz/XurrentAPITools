function Import-XurrentData
{
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[ValidateScript({ $null -ne $script:XurrentAuth.$_ })]
		[string]$Environment,
		[Parameter(Mandatory)]
		[ValidateScript({ $_ -in $script:XurrentDataTypes })]
		[String]$Type,
		[Parameter(Mandatory = $true)]
		[System.Array]$InputObject,
		[ValidateScript({ (Get-Item $_) -is [System.IO.DirectoryInfo] })]
		[IO.FileInfo]$Path = $env:TEMP,
		[switch]$NoUpload = $script:ImportNoUpload
	)
	Write-Verbose -Message "import $($Type)"
	$Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False
	$FilePath = Join-Path -Path $Path -ChildPath "import_$($Type).csv"
	Write-Verbose -Message "create importfile $($FilePath)"
	[System.IO.File]::WriteAllLines($FilePath, ($InputObject | ConvertTo-Csv -NoTypeInformation), $Utf8NoBomEncoding)
	if ($NoUpload -eq $true)
	{
		return $FilePath
	}
	
	Write-Verbose -Message "upload $($FilePath)"
	$body = @{
		type = $Type
		file = Get-Item $FilePath
	}
	$token = Invoke-RestMethod -Method Post -Uri "$($script:XurrentAuth.$Environment.URL)/import" -Headers $script:XurrentAuth.$Environment.header -Form $body -ErrorAction Stop -Verbose:$false
	
	$Import = Invoke-RestMethod -Method get -Uri "$($script:XurrentAuth.$Environment.URL)/import/$($token.token)" -Headers $script:XurrentAuth.$Environment.header -Verbose:$false
	while ($Import.state -eq "queued" -or $Import.state -eq "processing")
	{
		$Import = Invoke-RestMethod -Method get -Uri "$($script:XurrentAuth.$Environment.URL)/import/$($token.token)" -Headers $script:XurrentAuth.$Environment.header -Verbose:$false
		if ($Import.state -eq "error")
		{
			throw "$($Import.message)"
		}
		Start-Sleep -Seconds 10
	}
	Write-Information -Message "$($Type) import result: $($Import.results -join ' ')"
	if ($Import.results.errors -ne 0)
	{
		Write-ERROR -Message "$($Import.results.errors) errors occurred. Logfile: $($Import.logfile)"
	}
	return
}