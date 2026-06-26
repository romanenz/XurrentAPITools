function Sync-XurrentTaskTemplates
{
<#
.SYNOPSIS
    Synchronises task templates (including dependencies) between two Xurrent environments.

.DESCRIPTION
    Synchronises task templates. When SyncDependency is enabled, also automatically
    synchronises UI extensions, request templates, approvals (for approval tasks) and
    automation rules.

.PARAMETER SourceEnvironment
    The source connection name. Mandatory.

.PARAMETER DestinationEnvironment
    The destination connection name. Mandatory.

.PARAMETER ID
    IDs of the task templates to synchronise. Mandatory.

.EXAMPLE
    Sync-XurrentTaskTemplates -SourceEnvironment $qa -DestinationEnvironment $prod -ID 1100, 1101
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
		[int[]]$ID
	)
	try
	{
		$Items = Get-XurrentData -Type task_templates -Environment $SourceEnvironment -ID $ID
		
		if ($script:SyncDependency -eq $true)
		{
			if ($null -ne $items.ui_extension.id)
			{
				Write-Verbose -Message "Dependency ui_extensions: $($items.ui_extension.id -join ",")"
				Sync-XurrentUIExtensions -SourceEnvironment $SourceEnvironment -DestinationEnvironment $DestinationEnvironment -ID $items.ui_extension.id
			}
			if ($null -ne $items.request_template.id)
			{
				Write-Verbose -Message "Dependency request_template: $($items.request_template.id -join ",")"
				Sync-XurrentRequestTemplates -SourceEnvironment $SourceEnvironment -DestinationEnvironment $DestinationEnvironment -ID $items.request_template.id
			}
		}
		
		# sync objects
		Sync-XurrentObject -Type task_templates -SourceEnvironment $SourceEnvironment -DestinationEnvironment $DestinationEnvironment -ID $Items.id
		if ($script:SyncDependency -eq $true)
		{
			if ($null -ne ($Items | Where-Object { $_.category -eq 'approval' }))
			{
				Write-Verbose -Message "Dependency task_template_approvals: $(($Items | Where-Object { $_.category -eq 'approval' }).subject -join ",")"
				Sync-XurrentTaskTemplateApprovals -SourceEnvironment $SourceEnvironment -DestinationEnvironment $DestinationEnvironment -Tasks ($Items | Where-Object { $_.category -eq 'approval' }).subject
			}
			Sync-XurrentTaskTemplateAutomationRules -SourceEnvironment $SourceEnvironment -DestinationEnvironment $DestinationEnvironment -Tasks $Items.Subject
		}
	}
	catch
	{
		$_
		return
	}
	return
}

function Get-Approvals
{
	param ()
	$approvalsPath = Export-4meData -URI $SourceURI -Header $SourceHeader -Type task_template_approvals
	return Import-Csv -Path $approvalsPath -Encoding UTF8 | Where-Object { $_.'Task Template' -in $Used_Tasks.subject }
}