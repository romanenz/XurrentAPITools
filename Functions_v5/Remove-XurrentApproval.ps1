function Remove-XurrentApproval
{
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