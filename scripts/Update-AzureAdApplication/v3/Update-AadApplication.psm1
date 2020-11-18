function Update-AadApplication {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [string]$ObjectId,
        [Parameter(Mandatory)]
        [string]$Name,
        [string]$AppIdUri,
        [string]$HomePageUrl,
        [string]$LogoutUrl,
        [string]$TermsOfServiceUrl,
        [string]$PrivacyStatementUrl,
        [bool]$MultiTenant,
        [string[]]$ReplyUrls,
        [string]$ResourceAccessFilePath,
        [string]$AppRolesFilePath,
        [string[]]$Owners,
        [Object[]]$Secrets,
        [bool]$Oauth2AllowImplicitFlow,
        [bool]$AppRoleAssignmentRequired
    )

    $ErrorActionPreference = "Stop"

    $oldverbose = $VerbosePreference
    $VerbosePreference = "continue"
    $oldinformation = $InformationPreference
    $InformationPreference = "continue"

    Write-Verbose "Get application by ObjectId: $ObjectId"
    $application = Get-AzADApplication -ObjectId $ObjectId -ErrorAction Continue

    if (!$application) {
        Write-Error "Azure AD Application with ObjectId '$ObjectId' can't be found"
    }
    else {
        Write-Information "Found application: "
        $application

        # Because AppIdUri is not required anymore in the task it can be empty. If empty, update the paramter with the value in the AD so we can use the update cmdlet.
        if ($null -eq $AppIdUri -or $AppIdUri -eq "") {
            Write-Host "AppIdUri is null or empty so use AppIdUri from the AD $($application.IdentifierUris[0])"
            $AppIdUri = $application.IdentifierUris[0]
            Write-Host "Going to use AppIdUri: $AppIdUri"
        }

        # Because HomePageUrl is not required anymore in the task it can be empty. If empty, update the paramter with the value in the AD so we can use the update cmdlet.
        if ($null -eq $HomePageUrl -or $HomePageUrl -eq "") {
            Write-Host "HomePageUrl is null or empty so use HomePage from the AD $($application.HomePage) because Microsoft Update cmdlet won't allow empty Homepage"
            $HomePageUrl = $application.HomePage
            Write-Host "Going to use HomePageUrl: $HomePageUrl"
            if ($null -eq $HomePageUrl -or $HomePageUrl -eq "") {
                Write-Host "HomePage is already empty in the AD so skip the parameter in the Update cmdlet"
            }
        }

        $appRoles = $application.AppRoles
        Write-Host "App Roles before setting the new roles:"
        Write-Host $appRoles

        # For local testing
        #$ResourceAccessFilePath = Join-Path -Path $PSScriptRoot -ChildPath "..\..\Test-RequiredResourceAccess.json"

        # ResourceAccess
        [System.Collections.ArrayList]$requiredResourceAccess = @()

        if ((Test-Path $ResourceAccessFilePath) -and ($ResourceAccessFilePath -Like "*.json")) {
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

        # AppRoles
        if ((Test-Path $AppRolesFilePath) -and ($AppRolesFilePath -Like "*.json")) {
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

        Write-Verbose "Set application properties"
        if ($null -eq $HomePageUrl -or $HomePageUrl -eq "") {
            Update-AzADApplication `
                -ObjectId $application.ObjectId `
                -DisplayName $Name `
                -IdentifierUris $AppIdUri `
                -AvailableToOtherTenants $MultiTenant `
                -ReplyUrls $ReplyUrls
        }
        else {
            Update-AzADApplication `
                -ObjectId $application.ObjectId `
                -DisplayName $Name `
                -IdentifierUris $AppIdUri `
                -HomePage $HomePageUrl `
                -AvailableToOtherTenants $MultiTenant `
                -ReplyUrls $ReplyUrls
        }

        Write-Verbose "Set required resource access, approles and Oauth2AllowImplicitFlow to application: "
        # Following can't be done by Az Module (yet)
        Set-AzureADApplication -ObjectId $application.ObjectId -Oauth2AllowImplicitFlow $Oauth2AllowImplicitFlow -RequiredResourceAccess $requiredResourceAccess -AppRoles $appRoles

        Write-Verbose "Set service principal properties"
        $servicePrincipal = Get-AzADServicePrincipal -ApplicationId $application.ApplicationId

        Write-Information "Found service principal: "
        $servicePrincipal

        # Do set with AzureAD modules because tags aren't available yet in the Az module
        # Update-AzADServicePrincipal `
        #     -ObjectId $servicePrincipal.Id `
        #     -DisplayName $Name `
        #     -Homepage $HomePageUrl

        if ($null -eq $HomePageUrl -or $HomePageUrl -eq "") {
            Set-AzureADServicePrincipal `
                -ObjectId $servicePrincipal.Id `
                -DisplayName $Name `
                -Tags "WindowsAzureActiveDirectoryIntegratedApp" `
                -AppRoleAssignmentRequired $AppRoleAssignmentRequired
        }
        else {
            Set-AzureADServicePrincipal `
                -ObjectId $servicePrincipal.Id `
                -DisplayName $Name `
                -Homepage $HomePageUrl `
                -Tags "WindowsAzureActiveDirectoryIntegratedApp" `
                -AppRoleAssignmentRequired $AppRoleAssignmentRequired
        }

        # Add owners to the application
        Write-Verbose "Set owners of the application. Current owners are:"
        $currentOwners = Get-AzureADApplicationOwner -ObjectId $application.ObjectId -All $True
        $currentOwners | Select-Object ObjectId, DisplayName, UserPrincipalName | Format-Table

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
                $user = Get-AzADUser -UserPrincipalName $owner
                $ownerObjectIds += $user.Id
            }
        }

        # Add missing owners
        foreach ($owner in $ownerObjectIds) {
            if ($null -eq $currentOwners -or $($currentOwners.ObjectId).Contains($owner) -eq $false) {
                Write-Verbose "Add applicationowner $owner"
                Add-AzureADApplicationOwner -ObjectId $application.ObjectId -RefObjectId $owner
                Add-AzureADServicePrincipalOwner -ObjectId $servicePrincipal.Id -RefObjectId $owner
            }
            else {
                Write-Verbose "Don't add $owner as owner because is already owner"
            }
        }

        if ($null -ne $currentOwners) {
            # Remove owners that should not be owner anymore
            foreach ($currentOwner in $currentOwners.ObjectId) {
                if ($ownerObjectIds.Contains($currentOwner) -eq $false) {
                    Write-Verbose "Remove applicationowner $currentOwner"
                    Remove-AzureADApplicationOwner -ObjectId $application.ObjectId -OwnerId $currentOwner
                    Remove-AzureADServicePrincipalOwner -ObjectId $servicePrincipal.Id -OwnerId $currentOwner
                }
                else {
                    Write-Verbose "Don't remove owner $currentOwner because must stay owner"
                }
            }
        }

        if ($Secrets) { 
            # Check for existing secrets and remove them so they can be re-created
            Write-Verbose "Checking for existing secrets"
            $appKeySecrets = Get-AzureADApplicationPasswordCredential -ObjectId $application.ObjectId

            if ($appKeySecrets) {
                foreach ($existingSecret in $appKeySecrets) {
                    foreach ($secret in $Secrets) {
                        $stringDescription = $secret.Description | Out-String
                        $trimmedStringDescription = $stringDescription -replace [Environment]::NewLine, "";

                        if ([System.Text.Encoding]::ASCII.GetString($existingSecret.CustomKeyIdentifier) -eq $trimmedStringDescription) {
                            Write-Verbose "Removing existing key with description: $trimmedStringDescription"
                            Remove-AzureADApplicationPasswordCredential  -ObjectId $application.ObjectId -KeyId $existingSecret.KeyId
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
                $appKeySecret = New-AzureADApplicationPasswordCredential -ObjectId $application.ObjectId -CustomKeyIdentifier $trimmedStringDescription -EndDate $endDate
                
                Write-Host "##vso[task.setvariable variable=Secret.$trimmedStringDescription;isOutput=true;issecret=true]$($appKeySecret.Value)"
            }
        }

        Write-Information "Owners of the application are now:"
        $currentOwners = Get-AzureADApplicationOwner -ObjectId $application.ObjectId -All $True
        $currentOwners | Select-Object ObjectId, DisplayName, UserPrincipalName | Format-Table

        Write-Host "##vso[task.setvariable variable=ObjectId;]$($application.ObjectId)"
        Write-Host "##vso[task.setvariable variable=ApplicationId;]$($application.ApplicationId)"
        Write-Host "##vso[task.setvariable variable=Name;]$($application.DisplayName)"
        Write-Host "##vso[task.setvariable variable=AppIdUri;]$($application.IdentifierUris[0])"
        Write-Host "##vso[task.setvariable variable=HomePageUrl;]$($application.HomePage)"
        Write-Host "##vso[task.setvariable variable=ServicePrincipalObjectId;]$($servicePrincipal.Id)"
    }

    $VerbosePreference = $oldverbose
    $InformationPreference = $oldinformation
}

# Export only the public function.
Export-ModuleMember -Function Update-AadApplication