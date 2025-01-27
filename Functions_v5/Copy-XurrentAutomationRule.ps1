function Copy-XurrentAutomationRule
{
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[ValidateScript({ $null -ne $script:XurrentAuth.$_ })]
		[string]$Environment,
		[Parameter(Mandatory = $true)]
		[int]$SourceID,
		[Parameter(Mandatory = $true)]
		[int]$DestinationID,
		[bool]$IncludeName = $false
		
	)
	
	$SourceItem = Get-XurrentData -Type automation_rules -Environment $Environment -ID $SourceID
	$body = @{
		expressions = $SourceItem.expressions
		condition   = $SourceItem.condition
		actions	    = $SourceItem.actions
		trigger	    = $SourceItem.trigger
	}
	if ($IncludeName)
	{
		$body.Add("name",$SourceItem.name)
	}
	Update-XurrentRecord -Environment $Environment -Type automation_rules -ID $DestinationID -Body $body
}