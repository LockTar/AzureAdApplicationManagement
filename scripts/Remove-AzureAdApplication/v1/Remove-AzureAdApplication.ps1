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

if ($application) {
    $servicePrincipal = Get-AzureRmADApplication -ObjectId $application.ObjectId | Get-AzureRmADServicePrincipal

    Write-Verbose "Removing application: $($application.ObjectId)"
    Write-Verbose "Removing Service Principal connected to Application): $($servicePrincipal.Id)"

    Remove-AzureRmADApplication -ObjectId $application.ObjectId -Force -PassThru
    Remove-AzureRmADServicePrincipal -ObjectId $servicePrincipal.Id -Force -PassThru
}
else {
    Write-Verbose "No application found to remove"
}

$VerbosePreference = $oldverbose
$InformationPreference = $oldinformation