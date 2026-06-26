function Get-XurrentAiClassifierHits
{
<#
.SYNOPSIS
    Retrieves requests and analyses which ones had their category, impact or
    service instance changed by the Xurrent AI classifier.

.DESCRIPTION
    Reads requests from a Xurrent environment (by creation date or from a given ID)
    and evaluates their AI classification notes. For each request where the AI classifier
    left a note, the function compares whether the suggested category, impact or service
    instance differs from the actual assignment.

    The result is a list of objects containing original and AI-suggested values, as well
    as boolean flags indicating whether the classifier made a change.

.PARAMETER Environment
    The Xurrent connection name. Mandatory.

.PARAMETER CreatedFrom
    Lower date boundary for the request creation timestamp.
    Mandatory in parameter set 'date'.

.PARAMETER CreatedTo
    Upper date boundary (optional). If not specified, defaults to now.
    Optional in parameter set 'date'.

.PARAMETER ID
    Minimum request ID for the query (all requests with ID greater than this value).
    Mandatory in parameter set 'id'.

.OUTPUTS
    System.Collections.ArrayList – List of objects with the following properties:
    Id, Subject, CategoryChanged, ImpactChanged, Service_InstanceChanged,
    CategoryByAI, Category, ImpactByAI, Impact, Service_InstanceByAI, Service_Instance.

.EXAMPLE
    Get-XurrentAiClassifierHits -Environment $env -CreatedFrom (Get-Date).AddDays(-7)

    Analyses all relevant requests from the last 7 days.

.EXAMPLE
    Get-XurrentAiClassifierHits -Environment $env -ID 100000

    Analyses all requests with an ID greater than 100000.

.NOTES
    Only requests with categories other than 'order' and 'fulfillment' are considered.
    Requires internationalization files to be configured in the module directory.
#>
	[CmdletBinding(DefaultParameterSetName = 'date')]
	param (
		[Parameter(Mandatory = $true, ParameterSetName = 'date')]
		[Parameter(Mandatory = $true, ParameterSetName = 'id')]
		[ValidateScript({ $null -ne $script:XurrentAuth.$_ })]
		[string]$Environment,
		[Parameter(Mandatory = $true, ParameterSetName = 'date')]
		[DateTime]$CreatedFrom,
		[Parameter(Mandatory = $false, ParameterSetName = 'date')]
		[DateTime]$CreatedTo,
		[Parameter(Mandatory = $true, ParameterSetName = 'id')]
		[int]$ID
	)
	
	
	class Item {
		[int]$Id
		[string]$Subject
		[bool]$CategoryChanged
		[bool]$ImpactChanged
		[bool]$Service_InstanceChanged
		[string]$CategoryByAI
		[string]$Category
		[string]$ImpactByAI
		[string]$Impact
		[string]$Service_InstanceByAI
		[string]$Service_Instance
	}
	
	try
	{
		[System.Collections.ArrayList]$Data = @()
		
		[System.Collections.ArrayList]$InternationalizationCategory = @()
		[System.Collections.ArrayList]$InternationalizationImpact = @()
		ForEach ($IntEnum in $script:InternationalizationLocal)
		{
			$tmp = Get-Content $IntEnum.FullName | ConvertFrom-Json | Select-Object 'request.category', 'request.impact'
			$InternationalizationCategory += $tmp.'request.category'
			$InternationalizationImpact += $tmp.'request.impact'
		}
		
		if ($PSCmdlet.ParameterSetName -eq 'date')
		{
			if ($null -ne $CreatedTo)
			{
				$CreatedTo = Get-Date
				$collection = get-xurrentData -Type requests -Environment $Environment -Parameter "category=!order,fulfillment&created_at=>$($CreatedFrom.ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ'))&created_at=<$($CreatedTo.ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ'))"
			}
			else
			{
				$collection = get-xurrentData -Type requests -Environment $Environment -Parameter "category=!order,fulfillment&created_at=>$($CreatedFrom.ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ'))"
			}
		}
		elseif ($PSCmdlet.ParameterSetName -eq 'id')
		{
			$collection = get-xurrentData -Type requests -Environment $Environment -Parameter "category=!order,fulfillment&id=>$($ID)"
		}
		foreach ($id in $collection.id)
		{
			Write-Verbose "parse request $($id)"
			$request = get-xurrentData -Type requests -Environment $Environment -ID $id
			$Notes = get-xurrentData -Type requests -Environment $Environment -ID $request.id -SubType notes -Parameter 'medium=ai'
			if ($null -ne $Notes)
			{
				$Note = ($Notes | Where-Object { $_.text -match 'AI Classifier' }) | Select-Object -First 1
				Write-Verbose "parse note $($Note.id)"
				$Assignments = $Note.text -split "`n" | Where-Object { $_ -match ':[^$]' }
				$CategoryLine = $Assignments | Where-Object { $_.split(':')[1].trim() -in $InternationalizationCategory.txt }
				$ImpactLine = $Assignments | Where-Object { $_.split(':')[1].trim() -in $InternationalizationImpact.txt }
				if ($ImpactLine -eq $null)
				{
					$Service_InstanceLine = $Assignments | Where-Object { $_ -ne $CategoryLine }
					$Impact = $null
				}
				else
				{
					$Impact = ($InternationalizationImpact | Where-Object { $_.txt -eq $ImpactLine.Split(':')[1].Trim() } | Select-Object -First 1).id
					$Service_InstanceLine = $Assignments | Where-Object { $_ -ne $CategoryLine -and $_ -ne $ImpactLine }
				}
				
				$Category = ($InternationalizationCategory | Where-Object { $_.txt -eq $CategoryLine.Split(':')[1].Trim() } | Select-Object -First 1).id
				$Service = $Service_InstanceLine.Split(':')[1].trim()
				
				Write-Verbose "add entry"
				$item = [item]::new()
				$item.id = $request.id
				$item.Subject = $request.subject
				$item.CategoryChanged = $request.category -ne $Category
				$item.ImpactChanged = $request.Impact -ne $Impact
				$item.Service_InstanceChanged = $request.service_instance.name -ne $Service
				$item.CategoryByAI = $Category
				$item.Category = $request.category
				$item.ImpactByAI = $Impact
				$item.Impact = $request.Impact
				$item.Service_InstanceByAI = $Service
				$item.Service_Instance = $request.service_instance.name
				$Data.Add($item) | Out-Null
			}
		}
		return $Data
	}
	catch
	{
		Write-Error $_
	}
}