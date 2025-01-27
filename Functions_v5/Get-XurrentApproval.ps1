function Get-XurrentApproval
{
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[ValidateScript({ $null -ne $script:XurrentAuth.$_ })]
		[string]$Environment,
		[Parameter(Mandatory = $true)]
		[ValidateSet('task_templates','task')]
		[string]$Type,
		[Parameter(Mandatory = $true)]
		[int]$ID
	)
	$data = Invoke-RestMethod -Method get -Uri "$($script:XurrentAuth.$Environment.URL)/$($Type)/$($id)/approvals" -Headers $script:XurrentAuth.$Environment.header
	return $data
}