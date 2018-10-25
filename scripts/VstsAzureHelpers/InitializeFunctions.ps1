function Initialize-AzureSubscription {
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
    $environmentName = "AzureCloud"
    $subscriptionId = $Endpoint.Data.SubscriptionId

    $psCredential = New-Object System.Management.Automation.PSCredential(
        $clientId,
        (ConvertTo-SecureString $clientSecret -AsPlainText -Force))

    Write-Verbose "##[command] Connect-AzureRMAccount -ServicePrincipal -Tenant $tenantId -Credential $psCredential -Environment $environmentName"
    $null = Connect-AzureRMAccount -ServicePrincipal -Tenant $tenantId -Credential $psCredential -Environment $environmentName
    
    Write-Verbose "##[command] Set-AzureRmContext -SubscriptionId $subscriptionId -Tenant $tenantId"
    $null = Set-AzureRmContext -SubscriptionId $subscriptionId -Tenant $tenantId
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