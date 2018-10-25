Trace-VstsEnteringInvocation $MyInvocation

# Get inputs.
$method = Get-VstsInput -Name method
$objectId = Get-VstsInput -Name objectId
$applicationId = Get-VstsInput -Name applicationId
$name = Get-VstsInput -Name name
$failIfNotFound = Get-VstsInput -Name failIfNotFound -AsBool

# Initialize Azure Connection
Import-Module $PSScriptRoot\ps_modules\VstsAzureHelpers\VstsAzureHelpers.psm1
Initialize-PackageProvider

Write-Information "List installed AzureRM modules"
Get-Module -ListAvailable | Where-Object {$_.Name -Like "AzureRM*"}  | Select-Object Name, Version | Format-Table

Write-Output "Remove all existing AzureRM Modules" 
Get-Module -ListAvailable | Where-Object {$_.Name -like 'AzureRM*'} | Remove-Module -Force 

Write-Information "List installed AzureRM modules"
Get-Module -ListAvailable | Where-Object {$_.Name -Like "AzureRM*"}  | Select-Object Name, Version | Format-Table

Initialize-Module -Name "AzureRM.Resources" -RequiredVersion "6.7.0"
#Initialize-Module -Name "AzureRM.profile" -RequiredVersion "5.7.0"

Write-Information "List installed AzureRM modules"
Get-Module -ListAvailable | Where-Object {$_.Name -Like "AzureRM*"}  | Select-Object Name, Version | Format-Table

Initialize-Azure

Write-Verbose "Input variables are: "
Write-Verbose "method: $method"
Write-Verbose "objectId: $objectId"
Write-Verbose "applicationId: $applicationId"
Write-Verbose "name: $name"
Write-Verbose "failIfNotFound: $failIfNotFound"

#Get-AzureRmADApplication -DisplayName $name | Where-Object { $_.DisplayName -eq $name }

Import-Module $PSScriptRoot\scripts\Get-AzureAdApplication.psm1

switch ($method)
{
    "objectid"
    {
        Write-Verbose "Get application by ObjectId"
        
        Get-AzureAdApplication -ObjectId $objectId -FailIfNotFound $failIfNotFound
    }
    "applicationid"
    {
        Write-Verbose "Get application by ApplicationId"           

        Get-AzureAdApplication -ApplicationId $applicationId -FailIfNotFound $failIfNotFound
    }  
    "name"
    {
        Write-Verbose "Get application by Name"

        Get-AzureAdApplication -ApplicationName $name -FailIfNotFound $failIfNotFound
    }
    default{
        Write-Error "Unknow method '$method'"
    }
}
