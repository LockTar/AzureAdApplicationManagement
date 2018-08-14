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
    [string]$ResourceAccessFilePath
)

$ErrorActionPreference = "Stop"

$oldverbose = $VerbosePreference
$VerbosePreference = "continue"
$oldinformation = $InformationPreference
$InformationPreference = "continue"

$application = Get-AzureRmADApplication -ObjectId $ObjectId -ErrorAction Continue

if (!$application) {
    Write-Error "Azure AD Application with ObjectId '$ObjectId' can't be found"
}
else {    
    # For local testing
    #$ResourceAccessFilePath = Join-Path -Path $PSScriptRoot -ChildPath "..\..\Test-Permissions.json"

    [System.Collections.ArrayList]$requiredResourceAccess = @()

    if ((Test-Path $ResourceAccessFilePath) -and ($ResourceAccessFilePath -Like "*.json")) {
        # Get the resources and permissions for app registration and convert into json object
        $resourceAccessInJson = Get-Content $ResourceAccessFilePath -Raw | ConvertFrom-Json
        
        # Loop through all resources and permissions
        foreach ($resourceInJson in $resourceAccessInJson) {
            $resource = New-Object -TypeName "Microsoft.Open.AzureAD.Model.RequiredResourceAccess"
            $resource.ResourceAppId = $resourceInJson.resourceAppId

            $resource.ResourceAccess = New-Object System.Collections.Generic.List[Microsoft.Open.AzureAD.Model.ResourceAccess]            
            foreach ($resourceAccessInJson in $resourceInJson.resourceAccess) {
                $resourceAccess = New-Object -TypeName "Microsoft.Open.AzureAD.Model.ResourceAccess" -ArgumentList $resourceAccessInJson.id,$resourceAccessInJson.type
                $resource.ResourceAccess.Add($resourceAccess)
            }

            $requiredResourceAccess.Add($resource)
        }
    }

    # Check if Update-AzureRmADApplication is better/newer than Set verion. See:
    # https://docs.microsoft.com/en-us/powershell/module/azurerm.resources/update-azurermadapplication?view=azurermps-6.6.0    
    Set-AzureRmADApplication `
        -ObjectId $application.ObjectId `
        -DisplayName $Name `
        -IdentifierUri $AppIdUri `
        -HomePage $HomePageUrl `
        -AvailableToOtherTenants $MultiTenant `
        -ReplyUrls $ReplyUrls

    # Following can't be done by AzureRM (yet)
    Set-AzureADApplication -ObjectId $application.ObjectId -RequiredResourceAccess $requiredResourceAccess

    $servicePrincipal = Get-AzureRmADServicePrincipal -ServicePrincipalName $application.ApplicationId
    Set-AzureRmADServicePrincipal `
        -ObjectId $servicePrincipal.Id `
        -DisplayName $Name
}

$VerbosePreference = $oldverbose
$InformationPreference = $oldinformation