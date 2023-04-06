#Invoke-Pester -Output Detailed .\Remove-AadApplication.Tests.ps1

BeforeAll { 
    Remove-Module ManageAadApplications
    Import-Module .\ManageAadApplications.psm1
}

Describe 'Remove-AadApplication' {
    Context "Remove by ObjectId" {
        BeforeEach { 
            $app1 = New-MgApplication -DisplayName "AzureAdApplicationManagementTestApp1"
            $app1 = Get-MgApplication -ApplicationId $app1.Id
            $sp1 = New-MgServicePrincipal -AppId $app1.AppId
        }
        
        It "Given empty objectid should throw error" {
            { Remove-AadApplication "" -InformationAction Continue } | Should -Throw "Cannot validate argument on parameter 'ObjectId'. The argument is null or empty. Provide an argument that is not null or empty, and then try the command again."
        }

        It "Given invalid objectid should show information message" {
            Remove-AadApplication -ObjectId "foo" -InformationAction Continue
        }

        It "Given non existing objectid with fail switch should throw error" {
            { Remove-AadApplication -ObjectId 88a82126-c223-4f2e-b997-2fe44d9131ec -FailIfNotFound -InformationAction Continue } | Should -Throw "The application with ObjectId 88a82126-c223-4f2e-b997-2fe44d9131ec cannot be found. Check if the application exists and if you search with the right values."
        }

        It "Given non existing objectid without fail switch should continue without error" {
            $result = Remove-AadApplication -ObjectId 88a82126-c223-4f2e-b997-2fe44d9131ec -InformationAction Continue
            
            $result | Should -BeNullOrEmpty
        }

        It "Given only existing objectid should remove the application" {
            $result = Remove-AadApplication -ObjectId $app1.Id -InformationAction Continue

            $result | Should -BeNullOrEmpty
        }
        
        AfterEach { 
            $apps = Get-MgApplication -Filter "DisplayName eq 'AzureAdApplicationManagementTestApp1'"
            foreach( $app in $apps) { Remove-MgApplication -ApplicationId $app.Id }

            $apps = Get-MgDirectoryDeletedItem -DirectoryObjectId microsoft.graph.application -Property '*'
            $apps = $apps.AdditionalProperties['value'] 
            foreach( $app in $apps) { Remove-MgDirectoryDeletedItem -DirectoryObjectId $app.id }
        }
    }

    Context "Remove by ApplicationId" {
        BeforeEach { 
            $app1 = New-MgApplication -DisplayName "AzureAdApplicationManagementTestApp1"
            $app1 = Get-MgApplication -ApplicationId $app1.Id
            $sp1 = New-MgServicePrincipal -AppId $app1.AppId
        }
        
        It "Given empty applicationid should throw error" {
            { Remove-AadApplication -ApplicationId "" -InformationAction Continue } | Should -Throw "Cannot validate argument on parameter 'ApplicationId'. The argument is null or empty. Provide an argument that is not null or empty, and then try the command again."
        }

        It "Given non existing applicationid with fail switch should throw error" {
            { Remove-AadApplication -ApplicationId 88a82126-c223-4f2e-b997-2fe44d9131ec -FailIfNotFound -InformationAction Continue } | Should -Throw "The application with ApplicationId 88a82126-c223-4f2e-b997-2fe44d9131ec cannot be found. Check if the application exists and if you search with the right values."
        }

        It "Given non existing applicationid without fail switch should continue without error" {
            $result = Remove-AadApplication -ApplicationId 88a82126-c223-4f2e-b997-2fe44d9131ec -InformationAction Continue
            
            $result | Should -BeNullOrEmpty
        }

        It "Given only existing applicationid should remove the application" {
            $result = Remove-AadApplication -ApplicationId $app1.AppId -InformationAction Continue

            $result | Should -BeNullOrEmpty
        }
        
        AfterEach { 
            $apps = Get-MgApplication -Filter "DisplayName eq 'AzureAdApplicationManagementTestApp1'"
            foreach( $app in $apps) { Remove-MgApplication -ApplicationId $app.Id }

            $apps = Get-MgDirectoryDeletedItem -DirectoryObjectId microsoft.graph.application -Property '*'
            $apps = $apps.AdditionalProperties['value'] 
            foreach( $app in $apps) { Remove-MgDirectoryDeletedItem -DirectoryObjectId $app.id }

        }
    }
}
