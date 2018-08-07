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
    [bool]$MultiTenant
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

Set-AzureRmADApplication `
    -ObjectId $application.ObjectId `
    -DisplayName $Name `
    -IdentifierUri = $AppIdUri `
    -HomePage $HomePageUrl `
    -AvailableToOtherTenants $MultiTenant

$VerbosePreference = $oldverbose
$InformationPreference = $oldinformation