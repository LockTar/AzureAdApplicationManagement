#Invoke-Pester -Output Detailed .\Update-AadApplication.Tests.ps1

BeforeAll { 
    Remove-Module ManageAadApplications
    Import-Module .\ManageAadApplications.psm1
}

Describe 'Update-AadApplication' {
    Context "ObjectId" {
        BeforeEach { 
            $app1 = New-AzADApplication -DisplayName "AzureAdApplicationManagementTestApp1" -IdentifierUris "https://AzureAdApplicationManagementTestApp1"
            $sp1 = Get-AzADApplication -ObjectId $app1.ObjectId | New-AzADServicePrincipal
            Start-Sleep 15
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
            $result = Update-AadApplication -ObjectId $app1.ObjectId

            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
            $result.ServicePrincipal | Should -BeNullOrEmpty -Not
            $result.Application.DisplayName | Should -Be "AzureAdApplicationManagementTestApp1"
            $result.ServicePrincipal.DisplayName | Should -Be "AzureAdApplicationManagementTestApp1"
        }
        
        AfterEach { 
            Get-AzADApplication -DisplayName "AzureAdApplicationManagementTestApp1" | Remove-AzADApplication -Force
        }
    }

    Context "ResourceAccessFilePath" {
        BeforeEach { 
            $app1 = New-AzADApplication -DisplayName "AzureAdApplicationManagementTestApp1" -IdentifierUris "https://AzureAdApplicationManagementTestApp1"
            $sp1 = Get-AzADApplication -ObjectId $app1.ObjectId | New-AzADServicePrincipal
            Start-Sleep 15
        }

        It "Given empty ResourceAccessFilePath should throw error" {
            { Update-AadApplication -ObjectId $app1.ObjectId -ResourceAccessFilePath "" } | Should -Throw "Invalid file path for ResourceAccessFilePath"
        }

        It "Given invalid ResourceAccessFilePath should throw error" {
            { Update-AadApplication -ObjectId $app1.ObjectId -ResourceAccessFilePath $PSScriptRoot"\..\..\Test-RequiredResourceAccessInvalidName.json" } | Should -Throw "Invalid file path for ResourceAccessFilePath"
        }

        It "Given ResourceAccessFilePath should update ResourceAccess" {
            $result = Update-AadApplication -ObjectId $app1.ObjectId -ResourceAccessFilePath $PSScriptRoot"\..\..\Test-RequiredResourceAccess.json"

            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
            $result.RequiredResourceAccess | Should -BeNullOrEmpty -Not
            $result.RequiredResourceAccess.Count | Should -Be 2
        }
        
        AfterEach { 
            Get-AzADApplication -DisplayName "AzureAdApplicationManagementTestApp1" | Remove-AzADApplication -Force
        }
    }

    Context "AppRolesFilePath" {
        BeforeEach { 
            $app1 = New-AzADApplication -DisplayName "AzureAdApplicationManagementTestApp1" -IdentifierUris "https://AzureAdApplicationManagementTestApp1"
            $sp1 = Get-AzADApplication -ObjectId $app1.ObjectId | New-AzADServicePrincipal
            Start-Sleep 15
        }

        It "Given empty AppRolesFilePath should throw error" {
            { Update-AadApplication -ObjectId $app1.ObjectId -AppRolesFilePath "" } | Should -Throw "Invalid file path for AppRolesFilePath"
        }

        It "Given invalid AppRolesFilePath should throw error" {
            { Update-AadApplication -ObjectId $app1.ObjectId -AppRolesFilePath $PSScriptRoot"\..\..\Test-AppRolesInvalidName.json" } | Should -Throw "Invalid file path for AppRolesFilePath"
        }

        It "Given AppRolesFilePath should update AppRoles" {
            $result = Update-AadApplication -ObjectId $app1.ObjectId -AppRolesFilePath $PSScriptRoot"\..\..\Test-AppRoles.json"

            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
            $result.RequiredResourceAccess.Count | Should -Be 0
            $result.AppRoles | Should -BeNullOrEmpty -Not
            $result.AppRoles.Count | Should -Be 3
        }
        
        AfterEach { 
            Get-AzADApplication -DisplayName "AzureAdApplicationManagementTestApp1" | Remove-AzADApplication -Force
        }
    }

    Context "DisplayName" {
        BeforeEach { 
            $app1 = New-AzADApplication -DisplayName "AzureAdApplicationManagementTestApp1" -IdentifierUris "https://AzureAdApplicationManagementTestApp1"
            $sp1 = Get-AzADApplication -ObjectId $app1.ObjectId | New-AzADServicePrincipal
            Start-Sleep 15
        }

        It "Given no DisplayName should skip update" {
            $result = Update-AadApplication -ObjectId $app1.ObjectId

            $result | Should -BeNullOrEmpty -Not
        }

        It "Given empty DisplayName should throw error" {
            { Update-AadApplication -ObjectId $app1.ObjectId -DisplayName "" } | Should -Throw "Cannot validate argument on parameter 'DisplayName'. The argument is null or empty. Provide an argument that is not null or empty, and then try the command again."
        }        

        It "Given DisplayName should update value" {
            $result = Update-AadApplication -ObjectId $app1.ObjectId -DisplayName "AzureAdApplicationManagementTestApp1NewName"

            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
            $result.Application.DisplayName | Should -Be "AzureAdApplicationManagementTestApp1NewName"
            $result.ServicePrincipal.DisplayName | Should -Be "AzureAdApplicationManagementTestApp1NewName"
        }
        
        AfterEach { 
            Get-AzADApplication -ObjectId $app1.ObjectId | Remove-AzADApplication -Force
        }
    }

    Context "IdentifierUri" {
        BeforeEach { 
            $app1 = New-AzADApplication -DisplayName "AzureAdApplicationManagementTestApp1" -IdentifierUris "https://AzureAdApplicationManagementTestApp1"
            $sp1 = Get-AzADApplication -ObjectId $app1.ObjectId | New-AzADServicePrincipal
            Start-Sleep 15
        }

        It "Given no IdentifierUri should skip update" {
            $result = Update-AadApplication -ObjectId $app1.ObjectId

            $result | Should -BeNullOrEmpty -Not
        }

        It "Given empty IdentifierUri should throw error" {
            { Update-AadApplication -ObjectId $app1.ObjectId -IdentifierUri "" } | Should -Throw "Cannot validate argument on parameter 'IdentifierUri'. The argument is null or empty. Provide an argument that is not null or empty, and then try the command again."
        }        

        It "Given IdentifierUri should update value" {
            $result = Update-AadApplication -ObjectId $app1.ObjectId -IdentifierUri "http://foo123"

            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
            $result.Application.IdentifierUris | Should -Be "http://foo123"
        }
        
        AfterEach { 
            Get-AzADApplication -ObjectId $app1.ObjectId | Remove-AzADApplication -Force
        }
    }

    Context "HomePage" {
        BeforeEach { 
            $app1 = New-AzADApplication -DisplayName "AzureAdApplicationManagementTestApp1" -IdentifierUris "https://AzureAdApplicationManagementTestApp1"
            $sp1 = Get-AzADApplication -ObjectId $app1.ObjectId | New-AzADServicePrincipal
            Start-Sleep 15
        }

        It "Given no HomePage should skip update" {
            $result = Update-AadApplication -ObjectId $app1.ObjectId

            $result | Should -BeNullOrEmpty -Not
            $result.Application.HomePage | Should -BeNullOrEmpty
            $result.ServicePrincipal.HomePage | Should -BeNullOrEmpty
        }

        It "Given empty HomePage should throw error" {
            { Update-AadApplication -ObjectId $app1.ObjectId -HomePage "" } | Should -Throw "Cannot validate argument on parameter 'HomePage'. The argument is null or empty. Provide an argument that is not null or empty, and then try the command again."
        }        

        It "Given HomePage should update value" {
            $result = Update-AadApplication -ObjectId $app1.ObjectId -HomePage "https://sampleurl.info"

            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
            $result.Application.HomePage | Should -Be "https://sampleurl.info"
            $result.ServicePrincipal.HomePage | Should -Be "https://sampleurl.info"
        }

        It "Given new HomePage should update old HomePage value" {
            $result = Update-AadApplication -ObjectId $app1.ObjectId -HomePage "https://old.info"
            $result = Update-AadApplication -ObjectId $app1.ObjectId -HomePage "https://sampleurl.info"

            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
            $result.Application.HomePage | Should -Be "https://sampleurl.info"
            $result.ServicePrincipal.HomePage | Should -Be "https://sampleurl.info"
        }
        
        AfterEach { 
            Get-AzADApplication -ObjectId $app1.ObjectId | Remove-AzADApplication -Force
        }
    }

    Context "AvailableToOtherTenants" {
        BeforeEach { 
            $app1 = New-AzADApplication -DisplayName "AzureAdApplicationManagementTestApp1" -IdentifierUris "https://AzureAdApplicationManagementTestApp1"
            $sp1 = Get-AzADApplication -ObjectId $app1.ObjectId | New-AzADServicePrincipal
            Start-Sleep 15
        }

        It "Given no AvailableToOtherTenants should skip update" {
            $result = Update-AadApplication -ObjectId $app1.ObjectId

            $result | Should -BeNullOrEmpty -Not
            $result.Application.AvailableToOtherTenants | Should -Be $false
        }

        It "Given AvailableToOtherTenants should update value" {
            $result = Update-AadApplication -ObjectId $app1.ObjectId -AvailableToOtherTenants $true

            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
            $result.Application.AvailableToOtherTenants | Should -Be $true
        }

        It "Given new AvailableToOtherTenants should update old AvailableToOtherTenants value" {
            $result = Update-AadApplication -ObjectId $app1.ObjectId -AvailableToOtherTenants $true
            $result = Update-AadApplication -ObjectId $app1.ObjectId -AvailableToOtherTenants $false

            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
            $result.Application.AvailableToOtherTenants | Should -Be $false
        }
        
        AfterEach { 
            Get-AzADApplication -ObjectId $app1.ObjectId | Remove-AzADApplication -Force
        }
    }

    Context "ReplyUrls" {
        BeforeEach { 
            $app1 = New-AzADApplication -DisplayName "AzureAdApplicationManagementTestApp1" -IdentifierUris "https://AzureAdApplicationManagementTestApp1"
            $sp1 = Get-AzADApplication -ObjectId $app1.ObjectId | New-AzADServicePrincipal
            Start-Sleep 15
        }

        It "Given no ReplyUrls should skip update" {
            $result = Update-AadApplication -ObjectId $app1.ObjectId

            $result | Should -BeNullOrEmpty -Not
            $result.ServicePrincipal.ReplyUrls | Should -BeNullOrEmpty
        }

        It "Given empty ReplyUrls should throw error" {
            { Update-AadApplication -ObjectId $app1.ObjectId -ReplyUrls "" } | Should -Throw "zzz Cannot validate argument on parameter 'ReplyUrls'. The argument is null or empty. Provide an argument that is not null or empty, and then try the command again."
        }

        It "Given ReplyUrls should update value" {
            $result = Update-AadApplication -ObjectId $app1.ObjectId -ReplyUrls "https://sampleurl.info"

            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
            $result.Application.ReplyUrls | Should -Be "https://sampleurl.info"
        }

        It "Given new ReplyUrls should update old ReplyUrls value" {
            $result = Update-AadApplication -ObjectId $app1.ObjectId -ReplyUrls "https://old.info"
            $result = Update-AadApplication -ObjectId $app1.ObjectId -ReplyUrls "https://sampleurl.info"

            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
            $result.Application.ReplyUrls | Should -Be "https://sampleurl.info"
        }
        
        AfterEach { 
            Get-AzADApplication -ObjectId $app1.ObjectId | Remove-AzADApplication -Force
        }
    }
}
