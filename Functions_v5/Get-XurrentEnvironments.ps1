function Get-XurrentEnvironments
{
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