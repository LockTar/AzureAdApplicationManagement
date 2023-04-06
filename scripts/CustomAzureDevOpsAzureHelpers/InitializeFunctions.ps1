function Initialize-AzureSubscriptionAD {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        $Endpoint)

    #Set UserAgent for Azure Calls
    Set-UserAgent

    Write-Verbose 'Get all values from the endpoint'
    $clientId = $Endpoint.Auth.Parameters.ServicePrincipalId
    $clientSecret = $Endpoint.Auth.Parameters.ServicePrincipalKey
    $tenantId = $Endpoint.Auth.Parameters.TenantId
    
    $adTokenUrl = "https://login.microsoftonline.com/$tenantId/oauth2/token"
    $resource = "https://graph.windows.net/"

    $body = @{
        grant_type    = "client_credentials"
        client_id     = $clientId
        client_secret = $clientSecret
        resource      = $resource
    }

    $response = Invoke-RestMethod -Method 'Post' -Uri $adTokenUrl -ContentType "application/x-www-form-urlencoded" -Body $body
    $token = $response.access_token
    Write-VstsSetSecret -Value $token

    Write-Verbose "##[command] Connect-AzureAD -AadAccessToken $token -AccountId $clientId -TenantId $tenantId"
    $null = Connect-AzureAD -AadAccessToken $token -AccountId $clientId -TenantId $tenantId
}

function Initialize-MsGraphConnection {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        $Endpoint)

    #Set UserAgent for Azure Calls
    Set-UserAgent

    Write-Verbose 'Get all values from the endpoint'
    $clientId = $Endpoint.Auth.Parameters.ServicePrincipalId
    $clientSecret = $Endpoint.Auth.Parameters.ServicePrincipalKey
    $tenantId = $Endpoint.Auth.Parameters.TenantId
    
    $adTokenUrl = "https://login.microsoftonline.com/$tenantId/oauth2/token"
    $resource = "https://graph.microsoft.com"

    $body = @{
        grant_type    = "client_credentials"
        client_id     = $clientId
        client_secret = $clientSecret
        resource      = $resource
    }

    $response = Invoke-RestMethod -Method 'Post' -Uri $adTokenUrl -ContentType "application/x-www-form-urlencoded" -Body $body
    $token = $response.access_token
    Write-VstsSetSecret -Value $token

    Write-Verbose "##[command] Connect-MgGraph -AccessToken $token"
    $null = Connect-MgGraph -AccessToken $token
}

function Set-UserAgent {
    [CmdletBinding()]
    param()

	$userAgent = Get-VstsTaskVariable -Name AZURE_HTTP_USER_AGENT
    if ($userAgent) {
        Set-UserAgent_Core -UserAgent $userAgent
    }
}

function Set-UserAgent_Core {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$UserAgent)

    Trace-VstsEnteringInvocation $MyInvocation
    try {
        [Microsoft.Azure.Common.Authentication.AzureSession]::ClientFactory.AddUserAgent($UserAgent)
    } catch {
        Write-Verbose "Set-UserAgent failed with exception message: $_.Exception.Message"
    } finally {
        Trace-VstsLeavingInvocation $MyInvocation
    }
}
