Param(
    [Parameter(Mandatory)]
    [string]$ApplicationName,
    [Parameter(Mandatory)]
    [string]$SignOnUrl
)

$ErrorActionPreference = "Stop"

$oldverbose = $VerbosePreference
$VerbosePreference = "continue"
$oldinformation = $InformationPreference
$InformationPreference = "continue"

$applicationCreated = New-AzureRmADApplication `
    -DisplayName $ApplicationName `
    -HomePage $SignOnUrl `
    -IdentifierUris $($SignOnUrl)

Start-Sleep -Seconds 10

#Return application and his service principal
$application = Get-AzureRmADApplication -ObjectId $applicationCreated.ObjectId
Get-AzureRmADApplication -ObjectId $application.ObjectId | Get-AzureRmADServicePrincipal

Write-Host "##vso[task.setvariable variable=ObjectId;]$($application.ObjectId)"
Write-Host "##vso[task.setvariable variable=ApplicationId;]$($application.ApplicationId)"
Write-Host "##vso[task.setvariable variable=Name;]$($application.DisplayName)"

$VerbosePreference = $oldverbose
$InformationPreference = $oldinformation