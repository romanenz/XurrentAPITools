function Get-XurrentApproval
{
	<#
.SYNOPSIS
    Retrieves the approvals of a task or task template.

.DESCRIPTION
    Returns the list of approvals assigned to a task or task template.
    Corresponds to the API endpoint GET /<type>/<id>/approvals.

.PARAMETER Environment
    The Xurrent connection name. Mandatory.

.PARAMETER Type
    The object type. Valid values: 'task_templates', 'tasks'. Mandatory.

.PARAMETER ID
    The ID of the task or task template. Mandatory.

.OUTPUTS
    The approval objects returned by the API.

.EXAMPLE
    Get-XurrentApproval -Environment $env -Type tasks -ID 9876

    Lists all approvals of the task with ID 9876.

.EXAMPLE
    Get-XurrentApproval -Environment $env -Type task_templates -ID 42
#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[ValidateScript({ $null -ne $script:XurrentAuth.$_ })]
		[string]$Environment,
		[Parameter(Mandatory = $true)]
		[ValidateSet('task_templates','tasks')]
		[string]$Type,
		[Parameter(Mandatory = $true)]
		[int]$ID
	)
	$data = Invoke-RestMethod -Method get -Uri "$($script:XurrentAuth.$Environment.URL)/$($Type)/$($id)/approvals" -Headers $script:XurrentAuth.$Environment.header
	return $data
}