#Invoke-Pester -Output Detailed .\Get-AadApplication.Tests.ps1

BeforeAll { 
    Remove-Module ManageAadApplications
    Import-Module .\ManageAadApplications.psm1
}

Describe 'Get-AadApplication' {
    Context "No parameter names" {
        BeforeAll { 
            $app = New-MgApplication -DisplayName "AzureAdApplicationManagementTestApp1"
            $app = Get-MgApplication -ApplicationId $app.Id
            $sp = New-MgServicePrincipal -AppId $app.AppId
        }

        It "Given an existing ObjectId should return application and service principal" {
            $result = Get-AadApplication $app.Id
    
            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
            $result.ServicePrincipal | Should -BeNullOrEmpty -Not
            $result.Application.DisplayName | Should -Be "AzureAdApplicationManagementTestApp1"
            $result.ServicePrincipal.DisplayName | Should -Be "AzureAdApplicationManagementTestApp1"
        }

        AfterAll { 
            $appToRemove = Get-MgApplication -ApplicationId $app.Id
            $spToRemove = Get-MgServicePrincipal -ServicePrincipalId $sp.Id

            Remove-MgApplication -ApplicationId $appToRemove.Id
            $deletedApp = Get-MgDirectoryDeletedItem -DirectoryObjectId $appToRemove.Id
            Remove-MgDirectoryDeletedItem -DirectoryObjectId $deletedApp.Id

            $deletedSp = Get-MgDirectoryDeletedItem -DirectoryObjectId $spToRemove.Id
            Remove-MgDirectoryDeletedItem -DirectoryObjectId $deletedSp.Id
        }
    }

    Context "Parameter ObjectId" {
        BeforeAll { 
            $app = New-MgApplication -DisplayName "AzureAdApplicationManagementTestApp2"
            $app = Get-MgApplication -ApplicationId $app.Id
            $sp = New-MgServicePrincipal -AppId $app.AppId
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
            $result = Get-AadApplication -ObjectId $app.Id
    
            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
            $result.ServicePrincipal | Should -BeNullOrEmpty -Not
            $result.Application.DisplayName | Should -Be "AzureAdApplicationManagementTestApp2"
            $result.ServicePrincipal.DisplayName | Should -Be "AzureAdApplicationManagementTestApp2"
        }

        AfterAll { 
            $appToRemove = Get-MgApplication -ApplicationId $app.Id
            $spToRemove = Get-MgServicePrincipal -ServicePrincipalId $sp.Id

            Remove-MgApplication -ApplicationId $appToRemove.Id
            $deletedApp = Get-MgDirectoryDeletedItem -DirectoryObjectId $appToRemove.Id
            Remove-MgDirectoryDeletedItem -DirectoryObjectId $deletedApp.Id

            $deletedSp = Get-MgDirectoryDeletedItem -DirectoryObjectId $spToRemove.Id
            Remove-MgDirectoryDeletedItem -DirectoryObjectId $deletedSp.Id
        }
    }

    Context "Parameter ApplicationId" {
        BeforeAll { 
            $app = New-MgApplication -DisplayName "AzureAdApplicationManagementTestApp3"
            $app = Get-MgApplication -ApplicationId $app.Id
            $sp = New-MgServicePrincipal -AppId $app.AppId
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
            $result = Get-AadApplication -ApplicationId $app.AppId
    
            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
            $result.ServicePrincipal | Should -BeNullOrEmpty -Not
            $result.Application.DisplayName | Should -Be "AzureAdApplicationManagementTestApp3"
            $result.ServicePrincipal.DisplayName | Should -Be "AzureAdApplicationManagementTestApp3"
        }
        
        AfterAll { 
            $appToRemove = Get-MgApplication -ApplicationId $app.Id
            $spToRemove = Get-MgServicePrincipal -ServicePrincipalId $sp.Id

            Remove-MgApplication -ApplicationId $appToRemove.Id
            $deletedApp = Get-MgDirectoryDeletedItem -DirectoryObjectId $appToRemove.Id
            Remove-MgDirectoryDeletedItem -DirectoryObjectId $deletedApp.Id

            $deletedSp = Get-MgDirectoryDeletedItem -DirectoryObjectId $spToRemove.Id
            Remove-MgDirectoryDeletedItem -DirectoryObjectId $deletedSp.Id
        }
    }

    Context "Parameter DisplayName" {
        BeforeAll { 
            $app = New-MgApplication -DisplayName "AzureAdApplicationManagementTestApp4"
            $app = Get-MgApplication -ApplicationId $app.Id
            $sp = New-MgServicePrincipal -AppId $app.AppId
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
            $result = Get-AadApplication -DisplayName $app.DisplayName
    
            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
            $result.ServicePrincipal | Should -BeNullOrEmpty -Not
            $result.Application.DisplayName | Should -Be "AzureAdApplicationManagementTestApp4"
            $result.ServicePrincipal.DisplayName | Should -Be "AzureAdApplicationManagementTestApp4"
        }
        
        AfterAll { 
            $appToRemove = Get-MgApplication -ApplicationId $app.Id
            $spToRemove = Get-MgServicePrincipal -ServicePrincipalId $sp.Id

            Remove-MgApplication -ApplicationId $appToRemove.Id
            $deletedApp = Get-MgDirectoryDeletedItem -DirectoryObjectId $appToRemove.Id
            Remove-MgDirectoryDeletedItem -DirectoryObjectId $deletedApp.Id

            $deletedSp = Get-MgDirectoryDeletedItem -DirectoryObjectId $spToRemove.Id
            Remove-MgDirectoryDeletedItem -DirectoryObjectId $deletedSp.Id
        }
    }
}
