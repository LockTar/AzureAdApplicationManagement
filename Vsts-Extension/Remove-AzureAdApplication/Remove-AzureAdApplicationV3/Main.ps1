Trace-VstsEnteringInvocation $MyInvocation

# Get inputs.
$method = Get-VstsInput -Name method
$objectId = Get-VstsInput -Name objectId
$applicationId = Get-VstsInput -Name applicationId


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

    
    Write-Verbose "Input variables are: "
    Write-Verbose "method: $method"
    Write-Verbose "objectId: $objectId"
    Write-Verbose "applicationId: $applicationId"

    Import-Module $PSScriptRoot\scripts\Remove-AadApplication.psm1

    Remove-AadApplication -ObjectId $objectId -ApplicationId $applicationId
}
finally {
    Remove-EndpointSecrets
    Disconnect-AzureAndClearContext -ErrorAction SilentlyContinue
}