function Import-XurrentData
{
<#
.SYNOPSIS
    Imports data into Xurrent via the asynchronous import mechanism of the API.

.DESCRIPTION
    Converts a PowerShell object array into a CSV file and uploads it to the Xurrent
    API endpoint /import. Waits asynchronously for the import to complete and outputs
    error details if the import fails.

    With -NoUpload, the CSV file is only created and returned without uploading.

.PARAMETER Environment
    The Xurrent connection name. Mandatory. Supports tab completion.

.PARAMETER Type
    The target data type (XurrentDataTypes enum). Mandatory.

.PARAMETER InputObject
    The array of objects to be imported. Mandatory.

.PARAMETER Path
    Directory for the temporary CSV file. Default: $env:TEMP.

.PARAMETER NoUpload
    When set, the CSV file is created but not uploaded. Useful for debugging.
    Default: $script:ImportNoUpload (configurable via Set-XurrentAPITools).

.OUTPUTS
    Nothing (on successful import) or String (file path when -NoUpload is set).

.EXAMPLE
    Import-XurrentData -Environment $env -Type people -InputObject $peopleArray

    Imports an array of people objects into Xurrent.

.EXAMPLE
    Import-XurrentData -Environment $env -Type services -InputObject $data -NoUpload

    Creates only the CSV file without uploading it.

.NOTES
    Alias: Import-4meData
    Requires PowerShell 7.2+.
    The import polls every 10 seconds until completion.
    Import results (successes/errors) are written via Write-Information.
#>
	[CmdletBinding()]
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
		[XurrentDataTypes]$Type,
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