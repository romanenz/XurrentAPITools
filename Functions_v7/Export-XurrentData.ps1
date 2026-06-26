
function Export-XurrentData
{
<#
.SYNOPSIS
    Exports Xurrent data as a CSV file via the asynchronous export mechanism of the API.

.DESCRIPTION
    Starts an asynchronous data export via the Xurrent API endpoint /export and downloads
    the generated file. For a single type a CSV file is returned; for multiple types a
    ZIP file is returned which is automatically extracted.

    Caching: If an export file already exists that is newer than the configured cache
    value (default: 20 minutes, configurable via Set-XurrentAPITools -ExportCache),
    the existing file is returned without starting a new export.

.PARAMETER Environment
    The Xurrent connection name. Mandatory. Supports tab completion.

.PARAMETER Type
    One or more data types (XurrentDataTypes[]) for the export. Mandatory.

.PARAMETER Path
    Target directory for the export file. Default: $env:TEMP. Must be an existing directory.

.PARAMETER Cache
    Cache duration in minutes. Default: $script:ExportCache (configurable via Set-XurrentAPITools).

.PARAMETER from
    Optional timestamp: exports only objects modified since this point in time.

.OUTPUTS
    System.String – File path to the exported CSV file (or array of FileInfo objects for ZIP).

.EXAMPLE
    $path = Export-XurrentData -Environment $env -Type people

    Exports all people as CSV.

.EXAMPLE
    $files = Export-XurrentData -Environment $env -Type requests, tasks

    Exports requests and tasks as ZIP (automatically extracted).

.EXAMPLE
    Export-XurrentData -Environment $env -Type services -from (Get-Date).AddDays(-1)

    Exports only services modified in the last 24 hours.

.NOTES
    Alias: Export-4meData
    Requires PowerShell 7.2+.
    The export process polls every 10 seconds until completion.
#>
	param (
		[Parameter(Mandatory = $true)]
		[ValidateScript({ $null -ne $script:XurrentAuth.$_ })]
		[ArgumentCompleter({
				param ($cmd,
					$param,
					$wordToComplete)
				$script:XurrentAuth.keys -like "$wordToComplete*"
			})]
		[string]$Environment,
		[Parameter(Mandatory = $true)]
		[XurrentDataTypes[]]$Type,
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