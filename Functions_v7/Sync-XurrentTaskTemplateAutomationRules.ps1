function Sync-XurrentTaskTemplateAutomationRules
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
		[string[]]$Tasks
	)
	try
	{
		$exportpath = Export-XurrentData -Environment $SourceEnvironment -Type task_template_automation_rules
		$Data = Import-Csv -Path $exportpath -Encoding UTF8 | Where-Object { $_.'Task Template' -in $Tasks } | Sort-Object Trigger
		if ($null -ne $Data)
		{
			Write-Verbose -Message "Sync task_template_automation_rules $($Data.Name -join ',')"
			Sync-XurrentObject -Type task_template_automation_rules -SourceEnvironment $SourceEnvironment -DestinationEnvironment $DestinationEnvironment -ID $Data.id
		}
		else
		{
			Write-Verbose -Message "no task_template_automation_rules exists"
		}
		
		$exportpathDest = Export-XurrentData -Environment $DestinationEnvironment -Type task_template_automation_rules
		$DestData = Import-Csv -Path $exportpathDest -Encoding UTF8 | Where-Object { $_.'Task Template' -in $Tasks } | Sort-Object Trigger
		$DeletedRules = $DestData | Where-Object { "$($_.'Source ID');$($_.Source)" -notin (($Data | Select-Object @{ l = "tmp"; e = { "$($_.'Source ID');$($_.Source)" } }).tmp) }
		if ($null -ne $DeletedRules)
		{
			Write-Warning -Message "disalbe automation_rules $($DeletedRules.id) in $($DestinationEnvironment)"
			foreach ($DeletedRule in $DeletedRules)
			{
				$null = update-XurrentRecord -Environment $DestinationEnvironment -Type automation_rules -ID $DeletedRule.id -Body @{ disabled = 1 }
				
			}
		}
	}
	catch
	{
		$_
		return
	}
	return
}