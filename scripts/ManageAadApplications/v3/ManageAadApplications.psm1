
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

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [ValidateNotNullOrEmpty()]
        [string]$DisplayName
    )

    Write-Verbose -Message "Get application $DisplayName"
        
    $app = Get-AzADApplication -DisplayName $DisplayName

    if ($null -eq $app) {
        Write-Information "No application found with name $DisplayName"
    }
    else {
        Write-Information "Found application with name $DisplayName under ObjectId $($app.ObjectId) and ApplicationId $($app.ApplicationId)"
        $app
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

function Test-AadApplication {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [ValidateNotNullOrEmpty()]
        [string]$DisplayName
    )

    Write-Verbose -Message "Test, new, get, remove application $DisplayName"
        
    $app = Get-AadApplication -DisplayName $DisplayName
    if (!$app) {
        Write-Verbose "No application found. Create one"
        $app = New-AadApplication -DisplayName $DisplayName
    }
    
    Remove-AadApplication -ObjectId $app.ObjectId

    Write-Verbose "Testing is done"
}

Export-ModuleMember -Function Test-AadApplication