function Sync-XurrentObject
{
<#
.SYNOPSIS
    Synchronises objects of a specific type from one Xurrent environment to another.

.DESCRIPTION
    The core function of the synchronisation process. Performs the following steps:
    1. Exports data from the source environment.
    2. Validates and sets missing source/sourceID anchors (if SetSource = $true).
    3. Adjusts referenced IDs (e.g. workflow template reference in automation rules).
    4. Imports the adjusted data into the destination environment via Import-XurrentData.

    Fields can be excluded from synchronisation via -ExcludeFields.
    The ID of the source record is always excluded, as Xurrent determines the destination ID
    via source/sourceID during import.

.PARAMETER SourceEnvironment
    The source connection name. Mandatory.

.PARAMETER DestinationEnvironment
    The destination connection name. Mandatory.

.PARAMETER Type
    The data type (XurrentDataTypes enum). Mandatory.

.PARAMETER ID
    IDs of the source objects to synchronise. Mandatory.

.PARAMETER ExcludeFields
    Optional list of CSV column names to exclude during import.

.PARAMETER SetSource
    Automatically sets source/sourceID for objects where it is missing.
    Default: $script:SyncSetSource (configurable via Set-XurrentAPITools).

.EXAMPLE
    Sync-XurrentObject -Type services -SourceEnvironment $qa -DestinationEnvironment $prod -ID 101, 102

.EXAMPLE
    Sync-XurrentObject -Type teams -SourceEnvironment $qa -DestinationEnvironment $prod `
        -ID 50 -ExcludeFields 'Manager', 'Coordinator'
#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[ValidateScript({ $null -ne $script:XurrentAuth.$_ })]
		[ArgumentCompleter({
				param ($cmd,
					$param,
					$wordToComplete)
				$script:XurrentAuth.keys -like "$wordToComplete*"
			})]
		[string]$SourceEnvironment,
		[Parameter(Mandatory = $true)]
		[ValidateScript({ $null -ne $script:XurrentAuth.$_ })]
		[ArgumentCompleter({
				param ($cmd,
					$param,
					$wordToComplete)
				$script:XurrentAuth.keys -like "$wordToComplete*"
			})]
		[string]$DestinationEnvironment,
		[Parameter(Mandatory)]
		[XurrentDataTypes]$Type,
		[Parameter(Mandatory = $true)]
		[int[]]$ID,
		[Parameter(Mandatory = $false)]
		[string[]]$ExcludeFields,
		[Parameter(Mandatory = $false)]
		[bool]$SetSource = $script:SyncSetSource
	)
	try
	{
		Write-Verbose -Message "sync $($Type): $($ID -join ',')"
		
		# get data
		$Data = Import-Csv -Path (Export-XurrentData -Type $Type -Environment $SourceEnvironment) -Encoding UTF8 | Where-Object { $_.id -in $ID }
		#region validate source anchor
		$MissingSource = $Data | Where-Object { [string]::IsNullOrEmpty($_.source) -or [string]::IsNullOrEmpty($_.'Source ID') }
		Write-Verbose -Message "source not set for $($MissingSource.count) items"
		if ($SetSource -eq $true -and $MissingSource.count -ge 1)
		{
			foreach ($item in $MissingSource)
			{
				Write-Verbose -Message "update source of $($item.id)"
				$item.'Source ID' = [guid]::NewGuid()
				$item.source = 'XurrentAPITools'
				if ($Type -match 'automation_rules$')
				{
					$tmpsource = Set-XurrentSource -Environment $SourceEnvironment -Type automation_rules -ID $item.id		
				}
				else
				{
					$tmpsource = Set-XurrentSource -Environment $SourceEnvironment -Type $Type -ID $item.id
				}
				$item.'Source ID' = $tmpsource.SourceID
				$item.source = $tmpsource.Source
				Start-Sleep -Milliseconds 500
			}
		}
		elseif ($MissingSource.count -ge 1)
		{
			throw "missing source anchor for $($MissingSource.id -join ',')"
		}
		#endregion 
		#region adapt data
		if ($null -ne $script:XurrentIDRelations.$Type)
		{
			$DestinationRelID = Get-XurrentData -Environment $DestinationEnvironment -Type $script:XurrentIDRelations.$Type.RelType -Parameter "fields=id, source, sourceID"
			$SourceRelID = Get-XurrentData -Environment $SourceEnvironment -Type $script:XurrentIDRelations.$Type.RelType -Parameter "fields=id, source, sourceID"
			Write-Verbose -Message "adapt relation for $($script:XurrentIDRelations.$Type.RelType)"
			foreach ($item in $data)
			{
				if (-not [string]::IsNullOrEmpty($item.$($script:XurrentIDRelations.$Type.RelHead)))
				{
					$oldItem = $SourceRelID | Where-Object {$_.id -eq $item.$($script:XurrentIDRelations.$Type.RelHead)}
					$item.$($script:XurrentIDRelations.$Type.RelHead) = ($DestinationRelID | Where-Object { $_.source -eq $oldItem.source -and $_.sourceID -eq $oldItem.sourceID }).id
					Write-Verbose -Message "change id from $($oldItem.id) to $($item.$($script:XurrentIDRelations.$Type.RelHead))"
				}
			}
		}
		#endregion
		
		# import
		Write-Verbose -Message "import....."
		if ($Type -match 'automation_rules$')
		{
			$Data = $Data | Sort-Object Trigger
		}
		if ($null -ne $script:SyncExcludeFields)
		{
			$ExcludeFields += $script:SyncExcludeFields
		}
		Write-Verbose -Message "ExcludeFields $($ExcludeFields.count): $($ExcludeFields -join ',')"
		$ExcludeFields += 'id'
		Write-Debug -Message "ExcludeFields $($ExcludeFields.count): $($ExcludeFields -join ',')"
		Import-XurrentData -Type $Type -Environment $DestinationEnvironment -InputObject ($Data | Select-Object -Property * -ExcludeProperty $ExcludeFields)
	}
	catch
	{
		$_
	}
	return
	
}