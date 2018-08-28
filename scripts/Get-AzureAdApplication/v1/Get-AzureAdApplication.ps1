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
    Write-Verbose "Get application by ObjectId: $ObjectId"
    $application = Get-AzureRmADApplication -ObjectId $ObjectId    
}
elseif ($ApplicationId) {
    Write-Verbose "Get application by ApplicationId: $ApplicationId"
    $application = Get-AzureRmADApplication -ApplicationId $ApplicationId
}
elseif ($ApplicationName) {
    Write-Verbose "Get application by ApplicationName: $ApplicationName"
    $application = Get-AzureRmADApplication -DisplayName $ApplicationName | Where-Object { $_.DisplayName -eq $ApplicationName }
}
else {
    Write-Error "At least one of the fields ObjectId, ApplicationId or ApplicationName must be given"
}

if ($null -eq $application) {
    Write-Verbose "Application not found. Check if we should fail the build."

    if ($FailOnError) {
        Write-Verbose "Fail build"

        $ErrorActionPreference = "Stop"
        Write-Error "The application cannot be found. Check if the application exists and if you search with the right values."
    }
    else {
        Write-Verbose "Do not fail build. Just set empty values to vsts variables."

        Write-Host "##vso[task.setvariable variable=ObjectId;]"
        Write-Host "##vso[task.setvariable variable=ApplicationId;]"
        Write-Host "##vso[task.setvariable variable=Name;]"
        Write-Host "##vso[task.setvariable variable=AppIdUri;]"
        Write-Host "##vso[task.setvariable variable=ServicePrincipalObjectId;]"
    }
}
else {
    $ErrorActionPreference = "Stop"

    Write-Verbose "Found application: "
    $application

    # Return application and his service principal
    $servicePrincipal = Get-AzureRmADServicePrincipal -ServicePrincipalName $application.ApplicationId
    #this doesn't work on vsts agent
    #$servicePrincipal = Get-AzureRmADApplication -ObjectId $application.ObjectId | Get-AzureRmADServicePrincipal

    Write-Verbose "Found service principal: "
    $servicePrincipal

    Write-Host "##vso[task.setvariable variable=ObjectId;]$($application.ObjectId)"
    Write-Host "##vso[task.setvariable variable=ApplicationId;]$($application.ApplicationId)"
    Write-Host "##vso[task.setvariable variable=Name;]$($application.DisplayName)"
    Write-Host "##vso[task.setvariable variable=AppIdUri;]$($application.IdentifierUris[0])"
    Write-Host "##vso[task.setvariable variable=ServicePrincipalObjectId;]$($servicePrincipal.Id)"
}

$VerbosePreference = $oldverbose
$InformationPreference = $oldinformation