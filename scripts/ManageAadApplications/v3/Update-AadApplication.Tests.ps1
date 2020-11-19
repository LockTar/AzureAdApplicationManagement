BeforeAll { 
    Remove-Module ManageAadApplications
    Import-Module .\ManageAadApplications.psm1
}

Describe 'Update-AadApplication' {
    Context "Update-AadApplication" {
        BeforeEach { 
            # $app1 = New-AzADApplication -DisplayName "AzureAdApplicationManagementTestApp1" -IdentifierUris "https://AzureAdApplicationManagementTestApp1"
            # $sp1 = Get-AzADApplication -ObjectId $app1.ObjectId | New-AzADServicePrincipal
        }
        
        # It "Given empty objectid should throw error" {
        #     { Update-AadApplication "" } | Should -Throw "Cannot validate argument on parameter 'ObjectId'. The argument is null or empty. Provide an argument that is not null or empty, and then try the command again."
        # }

        # It "Given invalid objectid should throw error" {
        #     { Update-AadApplication -ObjectId "foo" } | Should -Throw "Invalid object identifier 'foo'."
        # }

        # It "Given non existing objectid should throw error" {
        #     { Update-AadApplication -ObjectId 88a82126-c223-4f2e-b997-2fe44d9131ec } | Should -Throw "Resource '88a82126-c223-4f2e-b997-2fe44d9131ec' does not exist or one of its queried reference-property objects are not present."
        # }

        # It "Given only existing objectid should give app and sp back" {
        #     $result = Update-AadApplication -ObjectId $app1.ObjectId

        #     $result | Should -BeNullOrEmpty -Not
        #     $result.Application | Should -BeNullOrEmpty -Not
        #     $result.ServicePrincipal | Should -BeNullOrEmpty -Not
        #     $result.Application.DisplayName | Should -Be "AzureAdApplicationManagementTestApp1"
        #     $result.ServicePrincipal.DisplayName | Should -Be "AzureAdApplicationManagementTestApp1"
        # }

        # It "Given empty ResourceAccessFilePath should skip ResourceAccess update" {
        #     $result = Update-AadApplication -ObjectId $app1.ObjectId -ResourceAccessFilePath "" -Verbose

        #     $result | Should -BeNullOrEmpty -Not
        #     $result.Application | Should -BeNullOrEmpty -Not
        #     $result.Application.AppPermissions.Count | Should -Be 0
        # }

        # It "Given invalid ResourceAccessFilePath should update ResourceAccess" {
        #     { Update-AadApplication -ObjectId $app1.ObjectId -ResourceAccessFilePath $PSScriptRoot"\..\..\Test-RequiredResourceAccessInvalidName.json" -Verbose } | Should -Throw "Invalid file path for ResourceAccessFilePath"
        # }

        # It "Given ResourceAccessFilePath should update ResourceAccess" {
        #     Write-Host $PSScriptRoot

        #     $result = Update-AadApplication -ObjectId 2276194d-d07e-4420-b2d8-dd35a6501f95 -ResourceAccessFilePath $PSScriptRoot"\..\..\Test-RequiredResourceAccess.json" -Verbose

        #     $result | Should -BeNullOrEmpty -Not
        #     $result.Application | Should -BeNullOrEmpty -Not
        #     $result.RequiredResourceAccess | Should -BeNullOrEmpty -Not
        #     $result.RequiredResourceAccess.Count | Should -Be 2
        # }

        # It "Given AppRolesFilePath should update AppRoles" {
        #     Write-Host $PSScriptRoot

        #     $result = Update-AadApplication -ObjectId 2276194d-d07e-4420-b2d8-dd35a6501f95 -AppRolesFilePath $PSScriptRoot"\..\..\Test-AppRoles.json" -Verbose

        #     $result | Should -BeNullOrEmpty -Not
        #     $result.Application | Should -BeNullOrEmpty -Not
        #     $result.RequiredResourceAccess.Count | Should -Be 2
        #     $result.AppRoles | Should -BeNullOrEmpty -Not
        #     $result.AppRoles.Count | Should -Be 3
        # }

        # It "Given empty AppRolesFilePath should skip AppRoles update" {
        #     { Update-AadApplication -ObjectId 2276194d-d07e-4420-b2d8-dd35a6501f95 -AppRolesFilePath "" -Verbose } | Should -Throw "Cannot bind argument to parameter 'Path' because it is an empty string."
        # }

        # It "Given invalid AppRolesFilePath should update AppRoles" {
        #     { Update-AadApplication -ObjectId 2276194d-d07e-4420-b2d8-dd35a6501f95 -AppRolesFilePath $PSScriptRoot"\..\..\Test-AppRolesInvalidName.json" -Verbose } | Should -Throw "Invalid file path for AppRolesFilePath"
        # }
        
        AfterEach { 
            #Get-AzADApplication -DisplayName "AzureAdApplicationManagementTestApp1" | Remove-AzADApplication -Force
        }
    }
}
