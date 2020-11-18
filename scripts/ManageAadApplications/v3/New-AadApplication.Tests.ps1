BeforeAll { 
    Remove-Module ManageAadApplications
    Import-Module .\ManageAadApplications.psm1
}

Describe 'New-AadApplication' {
    Context "No parameter names" {
        It "Given a name should return application and service principal with default identifieruri" {
            $result = New-AadApplication "AzureAdApplicationManagementTestApp1"
            
            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
            $result.ServicePrincipal | Should -BeNullOrEmpty -Not
            $result.Application.DisplayName | Should -Be "AzureAdApplicationManagementTestApp1"
            $result.Application.IdentifierUris[0] | Should -Be "api://$($result.Application.ApplicationId)"
            $result.ServicePrincipal.DisplayName | Should -Be "AzureAdApplicationManagementTestApp1"
        }
        
        AfterEach { 
            Get-AzADApplication -DisplayName "AzureAdApplicationManagementTestApp1" | Remove-AzADApplication -Force
        }
    }
}
