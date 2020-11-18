# BeforeAll { 
#     Import-Module .\ManageAadApplications.psm1
# }

Describe 'Get-AadApplication' {
    Context "No parameters" {
        # It 'Given no parameters, it should show error' {
        #     Get-AadApplication | Should -Throw
        # }
    }

    Context "Parameter DisplayName" {
        # It "Given empty parameter should show error" {
        #     Get-AadApplication "" | Should -Throw# -ExceptionType "ValidationMetadataException"
        # }

        It "Given not existing name should return null" {
            Get-AadApplication -DisplayName "foo" | Should -BeNullOrEmpty
        }

        It "Given an existing name should return application and service principal" {
            $result = Get-AadApplication -DisplayName "TestRalph"
            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
            $result.ServicePrincipal | Should -BeNullOrEmpty -Not
            $result.Application.DisplayName | Should -Be "TestRalph"
        }
    }
}

# AfterAll {
#     Remove-Module ManageAadApplications
# }