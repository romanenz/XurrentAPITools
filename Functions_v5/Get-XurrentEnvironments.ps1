function Get-XurrentEnvironments
{
<#
.SYNOPSIS
    Returns the active Xurrent connections.

.DESCRIPTION
    Lists all connections that were established with Connect-Xurrent and are stored
    in the module scope ($script:XurrentAuth). Can optionally be filtered by a
    search pattern.

.PARAMETER Search
    Optional search term (regular expression). Only entries matching this term are
    returned. Useful for finding connections for a specific account or environment.

.OUTPUTS
    Hashtable or filtered enumeration of connection entries.

.EXAMPLE
    Get-XurrentEnvironments

    Shows all active connections.

.EXAMPLE
    Get-XurrentEnvironments -Search 'wdc_Production'

    Filters connections whose name contains 'wdc_Production'.
#>
	[CmdletBinding()]
	param (		
		[Parameter(Mandatory = $false)]
		[string]$Search
	)
	if (-not [string]::IsNullOrEmpty($Search))
	{
		Write-Debug -Message "find by name"
		return $script:XurrentAuth.GetEnumerator() | Where-Object { $_.Key -match  $Search}
	}
	else
	{
		return $script:XurrentAuth
	}	
}