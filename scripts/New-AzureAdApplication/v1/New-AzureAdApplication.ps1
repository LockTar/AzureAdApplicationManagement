Param(
    [Parameter(Mandatory)]
    [string]$ApplicationName,
    [Parameter(Mandatory)]
    [string]$SignOnUrl,
    [string]$IdentifierUri
)

$ErrorActionPreference = "Stop"

$oldverbose = $VerbosePreference
$VerbosePreference = "continue"
$oldinformation = $InformationPreference
$InformationPreference = "continue"

if (!$IdentifierUri) {
    Write-Verbose "No IdentifierUri so generate one with format: http://{TenantId}/{ApplicationName}"
    Write-Verbose "Get context of account"
    $context = Get-AzureRmContext
    $context
    $IdentifierUri = "https://$($context.Account.Tenants[0])/$ApplicationName"
    Write-Verbose "Generated IdentifierUri: $IdentifierUri"
}

Write-Verbose "Create application"
$applicationCreated = New-AzureRmADApplication `
    -DisplayName $ApplicationName `
    -HomePage $SignOnUrl `
    -IdentifierUris $($IdentifierUri) `
    -ReplyUrls $($SignOnUrl)

Write-Verbose "Wait 10 seconds until AD processed application creation"
Start-Sleep -Seconds 10

Write-Verbose "Create service principal connected to application"
$servicePrincipal = Get-AzureRmADApplication -ObjectId $applicationCreated.ObjectId | New-AzureRmADServicePrincipal

Write-Verbose "Wait 10 seconds until AD processed service principal creation"
Start-Sleep -Seconds 10

#Return application and his service principal
$application = Get-AzureRmADApplication -ObjectId $applicationCreated.ObjectId
$servicePrincipal = Get-AzureRmADServicePrincipal -ApplicationId $application.ApplicationId

#this doesn't work on vsts agent
#$servicePrincipal = Get-AzureRmADApplication -ObjectId $application.ObjectId | Get-AzureRmADServicePrincipal

$application
$servicePrincipal

Write-Host "##vso[task.setvariable variable=ObjectId;]$($application.ObjectId)"
Write-Host "##vso[task.setvariable variable=ApplicationId;]$($application.ApplicationId)"
Write-Host "##vso[task.setvariable variable=Name;]$($application.DisplayName)"
Write-Host "##vso[task.setvariable variable=ServicePrincipalObjectId;]$($servicePrincipal.Id)"

$VerbosePreference = $oldverbose
$InformationPreference = $oldinformation