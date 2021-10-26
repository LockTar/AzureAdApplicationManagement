Trace-VstsEnteringInvocation $MyInvocation

# Get inputs.
$method = Get-VstsInput -Name method
$objectId = Get-VstsInput -Name objectId
$applicationId = Get-VstsInput -Name applicationId
$failIfNotFound = Get-VstsInput -Name failIfNotFound -AsBool

# Cleanup hosted agent with AzureRM modules
. "$PSScriptRoot\Utility.ps1"
CleanUp-PSModulePathForHostedAgent

# Initialize Azure helpers
Import-Module $PSScriptRoot\ps_modules\VstsAzureHelpers_
Import-Module $PSScriptRoot\ps_modules\CustomAzureDevOpsAzureHelpers\CustomAzureDevOpsAzureHelpers.psm1

try {
    # Login
    Initialize-PackageProvider
    Initialize-Module -Name "Az.Accounts" -RequiredVersion "2.6.0"
    Initialize-Module -Name "Az.Resources" -RequiredVersion "4.4.0"

    $connectedServiceName = Get-VstsInput -Name ConnectedServiceNameARM -Require
    $endpoint = Get-VstsEndpoint -Name $connectedServiceName -Require
    Initialize-AzModule -Endpoint $endpoint

    
    Write-Verbose "Input variables are: "
    Write-Verbose "method: $method"
    Write-Verbose "objectId: $objectId"
    Write-Verbose "applicationId: $applicationId"
    Write-Verbose "failIfNotFound: $failIfNotFound"

    Import-Module $PSScriptRoot\scripts\ManageAadApplications.psm1

    switch ($method) {
        "objectId" { 
            Remove-AadApplication -ObjectId $objectId -FailIfNotFound:$failIfNotFound
        }
        "applicationid" { 
            Remove-AadApplication -ApplicationId $applicationId -FailIfNotFound:$failIfNotFound
        }        
        default {
            Write-Error "Unknow method '$method'"
        }
    }
}
finally {
    Remove-EndpointSecrets
    Disconnect-AzureAndClearContext -ErrorAction SilentlyContinue
}