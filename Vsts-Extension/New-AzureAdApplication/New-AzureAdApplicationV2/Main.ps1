Trace-VstsEnteringInvocation $MyInvocation

# Get inputs.
$name = Get-VstsInput -Name name -Require
$signOnUrl = Get-VstsInput -Name signOnUrl -Require
$appIdUri = Get-VstsInput -Name appIdUri

# Initialize Azure Connection
Import-Module $PSScriptRoot\ps_modules\VstsAzureHelpers\VstsAzureHelpers.psm1
Initialize-PackageProvider
Initialize-Module -Name "AzureRM.Resources" -RequiredVersion "6.7.0"
Initialize-AzureRM

Write-Verbose "Input variables are: "
Write-Verbose "name: $name"
Write-Verbose "signOnUrl: $signOnUrl"
Write-Verbose "appIdUri: $appIdUri"

Import-Module $PSScriptRoot\scripts\New-AadApplication.psm1

New-AadApplication `
    -ApplicationName $name `
    -SignOnUrl $signOnUrl `
    -IdentifierUri $appIdUri