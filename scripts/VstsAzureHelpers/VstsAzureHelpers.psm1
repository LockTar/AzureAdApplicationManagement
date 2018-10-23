# Private module-scope variables.
$script:azureModule = $null
$script:azureRMProfileModule = $null

# Override the DebugPreference.
if ($global:DebugPreference -eq 'Continue') {
    Write-Verbose '$OVERRIDING $global:DebugPreference from ''Continue'' to ''SilentlyContinue''.'
    $global:DebugPreference = 'SilentlyContinue'
}

# Dot source the private functions.
. $PSScriptRoot/InitializeFunctions.ps1

function Initialize-Azure {
    [CmdletBinding()]
    param()
    Trace-VstsEnteringInvocation $MyInvocation
    try {
        $serviceName = Get-VstsInput -Name ConnectedServiceNameARM -Require

        Write-Verbose "Get endpoint $serviceName"
        $endpoint = Get-VstsEndpoint -Name $serviceName -Require

        # Import/initialize the Azure module.
        Initialize-AzureSubscription -Endpoint $endpoint
    } finally {
        Trace-VstsLeavingInvocation $MyInvocation
    }
}

# Export only the public function.
Export-ModuleMember -Function Initialize-Azure