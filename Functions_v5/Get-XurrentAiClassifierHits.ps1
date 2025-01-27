function Get-XurrentAiClassifierHits
{
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