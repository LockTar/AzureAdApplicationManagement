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
        Initialize-AzureSubscriptionRM -Endpoint $endpoint
    }
    finally {
        Trace-VstsLeavingInvocation $MyInvocation
    }
}

function Initialize-AzureAD {
    [CmdletBinding()]
    param()
    Trace-VstsEnteringInvocation $MyInvocation
    try {
        $serviceName = Get-VstsInput -Name ConnectedServiceNameARM -Require

        Write-Verbose "Get endpoint $serviceName"
        $endpoint = Get-VstsEndpoint -Name $serviceName -Require

        # Import/initialize the Azure module.
        Initialize-AzureSubscriptionAD -Endpoint $endpoint
    }
    finally {
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
    
    if ($packageProvider) {
        Write-Verbose "Package provider $Name with version $($packageProvider.Version) already installed"
    }
    else {     
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
    $modulePath = 'c:\ps_modules'

    Write-Verbose "Create custom PowerShell modules path '$modulePath' if not exist"
    if (!(Test-Path -Path $modulePath)) {
        New-Item -Path $modulePath -ItemType Directory
    }

    # Check if AzureRM module is locally available via an already downloaded version on the system drive (hosted microsoft agents)
    $targetAzureRmVersion = Get-AzureRMVersion -AzureRMModuleName $Name -RequiredVersion $RequiredVersion
    $installedAzureRmVersions = "2.1.0","3.8.0","4.2.1","5.1.1","6.7.0"
    $hostedAgentAzureRMDownloadPath = ('c:\Modules\AzureRM_{0}' -f $targetAzureRmVersion)
        
    if ($installedAzureRmVersions.Contains($targetAzureRmVersion) -and (Test-Path -Path $hostedAgentAzureRMDownloadPath)) {
        Write-Verbose -Message ('Module {0} with Version {1} is locally available in AzureRM version {2}' -f $Name, $RequiredVersion, $targetAzureRmVersion)
        Write-Verbose "Add local AzureRM PowerShell modules path to the PSModulePath Environment variable"
        $modulePath = $hostedAgentAzureRMDownloadPath
        if (!$env:PSModulePath.Contains($modulePath)) {
            $env:PSModulePath = $modulePath + ';' + $env:PSModulePath
        }

        Write-Verbose "Check if Module with correct version $RequiredVersion is available on system"
        $module = Get-Module -Name $Name -ListAvailable | Where-Object {$_.Version -eq $RequiredVersion -and $_.Name -eq $_.Name}
        if (!($module)) {
            Write-Error -Message ('Module {0} with Version {1} is NOT locally available' -f $Name, $RequiredVersion)
        }
        else {
            # List all the locations where the Module version is located.
            $module | ForEach-Object {
                Write-Verbose -Message ('Module {0} with Version {1} is locally available in folder {2}' -f $Name, $RequiredVersion, $_.ModuleBase)
            }
        }
    }
    else {
        Write-Verbose "Add custom PowerShell modules path to the PSModulePath Environment variable"
        if (!$env:PSModulePath.Contains($modulePath)) {
            $env:PSModulePath = $modulePath + ';' + $env:PSModulePath
        }
    
        Write-Verbose -Message  ('Check if Module {0} with correct version {1} is available on system' -f $Name, $RequiredVersion)
        $module = Get-Module -Name $Name -ListAvailable | Where-Object {$_.Version -eq $RequiredVersion} #Rema

        if ($module) {
            Write-Verbose ('Module {0} with version {1} already installed' -f $module.Name, $module.Version)
        }
        else {        
            if ($RequiredVersion) {
                Write-Information "Install module $Name with version $RequiredVersion"
                Find-Module -Name  $Name -RequiredVersion $RequiredVersion | Save-Module -Path $modulePath
            }
            else {
                Write-Information "Install module $Name"
                Find-Module -Name  $Name | Save-Module -Path $modulePath
            }
        }
    }
}

<#
.Synopsis
   Retrieve AzureRM PowerShell version containing AzureRM Powershell module.
.DESCRIPTION
   Retrieve AzureRM PowerShell version containing AzureRM Powershell module with required version from PowerShell Gallery.
.EXAMPLE
   Get-AzureRMVersion -AzureRMModuleName 'AzureRM.ApplicationInsights' -RequiredVersion '0.1.8'
   6.11.0
.INPUTS
   AzureRMModuleName. AzureRM PowerShell Module Name.
.INPUTS
   RequiredVersion. AzureRM PowerShell Module Version.
.OUTPUTS
   AzureRM (Meta) PowerShell Module Version.
#>
function Get-AzureRMVersion {
    [CmdletBinding()]
    [OutputType([string])]
    Param
    (
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        [string]$AzureRMModuleName,

        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 1)]
        [string]
        $RequiredVersion
    )

    #region check AzureRm PowerShell module version for specific Module.
    Write-Verbose -Message ('Retrieve all AzureRM module versions from PSGallery')
    $AllAzureRMModules = Find-Module -Name AzureRM -AllVersions
    Write-Verbose -Message ('{0} AzureRM Module versions retrieve from the PSGallery' -f $AllAzureRMModules.count)
    #endregion

    #region get AzureRM PowerShell module version container the specified AzureRM.[name] Module version
    Write-Verbose -Message ('Find Module {0} with version {1} in AzureRM Module versions' -f $($AzureRMModuleName), $($RequiredVersion))
    foreach ($AzureRMModule in $AllAzureRMModules) {
        Write-Verbose -Message ('Checking AzureRM Module version {0} for Module {1} with version {2}' -f $($AzureRMModule.Version), $($AzureRMModuleName), $($RequiredVersion))
        if ($AzureRMModule.dependencies | Where-Object {($_.Name -eq $($AzureRMModuleName) -and $_.RequiredVersion -eq $RequiredVersion) }) {
            $AzureRMModuleVersion = $AzureRMModule.Version
            Write-Verbose -Message ('Found AzureRM Module with version {0} for Module {1} with version {2}' -f $($AzureRMModule.Version), $($AzureRMModuleName), $($RequiredVersion))
            return $AzureRMModuleVersion
        }
    }
    if (!($AzureRMModuleVersion)) {
        Write-Error -Message ('No AzureRM Module version found which contains Module {0} with version {1}' -f $($AzureRMModuleName), $($RequiredVersion))
    }
    #endregion
}

# Export only the public function.
Export-ModuleMember -Function Initialize-AzureRM, Initialize-AzureAD, Initialize-PackageProvider, Initialize-Module, Get-AzureRMVersion