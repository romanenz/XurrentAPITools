function Clear-XurrentExportCache
{
	<#
.SYNOPSIS
    Deletes cached export files for one or all Xurrent environments.

.DESCRIPTION
    Removes CSV export files that have been cached in the temporary directory.
    If no Environment is specified, cache files for all active connections are deleted.
    Useful for discarding stale export data and forcing fresh data on the next call to
    Export-XurrentData or Get-XurrentData (export mode).

.PARAMETER Environment
    Name of the Xurrent connection (e.g. 'wdc_Production_Global') as returned by
    Connect-Xurrent. Must match an active connection in $script:XurrentAuth.
    If omitted, all known connections are cleaned up.

.EXAMPLE
    Clear-XurrentExportCache

    Deletes all cached export files for all connected environments.

.EXAMPLE
    Clear-XurrentExportCache -Environment 'wdc_Production_Global'

    Deletes only the export files for the connection 'wdc_Production_Global'.

.NOTES
    Files are located in $env:TEMP using the pattern '<Environment>*.csv'.
#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $false)]
		[ValidateScript({ $null -ne $script:XurrentAuth.$_ })]
		[string]$Environment
		
	)
	try
	{
		if (-not [string]::IsNullOrEmpty($Environment))
		{
			Get-ChildItem -Path $env:TEMP -Filter "$($Environment)*.csv" | Remove-Item -Force
		}
		else
		{
			foreach ($Environment in $script:XurrentAuth.keys)
			{
				Get-ChildItem -Path $env:TEMP -Filter "$($Environment)*.csv" | Remove-Item -Force
			}
		}
	}
	catch
	{
		Write-Error $_
		return
	}
	return
}