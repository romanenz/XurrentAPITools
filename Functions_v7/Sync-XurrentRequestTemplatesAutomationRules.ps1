function Sync-XurrentRequestTemplatesAutomationRules
{
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[ValidateScript({ $null -ne $script:XurrentAuth.$_ })]
		[string]$SourceEnvironment,
		[Parameter(Mandatory = $true)]
		[ValidateScript({ $null -ne $script:XurrentAuth.$_ })]
		[string]$DestinationEnvironment,
		[Parameter(Mandatory = $true)]
		[int[]]$Templates
	)
	try
	{
		$exportpath = Export-XurrentData -Environment $SourceEnvironment -Type request_template_automation_rules
		$Data = Import-Csv -Path $exportpath -Encoding UTF8 | Where-Object { $_.'Request Template' -in $Templates } | Sort-Object Trigger
		if ($null -ne $Data)
		{
			Write-Verbose -Message "Sync request_template_automation_rules $($Data.Name -join ',')"
			Sync-XurrentObject -Type request_template_automation_rules -SourceEnvironment $SourceEnvironment -DestinationEnvironment $DestinationEnvironment -ID $Data.id
		}
		else
		{
			Write-Verbose -Message "no request_template_automation_rules exists"
		}
	}
	catch
	{
		$_
		return
	}
	return
}