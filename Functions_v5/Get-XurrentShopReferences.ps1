function Get-XurrentShopReferences
{
<#
.SYNOPSIS
    Resolves all linked objects of a shop order (tasks, workflows, requests,
    shop order lines, fulfillment tasks).

.DESCRIPTION
    Traverses the reference network of a shop order process starting from a known
    object type and its ID. Returns an object containing the IDs of all related
    objects: tasks, fulfillment workflow, fulfillment request, order workflow,
    order request, shop order lines and fulfillment tasks.

    Useful for resolving all associated requests and workflows from a task ID.

.PARAMETER Environment
    The Xurrent connection name. Mandatory.

.PARAMETER ID
    The ID of the known starting object. Mandatory.

.PARAMETER Type
    The type of the starting object. Valid values:
    tasks, fulfillmentRequest, fulfillmentWorkflow, orderWorkflow, orderRequest,
    shopOrderLines, fulfillmentTask. Mandatory.

.OUTPUTS
    PSCustomObject with the properties: tasks, fulfillmentWorkflow, fulfillmentRequest,
    orderWorkflow, orderRequest, shopOrderLines, fulfillmentTask.

.EXAMPLE
    Get-XurrentShopReferences -Environment $env -Type tasks -ID 55001

    Resolves all linked shop objects starting from task 55001.

.NOTES
    Alias: Get-4meShopReferences
#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[ValidateScript({ $null -ne $script:XurrentAuth.$_ })]
		[string]$Environment,
		[Parameter(Mandatory = $true)]
		[int]$ID,
		[Parameter(Mandatory = $true)]
		[ValidateSet('tasks', 'fulfillmentRequest', 'fulfillmentWorkflow', 'orderWorkflow', 'orderRequest', 'shopOrderLines', 'fulfillmentTask')]
		[string]$Type
	)
	$References = [PSCustomObject]@{
		tasks			    = 'notResolved'
		fulfillmentWorkflow = 'notResolved'
		fulfillmentRequest  = 'notResolved'
		orderWorkflow	    = 'notResolved'
		orderRequest	    = 'notResolved'
		shopOrderLines	    = 'notResolved'
		fulfillmentTask	    = 'notResolved'
	}
	$References.$Type = $id
	
	if ($Type -ne 'tasks')
	{
		$References.tasks = $null
	}
	$i = 0
	while ($References.psobject.Members.Where({ $_.MemberType -eq 'NoteProperty' }).where({ $_.value -eq 'notResolved' }).name.count -ne 0 -and $i -lt 4)
	{
		if ($References.tasks -ne 'notResolved' -and $null -ne $References.tasks)
		{
			$Task = Get-XurrentData -Environment $Environment -Type "tasks" -ID $References.tasks
			$References.fulfillmentWorkflow = $Task.workflow.id
		}
		if ($References.fulfillmentWorkflow -ne 'notResolved' -and $null -ne $References.fulfillmentWorkflow)
		{
			$workflow = Get-XurrentData -Environment $Environment -Type "workflows" -ID ($References.fulfillmentWorkflow -join ',')
			$References.fulfillmentRequest = (Get-XurrentData -Environment $Environment -Type "requests" -Parameter "workflow=$($workflow.id)&category=fulfillment" | Select-Object -First 1).id
		}
		if ($References.fulfillmentRequest -ne 'notResolved' -and $null -ne $References.fulfillmentRequest)
		{
			$Requests = Get-XurrentData -Environment $Environment -Type "requests" -ID $References.fulfillmentRequest | Where-Object { $_.category -eq 'fulfillment' }
			$References.shopOrderLines = (
				Get-XurrentData -Environment $Environment -Type "shop_order_lines" -Parameter "status=fulfillment_pending&fields=id,fulfillment_request" |
				Where-Object {
					$_.fulfillment_request.id -eq $Requests.id
				}
			).id
			$References.fulfillmentWorkflow = $Requests.workflow.id
		}
		if ($References.shopOrderLines -ne 'notResolved' -and $null -ne $References.shopOrderLines)
		{
			$ShopOrderLine = Get-XurrentData -Environment $Environment -Type "shop_order_lines" -ID ($References.shopOrderLines -join ',')
			$References.fulfillmentRequest = $ShopOrderLine.fulfillment_request.id
			$References.fulfillmentTask = $ShopOrderLine.fulfillment_task.id
		}
		if ($References.fulfillmentTask -ne 'notResolved' -and $null -ne $References.fulfillmentTask)
		{
			$Task = Get-XurrentData -Environment $Environment -Type "tasks" -ID ($References.fulfillmentTask -join ',')
			$References.orderWorkflow = $Task.workflow.id
			$References.fulfillmentRequest = $Task.request.id
			$References.shopOrderLines = (
				Get-XurrentData -Environment $Environment -Type "shop_order_lines" -Parameter "status=fulfillment_pending&fields=id,fulfillment_task" |
				Where-Object {
					$_.fulfillment_task.id -eq $References.fulfillmentTask
				}
			).id
		}
		if ($References.orderWorkflow -ne 'notResolved' -and $null -ne $References.orderWorkflow)
		{
			$workflow = Get-XurrentData -Environment $Environment -Type "workflows" -ID $References.orderWorkflow
			$References.orderRequest = (Get-XurrentData -Environment $Environment -Type "requests" -Parameter "workflow=$($workflow.id)").id
			$References.fulfillmentTask = (Get-XurrentData -Environment $Environment -Type "tasks" -Parameter "workflow=$($workflow.id)&category=implementation" -full | Where-Object { $_.request -ne $null }).id
		}
		if ($References.orderRequest -ne 'notResolved' -and $null -ne $References.orderRequest)
		{
			$Requests = Get-XurrentData -Environment $Environment -Type "requests" -ID $References.orderRequest
			$References.orderWorkflow = $Requests.workflow.id
		}
		$i++
	}
	
	
	return $References
}
