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

function Initialize-AzureRM {
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

    Write-Verbose "Create custom PowerShell modules path '$modulePath' if not exist"
    if (!(Test-Path -Path $modulePath)) {
        New-Item -Path $modulePath -ItemType Directory
    }

    Write-Verbose "Add custom PowerShell modules path to the PSModulePath Environment variable"
    if(!$env:PSModulePath.Contains($modulePath))
    {
        $env:PSModulePath = $modulePath + ';' + $env:PSModulePath
    }

    #Write-Verbose "Show files in $modulePath"
    #Get-ChildItem -Path $modulePath
    
    Write-Verbose "Check if Module with correct version $RequiredVersion is available on system"
    $module = Get-Module -Name $Name -ListAvailable | Where-Object {$_.Version -eq $RequiredVersion}

    if($module)
    {
        Write-Verbose ('Module {0} with version {1} already installed' -f  $module.Name, $module.Version)
    }
    else
    {        
        if($RequiredVersion)
        {
            Write-Information "Install module $Name with version $RequiredVersion"
            Find-Module -Name  $Name -RequiredVersion $RequiredVersion | Save-Module -Path $modulePath
        }
        else
        {
            Write-Information "Install module $Name"
            Find-Module -Name  $Name | Save-Module -Path $modulePath
        }
    }
}

# Export only the public function.
Export-ModuleMember -Function Initialize-AzureRM, Initialize-PackageProvider, Initialize-Module