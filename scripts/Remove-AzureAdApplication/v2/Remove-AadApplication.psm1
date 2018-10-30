# Private module-scope variables.
$script:azureModule = $null
$script:azureRMProfileModule = $null

# Override the DebugPreference.
if ($global:DebugPreference -eq 'Continue') {
    Write-Verbose '$OVERRIDING $global:DebugPreference from ''Continue'' to ''SilentlyContinue''.'
    $global:DebugPreference = 'SilentlyContinue'
}

function Remove-AzureAdApplication {
    [CmdletBinding()]
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
        $applicationId = $application.ApplicationId

        $servicePrincipal = Get-AzureRmADServicePrincipal -ApplicationId $applicationId
        Write-Verbose "Found service principal: "
        $servicePrincipal

        Write-Verbose "Removing application: $($application.ObjectId)"
        Remove-AzureRmADApplication -ObjectId $application.ObjectId -Force

        Write-Verbose "Wait 15 seconds until application removal is done in AD"
        Start-Sleep -Seconds 15

        Write-Verbose "Check if we find the service principal that was connected to the application or that it is removed with the application directly"
        $servicePrincipal = Get-AzureRmADServicePrincipal -ApplicationId $applicationId
    
        if ($servicePrincipal.Id) {
            Write-Verbose "Removing Service Principal connected to Application: $($servicePrincipal.Id)"
            Remove-AzureRmADServicePrincipal -ObjectId $servicePrincipal.Id -Force    
        }
        else {
            Write-Verbose "Not removing Service Principal connected to Application because there is none or is already removed"
        }
    }
    else {
        Write-Verbose "No application found to remove"
    }

    $VerbosePreference = $oldverbose
    $InformationPreference = $oldinformation
}

# Export only the public function.
Export-ModuleMember -Function Remove-AzureAdApplication