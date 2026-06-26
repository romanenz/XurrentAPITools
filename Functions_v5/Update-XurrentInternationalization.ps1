function Update-XurrentInternationalization
{
<#
.SYNOPSIS
    Downloads and saves the Xurrent enum translations for a given language.

.DESCRIPTION
    Calls the /enums endpoint of the Xurrent API with a specific language header and
    saves the response as a JSON file in the module's internationalization directory.
    These files are used by Get-XurrentAiClassifierHits to recognise localised
    category and impact texts.

.PARAMETER Language
    The language code (e.g. 'de', 'en', 'fr'). Mandatory.

.EXAMPLE
    Update-XurrentInternationalization -Language 'de'

    Downloads the German enum translations and saves them in the module directory.

.NOTES
    No authentication required (public endpoint).
    File is saved as <Language>.json in the Internationalization subdirectory.
#>
	[CmdletBinding(DefaultParameterSetName = 'Language')]
	param (
		[Parameter(Mandatory = $true, ParameterSetName = 'Language')]
		[string]$Language
	)
	
	try
	{
		$Enum = Invoke-RestMethod -Method get -Uri "https://api.xurrent.com/v1/enums" -Headers @{ "X-Xurrent-Language" = $Language }
		$Enum | ConvertTo-Json | Out-File -Encoding UTF8 -FilePath "$($script:InternationalizationPath)\$($Language).json" -Force
	}
	catch
	{
		Write-Error $_
	}
}