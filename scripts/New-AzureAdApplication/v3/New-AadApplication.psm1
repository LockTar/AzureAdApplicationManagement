# # Private module-scope variables.
# $script:azureModule = $null
# $script:azureRMProfileModule = $null

# # Override the DebugPreference.
# if ($global:DebugPreference -eq 'Continue') {
#     Write-Verbose '$OVERRIDING $global:DebugPreference from ''Continue'' to ''SilentlyContinue''.'
#     $global:DebugPreference = 'SilentlyContinue'
# }

function New-AadApplication {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [string]$ApplicationName,
        [string]$HomePageUrl,
        [string]$IdentifierUri
    )

    $ErrorActionPreference = "Stop"

    $oldverbose = $VerbosePreference
    $VerbosePreference = "continue"
    $oldinformation = $InformationPreference
    $InformationPreference = "continue"

    $IdentifierUriFromTask = $false
    Write-Verbose "Check if IdentifierUri is given"
    if ($null -eq $IdentifierUri -or $IdentifierUri -eq "") {
        Write-Verbose "No IdentifierUri so generate one with format: https://{ApplicationName}"        
        $IdentifierUri = "https://$ApplicationName"
        $IdentifierUriFromTask = $false
        Write-Verbose "Generated IdentifierUri: $IdentifierUri"
    }
    else {
        Write-Verbose "Use given IdentifierUri: $IdentifierUri"
        $IdentifierUriFromTask = $true
    }

    Write-Verbose "Create application $ApplicationName"
    if ($null -eq $HomePageUrl -or $HomePageUrl -eq "") {
        $application = New-AzADApplication `
            -DisplayName $ApplicationName `
            -IdentifierUris $($IdentifierUri)
    }
    else {
        $application = New-AzADApplication `
            -DisplayName $ApplicationName `
            -HomePage $HomePageUrl `
            -IdentifierUris $($IdentifierUri)
    }

    if ($IdentifierUriFromTask -eq $false) {
        # The IdentifierUri was not given in the task so create the new default identifieruri. This can only be done with the ApplicationId so use it from the 'New' action.
        Write-Verbose "Change IdentifierUri to the new default format of Microsoft: api://{ApplicationId}"
        $IdentifierUri = "api://$($application.ApplicationId)"
        $application = Update-AzADApplication `
            -IdentifierUris $($IdentifierUri)
    }

    $delayInSeconds = 10
    $numberOfRetries = 10
    $retryCount = 0
    $completed = $false
    $servicePrincipal = $null

    while (-not $completed) {
        try {
            Write-Verbose "Create service principal connected to application"
            $servicePrincipal = Get-AzADApplication -ObjectId $application.ObjectId | New-AzADServicePrincipal
            
            $completed = $true
        }
        catch {
            if ($retrycount -ge $numberOfRetries) {
                Write-Error "Tried $numberOfRetries times but still no result"
                throw
            }
            else {
                Write-Verbose "Wait $delayInSeconds seconds before trying again"
                Start-Sleep $delayInSeconds
                $retrycount++    
            }
        }
    }
    
    Get-AzADApplication -ObjectId $application.ObjectId

    Write-Verbose "Created application: "
    $application

    Write-Verbose "Created service principal: "
    $servicePrincipal

    Write-Host "##vso[task.setvariable variable=ObjectId;]$($application.ObjectId)"
    Write-Host "##vso[task.setvariable variable=ApplicationId;]$($application.ApplicationId)"
    Write-Host "##vso[task.setvariable variable=Name;]$($application.DisplayName)"
    Write-Host "##vso[task.setvariable variable=AppIdUri;]$($application.IdentifierUris[0])"
    Write-Host "##vso[task.setvariable variable=HomePageUrl;]$($application.HomePage)"
    Write-Host "##vso[task.setvariable variable=ServicePrincipalObjectId;]$($servicePrincipal.Id)"

    $VerbosePreference = $oldverbose
    $InformationPreference = $oldinformation
}

# Export only the public function.
Export-ModuleMember -Function New-AadApplication