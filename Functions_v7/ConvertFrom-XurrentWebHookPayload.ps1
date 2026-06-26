function ConvertFrom-XurrentWebHookPayload
{	
<#
.SYNOPSIS
    Decodes and optionally verifies a Xurrent webhook payload (JWT).

.DESCRIPTION
    Processes the JSON payload of an incoming Xurrent webhook. Decodes the JWT token
    (header, payload, signature), converts Unix timestamps to DateTime objects and
    determines the Xurrent environment from the issuer URL.

    Optionally the JWT signature can be verified using a public RSA key (RS256).
    The function returns a structured object containing all relevant webhook information.

.PARAMETER PayloadString
    The raw webhook payload as a JSON string. Mandatory in parameter set 'string'.

.PARAMETER PayloadPath
    Path to a file containing the webhook payload. Mandatory in parameter set 'path'.

.PARAMETER CertPublicKey
    Optional Base64-encoded public RSA key for signature verification.

.OUTPUTS
    PSCustomObject with the properties: Header, Payload, Signature, Environment, Region, Account.

.EXAMPLE
    $result = ConvertFrom-XurrentWebHookPayload -PayloadString $rawJson

    Decodes a webhook payload without signature verification.

.EXAMPLE
    $result = ConvertFrom-XurrentWebHookPayload -PayloadPath 'C:\webhooks\payload.json' `
        -CertPublicKey $pubKeyBase64

    Loads the payload from a file and verifies the signature.

.NOTES
    Requires PowerShell 7.2+.
    The properties Payload.exp, Payload.nbf and Payload.iat are returned as DateTime.
#>
	[CmdletBinding(DefaultParameterSetName = 'string')]
	param (
		[Parameter(Mandatory = $true, ParameterSetName = 'string', Position = 0)]
		[string]$PayloadString,
		[Parameter(Mandatory = $true, ParameterSetName = 'path', Position = 0)]
		[string]$PayloadPath,
		[Parameter(Mandatory = $false, ParameterSetName = 'string', Position = 1)]
		[Parameter(Mandatory = $false, ParameterSetName = 'path', Position = 1)]
		[string]$CertPublicKey
	)
	
	Write-Verbose -Message "ParameterSetName $($PSCmdlet.ParameterSetName)"
	if ($PSCmdlet.ParameterSetName -eq 'path')
	{
		$PayloadString = get-content $PayloadPath
	}
	try
	{
		$payloadJson = $PayloadString | ConvertFrom-Json
		$tokenParts = $payloadJson.jwt -split '\.'
		$headerEncoded = $tokenParts[0]
		$payloadEncoded = $tokenParts[1]
		$signatureEncoded = $tokenParts[2]
		
		while ($headerEncoded.Length % 4) { Write-Debug -Message "Invalid length for a Base-64 char array or string, adding ="; $headerEncoded += "=" }
		while ($payloadEncoded.Length % 4) { Write-Debug -Message "Invalid length for a Base-64 char array or string, adding ="; $payloadEncoded += "=" }
		while ($signatureEncoded.Length % 4) { Write-Debug -Message "Invalid length for a Base-64 char array or string, adding ="; $signatureEncoded += "=" }
		
		$HeaderObj = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String(($headerEncoded).Replace('_', '/').Replace('-', '+'))) | ConvertFrom-Json
		if ($headerObj.typ -ne 'JWT')
		{
			Write-Error 'payload is not a jwt' -ErrorAction Stop
		}
		
		$PayloadObj = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String(($payloadEncoded).Replace('_', '/').Replace('-', '+'))) | ConvertFrom-Json -DateKind string
		
		$PayloadObj.exp = (Get-Date 01.01.1970).AddSeconds($PayloadObj.exp)
		$PayloadObj.nbf = (Get-Date 01.01.1970).AddSeconds($PayloadObj.nbf)
		$PayloadObj.iat = (Get-Date 01.01.1970).AddSeconds($PayloadObj.iat)
		
		if (-not [string]::IsNullOrEmpty($CertPublicKey))
		{
			if ($headerObj.alg -ne 'RS256')
			{
				Write-Error 'alg not RS256 as expected' -ErrorAction Stop
			}
			# Decoding Base64url to the original byte array
			$signatureBytes = [Convert]::FromBase64String(($signatureEncoded).Replace('_', '/').Replace('-', '+'))
			
			# Decode Base64 PEM key
			$publicKeyBytes = [Convert]::FromBase64String($CertPublicKey)
			
			# Create RSA Key
			$rsa = [System.Security.Cryptography.RSA]::Create()
			$rsa.ImportSubjectPublicKeyInfo($publicKeyBytes, [ref]0)
			
			# Verify the Signature
			$sha256 = New-Object System.Security.Cryptography.SHA256CryptoServiceProvider
			# Computing SHA-256 hash of the JWT parts 1 and 2 - header and payload
			$computed = $SHA256.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($tokenParts[0] + "." + $tokenParts[1]))
			# Decoding Base64url to the original byte array
			$signed = $tokenParts[2].replace('-', '+').replace('_', '/')
			while ($signed.Length % 4) { Write-Debug -Message "Invalid length for a Base-64 char array or string, adding ="; $signed += "=" }
			$bytes = [Convert]::FromBase64String($signed) # Conversion completed
			
			$SignatureObj = [PSCustomObject]::new(@{
					isValid   = $rsa.VerifyHash($computed, $bytes, [System.Security.Cryptography.HashAlgorithmName]::SHA256, [System.Security.Cryptography.RSASignaturePadding]::Pkcs1)
					PublcKey  = $CertPublicKey
					Signature = $signatureEncoded
				})
		}
		$XurrentEnvironment = Find-XurrentEnvironment -AccountURL $PayloadObj.iss
		$Obj = [PSCustomObject]::new(@{
				Header	    = $HeaderObj
				Payload	    = $PayloadObj
				Signature   = $SignatureObj
				Environment = $XurrentEnvironment.Environment
				Region	    = $XurrentEnvironment.Region
				Account	    = $PayloadObj.data.account_id
			})
		
		return $Obj
	}
	catch
	{
		Write-Error $_
		return
	}
	
}