Trace-VstsEnteringInvocation $MyInvocation

# Get inputs.
$createIfNotExist = Get-VstsInput -Name createIfNotExist -AsBool
$objectId = Get-VstsInput -Name objectId
$name = Get-VstsInput -Name name -Require
$appIdUri = Get-VstsInput -Name appIdUri
$webHomePageURl = Get-VstsInput -Name webHomePageURl 
$logoutUrl = Get-VstsInput -Name logoutUrl
$termsOfServiceUrl = Get-VstsInput -Name termsOfServiceUrl
$privacyStatementUrl = Get-VstsInput -Name privacyStatementUrl
$signInAudience = Get-VstsInput -Name signInAudience -AsString
$webRedirectUrisMethod = Get-VstsInput -Name webRedirectUrisMethod -Require
$webRedirectUrisSingleLine = Get-VstsInput -Name webRedirectUrisSingleLine
$webRedirectUrisMultiLine = Get-VstsInput -Name webRedirectUrisMultiLine
$resourceAccessFilePath = Get-VstsInput -Name resourceAccessFilePath
$appRolesFilePath = Get-VstsInput -Name appRolesFilePath
$ownersMethod = Get-VstsInput -Name ownersMethod -Require
$ownersSingleLine = Get-VstsInput -Name ownersSingleLine
$ownersMultiLine = Get-VstsInput -Name ownersMultiLine
$secrets = Get-VstsInput -Name secrets
$enableAccessTokenIssuance = Get-VstsInput -Name enableAccessTokenIssuance -AsBool
$appRoleAssignmentRequired = Get-VstsInput -Name appRoleAssignmentRequired -AsBool

# Create pretty array for optional webRedirectUris array
$webRedirectUris = @()
switch ($webRedirectUrisMethod) {
    "Singleline" {
        if ($webRedirectUrisSingleLine -ne "") {
            $webRedirectUris = $webRedirectUrisSingleLine.Split(";")
        }
    }
    "Multiline" {
        if ($webRedirectUrisMultiLine -ne "") {
            $webRedirectUris = $webRedirectUrisMultiLine.Split("`n")
        }
    }
}

if ($webRedirectUris.Count -eq 0) {
    Write-Verbose "Set webRedirectUris to null because there is nothing in the task"
    $webRedirectUris = $null
}

# Create pretty array for optional owners array
$ownersArray = @()
switch ($ownersMethod) {
    "Singleline" {
        if ($ownersSingleLine -ne "") {
            $ownersArray = $ownersSingleLine.Split(";")
        }
    }
    "Multiline" {
        if ($ownersMultiLine -ne "") {
            $ownersArray = $ownersMultiLine.Split("`n")
        }
    }
}

$secretsArray
if ($secrets) {
    # Create JSON array for secrets
    $secretsArray = $secrets | ConvertFrom-Json
}


# Cleanup hosted agent with AzureRM modules
. "$PSScriptRoot\Utility.ps1"
CleanUp-PSModulePathForHostedAgent

# Initialize Azure helpers
Import-Module $PSScriptRoot\ps_modules\VstsAzureHelpers_
Import-Module $PSScriptRoot\ps_modules\CustomAzureDevOpsAzureHelpers\CustomAzureDevOpsAzureHelpers.psm1

try {
    # Login
    # Initialize-PackageProvider
    # Initialize-Module -Name "Az.Accounts" -RequiredVersion "2.6.0"
    # Initialize-Module -Name "Az.Resources" -RequiredVersion "4.4.0"
    
    # $connectedServiceName = Get-VstsInput -Name ConnectedServiceNameARM -Require
    # $endpoint = Get-VstsEndpoint -Name $connectedServiceName -Require
    # Initialize-AzModule -Endpoint $endpoint

    # # Login into old AzureAD because Az still doesn't have all the functions
    # Initialize-Module -Name "AzureAD" -RequiredVersion "2.0.2.140"
    # Initialize-AzureAD


    Write-Verbose "Input variables are: "
    Write-Verbose "createIfNotExist: $createIfNotExist"
    Write-Verbose "objectId: $objectId"
    Write-Verbose "name: $name"
    Write-Verbose "appIdUri: $appIdUri"
    Write-Verbose "webHomePageURl: $webHomePageURl"
    Write-Verbose "logoutUrl: $logoutUrl"
    Write-Verbose "termsOfServiceUrl: $termsOfServiceUrl"
    Write-Verbose "privacyStatementUrl: $privacyStatementUrl"
    Write-Verbose "signInAudience: $signInAudience"
    Write-Verbose "webRedirectUris: $webRedirectUris"
    Write-Verbose "resourceAccessFilePath: $resourceAccessFilePath"
    Write-Verbose "appRolesFilePath: $appRolesFilePath"
    Write-Verbose "ownersArray: $ownersArray"
    Write-Verbose "secretsArray: $secretsArray"
    Write-Verbose "enableAccessTokenIssuance: $enableAccessTokenIssuance"
    Write-Verbose "appRoleAssignmentRequired: $appRoleAssignmentRequired"

    Write-Verbose "Add service principal of the ARM connection to the array of owners"
    $serviceName = Get-VstsInput -Name ConnectedServiceNameARM -Require
    $endpoint = Get-VstsEndpoint -Name $serviceName -Require
    $clientId = $endpoint.Auth.Parameters.ServicePrincipalId
    $deployServicePrincipalId = (Get-MgApplication -ApplicationId $clientId).Id
    $ownersArray += $deployServicePrincipalId

    Import-Module $PSScriptRoot\scripts\ManageAadApplications.psm1

    if ($createIfNotExist) {
        Write-Verbose "Check if the application '$name' exists"
        $result = Get-AadApplication -DisplayName $name

        if (!$result.Application) {
            Write-Verbose "Application doesn't exist. Create the application '$name'"
            New-AadApplication -DisplayName $name
            
            $secondsToWait = 10
            Write-Verbose "Application '$name' is created but wait $secondsToWait seconds so Azure AD can process it and we can set all the properties"
            Start-Sleep -Seconds $secondsToWait
            
            Write-Verbose "Get the application '$name' again so we have the ObjectId to alter the application"
            $result = Get-AadApplication -DisplayName $name
        }

        # Because this is a newly created app or 
        # because the app is already created (second time pipeline runs) but the parameter is still not given and the IdentifierUri from task is empty, 
        # use the newly generated or already existing IdentifierUri in update cmdlet
        if ([string]::IsNullOrWhiteSpace($appIdUri)) {
            $appIdUri = $result.Application.IdentifierUris[0]
            Write-Verbose "Newly generated IdentifierUri: $appIdUri"
        }

        # The app already exists or is just created. Use the ObjectId to update "set" it further.
        $objectId = $result.Application.ObjectId
    }

    Update-AadApplication `
        -ObjectId $objectId `
        -DisplayName $name `
        -IdentifierUri $appIdUri `
        -WebHomePageUrl $webHomePageURl `
        -SignInAudience $signInAudience `
        -WebRedirectUris $webRedirectUris `
        -ResourceAccessFilePath $resourceAccessFilePath `
        -AppRolesFilePath $appRolesFilePath `
        -Owners $ownersArray `
        -Secrets $secretsArray `
        -EnableAccessTokenIssuance $enableAccessTokenIssuance `
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