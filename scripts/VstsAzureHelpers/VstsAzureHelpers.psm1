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

function Initialize-PackageProvider {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$Name = "NuGet"
    )

    Write-Verbose "Initialize package provider $Name"
    $packageProvider = Get-PackageProvider -Name $Name -ListAvailable
    
    if($packageProvider)
    {
        Write-Verbose "Package provider $Name with version $($packageProvider.Version) already installed"
    }
    else
    {     
        Write-Verbose "Install package provider $Name"
        Find-PackageProvider -Name $Name | Install-PackageProvider -Verbose -Scope CurrentUser -Force
    }
}

function Initialize-Package {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,
        [Parameter()]
        [string]$RequiredVersion
    )

    Write-Verbose "Initialize package $Name"
    $package = Get-Package -Name $Name -RequiredVersion $RequiredVersion -ErrorAction SilentlyContinue

    if($package)
    {
        Write-Verbose "Package $Name with version $($package.Version) already installed"
    }
    else
    {        
        if($RequiredVersion)
        {
            Write-Verbose "Install package $Name with version $RequiredVersion"
            Find-Package $Name -RequiredVersion $RequiredVersion | Install-Package -Scope CurrentUser -Force
        }
        else
        {
            Write-Verbose "Install package $Name"
            Find-Package $Name | Install-Package -Scope CurrentUser -Force
        }
    }
}

# Export only the public function.
Export-ModuleMember -Function Initialize-Azure, Initialize-PackageProvider, Initialize-Package