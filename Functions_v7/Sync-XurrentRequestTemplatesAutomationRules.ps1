function Sync-XurrentRequestTemplatesAutomationRules
{
<#
.SYNOPSIS
    Synchronises automation rules of request templates between two Xurrent environments.

.PARAMETER SourceEnvironment
    The source connection name. Mandatory.

.PARAMETER DestinationEnvironment
    The destination connection name. Mandatory.

.PARAMETER Templates
    IDs of the request templates whose automation rules should be synchronised. Mandatory.

.EXAMPLE
    Sync-XurrentRequestTemplatesAutomationRules -SourceEnvironment $qa -DestinationEnvironment $prod `
        -Templates 800, 801
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