BeforeAll { 
    Remove-Module ManageAadApplications
    Import-Module .\ManageAadApplications.psm1
}

Describe 'Get-AadApplication' {
    Context "No parameters" {
        # It 'Given no parameters, it should show error' {
        #     Get-AadApplication | Should -Throw
        # }
    }

    Context "No parameter names" {
        It "Given an existing ObjectId should return application and service principal" {
            $result = Get-AadApplication 88a82126-c223-4f2e-b997-2fe44d9131eb
    
            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
            $result.ServicePrincipal | Should -BeNullOrEmpty -Not
            $result.Application.DisplayName | Should -Be "AzureAdApplicationManagementTestApp1"
            $result.ServicePrincipal.DisplayName | Should -Be "AzureAdApplicationManagementTestApp1"
        }
    }

    Context "Parameter ObjectId" {
        # It "Given empty parameter should show error" {
        #     Get-AadApplication "" | Should -Throw# -ExceptionType "ValidationMetadataException"
        # }

        It "Given not existing id should return null" {
            Get-AadApplication -ObjectId 88a82126-c223-4f2e-b997-2fe44d9131ec | Should -BeNullOrEmpty
        }

        It "Given an existing id should return application and service principal" {
            $result = Get-AadApplication -ObjectId 88a82126-c223-4f2e-b997-2fe44d9131eb
    
            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
            $result.ServicePrincipal | Should -BeNullOrEmpty -Not
            $result.Application.DisplayName | Should -Be "AzureAdApplicationManagementTestApp1"
            $result.ServicePrincipal.DisplayName | Should -Be "AzureAdApplicationManagementTestApp1"
        }
    }

    Context "Parameter ApplicationId" {
        # It "Given empty parameter should show error" {
        #     Get-AadApplication "" | Should -Throw# -ExceptionType "ValidationMetadataException"
        # }

        It "Given not existing id should return null" {
            Get-AadApplication -ApplicationId 88a82126-c223-4f2e-b997-2fe44d9131ec | Should -BeNullOrEmpty
        }

        It "Given an existing id should return application and service principal" {
            $result = Get-AadApplication -ApplicationId f3d89221-40cd-45bb-b329-35ebba17ff8a
    
            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
            $result.ServicePrincipal | Should -BeNullOrEmpty -Not
            $result.Application.DisplayName | Should -Be "AzureAdApplicationManagementTestApp1"
            $result.ServicePrincipal.DisplayName | Should -Be "AzureAdApplicationManagementTestApp1"
        }
    }

    Context "Parameter DisplayName" {
        # It "Given empty parameter should show error" {
        #     Get-AadApplication "" | Should -Throw# -ExceptionType "ValidationMetadataException"
        # }

        It "Given not existing name should return null" {
            Get-AadApplication -DisplayName "foo" | Should -BeNullOrEmpty
        }

        It "Given an existing name should return application and service principal" {
            $result = Get-AadApplication -DisplayName "AzureAdApplicationManagementTestApp1"
    
            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
            $result.ServicePrincipal | Should -BeNullOrEmpty -Not
            $result.Application.DisplayName | Should -Be "AzureAdApplicationManagementTestApp1"
            $result.ServicePrincipal.DisplayName | Should -Be "AzureAdApplicationManagementTestApp1"
        }
    }
}