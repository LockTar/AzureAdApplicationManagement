Trace-VstsEnteringInvocation $MyInvocation

# Get inputs.
$name = Get-VstsInput -Name name
$signOnUrl = Get-VstsInput -Name signOnUrl

# Initialize Azure Connection.
Write-Verbose "Import module VstsAzureHelpers" 
Import-Module $PSScriptRoot\ps_modules\VstsAzureHelpers_
Initialize-Azure -strict

Write-Verbose "Input variables are: "
Write-Verbose "name: $name"
Write-Verbose "signOnUrl: $signOnUrl"

.\scripts\New-AzureAdApplication.ps1 -ApplicationName $name -SignOnUrl $signOnUrl