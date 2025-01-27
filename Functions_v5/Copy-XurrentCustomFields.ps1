function Copy-XurrentCustomFields
{
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[ValidateScript({ $null -ne $script:XurrentAuth.$_ })]
		[string]$Environment,
		[Parameter(Mandatory = $true)]
		[int]$SourceID,
		[Parameter(Mandatory = $true)]
		[ValidateScript({ $_ -in $script:XurrentDataTypes })]
		[string]$SourceType,
		[Parameter(Mandatory = $true)]
		[int]$DestinationID,
		[Parameter(Mandatory = $false)]
		[ValidateScript({ $_ -in $script:XurrentDataTypes })]
		[string]$DestinationType
		
	)
	if ([string]::IsNullOrEmpty($DestinationType))
	{
		$DestinationType = $SourceType
	}
	$SourceItem = Get-XurrentData -Type $DestinationType -Environment $Environment -ID $SourceID -Full -ConvertCustomFields:$fale
	$body = @{
		custom_fields = $SourceItem.custom_fields
	}
	Update-XurrentRecord -Environment $Environment -Type $SourceType -ID $DestinationID -Body $body
}