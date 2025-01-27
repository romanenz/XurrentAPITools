function Sync-XurrentServiceOfferings
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
			
			Write-Verbose -Message "Dependency waiting_for_customer_follow_up: $($Items.waiting_for_customer_follow_up.id -join ",")"
			Sync-XurrentWaitingForCustomerFollowUps -SourceEnvironment $SourceEnvironment -DestinationEnvironment $DestinationEnvironment -ID $Items.waiting_for_customer_follow_up.id
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