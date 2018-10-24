# Private module-scope variables.
$script:azureModule = $null
$script:azureRMProfileModule = $null

# Override the DebugPreference.
if ($global:DebugPreference -eq 'Continue') {
    Write-Verbose '$OVERRIDING $global:DebugPreference from ''Continue'' to ''SilentlyContinue''.'
    $global:DebugPreference = 'SilentlyContinue'
}

function Get-AzureAdApplication {
    [CmdletBinding()]
    Param(
        [string]$ObjectId,
        [string]$ApplicationId,
        [string]$ApplicationName,
        [bool]$FailIfNotFound = $false
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

        if ($FailIfNotFound) {
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
            Write-Host "##vso[task.setvariable variable=HomePageUrl;]"
            Write-Host "##vso[task.setvariable variable=ServicePrincipalObjectId;]"
        }
    }
    else {
        $ErrorActionPreference = "Stop"

        Write-Information "Found application: $($application.ObjectId)"
        $application

        # Return application and his service principal    
        $servicePrincipal = Get-AzureRmADApplication -ObjectId $application.ObjectId | Get-AzureRmADServicePrincipal
        
        Write-Information "Found service principal: $($servicePrincipal.Id)"
        $servicePrincipal

        Write-Host "##vso[task.setvariable variable=ObjectId;]$($application.ObjectId)"
        Write-Host "##vso[task.setvariable variable=ApplicationId;]$($application.ApplicationId)"
        Write-Host "##vso[task.setvariable variable=Name;]$($application.DisplayName)"
        Write-Host "##vso[task.setvariable variable=AppIdUri;]$($application.IdentifierUris[0])"
        Write-Host "##vso[task.setvariable variable=HomePageUrl;]$($application.HomePage)"
        Write-Host "##vso[task.setvariable variable=ServicePrincipalObjectId;]$($servicePrincipal.Id)"
    }

    $result = [PSCustomObject]@{
        Application = $application
        ServicePrincipal = $servicePrincipal
    }

    return $result

    $VerbosePreference = $oldverbose
    $InformationPreference = $oldinformation
}

# Export only the public function.
Export-ModuleMember -Function Get-AzureAdApplication