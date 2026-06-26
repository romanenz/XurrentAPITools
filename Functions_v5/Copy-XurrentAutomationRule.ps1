function Copy-XurrentAutomationRule
{
<#
.SYNOPSIS
    Copies the content of one automation rule onto another automation rule.

.DESCRIPTION
    Reads the configuration of a source automation rule (expressions, condition,
    actions, trigger) and overwrites an existing destination automation rule in the
    same environment. Optionally the name of the source rule can also be transferred.

    Useful for replicating automation rules between objects without having to
    recreate them from scratch.

.PARAMETER Environment
    The Xurrent connection name as returned by Connect-Xurrent.
    Mandatory; must match an active connection.

.PARAMETER SourceID
    The ID of the automation rule whose configuration is read. Mandatory.

.PARAMETER DestinationID
    The ID of the automation rule to be overwritten. Mandatory.

.PARAMETER IncludeName
    When $true, the name of the source rule is also transferred to the destination rule.
    Default: $false.

.EXAMPLE
    Copy-XurrentAutomationRule -Environment $env -SourceID 1001 -DestinationID 2001

    Copies expressions, condition, actions and trigger from rule 1001 to rule 2001.

.EXAMPLE
    Copy-XurrentAutomationRule -Environment $env -SourceID 1001 -DestinationID 2001 -IncludeName $true

    Additionally copies the name of the rule.
#>
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