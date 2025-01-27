<#	
	===========================================================================
	 Created on:   	16.07.2024 08:49
	 Created by:   	roman.enz
	 Organization: 	
	 Filename:     	XurrentAPITools.psm1
	-------------------------------------------------------------------------
	 Module Name: XurrentAPITools
	===========================================================================
#>

[version]$Script:MinimalV7Version = "7.2.0"

foreach ($Item in (Get-ChildItem -Path "$($PSScriptRoot)\Functions_v5"))
{
	Write-Verbose -Message "import $([System.IO.Path]::GetFileNameWithoutExtension($Item.Name))"
	. $Item.FullName
}

if ($PSVersionTable.PSVersion -lt $Script:MinimalV7Version)
{
	Write-Warning -Message "$($Script:MinimalV7Version.ToString()) is required for a full set of function. Limited set imported."
	Write-Warning -Message "set default parameter: '*RestMethod*:ContentType', 'application/json; charset=utf-8'"
	$script:PSDefaultParameterValues.Remove("*RestMethod*:ContentType")
	$script:PSDefaultParameterValues.Add('*RestMethod*:ContentType', 'application/json; charset=utf-8')
}
elseif ($PSVersionTable.PSVersion -ge $Script:MinimalV7Version)
{
	foreach ($Item in (Get-ChildItem -Path "$($PSScriptRoot)\Functions_v7"))
	{
		Write-Verbose -Message "import $([System.IO.Path]::GetFileNameWithoutExtension($Item.Name))"
		. $Item.FullName
	}
}
$script:XurrentAuth = @{ }

$script:InternationalizationPath = "$($PSScriptRoot)\Internationalization"
$script:InternationalizationLocal = Get-ChildItem -Path $script:InternationalizationPath

. "$($PSScriptRoot)\XurrentDataTypes.ps1"

$script:XurrentIDRelations = @{
	request_templates = @{
		RelType = 'workflow_templates'
		RelHead = 'Workflow Template'
	}
	request_template_automation_rules = @{
		RelType = 'request_templates'
		RelHead = 'Request Template'
	}
	task_templates    = @{
		RelType = 'request_templates'
		RelHead = 'Request Template'
	}
	workflow_template_automation_rules = @{
		RelType = 'workflow_templates'
		RelHead = 'Workflow Template'
	}
	shop_articles	  = @{
		RelType = 'request_templates'
		RelHead = 'Fulfillment Template'
	}
}

function Get-XurrentAPITools
{
	[CmdletBinding()]
	param (
	)
	[pscustomobject]::new(@{
			ExportCache				      = $script:ExportCache
			SyncDependency			      = $script:SyncDependency
			SyncSetSource				  = $script:SyncSetSource
			ImportNoUpload			      = $script:ImportNoUpload
			SyncExcludeFields			  = $script:SyncExcludeFields
			DefaultEnvironment		      = $global:PSDefaultParameterValues["*-Xurrent*:Environment"]
			DefaultSourceEnvironment	  = $global:PSDefaultParameterValues["*-Xurrent*:SourceEnvironment"]
			DefaultDestinationEnvironment = $global:PSDefaultParameterValues["*-Xurrent*:DestinationEnvironment"]
		})
}

function Set-XurrentAPITools
{
	[CmdletBinding()]
	param (
		[int]$ExportCache,
		[bool]$SyncDependency,
		[bool]$SyncSetSource,
		[bool]$ImportNoUpload,
		[string[]]$SyncExcludeFields,
		[ValidateScript({ $null -ne $script:XurrentAuth.$_ })]
		[string]$DefaultEnvironment,
		[ValidateScript({ $null -ne $script:XurrentAuth.$_ })]
		[string]$DefaultSourceEnvironment,
		[ValidateScript({ $null -ne $script:XurrentAuth.$_ })]
		[string]$DefaultDestinationEnvironment,
		[switch]$Reset
	)
	if ($Reset)
	{
		Write-Verbose -Message "reset to default"
		$script:ExportCache = 20
		$script:SyncDependency = $true
		$script:SyncSetSource = $true
		$script:ImportNoUpload = $false
		$script:SyncExcludeFields = $null
		$global:PSDefaultParameterValues.Remove("*-Xurrent*:Environment")
		$global:PSDefaultParameterValues.Remove("*-Xurrent*:SourceEnvironment")
		$global:PSDefaultParameterValues.Remove("*-Xurrent*:DestinationEnvironment")
	}
	
	if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey("ExportCache"))
	{
		Write-Verbose -Message "update ExportCache"
		$script:ExportCache = $ExportCache
	}
	if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey("SyncDependency"))
	{
		Write-Verbose -Message "update SyncDependency"
		$script:SyncDependency = $SyncDependency
	}
	if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey("SyncSetSource"))
	{
		Write-Verbose -Message "update SyncSetSource"
		$script:SyncSetSource = $SyncSetSource
	}
	if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey("ImportNoUpload"))
	{
		Write-Verbose -Message "update ImportNoUpload"
		$script:ImportNoUpload = $ImportNoUpload
	}
	if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey("SyncExcludeFields"))
	{
		Write-Verbose -Message "update SyncExcludeFields"
		$script:SyncExcludeFields = $SyncExcludeFields
	}
	if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey("DefaultEnvironment"))
	{
		Write-Verbose -Message "update Environment"
		$global:PSDefaultParameterValues.Remove("*-Xurrent*:Environment")
		$global:PSDefaultParameterValues.Add("*-Xurrent*:Environment", $DefaultEnvironment)
	}
	if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey("DefaultSourceEnvironment"))
	{
		Write-Verbose -Message "update SourceEnvironment"
		$global:PSDefaultParameterValues.Remove("*-Xurrent*:SourceEnvironment")
		$global:PSDefaultParameterValues.Add("*-Xurrent*:SourceEnvironment", $DefaultSourceEnvironment)
	}
	if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey("DefaultDestinationEnvironment"))
	{
		Write-Verbose -Message "update DestinationEnvironment"
		$global:PSDefaultParameterValues.Remove("*-Xurrent*:DestinationEnvironment")
		$global:PSDefaultParameterValues.Add("*-Xurrent*:DestinationEnvironment", $DefaultDestinationEnvironment)
	}
}

Set-XurrentAPITools -Reset

New-Alias -Name Connect-4me -Scope global -Value Connect-Xurrent
New-Alias -Name ConvertFrom-4meCustomFields -Scope global -Value ConvertFrom-XurrentCustomFields
New-Alias -Name Export-4meData -Scope global -Value Export-XurrentData
New-Alias -Name Get-4meData -Scope global -Value Get-XurrentData
New-Alias -Name Get-4meShopReferences -Scope global -Value Get-XurrentShopReferences
New-Alias -Name Import-4meData -Scope global -Value Import-XurrentData
New-Alias -Name New-4meRecord -Scope global -Value New-XurrentRecord
New-Alias -Name Update-4meRecord -Scope global -Value Update-XurrentRecord