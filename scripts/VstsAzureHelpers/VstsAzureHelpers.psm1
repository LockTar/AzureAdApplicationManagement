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
        Write-Information "Install package provider $Name"
        Find-PackageProvider -Name $Name | Install-PackageProvider -Verbose -Scope CurrentUser -Force
    }
}

function Initialize-Module {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,
        [Parameter()]
        [string]$RequiredVersion
    )

    Write-Verbose "Initialize module $Name"
    $modulePath = 'c:\temp\ps_modules'

    Write-Verbose "Add PowerShell modules path the PSModulePath Environment variable"
    if (!(Test-Path -Path $modulePath)) {
        New-Item -Path $modulePath -ItemType Directory
    }
    $env:PSModulePath = $env:PSModulePath + ';' + $modulePath
    
    Write-Verbose "Check if Module with correct version is available on system"
    Get-Module -Name $Name -ListAvailable | Where-Object {$_.Version -eq $RequiredVersion} -OutVariable module
    #$module = Get-Module -Name $Name -RequiredVersion $RequiredVersion -ErrorAction SilentlyContinue

    if($module)
    {
        Write-Verbose "Module $Name with version $($module.Version) already installed"
    }
    else
    {        
        if($RequiredVersion)
        {
            Write-Information "Install module $Name with version $RequiredVersion"
            Find-Module -Name  $Name -RequiredVersion $RequiredVersion | Save-Module -Path $modulePath

            #Find-Module $Name -RequiredVersion $RequiredVersion | Install-Module -Scope CurrentUser -Force
        }
        else
        {
            Write-Information "Install module $Name"
            Find-Module -Name  $Name | Save-Module -Path $modulePath

            #Find-Module $Name | Install-Module -Scope CurrentUser -Force
        }
    }
}

# Export only the public function.
Export-ModuleMember -Function Initialize-Azure, Initialize-PackageProvider, Initialize-Module