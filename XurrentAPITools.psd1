<#	
	===========================================================================
	 Created on:   	16.07.2024 08:49
	 Created by:   	roman.enz
	 Organization: 	
	 Filename:     	XurrentAPITools.psd1
	 -------------------------------------------------------------------------
	 Module Manifest
	-------------------------------------------------------------------------
	 Module Name: XurrentAPITools
	===========================================================================
#>


@{
	
	# Script module or binary module file associated with this manifest
	RootModule			   = 'XurrentAPITools.psm1'
	
	# Version number of this module.
	ModuleVersion		   = '0.1.1.0'
	
	# ID used to uniquely identify this module
	GUID				   = 'a4960da8-44ab-464e-ac5c-a092deefe971'
	
	# Author of this module
	Author				   = 'roman.enz'
	
	# Company or vendor of this module
	CompanyName		       = ''
	
	# Copyright statement for this module
	Copyright			   = '(c) 2024. All rights reserved.'
	
	# Description of the functionality provided by this module
	Description		       = 'Module description'
	
	# Supported PSEditions
	# CompatiblePSEditions = @('Core', 'Desktop')
	
	# Minimum version of the Windows PowerShell engine required by this module
	PowerShellVersion	   = '5.1'
	
	# Name of the Windows PowerShell host required by this module
	PowerShellHostName	   = ''
	
	# Minimum version of the Windows PowerShell host required by this module
	PowerShellHostVersion  = ''
	
	# Minimum version of the .NET Framework required by this module
	DotNetFrameworkVersion = '4.5.2'
	
	# Minimum version of the common language runtime (CLR) required by this module
	# CLRVersion = ''
	
	# Processor architecture (None, X86, Amd64, IA64) required by this module
	ProcessorArchitecture  = 'None'
	
	# Modules that must be imported into the global environment prior to importing
	# this module
	RequiredModules	       = @()
	
	# Assemblies that must be loaded prior to importing this module
	RequiredAssemblies	   = @()
	
	# Script files (.ps1) that are run in the caller's environment prior to
	# importing this module
	ScriptsToProcess	   = @()
	
	# Type files (.ps1xml) to be loaded when importing this module
	TypesToProcess		   = @()
	
	# Format files (.ps1xml) to be loaded when importing this module
	FormatsToProcess	   = @()
	
	# Modules to import as nested modules of the module specified in
	# ModuleToProcess
	NestedModules		   = @()
	
	# Functions to export from this module
	FunctionsToExport	   = @(
		'Clear-XurrentExportCache',
		'Connect-Xurrent',
		'ConvertFrom-XurrentCustomFields',
		'ConvertFrom-XurrentWebHookPayload',
		'Copy-XurrentAutomationRule',
		'Copy-XurrentCustomFields',
		'Export-XurrentConnection',
		'Export-XurrentData',
		'Get-XurrentAiClassifierHits',
		'Get-XurrentApiTools',
		'Get-XurrentApproval',
		'Get-XurrentData',
		'Get-XurrentEnvironments',
		'Get-XurrentRateLimit',
		'Get-XurrentShopReferences',
		'Get-XurrentWorkflowTasks',
		'Import-XurrentConnection',
		'Import-XurrentData',
		'New-XurrentRecord',
		'Resolve-XurrentRelation',
		'Set-XurrentAPITools',
		'Set-XurrentSource',
		'Sync-XurrentCalendars',
		'Sync-XurrentCustomCollectionElements',
		'Sync-XurrentCustomCollections',
		'Sync-XurrentCustomViews',
		'Sync-XurrentFirstLineSupportAgreements',
		'Sync-XurrentObject',
		'Sync-XurrentProjectCategories',
		'Sync-XurrentRequestTemplates',
		'Sync-XurrentRequestTemplatesAutomationRules',
		'Sync-XurrentServiceInstances',
		'Sync-XurrentServiceOfferings',
		'Sync-XurrentServices',
		'Sync-XurrentShopArtikleCategories',
		'Sync-XurrentShopArtikles',
		'Sync-XurrentSLACoverageGroups',
		'Sync-XurrentSLANotificationSchemes',
		'Sync-XurrentTaskTemplateApprovals',
		'Sync-XurrentTaskTemplateAutomationRules',
		'Sync-XurrentTaskTemplates',
		'Sync-XurrentTeams',
		'Sync-XurrentUIExtensions',
		'Sync-XurrentWaitingForCustomerFollowUps',
		'Sync-XurrentWorkflowTemplateAutomationRules',
		'Sync-XurrentWorkflowTemplates',
		'Update-XurrentInternationalization',
		'Update-XurrentRecord'
	)
	
	# Cmdlets to export from this module
	CmdletsToExport	       = '*'
	
	# Variables to export from this module
	VariablesToExport	   = '*'
	
	# Aliases to export from this module
	AliasesToExport	       = '*' #For performance, list alias explicitly
	
	# DSC class resources to export from this module.
	#DSCResourcesToExport = ''
	
	# List of all modules packaged with this module
	ModuleList			   = @()
	
	# List of all files packaged with this module
	FileList			   = @('Internationalization/en.json')
	
	# Private data to pass to the module specified in ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
	PrivateData		       = @{
		
		#Support for PowerShellGet galleries.
		PSData = @{
			
			# Tags applied to this module. These help with module discovery in online galleries.
			Tags = @('xurrent','api')
			
			# A URL to the license for this module.
			LicenseUri = 'https://raw.githubusercontent.com/romanenz/XurrentAPITools/refs/heads/main/LICENSE'
			
			# A URL to the main website for this project.
			ProjectUri = 'https://github.com/romanenz/XurrentAPITools'
			
			# A URL to an icon representing this module.
			# IconUri = ''
			
			# ReleaseNotes of this module
			# ReleaseNotes = ''
			
		} # End of PSData hashtable
		
	} # End of PrivateData hashtable
}








