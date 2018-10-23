Trace-VstsEnteringInvocation $MyInvocation

# Get inputs.
$method = Get-VstsInput -Name method
$objectId = Get-VstsInput -Name objectId
$applicationId = Get-VstsInput -Name applicationId

# Initialize Azure Connection.
Import-Module $PSScriptRoot\ps_modules\AzureRM
Import-Module $PSScriptRoot\VstsAzureHelpers
Initialize-Azure

Write-Verbose "Input variables are: "
Write-Verbose "method: $method"
Write-Verbose "objectId: $objectId"
Write-Verbose "applicationId: $applicationId"

.\scripts\Remove-AzureAdApplication.ps1 -ObjectId $objectId -ApplicationId $applicationId