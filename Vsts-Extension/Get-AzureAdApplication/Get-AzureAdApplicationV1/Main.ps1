Trace-VstsEnteringInvocation $MyInvocation

# Get inputs.
$method = Get-VstsInput -Name method
$objectId = Get-VstsInput -Name objectId
$applicationId = Get-VstsInput -Name applicationId
$name = Get-VstsInput -Name name

# Initialize Azure Connection.
Write-Verbose "Import module VstsAzureHelpers" 
Import-Module $PSScriptRoot\ps_modules\VstsAzureHelpers_
Initialize-Azure -strict

Write-Verbose "Input variables are: "
Write-Verbose "method: $method"
Write-Verbose "objectId: $objectId"
Write-Verbose "applicationId: $applicationId"
Write-Verbose "name: $name"

switch ($method)
{
    "objectid"
    {
        Write-Verbose "Get application by ObjectId"
        
        .\scripts\Get-AzureAdApplication.ps1 -ObjectId $objectId        
    }
    "applicationid"
    {
        Write-Verbose "Get application by ApplicationId"           

        .\scripts\Get-AzureAdApplication.ps1 -ApplicationId $applicationId
    }  
    "name"
    {
        Write-Verbose "Get application by Name"

        .\scripts\Get-AzureAdApplication.ps1 -ApplicationName $name
    }
    default{
        Write-Error "Unknow method '$method'"
    }
}
