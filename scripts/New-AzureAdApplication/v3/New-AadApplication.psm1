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
        [Parameter(Mandatory)]
        [string]$SignOnUrl,
        [string]$IdentifierUri
    )

    $ErrorActionPreference = "Stop"

    $oldverbose = $VerbosePreference
    $VerbosePreference = "continue"
    $oldinformation = $InformationPreference
    $InformationPreference = "continue"

    Write-Verbose "Check if IdentifierUri is given"
    if ($null -eq $IdentifierUri -or $IdentifierUri -eq "") {
        Write-Verbose "No IdentifierUri so generate one with format: https://{ApplicationName}"        
        $IdentifierUri = "https://$ApplicationName"
        Write-Verbose "Generated IdentifierUri: $IdentifierUri"
    }
    else {
        Write-Verbose "Use given IdentifierUri: $IdentifierUri"
    }

    Write-Verbose "Create application $ApplicationName"
    $applicationCreated = New-AzADApplication `
        -DisplayName $ApplicationName `
        -HomePage $SignOnUrl `
        -IdentifierUris $($IdentifierUri) `
        -ReplyUrls $($SignOnUrl)

    $delayInSeconds = 10
    $numberOfRetries = 10
    $retryCount = 0
    $completed = $false
    $servicePrincipal = $null

    while (-not $completed) {
        try {
            Write-Verbose "Create service principal connected to application"
            $servicePrincipal = Get-AzADApplication -ObjectId $applicationCreated.ObjectId | New-AzADServicePrincipal

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

    $application = $applicationCreated
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