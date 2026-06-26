function Sync-XurrentWorkflowTemplateAutomationRules
{
<#
.SYNOPSIS
    Synchronises automation rules of workflow templates between two Xurrent environments.

.DESCRIPTION
    Synchronises automation rules and disables rules in the destination environment that
    no longer exist in the source environment (based on source/sourceID comparison).

.PARAMETER SourceEnvironment
    The source connection name. Mandatory.

.PARAMETER DestinationEnvironment
    The destination connection name. Mandatory.

.PARAMETER WorkflowTemplates
    IDs of the workflow templates whose automation rules should be synchronised. Mandatory.

.EXAMPLE
    Sync-XurrentWorkflowTemplateAutomationRules -SourceEnvironment $qa -DestinationEnvironment $prod `
        -WorkflowTemplates 300, 301
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
		[string]$SourceEnvironment,
		[Parameter(Mandatory = $true)]
		[ValidateScript({ $null -ne $script:XurrentAuth.$_ })]
		[ArgumentCompleter({
				param ($cmd,
					$param,
					$wordToComplete)
				$script:XurrentAuth.keys -like "$wordToComplete*"
			})]
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