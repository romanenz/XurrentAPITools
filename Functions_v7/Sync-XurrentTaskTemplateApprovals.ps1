function Sync-XurrentTaskTemplateApprovals
{
<#
.SYNOPSIS
    Synchronises approvals of task templates between two Xurrent environments.

.PARAMETER SourceEnvironment
    The source connection name. Mandatory.

.PARAMETER DestinationEnvironment
    The destination connection name. Mandatory.

.PARAMETER Tasks
    Names (subject) of the task templates whose approvals should be synchronised. Mandatory.

.EXAMPLE
    Sync-XurrentTaskTemplateApprovals -SourceEnvironment $qa -DestinationEnvironment $prod `
        -Tasks 'Approve change', 'Final review'
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
		[string[]]$Tasks
	)
	try
	{
		$exportpath = Export-XurrentData -Environment $SourceEnvironment -Type task_template_approvals
		$Data = Import-Csv -Path $exportpath -Encoding UTF8 | Where-Object { $_.'Task Template' -in $Tasks }
		if ($null -ne $Data)
		{
			Write-Verbose -Message "Sync approver $($Data.Approver -join ',')"
			Import-XurrentData -Type task_template_approvals -Environment $DestinationEnvironment -InputObject ($Data | Select-Object -Property * -ExcludeProperty id)
		}
		else
		{
			Write-Verbose -Message "no approver assigned"
		}
		
	}
	catch
	{
		$_
		return
	}
	return
}