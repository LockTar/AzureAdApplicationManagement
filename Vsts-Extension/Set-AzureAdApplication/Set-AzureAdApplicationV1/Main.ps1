Trace-VstsEnteringInvocation $MyInvocation

# Get inputs.
$createIfNotExist = Get-VstsInput -Name createIfNotExist -AsBool
$objectId = Get-VstsInput -Name objectId
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
Write-Debug "Import module VstsAzureHelpers" 
Import-Module $PSScriptRoot\ps_modules\VstsAzureHelpers_
Initialize-Azure -strict

Write-Debug "Input variables are: "
Write-Debug "createIfNotExist: $createIfNotExist"
Write-Debug "objectId: $objectId"
Write-Debug "name: $name"
Write-Debug "appIdUri: $appIdUri"
Write-Debug "homePageUrl: $homePageUrl"
Write-Debug "logoutUrl: $logoutUrl"
Write-Debug "termsOfServiceUrl: $termsOfServiceUrl"
Write-Debug "privacyStatementUrl: $privacyStatementUrl"
Write-Debug "multiTenant: $multiTenant"
Write-Debug "replyUrls: $replyUrls"
Write-Debug "replyUrlsArray: $replyUrlsArray"
Write-Debug "resourceAccessFilePath: $resourceAccessFilePath"
Write-Debug "owners: $owners"
Write-Debug "ownersArray: $ownersArray"

Write-Debug "Import AzureAD module because is not on default VSTS agent"
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

Write-Debug "Login to AzureAD with same application as endpoint"
Connect-AzureAD -AadAccessToken $token -AccountId $clientId -TenantId $tenantId

Write-Debug "Add service principal of the azurerm connection to the array of owners"
$deployServicePrincipalId = (Get-AzureRmADServicePrincipal -ServicePrincipalName $clientId).Id
$ownersArray += $deployServicePrincipalId

if ($createIfNotExist) {
    Write-Debug "Check if the application '$name' exists"
    $result = .\scripts\Get-AzureAdApplication.ps1 -ApplicationName $name -FailOnError $failOnError

    if (!$result.Application) {
        Write-Debug "Application doesn't exist. Create the application '$name'"
        .\scripts\New-AzureAdApplication.ps1 `
            -ApplicationName $name `
            -SignOnUrl $homePageUrl

        Start-Sleep -Seconds 15
    }

    Write-Debug "Get the application '$name' again so we have the ObjectId to alter the application"
    $result = .\scripts\Get-AzureAdApplication.ps1 -ApplicationName $name -FailOnError $failOnError

    $objectId = $result.Application.ObjectId
}

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