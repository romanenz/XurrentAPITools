function Sync-XurrentWorkflowTemplateAutomationRules
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
		[string[]]$WorkflowTemplates
	)
	try
	{
		$exportpath = Export-XurrentData -Environment $SourceEnvironment -Type workflow_template_automation_rules
		$Data = Import-Csv -Path $exportpath -Encoding UTF8 | Where-Object { $_.'Workflow Template' -in $WorkflowTemplates } | Sort-Object Trigger
		if ($null -ne $Data)
		{
			Write-Verbose -Message "Sync workflow_template_automation_rules $($Data.Name -join ',')"
			Sync-XurrentObject -Type workflow_template_automation_rules -SourceEnvironment $SourceEnvironment -DestinationEnvironment $DestinationEnvironment -ID $Data.id
		}
		else
		{
			Write-Verbose -Message "no workflow_template_automation_rules exists"
		}
		$Relations = Resolve-XurrentRelation -Type workflow_templates -SourceEnvironment $SourceEnvironment -DestinationEnvironment $DestinationEnvironment -ID $WorkflowTemplates
		
		$exportpathDest = Export-XurrentData -Environment $DestinationEnvironment -Type workflow_template_automation_rules
		$DestData = Import-Csv -Path $exportpathDest -Encoding UTF8 | Where-Object { $_.'Workflow Template' -in $Relations.IDdestination } | Sort-Object Trigger
		$DeletedRules = $DestData | Where-Object { "$($_.'Source ID');$($_.Source)" -notin (($Data | Select-Object @{ l = "tmp"; e = { "$($_.'Source ID');$($_.Source)" } }).tmp) }
		if ($null -ne $DeletedRules)
		{
			Write-Warning -Message "disalbe automation_rules $($DeletedRules.id) in $($DestinationEnvironment)"
			$null = update-XurrentRecord -Environment $DestinationEnvironment -Type automation_rules -ID $DeletedRules.id -Body @{ disabled = 1 }
			
		}
	}
	catch
	{
		$_
		return
	}
	return
}