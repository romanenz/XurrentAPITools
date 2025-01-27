function Sync-XurrentWorkflowTemplates
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
		[int[]]$ID
	)
	$Items = Get-XurrentData -Type workflow_templates -Environment $SourceEnvironment -ID $ID
	
	foreach ($Item in $Items)
	{
		try
		{
			
			if ($script:SyncDependency -eq $true)
			{
				if ($null -ne $item.ui_extension.id)
				{
					Write-Verbose -Message "Dependency ui_extensions: $($item.ui_extension.id -join ",")"
					Sync-XurrentUIExtensions -SourceEnvironment $SourceEnvironment -DestinationEnvironment $DestinationEnvironment -ID $item.ui_extension.id
				}
				$TaskTemplates = Get-XurrentWorkflowTasks -Environment $sourceenvironment -Type workflow_templates -ID $Items.id
				Sync-XurrentTaskTemplates -SourceEnvironment $SourceEnvironment -DestinationEnvironment $DestinationEnvironment -ID $TaskTemplates.id
				
				
			}
			# sync objects
			Sync-XurrentObject -Type workflow_templates -SourceEnvironment $SourceEnvironment -DestinationEnvironment $DestinationEnvironment -ID $Item.id
			if ($script:SyncDependency -eq $true)
			{
				Sync-XurrentWorkflowTemplateAutomationRules -SourceEnvironment $SourceEnvironment -DestinationEnvironment $DestinationEnvironment -WorkflowTemplates $Item.id
				$RequestTemplates = Get-XurrentData -Type request_templates -Environment $SourceEnvironment -Parameter "workflow_template=$($Items.id)"
				if ($null -ne $RequestTemplates)
				{
					Sync-XurrentRequestTemplates -SourceEnvironment $SourceEnvironment -DestinationEnvironment $DestinationEnvironment -ID $RequestTemplates.id
				}
			}
		}
		catch
		{
			$_
		}
	}
	return
}