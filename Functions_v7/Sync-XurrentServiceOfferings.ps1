function Sync-XurrentServiceOfferings
{
<#
.SYNOPSIS
    Synchronises service offerings (including dependencies) between two Xurrent environments.

.DESCRIPTION
    Synchronises service offerings. When SyncDependency is enabled, also automatically
    synchronises calendars (service_hours, support_hours_*), services and optionally
    WaitingForCustomerFollowUps.

.PARAMETER SourceEnvironment
    The source connection name. Mandatory.

.PARAMETER DestinationEnvironment
    The destination connection name. Mandatory.

.PARAMETER ID
    IDs of the service offerings to synchronise. Mandatory.

.EXAMPLE
    Sync-XurrentServiceOfferings -SourceEnvironment $qa -DestinationEnvironment $prod -ID 600, 601
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
		$Items = Get-XurrentData -Type service_offerings -Environment $SourceEnvironment -ID $ID
		if ($script:SyncDependency -eq $true)
		{
			[int[]]$service_hours = @()
			foreach ($type in @('service_hours', 'support_hours_case', 'support_hours_high', 'support_hours_low', 'support_hours_medium', 'support_hours_rfc', 'support_hours_rfi', 'support_hours_top'))
			{
				$service_hours += $Items.$type.id
			}
			Write-Verbose -Message "Dependency support_hours: $(@($service_hours | Where-Object { $_ -ne 0 } | Select-Object -Unique) -join ",")"
			Sync-XurrentCalendars -SourceEnvironment $SourceEnvironment -DestinationEnvironment $DestinationEnvironment -ID @($service_hours | Where-Object { $_ -ne 0 } | Select-Object -Unique)
			
			Write-Verbose -Message "Dependency services: $($Items.service.id -join ",")"
			Sync-XurrentServices -SourceEnvironment $SourceEnvironment -DestinationEnvironment $DestinationEnvironment -ID $Items.service.id
			
			if ($Items.waiting_for_customer_follow_up.id)
			{
				Write-Verbose -Message "Dependency waiting_for_customer_follow_up: $($Items.waiting_for_customer_follow_up.id -join ",")"
				Sync-XurrentWaitingForCustomerFollowUps -SourceEnvironment $SourceEnvironment -DestinationEnvironment $DestinationEnvironment -ID $Items.waiting_for_customer_follow_up.id				
			}
		}
		# sync objects
		Sync-XurrentObject -Type service_offerings -SourceEnvironment $SourceEnvironment -DestinationEnvironment $DestinationEnvironment -ID $Items.id
	}
	catch
	{
		$_
		return
	}
	return
}