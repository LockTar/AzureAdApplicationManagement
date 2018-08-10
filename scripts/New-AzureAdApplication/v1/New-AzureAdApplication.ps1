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
    Write-Verbose "No IdentifierUri so generate one with format: http://{TenantId}/{ApplicationName}"
    Write-Verbose "Get context of account"
    $context = Get-AzureRmContext
    $context
    $IdentifierUri = "https://$($context.Account.Tenants[0])/$ApplicationName"
    Write-Verbose "Generated IdentifierUri: $IdentifierUri"
}
else {
    Write-Verbose "Use given IdentifierUri: $IdentifierUri"
}

Write-Verbose "Create application"
$applicationCreated = New-AzureRmADApplication `
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
        $servicePrincipal = Get-AzureRmADApplication -ObjectId $applicationCreated.ObjectId | New-AzureRmADServicePrincipal

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

$delayInSeconds = 10
$numberOfRetries = 10
$retryCount = 0
$completed = $false
$application = $null
$servicePrincipal = $null

while (-not $completed) {
    Write-Verbose "Return application and his service principal"
    $application = Get-AzureRmADApplication -ObjectId $applicationCreated.ObjectId
    $servicePrincipal = Get-AzureRmADServicePrincipal -ApplicationId $applicationCreated.ApplicationId

    if ($null -eq $application -or $null -eq $servicePrincipal) {
        if ($retrycount -ge $numberOfRetries) {
            Write-Error "Retried $numberOfRetries times but still no result"
        }
        else {
            Write-Verbose "Wait $delayInSeconds seconds before trying again"
            Start-Sleep $delayInSeconds
            $retrycount++    
        }            
    }   
    else {
        $completed = $true
    }     
}

$application
$servicePrincipal

Write-Host "##vso[task.setvariable variable=ObjectId;]$($application.ObjectId)"
Write-Host "##vso[task.setvariable variable=ApplicationId;]$($application.ApplicationId)"
Write-Host "##vso[task.setvariable variable=Name;]$($application.DisplayName)"
Write-Host "##vso[task.setvariable variable=ServicePrincipalObjectId;]$($servicePrincipal.Id)"

$VerbosePreference = $oldverbose
$InformationPreference = $oldinformation