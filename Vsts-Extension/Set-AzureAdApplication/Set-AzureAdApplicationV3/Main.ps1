Trace-VstsEnteringInvocation $MyInvocation

# Get inputs.
$createIfNotExist = Get-VstsInput -Name createIfNotExist -AsBool
$objectId = Get-VstsInput -Name objectId
$name = Get-VstsInput -Name name -Require
$appIdUri = Get-VstsInput -Name appIdUri
$homePageUrl = Get-VstsInput -Name homePageUrl
$logoutUrl = Get-VstsInput -Name logoutUrl
$termsOfServiceUrl = Get-VstsInput -Name termsOfServiceUrl
$privacyStatementUrl = Get-VstsInput -Name privacyStatementUrl
$multiTenant = Get-VstsInput -Name multiTenant -AsBool
$replyUrlsMethod = Get-VstsInput -Name replyUrlsMethod -Require
$replyUrlsSingleLine = Get-VstsInput -Name replyUrlsSingleLine
$replyUrlsMultiLine = Get-VstsInput -Name replyUrlsMultiLine
$resourceAccessFilePath = Get-VstsInput -Name resourceAccessFilePath
$appRolesFilePath = Get-VstsInput -Name appRolesFilePath
$ownersMethod = Get-VstsInput -Name ownersMethod -Require
$ownersSingleLine = Get-VstsInput -Name ownersSingleLine
$ownersMultiLine = Get-VstsInput -Name ownersMultiLine
$secrets = Get-VstsInput -Name secrets
$oauth2AllowImplicitFlow = Get-VstsInput -Name oauth2AllowImplicitFlow -AsBool
$appRoleAssignmentRequired = Get-VstsInput -Name appRoleAssignmentRequired -AsBool

# Create pretty array for optional replyurls array
$replyUrlsArray = @()
switch ($replyUrlsMethod)
{
    "Singleline"
    {
        if ($replyUrlsSingleLine -ne "") {
            $replyUrlsArray = $replyUrlsSingleLine.Split(";")
        }
    }
    "Multiline"
    {
        if ($replyUrlsMultiLine -ne "") {
            $replyUrlsArray = $replyUrlsMultiLine.Split("`n")
        }
    }
}

# Create pretty array for optional owners array
$ownersArray = @()
switch ($ownersMethod)
{
    "Singleline"
    {
        if ($ownersSingleLine -ne "") {
            $ownersArray = $ownersSingleLine.Split(";")
        }
    }
    "Multiline"
    {
        if ($ownersMultiLine -ne "") {
            $ownersArray = $ownersMultiLine.Split("`n")
        }
    }
}

$secretsArray
if($secrets) {
    # Create JSON array for secrets
    $secretsArray = $secrets | ConvertFrom-Json
}


# Cleanup hosted agent with AzureRM modules
. "$PSScriptRoot\Utility.ps1"
CleanUp-PSModulePathForHostedAgent

# Initialize Azure helpers
Import-Module $PSScriptRoot\ps_modules\VstsAzureHelpers_
Import-Module $PSScriptRoot\ps_modules\CustomAzureDevOpsAzureHelpers\CustomAzureDevOpsAzureHelpers.psm1

try 
{
    # Login
    Initialize-PackageProvider
    Initialize-Module -Name "Az.Accounts" -RequiredVersion "2.1.2"
    Initialize-Module -Name "Az.Resources" -RequiredVersion "3.0.0"
    
    $connectedServiceName = Get-VstsInput -Name ConnectedServiceNameARM -Require
    $endpoint = Get-VstsEndpoint -Name $connectedServiceName -Require
    Initialize-AzModule -Endpoint $endpoint

    # Login into old AzureAD because Az still doesn't have all the functions
    Initialize-Module -Name "AzureAD" -RequiredVersion "2.0.2.118"
    Initialize-AzureAD


    Write-Verbose "Input variables are: "
    Write-Verbose "createIfNotExist: $createIfNotExist"
    Write-Verbose "objectId: $objectId"
    Write-Verbose "name: $name"
    Write-Verbose "appIdUri: $appIdUri"
    Write-Verbose "homePageUrl: $homePageUrl"
    Write-Verbose "logoutUrl: $logoutUrl"
    Write-Verbose "termsOfServiceUrl: $termsOfServiceUrl"
    Write-Verbose "privacyStatementUrl: $privacyStatementUrl"
    Write-Verbose "multiTenant: $multiTenant"
    Write-Verbose "replyUrlsArray: $replyUrlsArray"
    Write-Verbose "resourceAccessFilePath: $resourceAccessFilePath"
    Write-Verbose "appRolesFilePath: $appRolesFilePath"
    Write-Verbose "ownersArray: $ownersArray"
    Write-Verbose "secretsArray: $secretsArray"
    Write-Verbose "oauth2AllowImplicitFlow: $oauth2AllowImplicitFlow"
    Write-Verbose "appRoleAssignmentRequired: $appRoleAssignmentRequired"

    Write-Verbose "Add service principal of the ARM connection to the array of owners"
    $serviceName = Get-VstsInput -Name ConnectedServiceNameARM -Require
    $endpoint = Get-VstsEndpoint -Name $serviceName -Require
    $clientId = $endpoint.Auth.Parameters.ServicePrincipalId
    $deployServicePrincipalId = (Get-AzADServicePrincipal -ApplicationId $clientId).Id
    $ownersArray += $deployServicePrincipalId

    Import-Module $PSScriptRoot\scripts\ManageAadApplications.psm1

    if ($createIfNotExist) {
        Write-Verbose "Check if the application '$name' exists"
        $result = Get-AadApplication -DisplayName $name

        if (!$result.Application) {
            Write-Verbose "Application doesn't exist. Create the application '$name'"
            $resultNew = New-AadApplication -DisplayName $name
            
            # Because this is a newly created and IdentifierUri from task is empty, use the generated IdentifierUri in new cmdlet
            if ([string]::IsNullOrWhiteSpace($appIdUri)) {
                $appIdUri = $resultNew.Application.IdentifierUris[0]
            }

            $secondsToWait = 10
            Write-Verbose "Application '$name' is created but wait $secondsToWait seconds so Azure AD can process it and we can set all the properties"
            Start-Sleep -Seconds $secondsToWait
        }

        Write-Verbose "Get the application '$name' again so we have the ObjectId to alter the application"
        $result = Get-AadApplication -DisplayName $name

        $objectId = $result.Application.ObjectId
    }

    Update-AadApplication `
        -ObjectId $objectId `
        -DisplayName $name `
        -IdentifierUri $appIdUri `
        -HomePageUrl $homePageUrl `
        -AvailableToOtherTenants $multiTenant `
        -ReplyUrls $replyUrlsArray `
        -ResourceAccessFilePath $resourceAccessFilePath `
        -AppRolesFilePath $appRolesFilePath `
        -Owners $ownersArray `
        -Secrets $secretsArray `
        -Oauth2AllowImplicitFlow $oauth2AllowImplicitFlow `
        -AppRoleAssignmentRequired $appRoleAssignmentRequired
        
        # Not used...
        # -LogoutUrl $logoutUrl `
        # -TermsOfServiceUrl $termsOfServiceUrl `
        # -PrivacyStatementUrl $privacyStatementUrl `
}
finally {
    Remove-EndpointSecrets
    Disconnect-AzureAndClearContext -ErrorAction SilentlyContinue
}