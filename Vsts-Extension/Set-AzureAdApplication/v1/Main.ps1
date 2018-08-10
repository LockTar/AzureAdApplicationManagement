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
$replyUrlsArray = $replyUrls.Split("`n")

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
        
.\scripts\Set-AzureAdApplication.ps1 `
    -ObjectId $objectId `
    -Name $name `
    -AppIdUri $appIdUri `
    -HomePageUrl $homePageUrl `
    -LogoutUrl $logoutUrl `
    -TermsOfServiceUrl $termsOfServiceUrl `
    -PrivacyStatementUrl $privacyStatementUrl `
    -MultiTenant $multiTenant `
    -ReplyUrls $replyUrlsArray