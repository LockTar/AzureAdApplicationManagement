Trace-VstsEnteringInvocation $MyInvocation

# Get inputs.
$method = Get-VstsInput -Name method
$objectId = Get-VstsInput -Name objectId
$applicationId = Get-VstsInput -Name applicationId
$name = Get-VstsInput -Name name
$failIfNotFound = Get-VstsInput -Name failIfNotFound -AsBool

Import-Module $PSScriptRoot\AzureRM\AzureRM.profile\5.6.0\AzureRM.Profile.psd1
Import-Module $PSScriptRoot\AzureRM\AzureRM.Resources\6.6.0\AzureRM.Resources.psd1

# Initialize Azure Connection.
#Write-Verbose "Import module VstsAzureHelpers" 
#Import-Module $PSScriptRoot\ps_modules\VstsAzureHelpers_
#Initialize-Azure -strict

$serviceNameInput = Get-VstsInput -Name ConnectedServiceNameSelector -Require
$serviceName = Get-VstsInput -Name $serviceNameInput -Require
$endPointRM = Get-VstsEndpoint -Name $serviceName -Require

$endPointRM = Get-VstsEndpoint -Name $serviceName -Require
$clientId = $endPointRM.Auth.Parameters.ServicePrincipalId
$clientSecret = $endPointRM.Auth.Parameters.ServicePrincipalKey
$tenantId = $endPointRM.Auth.Parameters.TenantId
$environmentName = "AzureCloud"
$subscriptionId = $Endpoint.Data.SubscriptionId

$psCredential = New-Object System.Management.Automation.PSCredential(
    $clientId,
    (ConvertTo-SecureString $clientSecret -AsPlainText -Force))

$null = Connect-AzureRMAccount -ServicePrincipal -Tenant $tenantId -Credential $psCredential -Environment $environmentName
$null = Set-AzureRmContext -SubscriptionId $subscriptionId -Tenant $tenantId

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
