function Remove-XurrentApproval
{
<#
.SYNOPSIS
    Removes an approval from a task or task template.

.DESCRIPTION
    Sends an HTTP DELETE request to the endpoint /<type>/<id>/approvals/<approvalId>,
    removing a specific approval assignment from a task or task template.

.PARAMETER Environment
    The Xurrent connection name. Mandatory.

.PARAMETER Type
    The object type. Valid values: 'task_templates', 'tasks'. Mandatory.

.PARAMETER ObjectID
    The ID of the task or task template. Mandatory.

.PARAMETER ApprovalID
    The ID of the approval to be deleted. Mandatory.

.OUTPUTS
    The API response of the DELETE call.

.EXAMPLE
    Remove-XurrentApproval -Environment $env -Type tasks -ObjectID 9876 -ApprovalID 11

    Removes approval 11 from task 9876.
#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[ValidateScript({ $null -ne $script:XurrentAuth.$_ })]
		[string]$Environment,
		[Parameter(Mandatory = $true)]
		[ValidateSet('task_templates', 'tasks')]
		[string]$Type,
		[Parameter(Mandatory = $true)]
		[int]$ObjectID,
		[Parameter(Mandatory = $true)]
		[int]$ApprovalID
	)
	$data = Invoke-RestMethod -Method Delete -Uri "$($script:XurrentAuth.$Environment.URL)/$($Type)/$($id)/approvals/$($ApprovalID)" -Headers $script:XurrentAuth.$Environment.header
	return $data
}