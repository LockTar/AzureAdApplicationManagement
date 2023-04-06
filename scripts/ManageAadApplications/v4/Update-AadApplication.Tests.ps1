#Invoke-Pester -Output Detailed .\Update-AadApplication.Tests.ps1
#$result | ConvertTo-Json -Depth 15 | Write-Host

BeforeAll { 
    Remove-Module ManageAadApplications
    Import-Module .\ManageAadApplications.psm1
}

Describe 'Update-AadApplication' {
    Context "ObjectId" {
        BeforeEach { 
            $app1 = New-MgApplication -DisplayName "AzureAdApplicationManagementTestApp1"
            $app1 = Get-MgApplication -ApplicationId $app1.Id
            $sp1 = New-MgServicePrincipal -AppId $app1.AppId
        }
        
        It "Given empty objectid should throw error" {
            { Update-AadApplication "" } | Should -Throw "Cannot validate argument on parameter 'ObjectId'. The argument is null or empty. Provide an argument that is not null or empty, and then try the command again."
        }

        It "Given invalid objectid should throw error" {
            { Update-AadApplication -ObjectId "foo" } | Should -Throw "Invalid object identifier 'foo'."
        }

        It "Given non existing objectid should throw error" {
            { Update-AadApplication -ObjectId 88a82126-c223-4f2e-b997-2fe44d9131ec } | Should -Throw "Resource '88a82126-c223-4f2e-b997-2fe44d9131ec' does not exist or one of its queried reference-property objects are not present."
        }

        It "Given only existing objectid should give app and sp back" {
            $result = Update-AadApplication -ObjectId $app1.Id

            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
            $result.ServicePrincipal | Should -BeNullOrEmpty -Not
            $result.Application.DisplayName | Should -Be "AzureAdApplicationManagementTestApp1"
            $result.ServicePrincipal.DisplayName | Should -Be "AzureAdApplicationManagementTestApp1"
        }
        
        AfterEach { 
            $appToRemove = Get-MgApplication -ApplicationId $app1.Id
            $spToRemove = Get-MgServicePrincipal -ServicePrincipalId $sp1.Id

            Remove-MgApplication -ApplicationId $appToRemove.Id
            $deletedApp = Get-MgDirectoryDeletedItem -DirectoryObjectId $appToRemove.Id
            Remove-MgDirectoryDeletedItem -DirectoryObjectId $deletedApp.Id

           $deletedSp = Get-MgDirectoryDeletedItem -DirectoryObjectId $spToRemove.Id
           Remove-MgDirectoryDeletedItem -DirectoryObjectId $deletedSp.Id
        }
    }

    Context "ResourceAccessFilePath" {
        BeforeEach { 
            $app1 = New-MgApplication -DisplayName "AzureAdApplicationManagementTestApp1"
            $app1 = Get-MgApplication -ApplicationId $app1.Id
            $sp1 = New-MgServicePrincipal -AppId $app1.AppId
        }

        It "Given empty ResourceAccessFilePath should skip update" {
            { Update-AadApplication -ObjectId $app1.Id -ResourceAccessFilePath "" } | Should -Throw -Not
        }

        It "Given invalid ResourceAccessFilePath should throw error" {
            { Update-AadApplication -ObjectId $app1.Id -ResourceAccessFilePath $PSScriptRoot"\..\..\Test-RequiredResourceAccessInvalidName.json" } | Should -Throw "Invalid file path for ResourceAccessFilePath"
        }

        It "Given ResourceAccessFilePath should update ResourceAccess" {
            $result = Update-AadApplication -ObjectId $app1.Id -ResourceAccessFilePath $PSScriptRoot"\..\..\Test-RequiredResourceAccess.json"

            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
            $result.RequiredResourceAccess | Should -BeNullOrEmpty -Not
            $result.RequiredResourceAccess.Count | Should -Be 2
        }
        
        AfterEach { 
            $appToRemove = Get-MgApplication -ApplicationId $app1.Id
            $spToRemove = Get-MgServicePrincipal -ServicePrincipalId $sp1.Id

            Remove-MgApplication -ApplicationId $appToRemove.Id
            $deletedApp = Get-MgDirectoryDeletedItem -DirectoryObjectId $appToRemove.Id
            Remove-MgDirectoryDeletedItem -DirectoryObjectId $deletedApp.Id

            $deletedSp = Get-MgDirectoryDeletedItem -DirectoryObjectId $spToRemove.Id
            Remove-MgDirectoryDeletedItem -DirectoryObjectId $deletedSp.Id
        }
    }

    Context "AppRolesFilePath" {
        BeforeEach { 
            $app1 = New-MgApplication -DisplayName "AzureAdApplicationManagementTestApp1"
            $app1 = Get-MgApplication -ApplicationId $app1.Id
            $sp1 = New-MgServicePrincipal -AppId $app1.AppId
        }

        It "Given empty AppRolesFilePath should throw error" {
            { Update-AadApplication -ObjectId $app1.Id -AppRolesFilePath "" } | Should -Throw -Not
        }

        It "Given invalid AppRolesFilePath should throw error" {
            { Update-AadApplication -ObjectId $app1.Id -AppRolesFilePath $PSScriptRoot"\..\..\Test-AppRolesInvalidName.json" } | Should -Throw "Invalid file path for AppRolesFilePath"
        }

        It "Given AppRolesFilePath should update AppRoles" {
            $result = Update-AadApplication -ObjectId $app1.Id -AppRolesFilePath $PSScriptRoot"\..\..\Test-AppRoles.json"

            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
            $result.RequiredResourceAccess.Count | Should -Be 0
            $result.AppRoles | Should -BeNullOrEmpty -Not
            $result.AppRoles.Count | Should -Be 3
        }
        
        AfterEach { 
            $appToRemove = Get-MgApplication -ApplicationId $app1.Id
            $spToRemove = Get-MgServicePrincipal -ServicePrincipalId $sp1.Id

            Remove-MgApplication -ApplicationId $appToRemove.Id
            $deletedApp = Get-MgDirectoryDeletedItem -DirectoryObjectId $appToRemove.Id
            Remove-MgDirectoryDeletedItem -DirectoryObjectId $deletedApp.Id

            $deletedSp = Get-MgDirectoryDeletedItem -DirectoryObjectId $spToRemove.Id
            Remove-MgDirectoryDeletedItem -DirectoryObjectId $deletedSp.Id
        }
    }

    Context "DisplayName" {
        BeforeEach { 
            $app1 = New-MgApplication -DisplayName "AzureAdApplicationManagementTestApp1"
            $app1 = Get-MgApplication -ApplicationId $app1.Id
            $sp1 = New-MgServicePrincipal -AppId $app1.AppId
        }

        It "Given no DisplayName should skip update" {
            $result = Update-AadApplication -ObjectId $app1.Id

            $result | Should -BeNullOrEmpty -Not
        }

        It "Given empty DisplayName should throw error" {
            { Update-AadApplication -ObjectId $app1.Id -DisplayName "" } | Should -Throw "Cannot validate argument on parameter 'DisplayName'. The argument is null or empty. Provide an argument that is not null or empty, and then try the command again."
        }

        It "Given DisplayName should update value" {
            $result = Update-AadApplication -ObjectId $app1.Id -DisplayName "AzureAdApplicationManagementTestApp1NewName"

            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
            $result.Application.DisplayName | Should -Be "AzureAdApplicationManagementTestApp1NewName"
            $result.ServicePrincipal.DisplayName | Should -Be "AzureAdApplicationManagementTestApp1NewName"
        }
        
        AfterEach { 
            $appToRemove = Get-MgApplication -ApplicationId $app1.Id
            $spToRemove = Get-MgServicePrincipal -ServicePrincipalId $sp1.Id

            Remove-MgApplication -ApplicationId $appToRemove.Id
            $deletedApp = Get-MgDirectoryDeletedItem -DirectoryObjectId $appToRemove.Id
            Remove-MgDirectoryDeletedItem -DirectoryObjectId $deletedApp.Id

            $deletedSp = Get-MgDirectoryDeletedItem -DirectoryObjectId $spToRemove.Id
            Remove-MgDirectoryDeletedItem -DirectoryObjectId $deletedSp.Id
        }
    }

    Context "IdentifierUri" {
        BeforeEach { 
            $app1 = New-MgApplication -DisplayName "AzureAdApplicationManagementTestApp1"
            $app1 = Get-MgApplication -ApplicationId $app1.Id
            $sp1 = New-MgServicePrincipal -AppId $app1.AppId
        }

        It "Given no IdentifierUri should skip update" {
            $result = Update-AadApplication -ObjectId $app1.Id

            $result | Should -BeNullOrEmpty -Not
        }

        It "Given empty IdentifierUri should throw error" {
            { Update-AadApplication -ObjectId $app1.Id -IdentifierUri "" } | Should -Throw "Cannot validate argument on parameter 'IdentifierUri'. The argument is null or empty. Provide an argument that is not null or empty, and then try the command again."
        }

        It "Given IdentifierUri should update value" {
            $result = Update-AadApplication -ObjectId $app1.Id -IdentifierUri "https://ralphjansenoutlook.onmicrosoft.com/AzureAdApplicationManagementTestApp1"

            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
            $result.Application.IdentifierUris | Should -Be "https://ralphjansenoutlook.onmicrosoft.com/AzureAdApplicationManagementTestApp1"
        }
        
        AfterEach { 
            $appToRemove = Get-MgApplication -ApplicationId $app1.Id
            $spToRemove = Get-MgServicePrincipal -ServicePrincipalId $sp1.Id

            Remove-MgApplication -ApplicationId $appToRemove.Id
            $deletedApp = Get-MgDirectoryDeletedItem -DirectoryObjectId $appToRemove.Id
            Remove-MgDirectoryDeletedItem -DirectoryObjectId $deletedApp.Id

            $deletedSp = Get-MgDirectoryDeletedItem -DirectoryObjectId $spToRemove.Id
            Remove-MgDirectoryDeletedItem -DirectoryObjectId $deletedSp.Id
        }
    }

    Context "HomePage" {
        BeforeEach { 
            $app1 = New-MgApplication -DisplayName "AzureAdApplicationManagementTestApp1"
            $app1 = Get-MgApplication -ApplicationId $app1.Id
            $sp1 = New-MgServicePrincipal -AppId $app1.AppId
        }

        It "Given no HomePage should skip update" {
            $result = Update-AadApplication -ObjectId $app1.Id

            $result | Should -BeNullOrEmpty -Not
            $result.Application.Web.HomePageUrl | Should -BeNullOrEmpty
            $result.ServicePrincipal.HomePage | Should -BeNullOrEmpty
        }

        It "Given app without HomePage, set HomePage to null should leave the app as is" {
            $result = Update-AadApplication -ObjectId $app1.Id -WebHomePageUrl $null            

            $result | Should -BeNullOrEmpty -Not
            $result.Application.Web.HomePageUrl | Should -BeNullOrEmpty
            $result.ServicePrincipal.HomePage | Should -BeNullOrEmpty
        }

        It "Given app without HomePage, set HomePage to empty string should leave the app as is" {
            $result = Update-AadApplication -ObjectId $app1.Id -WebHomePageUrl ""

            $result | Should -BeNullOrEmpty -Not
            $result.Application.Web.HomePageUrl | Should -BeNullOrEmpty
            $result.ServicePrincipal.HomePage | Should -BeNullOrEmpty
        }

        It "Given app with HomePage, set HomePage to null should throw error" {
            Update-AadApplication -ObjectId $app1.Id -WebHomePageUrl "https://sampleurl.info"
            
            { Update-AadApplication -ObjectId $app1.Id -WebHomePageUrl $null } | Should -Throw "Invalid value specified for property 'web' of resource 'Application'."
        }

        It "Given app with HomePage, set HomePage to empty string should throw error" {
            Update-AadApplication -ObjectId $app1.Id -WebHomePageUrl "https://sampleurl.info"

            { Update-AadApplication -ObjectId $app1.Id -WebHomePageUrl "" } | Should -Throw "Invalid value specified for property 'web' of resource 'Application'."
        }

        It "Given app without HomePage, set HomePage with correct value should update value" {
            $result = Update-AadApplication -ObjectId $app1.Id -WebHomePageUrl "https://sampleurl.info"
            
            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
            $result.Application.Web.HomePageUrl | Should -Be "https://sampleurl.info"
        }

        It "Given app with HomePage, set new HomePage should update old value" {
            $result = Update-AadApplication -ObjectId $app1.Id -WebHomePageUrl "https://old.info"
            $result = Update-AadApplication -ObjectId $app1.Id -WebHomePageUrl "https://sampleurl.info"

            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
            $result.Application.Web.HomePageUrl | Should -Be "https://sampleurl.info"
        }
        
        AfterEach { 
            $appToRemove = Get-MgApplication -ApplicationId $app1.Id
            $spToRemove = Get-MgServicePrincipal -ServicePrincipalId $sp1.Id

            Remove-MgApplication -ApplicationId $appToRemove.Id
            $deletedApp = Get-MgDirectoryDeletedItem -DirectoryObjectId $appToRemove.Id
            Remove-MgDirectoryDeletedItem -DirectoryObjectId $deletedApp.Id

            $deletedSp = Get-MgDirectoryDeletedItem -DirectoryObjectId $spToRemove.Id
            Remove-MgDirectoryDeletedItem -DirectoryObjectId $deletedSp.Id
        }
    }

    Context "SignInAudience" {
        BeforeEach { 
            $app1 = New-MgApplication -DisplayName "AzureAdApplicationManagementTestApp1"
            $app1 = Get-MgApplication -ApplicationId $app1.Id
            $sp1 = New-MgServicePrincipal -AppId $app1.AppId
        }

        It "Given no SignInAudience should leave at default value: 'AzureADandPersonalMicrosoftAccount'" {
            $result = Update-AadApplication -ObjectId $app1.Id

            $result | Should -BeNullOrEmpty -Not
            $result.Application.SignInAudience | Should -Be "AzureADandPersonalMicrosoftAccount"
        }

        It "Given SignInAudience should update value" {
            $result = Update-AadApplication -ObjectId $app1.Id -SignInAudience "AzureADMyOrg"

            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
            $result.Application.SignInAudience | Should -Be "AzureADMyOrg"
        }

        It "Given new SignInAudience should update old SignInAudience value" {
            $result = Update-AadApplication -ObjectId $app1.Id -SignInAudience "AzureADMyOrg"
            $result = Update-AadApplication -ObjectId $app1.Id -SignInAudience "AzureADMultipleOrgs"

            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
            $result.Application.SignInAudience | Should -Be "AzureADMultipleOrgs"
        }
        
        AfterEach { 
            $appToRemove = Get-MgApplication -ApplicationId $app1.Id
            $spToRemove = Get-MgServicePrincipal -ServicePrincipalId $sp1.Id

            Remove-MgApplication -ApplicationId $appToRemove.Id
            $deletedApp = Get-MgDirectoryDeletedItem -DirectoryObjectId $appToRemove.Id
            Remove-MgDirectoryDeletedItem -DirectoryObjectId $deletedApp.Id

           $deletedSp = Get-MgDirectoryDeletedItem -DirectoryObjectId $spToRemove.Id
           Remove-MgDirectoryDeletedItem -DirectoryObjectId $deletedSp.Id
        }
    }

    Context "WebRedirectUris" {
        BeforeEach { 
            $app1 = New-MgApplication -DisplayName "AzureAdApplicationManagementTestApp1"
            $app1 = Get-MgApplication -ApplicationId $app1.Id
            $sp1 = New-MgServicePrincipal -AppId $app1.AppId
        }

        It "Given no WebRedirectUris should skip update" {
            $result = Update-AadApplication -ObjectId $app1.Id

            $result | Should -BeNullOrEmpty -Not
            $result.Application.WebRedirectUris | Should -BeNullOrEmpty
        }

        It "Given app without WebRedirectUris, set null as WebRedirectUris should leave the app as is" {
            $result = Update-AadApplication -ObjectId $app1.Id -WebRedirectUris $null

            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
            $result.Application.WebRedirectUris | Should -BeNullOrEmpty
        }

        It "Given app without WebRedirectUris, set empty as WebRedirectUris should throw error" {
            { $result = Update-AadApplication -ObjectId $app1.Id -WebRedirectUris "" } | Should -Throw "WebRedirectUris can not be an empty string"

            # $result | Should -BeNullOrEmpty -Not
            # $result.Application | Should -BeNullOrEmpty -Not
            # $result.Application.WebRedirectUris | Should -BeNullOrEmpty
        }

        It "Given app with WebRedirectUris, set empty WebRedirectUris should throw error" {
            Update-AadApplication -ObjectId $app1.Id -WebRedirectUris "https://sampleurl.info"

            { Update-AadApplication -ObjectId $app1.Id -WebRedirectUris "" } | Should -Throw "WebRedirectUris can not be an empty string"
        }

        It "Given app with WebRedirectUris, set null as WebRedirectUris should remove them" {
            Update-AadApplication -ObjectId $app1.Id -WebRedirectUris "https://sampleurl.info"

            { Update-AadApplication -ObjectId $app1.Id -WebRedirectUris $null } | Should -Throw "WebRedirectUris can not be an empty string"
        }

        It "Given app without WebRedirectUris, set WebRedirectUris should update value" {
            $result = Update-AadApplication -ObjectId $app1.Id -WebRedirectUris "https://sampleurl.info"

            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
            $result.Application.Web.RedirectUris | Should -Be "https://sampleurl.info"
        }

        It "Given app with WebRedirectUris, set new WebRedirectUris should update old value" {
            $result = Update-AadApplication -ObjectId $app1.Id -WebRedirectUris "https://old.info"
            $result = Update-AadApplication -ObjectId $app1.Id -WebRedirectUris "https://sampleurl.info"

            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
            $result.Application.Web.RedirectUris | Should -Be "https://sampleurl.info"
        }
        
        AfterEach { 
            $appToRemove = Get-MgApplication -ApplicationId $app1.Id
            $spToRemove = Get-MgServicePrincipal -ServicePrincipalId $sp1.Id

            Remove-MgApplication -ApplicationId $appToRemove.Id
            $deletedApp = Get-MgDirectoryDeletedItem -DirectoryObjectId $appToRemove.Id
            Remove-MgDirectoryDeletedItem -DirectoryObjectId $deletedApp.Id

            $deletedSp = Get-MgDirectoryDeletedItem -DirectoryObjectId $spToRemove.Id
            Remove-MgDirectoryDeletedItem -DirectoryObjectId $deletedSp.Id
        }
    }

    Context "Owners" {
        BeforeEach { 
            $app1 = New-MgApplication -DisplayName "AzureAdApplicationManagementTestApp1"
            $app1 = Get-MgApplication -ApplicationId $app1.Id
            $sp1 = New-MgServicePrincipal -AppId $app1.AppId
        }

        It "Given no Owners should skip update" {
            $result = Update-AadApplication -ObjectId $app1.Id

            $result | Should -BeNullOrEmpty -Not
            $result.Owners.Count | Should -Be 1
        }

        It "Given empty Owners should throw error" {
            { Update-AadApplication -ObjectId $app1.Id -Owners "" } | Should -Throw "Cannot validate argument on parameter 'Owners'. The argument is null, empty, or an element of the argument collection contains a null value. Supply a collection that does not contain any null values and then try the command again."
        }

        It "Given Owners should update value" {
            $result = Update-AadApplication -ObjectId $app1.Id -Owners "2a191095-ecff-4122-8992-e65344d01a23"

            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
            $result.Owners.Id | Should -Be "2a191095-ecff-4122-8992-e65344d01a23"
        }

        It "Given new Owners should update old Owners value" {
            $result = Update-AadApplication -ObjectId $app1.Id -Owners "2a191095-ecff-4122-8992-e65344d01a23"
            $result = Update-AadApplication -ObjectId $app1.Id -Owners "fec3a6da-172f-4281-90d0-b4f40e8d248e"

            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
            $result.Owners.Id | Should -Be "fec3a6da-172f-4281-90d0-b4f40e8d248e"
        }
        
        AfterEach { 
            $appToRemove = Get-MgApplication -ApplicationId $app1.Id
            $spToRemove = Get-MgServicePrincipal -ServicePrincipalId $sp1.Id

            Remove-MgApplication -ApplicationId $appToRemove.Id
            $deletedApp = Get-MgDirectoryDeletedItem -DirectoryObjectId $appToRemove.Id
            Remove-MgDirectoryDeletedItem -DirectoryObjectId $deletedApp.Id

            $deletedSp = Get-MgDirectoryDeletedItem -DirectoryObjectId $spToRemove.Id
            Remove-MgDirectoryDeletedItem -DirectoryObjectId $deletedSp.Id
        }
    }

    Context "Secrets" {
        BeforeEach { 
            $app1 = New-MgApplication -DisplayName "AzureAdApplicationManagementTestApp1"
            $app1 = Get-MgApplication -ApplicationId $app1.Id
            $sp1 = New-MgServicePrincipal -AppId $app1.AppId
        }

        It "Given no Secrets should skip update" {
            $result = Update-AadApplication -ObjectId $app1.Id

            $result | Should -BeNullOrEmpty -Not
        }

        It "Given empty Secrets should skip update" {
            { Update-AadApplication -ObjectId $app1.Id -Secrets "" } | Should -Throw -Not
        }

        It "Given Secrets should update value" {
            $secrets = '[{ ''Description'': ''testkey'', ''EndDate'': ''01/12/2024'' }]'
            $secretsArray = $secrets | ConvertFrom-Json

            # Check output for the above secret because will not send to output for security reasons
            $result = Update-AadApplication -ObjectId $app1.Id -Secrets $secretsArray

            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
        }

        It "Given Secrets should update existing secret" {
            $secretsOld = '[{ ''Description'': ''testkeyold'', ''EndDate'': ''01/12/2024'' }]'
            $secretsNew = '[{ ''Description'': ''testkeynew'', ''EndDate'': ''01/12/2024'' }]'
            
            $secretsArrayOld = $secretsOld | ConvertFrom-Json
            $secretsArrayNew = $secretsNew | ConvertFrom-Json
`
            # Check output for the above secret because will not send to output for security reasons
            $result = Update-AadApplication -ObjectId $app1.Id -Secrets $secretsArrayOld
            $result = Update-AadApplication -ObjectId $app1.Id -Secrets $secretsArrayNew

            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
        }
        
        AfterEach { 
            $appToRemove = Get-MgApplication -ApplicationId $app1.Id
            $spToRemove = Get-MgServicePrincipal -ServicePrincipalId $sp1.Id

            Remove-MgApplication -ApplicationId $appToRemove.Id
            $deletedApp = Get-MgDirectoryDeletedItem -DirectoryObjectId $appToRemove.Id
            Remove-MgDirectoryDeletedItem -DirectoryObjectId $deletedApp.Id

            $deletedSp = Get-MgDirectoryDeletedItem -DirectoryObjectId $spToRemove.Id
            Remove-MgDirectoryDeletedItem -DirectoryObjectId $deletedSp.Id
        }
    }

    Context "AppRoleAssignmentRequired" {
        BeforeEach { 
            $app1 = New-MgApplication -DisplayName "AzureAdApplicationManagementTestApp1"
            $app1 = Get-MgApplication -ApplicationId $app1.Id
            $sp1 = New-MgServicePrincipal -AppId $app1.AppId
        }

        It "Given no AppRoleAssignmentRequired should skip update" {
            $result = Update-AadApplication -ObjectId $app1.Id

            $result | Should -BeNullOrEmpty -Not
            $result.SpAppRoleAssignmentRequired | Should -Be $false
        }

        It "Given AppRoleAssignmentRequired should update value" {
            $result = Update-AadApplication -ObjectId $app1.Id -DisplayName "AzureAdApplicationManagementTestApp2" -AppRoleAssignmentRequired $true -WebHomePageUrl "https://test.com"

            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
            $result.SpAppRoleAssignmentRequired | Should -Be $true
            $result.Application.DisplayName | Should -Be "AzureAdApplicationManagementTestApp2"
            $result.ServicePrincipal.DisplayName | Should -Be "AzureAdApplicationManagementTestApp2"
            $result.Application.Web.HomePageUrl | Should -Be "https://test.com"
        }

        It "Given new AppRoleAssignmentRequired should update old AppRoleAssignmentRequired value" {
            $result = Update-AadApplication -ObjectId $app1.Id -AppRoleAssignmentRequired $true
            $result = Update-AadApplication -ObjectId $app1.Id -AppRoleAssignmentRequired $false

            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
            $result.SpAppRoleAssignmentRequired | Should -Be $false
        }
        
        AfterEach { 
            $appToRemove = Get-MgApplication -ApplicationId $app1.Id
            $spToRemove = Get-MgServicePrincipal -ServicePrincipalId $sp1.Id

            Remove-MgApplication -ApplicationId $appToRemove.Id
            $deletedApp = Get-MgDirectoryDeletedItem -DirectoryObjectId $appToRemove.Id
            Remove-MgDirectoryDeletedItem -DirectoryObjectId $deletedApp.Id

            $deletedSp = Get-MgDirectoryDeletedItem -DirectoryObjectId $spToRemove.Id
            Remove-MgDirectoryDeletedItem -DirectoryObjectId $deletedSp.Id
        }
    }

    Context "EnableAccessTokenIssuance" {
        BeforeEach { 
            $app1 = New-MgApplication -DisplayName "AzureAdApplicationManagementTestApp1"
            $app1 = Get-MgApplication -ApplicationId $app1.Id
            $sp1 = New-MgServicePrincipal -AppId $app1.AppId
        }

        It "Given no EnableAccessTokenIssuance should skip update" {
            $result = Update-AadApplication -ObjectId $app1.Id

            $result | Should -BeNullOrEmpty -Not
            $result.Application.Web.ImplicitGrantSettings.EnableAccessTokenIssuance | Should -Be $false
        }

        It "Given EnableAccessTokenIssuance should update value" {
            $result = Update-AadApplication -ObjectId $app1.Id -EnableAccessTokenIssuance $true

            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
            $result.Application.Web.ImplicitGrantSettings.EnableAccessTokenIssuance | Should -Be $true
        }

        It "Given new EnableAccessTokenIssuance should update old EnableAccessTokenIssuance value" {
            $result = Update-AadApplication -ObjectId $app1.Id -EnableAccessTokenIssuance $true
            $result = Update-AadApplication -ObjectId $app1.Id -EnableAccessTokenIssuance $false

            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
            $result.Application.Web.ImplicitGrantSettings.EnableAccessTokenIssuance | Should -Be $false
        }
        
        AfterEach { 
            $appToRemove = Get-MgApplication -ApplicationId $app1.Id
            $spToRemove = Get-MgServicePrincipal -ServicePrincipalId $sp1.Id

            Remove-MgApplication -ApplicationId $appToRemove.Id
            $deletedApp = Get-MgDirectoryDeletedItem -DirectoryObjectId $appToRemove.Id
            Remove-MgDirectoryDeletedItem -DirectoryObjectId $deletedApp.Id

            $deletedSp = Get-MgDirectoryDeletedItem -DirectoryObjectId $spToRemove.Id
            Remove-MgDirectoryDeletedItem -DirectoryObjectId $deletedSp.Id
        }
    }
}
