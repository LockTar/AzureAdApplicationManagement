Param(
    [Parameter(Mandatory)]
    [string]$ObjectId,
    [Parameter(Mandatory)]
    [string]$Name,
    [Parameter(Mandatory)]
    [string]$AppIdUri,
    [string]$HomePageUrl,
    [string]$LogoutUrl,
    [string]$TermsOfServiceUrl,
    [string]$PrivacyStatementUrl,
    [bool]$MultiTenant,
    [string[]]$ReplyUrls,
    [string]$ResourceAccessFilePath,
    [string[]]$Owners
)

$ErrorActionPreference = "Stop"

$oldverbose = $VerbosePreference
$VerbosePreference = "continue"
$oldinformation = $InformationPreference
$InformationPreference = "continue"

Write-Verbose "Get application by ObjectId: $ObjectId"
$application = Get-AzureRmADApplication -ObjectId $ObjectId -ErrorAction Continue

if (!$application) {
    Write-Error "Azure AD Application with ObjectId '$ObjectId' can't be found"
}
else {
    Write-Information "Found application: "
    $application

    # For local testing
    #$ResourceAccessFilePath = Join-Path -Path $PSScriptRoot -ChildPath "..\..\Test-RequiredResourceAccess.json"

    [System.Collections.ArrayList]$requiredResourceAccess = @()

    if ((Test-Path $ResourceAccessFilePath) -and ($ResourceAccessFilePath -Like "*.json")) {
        Write-Verbose "Get the resources and permissions for app registration and convert into json object"
        $resourceAccessInJson = Get-Content $ResourceAccessFilePath -Raw | ConvertFrom-Json
        
        Write-Verbose "Loop through all resources and permissions"
        foreach ($resourceInJson in $resourceAccessInJson) {
            Write-Verbose "Create new 'Microsoft.Open.AzureAD.Model.RequiredResourceAccess' object and set '$($resourceInJson.resourceAppId)' as the ResourceAppId"
            $resource = New-Object -TypeName "Microsoft.Open.AzureAD.Model.RequiredResourceAccess"
            $resource.ResourceAppId = $resourceInJson.resourceAppId

            Write-Verbose "Create new 'System.Collections.Generic.List[Microsoft.Open.AzureAD.Model.ResourceAccess]' object for ResourceAccess"
            $resource.ResourceAccess = New-Object System.Collections.Generic.List[Microsoft.Open.AzureAD.Model.ResourceAccess]            
            foreach ($resourceAccessInJson in $resourceInJson.resourceAccess) {
                Write-Verbose "Create new 'Microsoft.Open.AzureAD.Model.ResourceAccess' object and set '$($resourceAccessInJson.id),$($resourceAccessInJson.type)'. Add this ResourceAccess to the list"
                $resourceAccess = New-Object -TypeName "Microsoft.Open.AzureAD.Model.ResourceAccess" -ArgumentList $resourceAccessInJson.id,$resourceAccessInJson.type
                $resource.ResourceAccess.Add($resourceAccess)
            }

            $requiredResourceAccess.Add($resource)
        }

        Write-Verbose "All resources with permissions are created and ready to set to the application"
    }

    Write-Verbose "Set application properties"
    # Check if Update-AzureRmADApplication is better/newer than Set verion. See:
    # https://docs.microsoft.com/en-us/powershell/module/azurerm.resources/update-azurermadapplication?view=azurermps-6.6.0    
    Set-AzureRmADApplication `
        -ObjectId $application.ObjectId `
        -DisplayName $Name `
        -IdentifierUri $AppIdUri `
        -HomePage $HomePageUrl `
        -AvailableToOtherTenants $MultiTenant `
        -ReplyUrls $ReplyUrls

    Write-Verbose "Set required resource access to application: "
    # Following can't be done by AzureRM (yet)
    Set-AzureADApplication -ObjectId $application.ObjectId -RequiredResourceAccess $requiredResourceAccess

    Write-Verbose "Set service principal properties"
    $servicePrincipal = Get-AzureRmADServicePrincipal -ServicePrincipalName $application.ApplicationId

    Write-Information "Found service principal: "
    $servicePrincipal

    Set-AzureRmADServicePrincipal `
        -ObjectId $servicePrincipal.Id `
        -DisplayName $Name

    # Add owners to the application
    Write-Verbose "Set owners of the application. Current owners are:"
    $currentOwners = Get-AzureADApplicationOwner -ObjectId $application.ObjectId -All $True
    $currentOwners | Select-Object ObjectId, DisplayName, UserPrincipalName | Format-Table

    # Add missing owners
    foreach ($owner in $Owners) {
        if ($($currentOwners.ObjectId).Contains($owner) -eq $false) {
            Write-Verbose "Add applicationowner $owner"
            Add-AzureADApplicationOwner -ObjectId $application.ObjectId -RefObjectId $owner
        }
        else {
            Write-Verbose "Don't add $owner as owner because is already owner"
        }
    }

    # Remove owners that should not be owner anymore
    foreach ($currentOwner in $currentOwners.ObjectId) {
        if ($Owners.Contains($currentOwner) -eq $false) {
            Write-Verbose "Remove applicationowner $currentOwner"
            Remove-AzureADApplicationOwner -ObjectId $application.ObjectId -OwnerId $currentOwner
        }
        else {
            Write-Verbose "Don't remove owner $currentOwner because must stay owner"
        }
    }

    Write-Information "Owners of the application are now:"
    $currentOwners = Get-AzureADApplicationOwner -ObjectId $application.ObjectId -All $True
    $currentOwners | Select-Object ObjectId, DisplayName, UserPrincipalName | Format-Table

    Write-Host "##vso[task.setvariable variable=ObjectId;]$($application.ObjectId)"
    Write-Host "##vso[task.setvariable variable=ApplicationId;]$($application.ApplicationId)"
    Write-Host "##vso[task.setvariable variable=Name;]$($application.DisplayName)"
    Write-Host "##vso[task.setvariable variable=AppIdUri;]$($application.IdentifierUris[0])"
    Write-Host "##vso[task.setvariable variable=HomePageUrl;]$($application.HomePage)"
    Write-Host "##vso[task.setvariable variable=ServicePrincipalObjectId;]$($servicePrincipal.Id)"
}

$VerbosePreference = $oldverbose
$InformationPreference = $oldinformation