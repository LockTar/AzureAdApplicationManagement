#Invoke-Pester -Output Detailed .\New-AadApplication.Tests.ps1

BeforeAll { 
    Remove-Module ManageAadApplications
    Import-Module .\ManageAadApplications.psm1
}

Describe 'New-AadApplication' {
    Context "New-AadApplication" {
        It "Given a name should return application and service principal with default identifieruri" {
            $result = New-AadApplication "AzureAdApplicationManagementTestApp1"
            
            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
            $result.ServicePrincipal | Should -BeNullOrEmpty -Not
            $result.Application.DisplayName | Should -Be "AzureAdApplicationManagementTestApp1"
            $result.Application.IdentifierUris[0] | Should -Be "api://$($result.Application.ApplicationId)"
            $result.ServicePrincipal.DisplayName | Should -Be "AzureAdApplicationManagementTestApp1"
        }
        
        It "Given an empty name should fail" {
            { New-AadApplication -DisplayName "" } | Should -Throw
        }

        It "Given a name should return application and service principal with default identifieruri" {
            $result = New-AadApplication -DisplayName "AzureAdApplicationManagementTestApp1"
            
            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
            $result.ServicePrincipal | Should -BeNullOrEmpty -Not
            $result.Application.DisplayName | Should -Be "AzureAdApplicationManagementTestApp1"
            $result.Application.IdentifierUris[0] | Should -Be "api://$($result.Application.ApplicationId)"
            $result.ServicePrincipal.DisplayName | Should -Be "AzureAdApplicationManagementTestApp1"
        }

        It "Given an empty identifieruri should return application and service principal with default identifieruri" {
            $result = New-AadApplication -DisplayName "AzureAdApplicationManagementTestApp1" -IdentifierUri ""
            
            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
            $result.ServicePrincipal | Should -BeNullOrEmpty -Not
            $result.Application.DisplayName | Should -Be "AzureAdApplicationManagementTestApp1"
            $result.Application.IdentifierUris[0] | Should -Be "api://$($result.Application.ApplicationId)"
            $result.ServicePrincipal.DisplayName | Should -Be "AzureAdApplicationManagementTestApp1"
        }

        It "Given an identifieruri should return application and service principal with given identifieruri" {
            $result = New-AadApplication -DisplayName "AzureAdApplicationManagementTestApp1" -IdentifierUri "https://SampleIdentifier"
            
            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
            $result.ServicePrincipal | Should -BeNullOrEmpty -Not
            $result.Application.DisplayName | Should -Be "AzureAdApplicationManagementTestApp1"
            $result.Application.IdentifierUris[0] | Should -Be "https://SampleIdentifier"
            $result.ServicePrincipal.DisplayName | Should -Be "AzureAdApplicationManagementTestApp1"
        }
        
        AfterEach { 
            Get-AzADApplication -DisplayName "AzureAdApplicationManagementTestApp1" | Remove-AzADApplication -Force
        }
    }
}
