
function New-AadApplication {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [ValidateNotNullOrEmpty()]
        [string]$DisplayName
    )

    Write-Verbose -Message "Create new application $DisplayName"
        
    $app = New-AzADApplication -DisplayName $DisplayName -IdentifierUris @("api://$DisplayName", "https://$DisplayName")

    Write-Information "Created application with name $DisplayName under ObjectId $($app.ObjectId) and ApplicationId $($app.ApplicationId)"
    $app
}

function Get-AadApplication {

    [CmdletBinding(DefaultParameterSetName = "ObjectId")]
    param (
        [ValidateNotNullOrEmpty()]
        [Parameter(Position = 0, ParameterSetName = "ObjectId", Mandatory = $true)]
        [string]$ObjectId,
        [ValidateNotNullOrEmpty()]
        [Parameter(ParameterSetName = "ApplicationId", Mandatory = $true)]
        [string]$ApplicationId,
        [ValidateNotNullOrEmpty()]
        [Parameter(ParameterSetName = "DisplayName", Mandatory = $true)]
        [string]$DisplayName,
        
        [switch]$FailIfNotFound
    )

    Write-Verbose "Get application by $($PSCmdlet.ParameterSetName)"
    
    switch ($PSCmdlet.ParameterSetName) {
        "ObjectId" { 
            Write-Verbose "Get application $ObjectId"
            $app = Get-AzADApplication -ObjectId $ObjectId -ErrorAction SilentlyContinue
        } 
        "ApplicationId" { 
            Write-Verbose "Get application $ApplicationId"
            $app = Get-AzADApplication -ApplicationId $ApplicationId -ErrorAction SilentlyContinue
        }
        "DisplayName" { 
            Write-Verbose "Get application $DisplayName"
            $app = Get-AzADApplication -DisplayName $DisplayName -ErrorAction SilentlyContinue
        }
        Default {
            throw "Unknown ParameterSetName"
        }
    }    

    if ($null -eq $app) {
        $message = "The application cannot be found. Check if the application exists and if you search with the right values."
        if ($FailIfNotFound) {
            throw [Microsoft.PowerShell.Commands.NotFoundException]$message
        }
        else {
            Write-Information $message
        }
    }
    else {
        Write-Information "Found application with name $DisplayName under ObjectId $($app.ObjectId) and ApplicationId $($app.ApplicationId)"
        $sp = Get-AzADApplication -ObjectId $app.ObjectId | Get-AzADServicePrincipal
        
        Write-Host "##vso[task.setvariable variable=ObjectId;]$($app.ObjectId)"
        Write-Host "##vso[task.setvariable variable=ApplicationId;]$($app.ApplicationId)"
        Write-Host "##vso[task.setvariable variable=Name;]$($app.DisplayName)"
        Write-Host "##vso[task.setvariable variable=AppIdUri;]$($app.IdentifierUris[0])"
        Write-Host "##vso[task.setvariable variable=HomePageUrl;]$($app.HomePage)"
        Write-Host "##vso[task.setvariable variable=ServicePrincipalObjectId;]$($sp.Id)"
                                
        $result = [PSCustomObject]@{
            Application      = $app
            ServicePrincipal = $sp
        }
                        
        $result
    }
}

function Remove-AadApplication {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [ValidateNotNullOrEmpty()]
        [string]$ObjectId
    )

    Write-Verbose -Message "Remove application with objectid $ObjectId"
        
    $app = Get-AzADApplication -ObjectId $ObjectId
    $displayName = $app.DisplayName

    if ($null -eq $app) {
        Write-Information "No application found to remove with name $displayName"
    }
    else {
        Write-Verbose "Found application to remove with name $displayName under ObjectId $($app.ObjectId) and ApplicationId $($app.ApplicationId)"
        Remove-AzADApplication -ObjectId $ObjectId -Force
        Write-Information "Removed application $displayName"
    }
}

Export-ModuleMember -Function New-AadApplication, Get-AadApplication, Remove-AadApplication