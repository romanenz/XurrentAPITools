
function Export-XurrentData
{
	param (
		[Parameter(Mandatory = $true)]
		[ValidateScript({ $null -ne $script:XurrentAuth.$_ })]
		[string]$Environment,
		[Parameter(Mandatory = $true)]
		[ValidateScript({ $_ -in $script:XurrentDataTypes })]
		[String[]]$Type,
		[ValidateScript({ (Get-Item $_) -is [System.IO.DirectoryInfo] })]
		[IO.FileInfo]$Path = $env:TEMP,
		[int]$Cache = $script:ExportCache,
		[DateTime]$from
	)
	# define path
	if ($Type.Count -eq 1)
	{
		$FilePath = Join-Path -Path $Path -ChildPath "$($Environment)_$($Type).csv"
		Write-Verbose -Message "export $($Type)"
	}
	else
	{
		$FilePath = Join-Path -Path $Path -ChildPath "Xurrent_export.zip"
		Write-Verbose -Message "export $($Type -join ',')"
	}
	if (Test-Path -Path $FilePath)
	{
		$FileCreationTime = ((Get-Date) - (Get-ChildItem -Path $FilePath).CreationTime).TotalMinutes
		Write-Verbose -Message "last export $($FileCreationTime) minutes ago, cache set to $($Cache)"
	}
	if ($FileCreationTime -gt $Cache -or $null -eq $FileCreationTime)
	{
		try
		{
			if (Test-Path -Path $FilePath)
			{
				Write-Verbose -Message "remove cache $($FilePath)"
				Remove-Item -Path $FilePath -Force
			}
			Write-Verbose -Message "download export $($FilePath)"
			
			if ($null -ne $from)
			{
				Write-Verbose -Message "export updates since $($from.ToUniversalTime().ToString("yyyyMMddTHH:mm:ssZ"))"
				$body = @{
					type = $Type -join ", "
					from = $from.ToUniversalTime().ToString("yyyyMMddTHH:mm:ssZ")
				} | ConvertTo-Json
			}
			else
			{
				$body = @{
					type = $Type -join ", "
				} | ConvertTo-Json
			}
			$token = Invoke-RestMethod -Method Post -Uri "$($script:XurrentAuth.$Environment.URL)/export" -Headers $script:XurrentAuth.$Environment.header -Body $body -ErrorAction Stop -Verbose:$false
			
			$export = Invoke-RestMethod -Method get -Uri "$($script:XurrentAuth.$Environment.URL)/export/$($token.token)" -Headers $script:XurrentAuth.$Environment.header -ErrorAction Stop -Verbose:$false
			# wait for export
			while ($export.state -ne "done")
			{
				$export = Invoke-RestMethod -Method get -Uri "$($script:XurrentAuth.$Environment.URL)/export/$($token.token)" -Headers $script:XurrentAuth.$Environment.header -ErrorAction Stop -Verbose:$false
				Start-Sleep -Seconds 10
			}
			
			# downlaod files
			Invoke-WebRequest -Uri $export.url -OutFile $FilePath
		}
		catch
		{
			Write-Error $_
			return
		}
		
	}
	
	if ([System.IO.Path]::GetExtension($FilePath) -match 'zip')
	{
		Expand-Archive -Path $FilePath -DestinationPath ([System.IO.Path]::GetFileNameWithoutExtension($FilePath)) -Force
		return Get-ChildItem -Path ([System.IO.Path]::GetFileNameWithoutExtension($FilePath))
	}
	else
	{
		return $FilePath
	}
}