# Private module-scope variables.
$script:azureModule = $null
$script:azureRMProfileModule = $null

# Override the DebugPreference.
if ($global:DebugPreference -eq 'Continue') {
    Write-Verbose '$OVERRIDING $global:DebugPreference from ''Continue'' to ''SilentlyContinue''.'
    $global:DebugPreference = 'SilentlyContinue'
}

function Set-AadApplication {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [string]$ObjectId,
        [Parameter(Mandatory)]
        [string]$Name,
        [Parameter(Mandatory)]
        [string]$AppIdUri,
        [string]$HomePageUrl,
        [string]$LogoutUrl,
        [string]$TermsOfServiceUrl,
        [string]$PrivacyStatementUrl,
        [bool]$MultiTenant,
        [string[]]$ReplyUrls,
        [string]$ResourceAccessFilePath,
        [string[]]$Owners,
        [Object[]]$Secrets
    )

    $ErrorActionPreference = "Stop"

    $oldverbose = $VerbosePreference
    $VerbosePreference = "continue"
    $oldinformation = $InformationPreference
    $InformationPreference = "continue"

    Write-Verbose "Get application by ObjectId: $ObjectId"
    $application = Get-AzureRmADApplication -ObjectId $ObjectId -ErrorAction Continue

    if (!$application) {
        Write-Error "Azure AD Application with ObjectId '$ObjectId' can't be found"
    }
    else {
        Write-Information "Found application: "
        $application

        # For local testing
        #$ResourceAccessFilePath = Join-Path -Path $PSScriptRoot -ChildPath "..\..\Test-RequiredResourceAccess.json"

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
                    $resourceAccess = New-Object -TypeName "Microsoft.Open.AzureAD.Model.ResourceAccess" -ArgumentList $resourceAccessInJson.id,$resourceAccessInJson.type
                    $resource.ResourceAccess.Add($resourceAccess)
                }

                $requiredResourceAccess.Add($resource)
            }

            Write-Verbose "All resources with permissions are created and ready to set to the application"
        }

        Write-Verbose "Set application properties"
        Update-AzureRmADApplication `
            -ObjectId $application.ObjectId `
            -DisplayName $Name `
            -IdentifierUri $AppIdUri `
            -HomePage $HomePageUrl `
            -AvailableToOtherTenants $MultiTenant `
            -ReplyUrls $ReplyUrls

        Write-Verbose "Set required resource access to application: "
        # Following can't be done by AzureRM (yet)
        Set-AzureADApplication -ObjectId $application.ObjectId -RequiredResourceAccess $requiredResourceAccess

        Write-Verbose "Set service principal properties"
        $servicePrincipal = Get-AzureRmADServicePrincipal -ApplicationId $application.ApplicationId

        Write-Information "Found service principal: "
        $servicePrincipal

        # Do set with AzureAD modules because tags aren't available yet in AzureRM
        # Update-AzureRmADServicePrincipal `
        #     -ObjectId $servicePrincipal.Id `
        #     -DisplayName $Name `
        #     -Homepage $HomePageUrl

        Set-AzureADServicePrincipal `
            -ObjectId $servicePrincipal.Id `
            -DisplayName $Name `
            -Homepage $HomePageUrl `
            -Tags "WindowsAzureActiveDirectoryIntegratedApp"

        # Add owners to the application
        Write-Verbose "Set owners of the application. Current owners are:"
        $currentOwners = Get-AzureADApplicationOwner -ObjectId $application.ObjectId -All $True
        $currentOwners | Select-Object ObjectId, DisplayName, UserPrincipalName | Format-Table

        # Retrieve owner ObjectId based on UserPrincipalName
        $ownerObjectIds = @()
        foreach($owner in $Owners)
        {
            Write-Verbose "Check if owner is an Object Id or UserPrincipalName"
            $result = New-Guid
            if([Guid]::TryParse($owner, [ref] $result))
            {
                Write-Verbose "Owner is an Object Id so add it to the list as desired owners"
                $ownerObjectIds += $owner
            }
            else
            {
                Write-Verbose "Owner is an UserPrincipalName so search for the user and add the ObjectId of the user to the list as desired owners"
                $user = Get-AzureADUser -Filter "UserPrincipalName eq '$owner'"
                $ownerObjectIds += $user.ObjectId
            }
        }

        # Add missing owners
        foreach ($owner in $ownerObjectIds) {
            if ($($currentOwners.ObjectId).Contains($owner) -eq $false) {
                Write-Verbose "Add applicationowner $owner"
                Add-AzureADApplicationOwner -ObjectId $application.ObjectId -RefObjectId $owner
                Add-AzureADServicePrincipalOwner -ObjectId $servicePrincipal.Id -RefObjectId $owner
            }
            else {
                Write-Verbose "Don't add $owner as owner because is already owner"
            }
        }

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

        if($Secrets){ 
            # Check for existing secrets and remove them so they can be re-created
            Write-Verbose "Checking for existing secrets"
            $appKeySecrets = Get-AzureADApplicationPasswordCredential -ObjectId $application.ObjectId

            if($appKeySecrets)  {
                foreach($existingSecret in $appKeySecrets) {
                    foreach($secret in $Secrets) {
                        if([System.Text.Encoding]::ASCII.GetString($existingSecret.CustomKeyIdentifier) -eq $secret.Description) {

                            $stringDescription = $secret.Description | Out-String
                            $trimmedStringDescription = $stringDescription -replace [Environment]::NewLine,"";

                            Write-Verbose "Removing existing key with description: $trimmedStringDescription"
                            Remove-AzureADApplicationPasswordCredential  -ObjectId $application.ObjectId -KeyId $existingSecret.KeyId
                        }
                    }
                }
            }

            # Create new secrets
            foreach($secret in $Secrets) {
                $endDate = [datetime]::ParseExact($secret.EndDate,'dd/MM/yyyy',[Globalization.CultureInfo]::InvariantCulture)
                
                $stringDescription = $secret.Description | Out-String
                $trimmedStringDescription = $stringDescription -replace [Environment]::NewLine,"";
                
                Write-Verbose "Creating new key with description: $trimmedStringDescription and end date $endDate"
                $appKeySecret = New-AzureADApplicationPasswordCredential -ObjectId $application.ObjectId -CustomKeyIdentifier $secret.Description -EndDate $endDate
                
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
Export-ModuleMember -Function Set-AadApplication