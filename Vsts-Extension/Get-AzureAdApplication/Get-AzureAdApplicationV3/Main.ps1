Trace-VstsEnteringInvocation $MyInvocation

# Get inputs.
$method = Get-VstsInput -Name method
$objectId = Get-VstsInput -Name objectId
$applicationId = Get-VstsInput -Name applicationId
$name = Get-VstsInput -Name name
$failIfNotFound = Get-VstsInput -Name failIfNotFound -AsBool

# Initialize Azure Connection
#Import-Module $PSScriptRoot\ps_modules\VstsAzureHelpers\VstsAzureHelpers.psm1
#Initialize-PackageProvider
#Initialize-Module -Name "Az" -RequiredVersion "5.0.0"
#Initialize-AzureAz

# Mock values like you would get from task.json like https://github.com/microsoft/azure-pipelines-tasks/blob/master/Tasks/AzurePowerShellV5/AzurePowerShell.ps1
$targetAzurePs = "OtherVersion" 
$customTargetAzurePs = "5.0.0" # This is the version of the Azure Az PowerShell module

# string constants
$otherVersion = "OtherVersion"
$latestVersion = "LatestVersion"

if ($targetAzurePs -eq $otherVersion) {
    if ($customTargetAzurePs -eq $null) {
        throw (Get-VstsLocString -Key InvalidAzurePsVersion $customTargetAzurePs)
    } else {
        $targetAzurePs = $customTargetAzurePs.Trim()
    }
}

$pattern = "^[0-9]+\.[0-9]+\.[0-9]+$"
$regex = New-Object -TypeName System.Text.RegularExpressions.Regex -ArgumentList $pattern

if ($targetAzurePs -eq $latestVersion) {
    $targetAzurePs = ""
} elseif (-not($regex.IsMatch($targetAzurePs))) {
    throw (Get-VstsLocString -Key InvalidAzurePsVersion -ArgumentList $targetAzurePs)
}

# Initialize Azure.
Import-Module $PSScriptRoot\ps_modules\VstsAzureHelpers_

$connectedServiceName = Get-VstsInput -Name ConnectedServiceNameARM -Require
$endpoint = Get-VstsEndpoint -Name $connectedServiceName -Require
Initialize-AzModule -Endpoint $endpoint


#. "$PSScriptRoot\Utility.ps1"

# $serviceName = Get-VstsInput -Name ConnectedServiceNameARM -Require
# $endpointObject = Get-VstsEndpoint -Name $serviceName -Require
# $endpoint = ConvertTo-Json $endpointObject

try 
{
#     $CoreAzArgument = $null;
#     if ($targetAzurePs) {
#         $CoreAzArgument = "-endpoint '$endpoint' -targetAzurePs $targetAzurePs"
#     } else {
#         $CoreAzArgument = "-endpoint '$endpoint'"
#     }

#     Write-Host "CoreAzArgument: " $CoreAzArgument
#     #$contents += ". $PSScriptRoot\CoreAz.ps1 $CoreAzArgument"
#     . $PSScriptRoot\CoreAz.ps1 $CoreAzArgument





    
    Write-Verbose "Input variables are: "
    Write-Verbose "method: $method"
    Write-Verbose "objectId: $objectId"
    Write-Verbose "applicationId: $applicationId"
    Write-Verbose "name: $name"
    Write-Verbose "failIfNotFound: $failIfNotFound"

    Import-Module $PSScriptRoot\scripts\Get-AadApplication.psm1

    switch ($method)
    {
        "objectid"
        {
            Write-Verbose "Get application by ObjectId"        
            $null = Get-AadApplication -ObjectId $objectId -FailIfNotFound $failIfNotFound
        }
        "applicationid"
        {
            Write-Verbose "Get application by ApplicationId"
            $null = Get-AadApplication -ApplicationId $applicationId -FailIfNotFound $failIfNotFound
        }  
        "name"
        {
            Write-Verbose "Get application by Name"
            $null = Get-AadApplication -ApplicationName $name -FailIfNotFound $failIfNotFound
        }
        default {
            Write-Error "Unknow method '$method'"
        }
    }
}
finally {
    if ($__vstsAzPSInlineScriptPath -and (Test-Path -LiteralPath $__vstsAzPSInlineScriptPath) ) {
        Remove-Item -LiteralPath $__vstsAzPSInlineScriptPath -ErrorAction 'SilentlyContinue'
    }

    Import-Module $PSScriptRoot\ps_modules\VstsAzureHelpers_
    Remove-EndpointSecrets
    Disconnect-AzureAndClearContext -ErrorAction SilentlyContinue
}