Param(
    [string]$ObjectId,
    [string]$ApplicationId  
)

$ErrorActionPreference = "Stop"

$oldverbose = $VerbosePreference
$VerbosePreference = "continue"
$oldinformation = $InformationPreference
$InformationPreference = "continue"

if ($ObjectId) {
    Write-Verbose "Remove application by ObjectId: $ObjectId"
    $application = Get-AzureRmADApplication -ObjectId $ObjectId    
}
elseif ($ApplicationId) {
    Write-Verbose "Remove application by ApplicationId: $ApplicationId"
    $application = Get-AzureRmADApplication -ApplicationId $ApplicationId
}
else {
    Write-Error "At least one of the fields ObjectId, ApplicationId or ApplicationName must be given"
}

if ($application) {
    Write-Verbose "Found application: "
    $application

    $servicePrincipal = Get-AzureRmADApplication -ObjectId $application.ObjectId | Get-AzureRmADServicePrincipal

    Write-Verbose "Found service principal: "
    $servicePrincipal

    Write-Verbose "Removing application: $($application.ObjectId)"
    Remove-AzureRmADApplication -ObjectId $application.ObjectId -Force
    
    if ($servicePrincipal.Id) {
        Write-Verbose "Removing Service Principal connected to Application: $($servicePrincipal.Id)"
        Remove-AzureRmADServicePrincipal -ObjectId $servicePrincipal.Id -Force    
    }
    else {
        Write-Verbose "Not removing Service Principal connected to Application because there is none"
    }
}
else {
    Write-Verbose "No application found to remove"
}

$VerbosePreference = $oldverbose
$InformationPreference = $oldinformation