Trace-VstsEnteringInvocation $MyInvocation

# Get inputs.
$name = Get-VstsInput -Name name -Require
$signOnUrl = Get-VstsInput -Name signOnUrl -Require
$appIdUri = Get-VstsInput -Name appIdUri

# Initialize Azure Connection.
Import-Module $PSScriptRoot\ps_modules\AzureRM
Import-Module $PSScriptRoot\VstsAzureHelpers
Initialize-Azure

Write-Verbose "Input variables are: "
Write-Verbose "name: $name"
Write-Verbose "signOnUrl: $signOnUrl"
Write-Verbose "appIdUri: $appIdUri"

.\scripts\New-AzureAdApplication.ps1 `
    -ApplicationName $name `
    -SignOnUrl $signOnUrl `
    -IdentifierUri $appIdUri