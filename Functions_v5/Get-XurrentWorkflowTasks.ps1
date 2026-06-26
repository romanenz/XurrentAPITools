function Get-XurrentWorkflowTasks
{
<#
.SYNOPSIS
    Returns the tasks or task templates of a workflow or workflow template.

.DESCRIPTION
    Retrieves the associated tasks (for type 'workflows') or task templates (for type
    'workflow_templates') of a specific workflow. Uses Get-XurrentData internally
    with the corresponding SubType.

.PARAMETER Environment
    The Xurrent connection name. Mandatory.

.PARAMETER Type
    'workflows' or 'workflow_templates'. Mandatory.

.PARAMETER ID
    The ID of the workflow or workflow template. Mandatory.

.OUTPUTS
    Array of task or task template objects.

.EXAMPLE
    Get-XurrentWorkflowTasks -Environment $env -Type workflow_templates -ID 300

    Returns all task templates of workflow template 300.

.EXAMPLE
    Get-XurrentWorkflowTasks -Environment $env -Type workflows -ID 88000

    Returns all tasks of workflow 88000.
#>
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