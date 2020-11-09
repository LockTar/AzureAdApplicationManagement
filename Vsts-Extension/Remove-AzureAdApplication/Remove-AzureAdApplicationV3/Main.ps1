Trace-VstsEnteringInvocation $MyInvocation

# Get inputs.
$method = Get-VstsInput -Name method
$objectId = Get-VstsInput -Name objectId
$applicationId = Get-VstsInput -Name applicationId

$requiredAzVersion = "5.0.0"

# Initialize Azure helpers
Import-Module $PSScriptRoot\ps_modules\VstsAzureHelpers_
Import-Module $PSScriptRoot\ps_modules\CustomAzureDevOpsAzureHelpers\CustomAzureDevOpsAzureHelpers.psm1

try 
{
    # Login
    Initialize-PackageProvider
    Initialize-Module -Name "Az" -RequiredVersion $requiredAzVersion

    $connectedServiceName = Get-VstsInput -Name ConnectedServiceNameARM -Require
    $endpoint = Get-VstsEndpoint -Name $connectedServiceName -Require
    Initialize-AzModule -Endpoint $endpoint -azVersion $requiredAzVersion

    
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