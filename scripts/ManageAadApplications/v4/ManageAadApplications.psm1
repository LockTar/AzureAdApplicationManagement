function New-AadApplication {

    [CmdletBinding(DefaultParameterSetName = "DisplayName")]
    param (
        [ValidateNotNullOrEmpty()]
        [Parameter(Position = 0, ParameterSetName = "DisplayName", Mandatory = $true)]
        [string]$DisplayName,
        [string]$IdentifierUri,
        [Parameter (Mandatory = $false)]
        [string]$SignInAudience = "AzureADMyOrg"
    )

    Write-Verbose "Check if IdentifierUri is given as parameter"
    if ([string]::IsNullOrWhiteSpace($IdentifierUri)) {
        Write-Verbose "Create application $DisplayName"
        $app = New-MgApplication -DisplayName $DisplayName -SignInAudience $SignInAudience

        # The IdentifierUri was not given as parameter so create the new default identifieruri. This can only be done with the ApplicationId so use it from the 'New' action.
        Write-Verbose "Change IdentifierUri to the new default format of Microsoft: api://{ApplicationId}"
        $IdentifierUri = "api://$($app.AppId)"
        Update-MgApplication -ApplicationId $app.Id -IdentifierUris "$IdentifierUri"
        $app = Get-MgApplication -ApplicationId $app.Id -ErrorAction Stop
    }
    else {
        Write-Verbose "Create application $DisplayName with given IdentifierUri: $IdentifierUri"
        $app = New-MgApplication -DisplayName $DisplayName -IdentifierUri $IdentifierUri -SignInAudience $SignInAudience
    }
    
    Write-Verbose "Create service principal connected to application"
    $sp = New-MgServicePrincipal -AppId $app.AppId

    Write-Host "##vso[task.setvariable variable=ObjectId;]$($app.Id)"
    Write-Host "##vso[task.setvariable variable=ApplicationId;]$($app.AppId)"
    Write-Host "##vso[task.setvariable variable=Name;]$($app.DisplayName)"
    Write-Host "##vso[task.setvariable variable=AppIdUri;]$($app.IdentifierUris[0])"
    Write-Host "##vso[task.setvariable variable=HomePageUrl;]$($app.HomePageUrl)"
    Write-Host "##vso[task.setvariable variable=SignInAudience;]$($app.SignInAudience)"
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
            $app = Get-MgApplication -ApplicationId $ObjectId
        } 
        "ApplicationId" { 
            Write-Verbose "Get application $ApplicationId"
            $app = Get-MgApplication -Filter "AppId eq '$ApplicationId'"
        }
        "DisplayName" { 
            Write-Verbose "Get application $DisplayName"
            $app = Get-MgApplication -Filter "DisplayName eq '$DisplayName'"
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
        Write-Information "Found application with name $($app.DisplayName) under ObjectId $($app.Id) and ApplicationId $($app.AppId)"
        $sp = Get-MgServicePrincipal -Filter "AppId eq '$($app.AppId)'"
        
        Write-Host "##vso[task.setvariable variable=ObjectId;]$($app.Id)"
        Write-Host "##vso[task.setvariable variable=ApplicationId;]$($app.AppId)"
        Write-Host "##vso[task.setvariable variable=Name;]$($app.DisplayName)"
        Write-Host "##vso[task.setvariable variable=AppIdUri;]$($app.IdentifierUris[0])"
        Write-Host "##vso[task.setvariable variable=HomePageUrl;]$($app.HomePageUrl)"
        Write-Host "##vso[task.setvariable variable=SignInAudience;]$($app.SignInAudience)"
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
        [string]$WebHomePageUrl,
        [string]$SignInAudience,
        [string[]]$WebRedirectUris,
        [string]$ResourceAccessFilePath,
        [string]$AppRolesFilePath,
        [ValidateNotNullOrEmpty()]
        [string[]]$Owners,
        [Object[]]$Secrets,
        [bool]$EnableAccessTokenIssuance,
        [bool]$AppRoleAssignmentRequired
    )

    Write-Verbose "Update application $ObjectId"

    Write-Verbose "Get application by ObjectId: $ObjectId"
    $app = Get-MgApplication -ApplicationId $ObjectId -ErrorAction Stop
    $sp = Get-MgServicePrincipal -Filter "AppId eq '$($app.AppId)'"
    $appOld = $app
    $spOld = $sp

    Write-Information "Found application with name $($app.DisplayName) under ObjectId $($app.Id) and ApplicationId $($app.AppId)"
       
    # Prepare ResourceAccess
    if ($PSBoundParameters.ContainsKey('ResourceAccessFilePath')) {
        if ([string]::IsNullOrWhiteSpace($ResourceAccessFilePath)) {
            # This can happen with 'SET' ADO task
            Write-Verbose "Skip update ResourceAccess because no file is given"
        }
        else {
            [System.Collections.ArrayList]$requiredResourceAccess = @()
            if ((Test-Path $ResourceAccessFilePath) -and ($ResourceAccessFilePath -Like "*.json")) {
                Write-Verbose "Get the resources and permissions for app registration and convert into json object"
                $resourceAccessInJson = Get-Content $ResourceAccessFilePath -Raw | ConvertFrom-Json
        
                Write-Verbose "Loop through all resources and permissions"
                foreach ($resourceInJson in $resourceAccessInJson) {
                    Write-Verbose "Create new 'Microsoft.Graph.PowerShell.Models.MicrosoftGraphRequiredResourceAccess' object and set '$($resourceInJson.resourceAppId)' as the ResourceAppId"
                    $resource = New-Object -TypeName "Microsoft.Graph.PowerShell.Models.MicrosoftGraphRequiredResourceAccess"
                    $resource.ResourceAppId = $resourceInJson.resourceAppId
            
                    Write-Verbose "Create new 'System.Collections.Generic.List[Microsoft.Graph.PowerShell.Models.MicrosoftGraphRequiredResourceAccess]' object for ResourceAccess"
                    $resource.ResourceAccess = New-Object System.Collections.Generic.List[Microsoft.Graph.PowerShell.Models.MicrosoftGraphRequiredResourceAccess]
                    foreach ($resourceAccessInJson in $resourceInJson.resourceAccess) {
                        Write-Verbose "Create new 'Microsoft.Graph.PowerShell.Models.MicrosoftGraphRequiredResourceAccess' object and set '$($resourceAccessInJson.id),$($resourceAccessInJson.type)'. Add this ResourceAccess to the list"
                        # $resourceAccess = New-Object -TypeName "Microsoft.Graph.PowerShell.Models.MicrosoftGraphRequiredResourceAccess" -ArgumentList $resourceAccessInJson.id, $resourceAccessInJson.type
                        $resource.ResourceAccess +=@{Id = $resourceAccessInJson.id; Type = $resourceAccessInJson.type}
                    }
            
                    $requiredResourceAccess.Add($resource)
                }
        
                Write-Verbose "All resources with permissions are created and ready to set to the application"
            }
            else {
                throw "Invalid file path for ResourceAccessFilePath"
            }
        }
    }
    
    # Prepare AppRoles
    if ($PSBoundParameters.ContainsKey('AppRolesFilePath')) {
        if ([string]::IsNullOrWhiteSpace($AppRolesFilePath)) {
            # This can happen with 'SET' ADO task
            Write-Verbose "Skip update AppRoles because no file is given"
        }
        else { 
            $appRoles = $app.AppRoles
            # Write-Verbose "App Roles before updating to the new roles:"
            # Write-Host $appRoles

            if ((Test-Path $AppRolesFilePath) -and ($AppRolesFilePath -Like "*.json")) {
                Write-Verbose "Get the approles for app registration and convert into json object"
                $appRolesInJson = Get-Content $AppRolesFilePath -Raw | ConvertFrom-Json
                $appRoles = New-Object System.Collections.Generic.List[Microsoft.Graph.PowerShell.Models.MicrosoftGraphAppRole]

                Write-Verbose "Loop through all approles"
                foreach ($appRoleInJson in $appRolesInJson) {
                    $appRole = New-Object "Microsoft.Graph.PowerShell.Models.MicrosoftGraphAppRole"
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
    }

    Write-Verbose "Start updating application properties"

    if ($PSBoundParameters.ContainsKey('DisplayName')) {
        Write-Verbose "Update DisplayName for application"
        Update-MgApplication -ApplicationId $app.Id -DisplayName $DisplayName
        $app = Get-MgApplication -ApplicationId $app.Id -ErrorAction Stop

        Write-Verbose "Update DisplayName for service principal"
        Update-MgServicePrincipal -ServicePrincipalId $sp.Id -DisplayName $DisplayName
    }

    if ($PSBoundParameters.ContainsKey('IdentifierUri')) {
        Write-Verbose "Update IdentifierUri"
        Update-MgApplication -ApplicationId $app.Id -IdentifierUris $IdentifierUri
        $app = Get-MgApplication -ApplicationId $app.Id -ErrorAction Stop
    }

    if ($PSBoundParameters.ContainsKey('WebHomePageUrl')) {
        if ([string]::IsNullOrWhiteSpace($($app.Web.HomePageUrl)) -and [string]::IsNullOrWhiteSpace($WebHomePageUrl)) {
            # This can happen with 'SET' ADO task
            Write-Host "Skip update HomePageUrl because both are null"
        }
        else {
            Write-Verbose "Update HomePageUrl"

            $app.Web.HomePageUrl = "$WebHomePageUrl"
            Update-MgApplication -ApplicationId $app.Id -BodyParameter $app -ErrorAction Stop
            $app = Get-MgApplication -ApplicationId $app.Id

            Start-Sleep 30
            Write-Verbose "Update HomePageUrl for service principal"
            # Update-MgServicePrincipal -ServicePrincipalId $sp.Id -BodyParameter $params
        }
    }

    if ($PSBoundParameters.ContainsKey('WebRedirectUris')) {
        if ([string]::IsNullOrWhiteSpace($app.Web.RedirectUris) -and ($WebRedirectUris.Count -eq 0)) {
            # This can happen with 'SET' ADO task
            Write-Host "Skip update WebRedirectUris because both are null"
        }
        else {
            if ([string]::IsNullOrWhiteSpace($WebRedirectUris)) {
                throw "WebRedirectUris can not be an empty string"
            }
            else {
                Write-Host "Update WebRedirectUris"
                
                $params = @{
                    Web = @{
                        RedirectUris = @(
                            foreach($url in $WebRedirectUris){
                                $url
                            }
                        )
                    }
                }

                Update-MgApplication -ApplicationId $app.Id -BodyParameter $params
                $app = Get-MgApplication -ApplicationId $app.Id
            }
        }
    }

    if ($PSBoundParameters.ContainsKey('SignInAudience')) {
        Write-Verbose "Update SignInAudience"
        Update-MgApplication -ApplicationId $app.Id -SignInAudience $SignInAudience
        $app = Get-MgApplication -ApplicationId $app.Id
    }
   
    if ($PSBoundParameters.ContainsKey('AppRoleAssignmentRequired')) {
        Write-Verbose "Update Tags and AppRoleAssignmentRequired"
        
        $servicePrincipalUpdate = @{
            AppRoleAssignmentRequired = $AppRoleAssignmentRequired
            Tags = "WindowsAzureActiveDirectoryIntegratedApp"
        }

        Update-MgServicePrincipal -ServicePrincipalId $sp.Id -BodyParameter $servicePrincipalUpdate
    }

    if ($PSBoundParameters.ContainsKey('EnableAccessTokenIssuance')) {
        Write-Verbose "Update EnableAccessTokenIssuance"
        $params = @{
            Web = @{
                ImplicitGrantSettings = @{
                    EnableAccessTokenIssuance = $EnableAccessTokenIssuance
                }
            }
        }
        Update-MgApplication -ApplicationId $app.Id -BodyParameter $params
    }

    if ($PSBoundParameters.ContainsKey('ResourceAccessFilePath')) {
        if ([string]::IsNullOrWhiteSpace($ResourceAccessFilePath)) {
            # This can happen with 'SET' ADO task
            Write-Verbose "Skip update ResourceAccess because no file is given"
        }
        else {
            if ((Test-Path $ResourceAccessFilePath) -and ($ResourceAccessFilePath -Like "*.json")) {
                Write-Verbose "Update RequiredResourceAccess"
                Update-MgApplication -ApplicationId $app.Id -RequiredResourceAccess $requiredResourceAccess
            }        
            else {
                throw "Invalid file path for ResourceAccessFilePath"
            }
        }
    }

    if ($PSBoundParameters.ContainsKey('AppRolesFilePath')) {
        if ([string]::IsNullOrWhiteSpace($AppRolesFilePath)) {
            # This can happen with 'SET' ADO task
            Write-Verbose "Skip update AppRoles because no file is given"
        }
        else { 
            if ((Test-Path $AppRolesFilePath) -and ($AppRolesFilePath -Like "*.json")) {
                Write-Verbose "Update AppRoles"
                Update-MgApplication -ApplicationId $app.Id -AppRoles $appRoles
            }
            else {
                throw "Invalid file path for AppRolesFilePath"
            }
        }
    }
    
    if ($PSBoundParameters.ContainsKey('Owners')) {
        Write-Verbose "Update owners of the application. Current owners are:"
        $currentOwners = Get-MgApplicationOwner -ApplicationId $app.Id -All
        $currentOwners | Select-Object Id, DisplayName, UserPrincipalName | Format-Table | Write-Verbose

        # Retrieve owner ObjectId based on UserPrincipalName
        $ownerObjectIds = @()
        foreach ($owner in $Owners) {
            Write-Verbose "Check if owner is an Object Id or UserPrincipalName"
            $result = New-Guid
            if ([Guid]::TryParse($owner, [ref] $result)) {
                Write-Verbose "Owner is an Object Id so add it to the list as desired owners"
                $ownerObjectIds += $owner
            }
            else {
                Write-Verbose "Owner is an UserPrincipalName so search for the user and add the ObjectId of the user to the list as desired owners"
                $user = Get-MgUser -UserId $owner
                $ownerObjectIds += $user.Id
            }
        }

        # Add missing owners
        foreach ($owner in $ownerObjectIds) {
            if ($null -eq $currentOwners -or $($currentOwners.Id).Contains($owner) -eq $false) {
                Write-Verbose "Add applicationowner $owner"
                $newOwner = @{
                  "@odata.id"= "https://graph.microsoft.com/v1.0/directoryObjects/$($owner)"
                }
                New-MgApplicationOwnerByRef -ApplicationId $app.Id -BodyParameter $newOwner
                New-MgServicePrincipalOwnerByRef -ServicePrincipalId $sp.Id -BodyParameter $newOwner
            }
            else {
                Write-Verbose "Don't add $owner as owner because is already owner"
            }
        }

        if ($null -ne $currentOwners) {
            # Remove owners that should not be owner anymore
            foreach ($currentOwner in $currentOwners.Id) {
                if ($ownerObjectIds.Contains($currentOwner) -eq $false) {
                    Write-Verbose "Remove applicationowner $currentOwner"
                    Remove-MgApplicationOwnerByRef -ApplicationId $app.Id -DirectoryObjectId $currentOwner
                    Remove-MgServicePrincipalOwnerByRef -ServicePrincipalId $sp.Id -DirectoryObjectId $currentOwner
                }
                else {
                    Write-Verbose "Don't remove owner $currentOwner because must stay owner"
                }
            }
        }
    }
    
    if ($PSBoundParameters.ContainsKey('Secrets')) {
        if ($Secrets) {
            # Check for existing secrets and remove them so they can be re-created
            Write-Verbose "Checking for existing secrets"
            $appKeySecrets = $app.passwordCredentials

            # Remove existing secret (if it exists) so we can create a new one
            if ($appKeySecrets) {
                foreach ($existingSecret in $appKeySecrets) { # Check for each existing secret
                    foreach ($secret in $Secrets) { # Check for each secret that we want to add
                        $stringDescription = $secret.Description | Out-String
                        $trimmedStringDescription = $stringDescription -replace [Environment]::NewLine, "";

                        if ([System.Text.Encoding]::ASCII.GetString($existingSecret.DisplayName) -eq $trimmedStringDescription) {
                            Write-Verbose "Removing existing key with description: $trimmedStringDescription"
                            Remove-MgApplicationPassword -ApplicationId  $app.Id -KeyId $existingSecret.KeyId
                        }
                    }
                }
            }

            # Create new secrets
            foreach ($secret in $Secrets) {
                $endDate = [datetime]::ParseExact($secret.EndDate, 'dd/MM/yyyy', [Globalization.CultureInfo]::InvariantCulture)
                
                $stringDescription = $secret.Description | Out-String
                $trimmedStringDescription = $stringDescription -replace [Environment]::NewLine, "";
                
                Write-Verbose "Creating new key with description: $trimmedStringDescription and end date $endDate"
                
                $passwordCredential = @{
                    DisplayName = $trimmedStringDescription
                    EndDateTime = $endDate
                }

                $appKeySecret = Add-MgApplicationPassword -ApplicationId $app.Id -PasswordCredential $passwordCredential
                
                Write-Host "##vso[task.setvariable variable=Secret.$trimmedStringDescription;isOutput=true;issecret=true]$($appKeySecret.Value)"
            }
        }
    }

    # Write-Verbose "Sleep so updates are processed"
    # Start-Sleep 10

    Write-Verbose "Get refreshed app and service principal properties"
    $app = Get-MgApplication -ApplicationId $app.Id
    $sp = Get-MgServicePrincipal -Filter "AppId eq '$($app.AppId)'"
    $currentOwners = Get-MgApplicationOwner -ApplicationId $app.Id -All

    Write-Host "##vso[task.setvariable variable=ObjectId;]$($app.Id)"
    Write-Host "##vso[task.setvariable variable=ApplicationId;]$($app.AppId)"
    Write-Host "##vso[task.setvariable variable=Name;]$($app.DisplayName)"
    Write-Host "##vso[task.setvariable variable=AppIdUri;]$($app.IdentifierUris[0])"
    Write-Host "##vso[task.setvariable variable=HomePageUrl;]$($app.Web.HomePageUrl)"
    Write-Host "##vso[task.setvariable variable=ServicePrincipalObjectId;]$($sp.Id)"

    $result = [PSCustomObject]@{
        Application                 = $app
        ServicePrincipal            = $sp
        RequiredResourceAccess      = $app.RequiredResourceAccess
        AppRoles                    = $app.AppRoles
        Owners                      = $currentOwners
        SpAppRoleAssignmentRequired = $sp.AppRoleAssignmentRequired
        AppEnableAccessTokenIssuance  = $app.Web.ImplicitGrantSettings.EnableAccessTokenIssuance
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
            $app = Get-MgApplication -ApplicationId $ObjectId -ErrorAction SilentlyContinue
            $notFoundMessage = "The application with ObjectId $ObjectId cannot be found. Check if the application exists and if you search with the right values."
        } 
        "ApplicationId" { 
            Write-Verbose "Remove application by ApplicationId: $ApplicationId"
            $app = Get-MgApplication -Filter "AppId eq '$ApplicationId'" -ErrorAction SilentlyContinue
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
        Write-Verbose "Found application to remove with name $($app.DisplayName) under ObjectId $($app.Id) and ApplicationId $($app.AppId)"
        Remove-MgApplication -ApplicationId $app.Id
        Write-Information "Removed application $($app.DisplayName)"
    }
}

Export-ModuleMember -Function New-AadApplication, Get-AadApplication, Update-AadApplication, Remove-AadApplication