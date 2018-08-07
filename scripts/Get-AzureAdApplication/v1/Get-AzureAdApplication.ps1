Param(
    [string]$ObjectId,
    [string]$ApplicationId,
    [string]$ApplicationName    
)

$ErrorActionPreference = "Stop"

$oldverbose = $VerbosePreference
$VerbosePreference = "continue"
$oldinformation = $InformationPreference
$InformationPreference = "continue"

if ($ObjectId) {
    $application = Get-AzureRmADApplication -ObjectId $ObjectId    
}
elseif ($ApplicationId) {
    $application = Get-AzureRmADApplication -ApplicationId $ApplicationId
}
elseif ($ApplicationName) {
    $application = Get-AzureRmADApplication -DisplayName = $ApplicationName
}
else {
    Write-Error "At least one of the fields ObjectId, ApplicationId or ApplicationName must be given"
}

#Return application and his service principal
$application
Get-AzureRmADApplication -ObjectId $application.ObjectId | Get-AzureRmADServicePrincipal

Write-Host "##vso[task.setvariable variable=ObjectId;]$($application.ObjectId)"
Write-Host "##vso[task.setvariable variable=ApplicationId;]$($application.ApplicationId)"
Write-Host "##vso[task.setvariable variable=Name;]$($application.DisplayName)"

$VerbosePreference = $oldverbose
$InformationPreference = $oldinformation