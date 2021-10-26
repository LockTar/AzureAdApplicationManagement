#Invoke-Pester -Output Detailed .\Get-AadApplication.Tests.ps1

BeforeAll { 
    Remove-Module ManageAadApplications
    Import-Module .\ManageAadApplications.psm1
}

Describe 'Get-AadApplication' {
    Context "No parameter names" {
        BeforeAll { 
            $app1 = New-AzADApplication -DisplayName "AzureAdApplicationManagementTestApp1"
            $sp1 = Get-AzADApplication -ObjectId $app1.ObjectId | New-AzADServicePrincipal
        }

        It "Given an existing ObjectId should return application and service principal" {
            $result = Get-AadApplication $app1.ObjectId
    
            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
            $result.ServicePrincipal | Should -BeNullOrEmpty -Not
            $result.Application.DisplayName | Should -Be "AzureAdApplicationManagementTestApp1"
            $result.ServicePrincipal.DisplayName | Should -Be "AzureAdApplicationManagementTestApp1"
        }

        AfterAll { 
            Get-AzADApplication -ObjectId $app1.ObjectId | Remove-AzADApplication -Force
        }
    }

    Context "Parameter ObjectId" {
        BeforeAll { 
            $app2 = New-AzADApplication -DisplayName "AzureAdApplicationManagementTestApp2"
            $sp2 = Get-AzADApplication -ObjectId $app2.ObjectId | New-AzADServicePrincipal
        }

        It "Given empty parameter should show error" {
            { Get-AadApplication -ObjectId "" } | Should -Throw
        }

        It "Given not existing id should return null" {
            Get-AadApplication -ObjectId 88a82126-c223-4f2e-b997-2fe44d9131ec | Should -BeNullOrEmpty
        }

        It "Given not existing id and fail should give error" {
            { Get-AadApplication -ObjectId 88a82126-c223-4f2e-b997-2fe44d9131ec -FailIfNotFound } | Should -Throw
        }

        It "Given an existing id should return application and service principal" {
            $result = Get-AadApplication -ObjectId $app2.ObjectId
    
            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
            $result.ServicePrincipal | Should -BeNullOrEmpty -Not
            $result.Application.DisplayName | Should -Be "AzureAdApplicationManagementTestApp2"
            $result.ServicePrincipal.DisplayName | Should -Be "AzureAdApplicationManagementTestApp2"
        }

        AfterAll { 
            Get-AzADApplication -ObjectId $app2.ObjectId | Remove-AzADApplication -Force
        }
    }

    Context "Parameter ApplicationId" {
        BeforeAll { 
            $app3 = New-AzADApplication -DisplayName "AzureAdApplicationManagementTestApp3"
            $sp3 = Get-AzADApplication -ObjectId $app3.ObjectId | New-AzADServicePrincipal
        }
        
        It "Given empty parameter should show error" {
            { Get-AadApplication -ApplicationId "" } | Should -Throw
        }

        It "Given not existing id should return null" {
            Get-AadApplication -ApplicationId 88a82126-c223-4f2e-b997-2fe44d9131ec | Should -BeNullOrEmpty
        }
        
        It "Given not existing id and fail should give error" {
            { Get-AadApplication -ApplicationId 88a82126-c223-4f2e-b997-2fe44d9131ec -FailIfNotFound } | Should -Throw
        }

        It "Given an existing id should return application and service principal" {
            $result = Get-AadApplication -ApplicationId $app3.ApplicationId
    
            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
            $result.ServicePrincipal | Should -BeNullOrEmpty -Not
            $result.Application.DisplayName | Should -Be "AzureAdApplicationManagementTestApp3"
            $result.ServicePrincipal.DisplayName | Should -Be "AzureAdApplicationManagementTestApp3"
        }
        
        AfterAll { 
            Get-AzADApplication -ObjectId $app3.ObjectId | Remove-AzADApplication -Force
        }
    }

    Context "Parameter DisplayName" {
        BeforeAll { 
            $app4 = New-AzADApplication -DisplayName "AzureAdApplicationManagementTestApp4"
            $sp4 = Get-AzADApplication -ObjectId $app4.ObjectId | New-AzADServicePrincipal
        }

        It "Given empty parameter should show error" {
            { Get-AadApplication -DisplayName "" } | Should -Throw
        }

        It "Given not existing name should return null" {
            Get-AadApplication -DisplayName "ThisOneShouldNotExist123" | Should -BeNullOrEmpty
        }
        
        It "Given not existing id and fail should give error" {
            { Get-AadApplication -DisplayName "ThisOneShouldNotExist123" -FailIfNotFound } | Should -Throw
        }

        It "Given an existing name should return application and service principal" {
            $result = Get-AadApplication -DisplayName $app4.DisplayName
    
            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
            $result.ServicePrincipal | Should -BeNullOrEmpty -Not
            $result.Application.DisplayName | Should -Be "AzureAdApplicationManagementTestApp4"
            $result.ServicePrincipal.DisplayName | Should -Be "AzureAdApplicationManagementTestApp4"
        }
        
        AfterAll { 
            Get-AzADApplication -ObjectId $app4.ObjectId | Remove-AzADApplication -Force
        }
    }
}
