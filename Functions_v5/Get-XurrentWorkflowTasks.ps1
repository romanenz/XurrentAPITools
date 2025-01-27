function Get-XurrentWorkflowTasks
{
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[ValidateScript({ $null -ne $script:XurrentAuth.$_ })]
		[string]$Environment,
		[Parameter(Mandatory = $true)]
		[ValidateSet('workflow_templates', 'workflows')]
		[string]$Type,
		[Parameter(Mandatory = $true)]
		[int]$ID
	)
	switch ($Type) {
		'workflow_templates' {
			$rel = 'task_templates'
		}
		'workflows' {
			$rel = 'tasks'
		}
	}
	$data = Get-XurrentData -Environment $Environment -Type $Type -ID $ID -SubType $rel 
	
	return $data
}