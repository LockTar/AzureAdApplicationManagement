
function New-AadApplication {

    [CmdletBinding(DefaultParameterSetName = "DisplayName")]
    param (
        [ValidateNotNullOrEmpty()]
        [Parameter(Position = 0, ParameterSetName = "DisplayName", Mandatory = $true)]
        [string]$DisplayName,
        [string]$IdentifierUri
    )

    Write-Verbose "Create new application $DisplayName"
        
    $identifierUriFromParameter = $false
    Write-Verbose "Check if IdentifierUri is given as parameter"
    if ([string]::IsNullOrWhiteSpace($IdentifierUri)) {
        Write-Verbose "No IdentifierUri so generate one with format: https://{DisplayName}"        
        $IdentifierUri = "https://$DisplayName"
        $identifierUriFromParameter = $false
        Write-Verbose "Generated IdentifierUri: $IdentifierUri"
    }
    else {
        Write-Verbose "Use given IdentifierUri: $IdentifierUri"
        $identifierUriFromParameter = $true
    }

    Write-Verbose "Create application $DisplayName"
    $app = New-AzADApplication -DisplayName $DisplayName -IdentifierUris $IdentifierUri
    
    if ($identifierUriFromParameter -eq $false) {
        # The IdentifierUri was not given as parameter so create the new default identifieruri. This can only be done with the ApplicationId so use it from the 'New' action.
        Write-Verbose "Change IdentifierUri to the new default format of Microsoft: api://{ApplicationId}"
        $IdentifierUri = "api://$($app.ApplicationId)"
        $app = Update-AzADApplication -ObjectId $app.ObjectId -IdentifierUris $IdentifierUri
    }

    Write-Verbose "Create service principal connected to application"
    $sp = Get-AzADApplication -ObjectId $app.ObjectId | New-AzADServicePrincipal

    $app = Get-AzADApplication -ObjectId $app.ObjectId

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
        Write-Information "Found application with name $($app.DisplayName) under ObjectId $($app.ObjectId) and ApplicationId $($app.ApplicationId)"
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

function Update-AadApplication {

    [CmdletBinding(DefaultParameterSetName = "ObjectId")]
    param (
        [ValidateNotNullOrEmpty()]
        [Parameter(Position = 0, ParameterSetName = "ObjectId", Mandatory = $true)]
        [string]$ObjectId,
        [ValidateNotNullOrEmpty()]
        [string]$DisplayName,
        [ValidateNotNullOrEmpty()]
        [string]$IdentifierUri,
        [ValidateNotNullOrEmpty()]
        [string]$HomePageUrl,
        [bool]$AvailableToOtherTenants,
        # [string[]]$ReplyUrls,
        [string]$ResourceAccessFilePath,
        [string]$AppRolesFilePath
        # [string[]]$Owners,
        # [Object[]]$Secrets,
        # [bool]$Oauth2AllowImplicitFlow,
        # [bool]$AppRoleAssignmentRequired
    )

    Write-Verbose "Update application $ObjectId"

    Write-Verbose "Get application by ObjectId: $ObjectId"
    $app = Get-AzADApplication -ObjectId $ObjectId -ErrorAction Stop
    $sp = Get-AzADServicePrincipal -ApplicationId $app.ApplicationId

    Write-Information "Found application with name $($app.DisplayName) under ObjectId $($app.ObjectId) and ApplicationId $($app.ApplicationId)"
       
    # Prepare ResourceAccess
    if ($PSBoundParameters.ContainsKey('ResourceAccessFilePath')) {
        [System.Collections.ArrayList]$requiredResourceAccess = @()
        if (![string]::IsNullOrWhiteSpace($ResourceAccessFilePath) -and (Test-Path $ResourceAccessFilePath) -and ($ResourceAccessFilePath -Like "*.json")) {            
            Write-Verbose "Get the resources and permissions for app registration and convert into json object"
            $resourceAccessInJson = Get-Content $ResourceAccessFilePath -Raw | ConvertFrom-Json
        
            Write-Verbose "Loop through all resources and permissions"
            foreach ($resourceInJson in $resourceAccessInJson) {
                Write-Verbose "Create new 'Microsoft.Open.AzureAD.Model.RequiredResourceAccess' object and set '$($resourceInJson.resourceAppId)' as the ResourceAppId"
                $resource = New-Object -TypeName "Microsoft.Open.AzureAD.Model.RequiredResourceAccess"
                $resource.ResourceAppId = $resourceInJson.resourceAppId
            
                Write-Verbose "Create new 'System.Collections.Generic.List[Microsoft.Open.AzureAD.Model.ResourceAccess]' object for ResourceAccess"
                $resource.ResourceAccess = New-Object System.Collections.Generic.List[Microsoft.Open.AzureAD.Model.ResourceAccess]
                foreach ($resourceAccessInJson in $resourceInJson.resourceAccess) {
                    Write-Verbose "Create new 'Microsoft.Open.AzureAD.Model.ResourceAccess' object and set '$($resourceAccessInJson.id),$($resourceAccessInJson.type)'. Add this ResourceAccess to the list"
                    $resourceAccess = New-Object -TypeName "Microsoft.Open.AzureAD.Model.ResourceAccess" -ArgumentList $resourceAccessInJson.id, $resourceAccessInJson.type
                    $resource.ResourceAccess.Add($resourceAccess)
                }
            
                $requiredResourceAccess.Add($resource)
            }
        
            Write-Verbose "All resources with permissions are created and ready to set to the application"
        }
        else {
            throw "Invalid file path for ResourceAccessFilePath"
        }
    }
    
    # Prepare AppRoles
    if ($PSBoundParameters.ContainsKey('AppRolesFilePath')) {
        $appRoles = $app.AppRoles
        # Write-Verbose "App Roles before updating to the new roles:"
        # Write-Host $appRoles

        if (![string]::IsNullOrWhiteSpace($AppRolesFilePath) -and (Test-Path $AppRolesFilePath) -and ($AppRolesFilePath -Like "*.json")) {
            Write-Verbose "Get the approles for app registration and convert into json object"
            $appRolesInJson = Get-Content $AppRolesFilePath -Raw | ConvertFrom-Json
            $appRoles = New-Object System.Collections.Generic.List[Microsoft.Open.AzureAD.Model.AppRole]

            Write-Verbose "Loop through all approles"
            foreach ($appRoleInJson in $appRolesInJson) {
                $appRole = New-Object Microsoft.Open.AzureAD.Model.AppRole
                $appRole.AllowedMemberTypes = $appRoleInJson.allowedMemberTypes
                $appRole.DisplayName = $appRoleInJson.displayName
                $appRole.Id = $appRoleInJson.id
                $appRole.IsEnabled = $appRoleInJson.isEnabled
                $appRole.Description = $appRoleInJson.description
                $appRole.Value = $appRoleInJson.value
                
                $appRoles.Add($appRole)
            }

            Write-Verbose "All approles are created and ready to set to the application"     
        }
        else {
            throw "Invalid file path for AppRolesFilePath"
        }
    }

    Write-Verbose "Start updating application properties"

    if ($PSBoundParameters.ContainsKey('DisplayName')) {        
        Write-Verbose "Update DisplayName for application"
        $app = Update-AzADApplication -ObjectId $app.ObjectId -DisplayName $DisplayName

        Write-Verbose "Update DisplayName for service principal"
        $sp = Update-AzADServicePrincipal -ObjectId $sp.Id -DisplayName $DisplayName
    }

    if ($PSBoundParameters.ContainsKey('IdentifierUri')) {        
        Write-Verbose "Update IdentifierUri"
        $app = Update-AzADApplication -ObjectId $app.ObjectId -IdentifierUris $IdentifierUri
    }

    if ($PSBoundParameters.ContainsKey('HomePageUrl')) {
        Write-Verbose "Update HomePageUrl"
        $app = Update-AzADApplication -ObjectId $app.ObjectId -HomePage $HomePageUrl

        Write-Verbose "Update HomePageUrl for service principal"
        $sp = Set-AzureADServicePrincipal -ObjectId $sp.Id -Homepage $HomePageUrl
    }

    # if ($PSBoundParameters.ContainsKey('ReplyUrls')) {
    #     Write-Verbose "Update ReplyUrls"
    #     $app = Update-AzADApplication -ObjectId $app.ObjectId -IdentifierUris $IdentifierUri -ReplyUrls $ReplyUrls        
    # }

    if ($PSBoundParameters.ContainsKey('AvailableToOtherTenants')) {
        Write-Verbose "Update AvailableToOtherTenants"
        $app = Update-AzADApplication -ObjectId $app.ObjectId -AvailableToOtherTenants $AvailableToOtherTenants
    }
   
    # How to deal with AppRoleAssignmentRequired? This is a boolean so always given
    # Write-Verbose "Update Tags and AppRoleAssignmentRequired"
    # Set-AzureADServicePrincipal -ObjectId $sp.Id -Tags "WindowsAzureActiveDirectoryIntegratedApp" -AppRoleAssignmentRequired $AppRoleAssignmentRequired

    # How to deal with Oauth2AllowImplicitFlow? This is a boolean so always given
    # Write-Verbose "Update Oauth2AllowImplicitFlow"
    # Set-AzureADApplication -ObjectId $app.ObjectId -Oauth2AllowImplicitFlow $Oauth2AllowImplicitFlow

    if ($PSBoundParameters.ContainsKey('ResourceAccessFilePath')) {
        if ((Test-Path $ResourceAccessFilePath) -and ($ResourceAccessFilePath -Like "*.json")) {
            Write-Verbose "Update RequiredResourceAccess"
            Set-AzureADApplication -ObjectId $app.ObjectId -RequiredResourceAccess $requiredResourceAccess
        }        
        else {
            throw "Invalid file path for ResourceAccessFilePath"
        }
    }

    if ($PSBoundParameters.ContainsKey('AppRolesFilePath')) {
        if ((Test-Path $AppRolesFilePath) -and ($AppRolesFilePath -Like "*.json")) {
            Write-Verbose "Update AppRoles"
            Set-AzureADApplication -ObjectId $app.ObjectId -AppRoles $appRoles        
        }
        else {
            throw "Invalid file path for AppRolesFilePath"
        }
    }
    
    # if ($PSBoundParameters.ContainsKey('Owners')) {
    #     Write-Verbose "Update owners of the application. Current owners are:"
    #     $currentOwners = Get-AzureADApplicationOwner -ObjectId $app.ObjectId -All $True
    #     $currentOwners | Select-Object ObjectId, DisplayName, UserPrincipalName | Format-Table | Write-Host

    #     # Retrieve owner ObjectId based on UserPrincipalName
    #     $ownerObjectIds = @()
    #     foreach ($owner in $Owners) {
    #         Write-Verbose "Check if owner is an Object Id or UserPrincipalName"
    #         $result = New-Guid
    #         if ([Guid]::TryParse($owner, [ref] $result)) {
    #             Write-Verbose "Owner is an Object Id so add it to the list as desired owners"
    #             $ownerObjectIds += $owner
    #         }
    #         else {
    #             Write-Verbose "Owner is an UserPrincipalName so search for the user and add the ObjectId of the user to the list as desired owners"
    #             $user = Get-AzADUser -UserPrincipalName $owner
    #             $ownerObjectIds += $user.Id
    #         }
    #     }

    #     # Add missing owners
    #     foreach ($owner in $ownerObjectIds) {
    #         if ($null -eq $currentOwners -or $($currentOwners.ObjectId).Contains($owner) -eq $false) {
    #             Write-Verbose "Add applicationowner $owner"
    #             Add-AzureADApplicationOwner -ObjectId $app.ObjectId -RefObjectId $owner
    #             Add-AzureADServicePrincipalOwner -ObjectId $sp.Id -RefObjectId $owner
    #         }
    #         else {
    #             Write-Verbose "Don't add $owner as owner because is already owner"
    #         }
    #     }

    #     if ($null -ne $currentOwners) {
    #         # Remove owners that should not be owner anymore
    #         foreach ($currentOwner in $currentOwners.ObjectId) {
    #             if ($ownerObjectIds.Contains($currentOwner) -eq $false) {
    #                 Write-Verbose "Remove applicationowner $currentOwner"
    #                 Remove-AzureADApplicationOwner -ObjectId $app.ObjectId -OwnerId $currentOwner
    #                 Remove-AzureADServicePrincipalOwner -ObjectId $sp.Id -OwnerId $currentOwner
    #             }
    #             else {
    #                 Write-Verbose "Don't remove owner $currentOwner because must stay owner"
    #             }
    #         }
    #     }
        
    #     Write-Information "Owners of the application are now:"
    #     $currentOwners = Get-AzureADApplicationOwner -ObjectId $app.ObjectId -All $True
    #     $currentOwners | Select-Object ObjectId, DisplayName, UserPrincipalName | Format-Table | Write-Host
    # }
    
    # if ($PSBoundParameters.ContainsKey('Secrets')) {
    #     if ($Secrets) { 
    #         # Check for existing secrets and remove them so they can be re-created
    #         Write-Verbose "Checking for existing secrets"
    #         $appKeySecrets = Get-AzureADApplicationPasswordCredential -ObjectId $app.ObjectId

    #         if ($appKeySecrets) {
    #             foreach ($existingSecret in $appKeySecrets) {
    #                 foreach ($secret in $Secrets) {
    #                     $stringDescription = $secret.Description | Out-String
    #                     $trimmedStringDescription = $stringDescription -replace [Environment]::NewLine, "";

    #                     if ([System.Text.Encoding]::ASCII.GetString($existingSecret.CustomKeyIdentifier) -eq $trimmedStringDescription) {
    #                         Write-Verbose "Removing existing key with description: $trimmedStringDescription"
    #                         Remove-AzureADApplicationPasswordCredential  -ObjectId $app.ObjectId -KeyId $existingSecret.KeyId
    #                     }
    #                 }
    #             }
    #         }

    #         # Create new secrets
    #         foreach ($secret in $Secrets) {
    #             $endDate = [datetime]::ParseExact($secret.EndDate, 'dd/MM/yyyy', [Globalization.CultureInfo]::InvariantCulture)
                
    #             $stringDescription = $secret.Description | Out-String
    #             $trimmedStringDescription = $stringDescription -replace [Environment]::NewLine, "";
                
    #             Write-Verbose "Creating new key with description: $trimmedStringDescription and end date $endDate"
    #             $appKeySecret = New-AzureADApplicationPasswordCredential -ObjectId $app.ObjectId -CustomKeyIdentifier $trimmedStringDescription -EndDate $endDate
                
    #             Write-Host "##vso[task.setvariable variable=Secret.$trimmedStringDescription;isOutput=true;issecret=true]$($appKeySecret.Value)"
    #         }
    #     }
    # }

    Write-Verbose "Sleep so updates are processed"
    Start-Sleep 10

    Write-Verbose "Get refreshed app and service principal properties"
    $app = Get-AzADApplication -ObjectId $app.ObjectId
    $appOld = Get-AzureADApplication -ObjectId $app.ObjectId
    $sp = Get-AzADServicePrincipal -ApplicationId $app.ApplicationId

    Write-Host "##vso[task.setvariable variable=ObjectId;]$($app.ObjectId)"
    Write-Host "##vso[task.setvariable variable=ApplicationId;]$($app.ApplicationId)"
    Write-Host "##vso[task.setvariable variable=Name;]$($app.DisplayName)"
    Write-Host "##vso[task.setvariable variable=AppIdUri;]$($app.IdentifierUris[0])"
    Write-Host "##vso[task.setvariable variable=HomePageUrl;]$($app.HomePage)"
    Write-Host "##vso[task.setvariable variable=ServicePrincipalObjectId;]$($sp.Id)"

    $result = [PSCustomObject]@{
        Application            = $app
        ServicePrincipal       = $sp
        RequiredResourceAccess = $appOld.RequiredResourceAccess
        AppRoles               = $appOld.AppRoles
    }
                    
    $result
}

function Remove-AadApplication {

    [CmdletBinding(DefaultParameterSetName = "ObjectId")]
    param (
        [ValidateNotNullOrEmpty()]
        [Parameter(Position = 0, ParameterSetName = "ObjectId", Mandatory = $true)]
        [string]$ObjectId,

        [ValidateNotNullOrEmpty()]
        [Parameter(ParameterSetName = "ApplicationId", Mandatory = $true)]
        [string]$ApplicationId,

        [switch]$FailIfNotFound
    )

    switch ($PSCmdlet.ParameterSetName) {
        "ObjectId" { 
            Write-Verbose "Remove application by ObjectId: $ObjectId"
            $app = Get-AzADApplication -ObjectId $ObjectId -ErrorAction SilentlyContinue
            $notFoundMessage = "The application with ObjectId $ObjectId cannot be found. Check if the application exists and if you search with the right values."
        } 
        "ApplicationId" { 
            Write-Verbose "Remove application by ApplicationId: $ApplicationId"
            $app = Get-AzADApplication -ApplicationId $ApplicationId -ErrorAction SilentlyContinue
            $notFoundMessage = "The application with ApplicationId $ApplicationId cannot be found. Check if the application exists and if you search with the right values."
        }
        Default {
            throw "Unknown ParameterSetName"
        }
    }  

    if ($null -eq $app) {
        Write-Verbose "Application not found. Check if we should throw error"
        if ($FailIfNotFound) {
            throw $notFoundMessage
        }
        else {
            Write-Information $notFoundMessage
        }
    }
    else {
        Write-Verbose "Found application to remove with name $($app.DisplayName) under ObjectId $($app.ObjectId) and ApplicationId $($app.ApplicationId)"
        Remove-AzADApplication -ObjectId $app.ObjectId -Force
        Write-Information "Removed application $($app.DisplayName)"
    }
}

Export-ModuleMember -Function New-AadApplication, Get-AadApplication, Update-AadApplication, Remove-AadApplication