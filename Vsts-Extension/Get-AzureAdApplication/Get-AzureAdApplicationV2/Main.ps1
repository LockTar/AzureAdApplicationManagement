Trace-VstsEnteringInvocation $MyInvocation

# Get inputs.
$method = Get-VstsInput -Name method
$objectId = Get-VstsInput -Name objectId
$applicationId = Get-VstsInput -Name applicationId
$name = Get-VstsInput -Name name
$failIfNotFound = Get-VstsInput -Name failIfNotFound -AsBool

# Initialize Azure Connection.
#Import-Module $PSScriptRoot\ps_modules\AzureRM
#Find-Module -Name "AzureRM.profile" -RequiredVersion 5.6.0 | Install-Module
#Find-Module -Name "AzureRM.Resources" -RequiredVersion 6.6.0 | Install-Module

Write-Output "------------------ Start: Upgrade AzureRM on build host ------------------"

Write-Output "- - - - - Install package provider"
#Install-PackageProvider -Name NuGet -Force -Scope CurrentUser
Find-PackageProvider -Name "NuGet" | Install-PackageProvider -Verbose -Scope CurrentUser -Force

#Write-Output "- - - - - List Modules Before"
#Get-Module -ListAvailable| where {$_.Name -Like "*AzureRM*"}  | Select Name, Version

#Write-Output "- - - - - Remove alll existing AzureRM Modules" 
#Get-Module -ListAvailable | Where-Object {$_.Name -like '*AzureRM*'} | Remove-Module -Force 

Write-Output "- - - - - Install modules"
Find-Package AzureRM.profile -RequiredVersion 5.6.0 | Install-Package -Scope CurrentUser -Force
Find-Package AzureRM.Resources -RequiredVersion 6.6.0 | Install-Package -Scope CurrentUser -Force
#Install-Module -Name AzureRM.profile -RequiredVersion 5.6.0 -Force -Scope CurrentUser -AllowClobber
#Install-Module -Name AzureRM.Resources -RequiredVersion 6.6.0 -Force -Scope CurrentUser -AllowClobber

#Write-Output "- - - - - Import downloaded modules"
#Import-Module AzureRM.profile -Force -Verbose -Scope Local
#Import-Module AzureRM.Resources -Force -Verbose -Scope Local

#Write-Output "- - - - - List Modules After"
#Get-Module -ListAvailable| where {$_.Name -Like "*AzureRM*"}  | Select Name, Version

Write-Output "------------------ End: Upgrade AzureRM on build host ------------------"


Import-Module $PSScriptRoot\VstsAzureHelpers
Initialize-Azure

Write-Verbose "Input variables are: "
Write-Verbose "method: $method"
Write-Verbose "objectId: $objectId"
Write-Verbose "applicationId: $applicationId"
Write-Verbose "name: $name"
Write-Verbose "failIfNotFound: $failIfNotFound"

switch ($method)
{
    "objectid"
    {
        Write-Verbose "Get application by ObjectId"
        
        .\scripts\Get-AzureAdApplication.ps1 -ObjectId $objectId -FailIfNotFound $failIfNotFound
    }
    "applicationid"
    {
        Write-Verbose "Get application by ApplicationId"           

        .\scripts\Get-AzureAdApplication.ps1 -ApplicationId $applicationId -FailIfNotFound $failIfNotFound
    }  
    "name"
    {
        Write-Verbose "Get application by Name"

        .\scripts\Get-AzureAdApplication.ps1 -ApplicationName $name -FailIfNotFound $failIfNotFound
    }
    default{
        Write-Error "Unknow method '$method'"
    }
}
