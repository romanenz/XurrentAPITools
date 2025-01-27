function Set-XurrentSource
{
	[CmdletBinding(DefaultParameterSetName = 'source')]
	param (
		[Parameter(Mandatory = $true, ParameterSetName = 'source')]
		[Parameter(Mandatory = $true, ParameterSetName = 'dest')]
		[ValidateScript({ $null -ne $script:XurrentAuth.$_ })]
		[string]$Environment,
		[Parameter(Mandatory = $true, ParameterSetName = 'source')]
		[Parameter(Mandatory = $true, ParameterSetName = 'dest')]
		[ValidateScript({ $_ -in $script:XurrentDataTypes })]
		[string]$Type,
		[Parameter(Mandatory = $true, ParameterSetName = 'source')]
		[Parameter(Mandatory = $true, ParameterSetName = 'dest')]
		[int]$ID,
		[Parameter(Mandatory = $true, ParameterSetName = 'dest')]
		[int]$DestinationID,
		[Parameter(Mandatory = $true, ParameterSetName = 'dest')]
		[ValidateScript({ $null -ne $script:XurrentAuth.$_ })]
		[string]$DestinationEnvironment
		
	)
	$guid = [guid]::NewGuid()
	Write-Verbose -Message "update source of $($ID) to $($guid)"
	try
	{
		Update-XurrentRecord -Environment $Environment -Type $Type -ID $ID -Body @{ source = 'XurrentAPITools'; sourceID = $guid.ToString() }
		if ($PSCmdlet.ParameterSetName -eq 'dest')
		{
			Write-Verbose -Message "update sourceid of $($DestinationID) in $($DestinationEnvironment)"
			Update-XurrentRecord -Environment $DestinationEnvironment -Type $Type -ID $DestinationID -Body @{ source = 'XurrentAPITools'; sourceID = $guid.ToString() }
		}
	}
	catch
	{
		Write-Error $_
		return
	}
	
	
	return [PSCustomObject]::new(@{
			source = 'XurrentAPITools'
			SourceID = $guid.ToString()
		})
}