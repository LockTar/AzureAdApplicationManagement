Trace-VstsEnteringInvocation $MyInvocation

# Get inputs.
$objectId = Get-VstsInput -Name objectId -Require
$resourceAccessFilePath = Get-VstsInput -Name resourceAccessFilePath
$appRolesFilePath = Get-VstsInput -Name appRolesFilePath

# Cleanup hosted agent with AzureRM modules
. "$PSScriptRoot\Utility.ps1"
CleanUp-PSModulePathForHostedAgent

# Initialize Azure helpers
Import-Module $PSScriptRoot\ps_modules\VstsAzureHelpers_
Import-Module $PSScriptRoot\ps_modules\CustomAzureDevOpsAzureHelpers\CustomAzureDevOpsAzureHelpers.psm1

try {
    # Login
    Initialize-PackageProvider
    Initialize-Module -Name "Az.Accounts" -RequiredVersion "2.5.2"
    Initialize-Module -Name "Az.Resources" -RequiredVersion "4.3.1"
    
    $connectedServiceName = Get-VstsInput -Name ConnectedServiceNameARM -Require
    $endpoint = Get-VstsEndpoint -Name $connectedServiceName -Require
    Initialize-AzModule -Endpoint $endpoint

    # Login into old AzureAD because Az still doesn't have all the functions
    Initialize-Module -Name "AzureAD" -RequiredVersion "2.0.2.140"
    Initialize-AzureAD


    Write-Verbose "Input variables are: "
    Write-Verbose "objectId: $objectId"
    Write-Verbose "resourceAccessFilePath: $resourceAccessFilePath"
    Write-Verbose "appRolesFilePath: $appRolesFilePath"

    Import-Module $PSScriptRoot\scripts\ManageAadApplications.psm1

    if ([string]::IsNullOrWhiteSpace($resourceAccessFilePath) -and ![string]::IsNullOrWhiteSpace($appRolesFilePath)) {
        Update-AadApplication -ObjectId $objectId -AppRolesFilePath $appRolesFilePath
    }
    elseif (![string]::IsNullOrWhiteSpace($resourceAccessFilePath) -and [string]::IsNullOrWhiteSpace($appRolesFilePath)) {
        Update-AadApplication -ObjectId $objectId -ResourceAccessFilePath $resourceAccessFilePath
    }
    elseif (![string]::IsNullOrWhiteSpace($resourceAccessFilePath) -and ![string]::IsNullOrWhiteSpace($appRolesFilePath)) {
        Update-AadApplication -ObjectId $objectId -ResourceAccessFilePath $resourceAccessFilePath -AppRolesFilePath $appRolesFilePath
    }
    else {
        throw "No parameters found"
    }
}
finally {
    Remove-EndpointSecrets
    Disconnect-AzureAndClearContext -ErrorAction SilentlyContinue
}