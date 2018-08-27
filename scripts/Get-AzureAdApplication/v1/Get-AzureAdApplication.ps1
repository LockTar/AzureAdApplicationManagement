Param(
    [string]$ObjectId,
    [string]$ApplicationId,
    [string]$ApplicationName,
    [bool]$FailOnError = $false
)

$ErrorActionPreference = "SilentlyContinue"

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
    $application = Get-AzureRmADApplication -DisplayName $ApplicationName
}
else {
    Write-Error "At least one of the fields ObjectId, ApplicationId or ApplicationName must be given"
}

if ($null -eq $application) {
    if ($FailOnError) {
        $ErrorActionPreference = "Stop"
        Write-Error "The application cannot be found. Check if the application exists and if you search with the right values."
    }
    else {
        Write-Host "##vso[task.setvariable variable=ObjectId;]"
        Write-Host "##vso[task.setvariable variable=ApplicationId;]"
        Write-Host "##vso[task.setvariable variable=Name;]"
        Write-Host "##vso[task.setvariable variable=AppIdUri;]"
        Write-Host "##vso[task.setvariable variable=ServicePrincipalObjectId;]"
    }
}
else {
    $ErrorActionPreference = "Stop"

    # Return application and his service principal
    $servicePrincipal = Get-AzureRmADServicePrincipal -ServicePrincipalName $application.ApplicationId
    #this doesn't work on vsts agent
    #$servicePrincipal = Get-AzureRmADApplication -ObjectId $application.ObjectId | Get-AzureRmADServicePrincipal

    $application
    $servicePrincipal

    Write-Host "##vso[task.setvariable variable=ObjectId;]$($application.ObjectId)"
    Write-Host "##vso[task.setvariable variable=ApplicationId;]$($application.ApplicationId)"
    Write-Host "##vso[task.setvariable variable=Name;]$($application.DisplayName)"
    Write-Host "##vso[task.setvariable variable=AppIdUri;]$($application.IdentifierUris[0])"
    Write-Host "##vso[task.setvariable variable=ServicePrincipalObjectId;]$($servicePrincipal.Id)"
}

$VerbosePreference = $oldverbose
$InformationPreference = $oldinformation