function Sync-XurrentTaskTemplateApprovals
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