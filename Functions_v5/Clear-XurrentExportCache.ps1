function Clear-XurrentExportCache
{
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $false)]
		[ValidateScript({ $null -ne $script:XurrentAuth.$_ })]
		[string]$Environment
		
	)
	try
	{
		if ([string]::IsNullOrEmpty($Environment))
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