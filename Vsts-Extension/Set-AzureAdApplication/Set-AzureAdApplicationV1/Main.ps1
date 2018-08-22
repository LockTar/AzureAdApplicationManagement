Trace-VstsEnteringInvocation $MyInvocation

# Get inputs.
$objectId = Get-VstsInput -Name objectId -Require
$name = Get-VstsInput -Name name -Require
$appIdUri = Get-VstsInput -Name appIdUri -Require
$homePageUrl = Get-VstsInput -Name homePageUrl
$logoutUrl = Get-VstsInput -Name logoutUrl
$termsOfServiceUrl = Get-VstsInput -Name termsOfServiceUrl
$privacyStatementUrl = Get-VstsInput -Name privacyStatementUrl
$multiTenant = Get-VstsInput -Name multiTenant -AsBool
$replyUrls = Get-VstsInput -Name replyUrls
$resourceAccessFilePath = Get-VstsInput -Name resourceAccessFilePath
$owners = Get-VstsInput -Name owners

# Create pretty array for optional replyurls array
$replyUrlsArray = @()
if ($replyUrls -ne "") {
    $replyUrlsArray = $replyUrls.Split("`n")
}

# Create pretty array for optional owners array
$ownersArray = @()
if ($owners -ne "") {
    $ownersArray = $owners.Split("`n")
}

# Initialize Azure Connection.
Write-Verbose "Import module VstsAzureHelpers" 
Import-Module $PSScriptRoot\ps_modules\VstsAzureHelpers_
Initialize-Azure -strict

Write-Verbose "Input variables are: "
Write-Verbose "objectId: $objectId"
Write-Verbose "name: $name"
Write-Verbose "appIdUri: $appIdUri"
Write-Verbose "homePageUrl: $homePageUrl"
Write-Verbose "logoutUrl: $logoutUrl"
Write-Verbose "termsOfServiceUrl: $termsOfServiceUrl"
Write-Verbose "privacyStatementUrl: $privacyStatementUrl"
Write-Verbose "multiTenant: $multiTenant"
Write-Verbose "replyUrls: $replyUrls"
Write-Verbose "replyUrlsArray: $replyUrlsArray"
Write-Verbose "resourceAccessFilePath: $resourceAccessFilePath"
Write-Verbose "owners: $owners"
Write-Verbose "ownersArray: $ownersArray"

Write-Verbose "Import AzureAD module because is not on default VSTS agent"
$azureAdModulePath = $PSScriptRoot + "\AzureAD\2.0.1.16\AzureAD.psd1"
Import-Module $azureAdModulePath 

# Workaround to use AzureAD in this task. Get an access token and call Connect-AzureAD
$serviceNameInput = Get-VstsInput -Name ConnectedServiceNameSelector -Require
$serviceName = Get-VstsInput -Name $serviceNameInput -Require
$endPointRM = Get-VstsEndpoint -Name $serviceName -Require

$clientId = $endPointRM.Auth.Parameters.ServicePrincipalId
$clientSecret = $endPointRM.Auth.Parameters.ServicePrincipalKey
$tenantId = $endPointRM.Auth.Parameters.TenantId

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

Write-Verbose "Login to AzureAD with same application as endpoint"
Connect-AzureAD -AadAccessToken $token -AccountId $clientId -TenantId $tenantId
        
.\scripts\Set-AzureAdApplication.ps1 `
    -ObjectId $objectId `
    -Name $name `
    -AppIdUri $appIdUri `
    -HomePageUrl $homePageUrl `
    -LogoutUrl $logoutUrl `
    -TermsOfServiceUrl $termsOfServiceUrl `
    -PrivacyStatementUrl $privacyStatementUrl `
    -MultiTenant $multiTenant `
    -ReplyUrls $replyUrlsArray `
    -ResourceAccessFilePath $resourceAccessFilePath `
    -Owners $ownersArray