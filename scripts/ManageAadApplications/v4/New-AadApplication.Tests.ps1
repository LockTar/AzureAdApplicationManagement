#Invoke-Pester -Output Detailed .\New-AadApplication.Tests.ps1

BeforeAll { 
    Remove-Module ManageAadApplications
    Import-Module .\ManageAadApplications.psm1
}

Describe 'New-AadApplication' {
    Context "New-AadApplication" {
        BeforeAll { 
            $appName = "AzureAdApplicationManagementTestApp1"
        }

        It "Given a name should return application and service principal with default identifieruri" {
            $result = New-AadApplication "$appName"

            Write-Host "##vso[task.setvariable variable=ObjectId;]$($result.Application.Id)"
            Write-Host "##vso[task.setvariable variable=ApplicationId;]$($result.Application.AppId)"
            Write-Host "##vso[task.setvariable variable=Name;]$($result.Application.DisplayName)"
            Write-Host "##vso[task.setvariable variable=AppIdUri;]$($result.Application.IdentifierUris[0])"
            Write-Host "##vso[task.setvariable variable=HomePageUrl;]$($result.Application.HomePage)"
            Write-Host "##vso[task.setvariable variable=SignInAudience;]$($result.Application.SignInAudience)"
            Write-Host "##vso[task.setvariable variable=ServicePrincipalObjectId;]$($result.ServicePrincipal.Id)"

            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
            $result.ServicePrincipal | Should -BeNullOrEmpty -Not
            $result.Application.DisplayName | Should -Be "$appName"
            $result.Application.IdentifierUris[0] | Should -Be "api://$($result.Application.AppId)"
            $result.ServicePrincipal.DisplayName | Should -Be "$appName"
        }
        
        It "Given an empty name should fail" {
            { New-AadApplication -DisplayName "" } | Should -Throw
        }

        It "Given a name should return application and service principal with default identifieruri" {
            $result = New-AadApplication -DisplayName "$appName"
            
            Write-Host "##vso[task.setvariable variable=ObjectId;]$($result.Application.Id)"
            Write-Host "##vso[task.setvariable variable=ApplicationId;]$($result.Application.AppId)"
            Write-Host "##vso[task.setvariable variable=Name;]$($result.Application.DisplayName)"
            Write-Host "##vso[task.setvariable variable=AppIdUri;]$($result.Application.IdentifierUris[0])"
            Write-Host "##vso[task.setvariable variable=HomePageUrl;]$($result.Application.HomePage)"
            Write-Host "##vso[task.setvariable variable=SignInAudience;]$($result.Application.SignInAudience)"
            Write-Host "##vso[task.setvariable variable=ServicePrincipalObjectId;]$($result.ServicePrincipal.Id)"

            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
            $result.ServicePrincipal | Should -BeNullOrEmpty -Not
            $result.Application.DisplayName | Should -Be "$appName"
            $result.Application.IdentifierUris[0] | Should -Be "api://$($result.Application.AppId)"
            $result.ServicePrincipal.DisplayName | Should -Be "$appName"
        }

        It "Given an empty identifieruri should return application and service principal with default identifieruri" {
            $result = New-AadApplication -DisplayName "$appName" -IdentifierUri ""
            
            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
            $result.ServicePrincipal | Should -BeNullOrEmpty -Not
            $result.Application.DisplayName | Should -Be "$appName"
            $result.Application.IdentifierUris[0] | Should -Be "api://$($result.Application.AppId)"
            $result.ServicePrincipal.DisplayName | Should -Be "$appName"
        }

        It "Given an identifieruri should return application and service principal with given identifieruri" {
            $result = New-AadApplication -DisplayName "$appName" -IdentifierUri "https://ralphjansenoutlook.onmicrosoft.com/AzureAdApplicationManagementTestApp1" # Revert to ralph
            
            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
            $result.ServicePrincipal | Should -BeNullOrEmpty -Not
            $result.Application.DisplayName | Should -Be "$appName"
            $result.Application.IdentifierUris[0] | Should -Be "https://ralphjansenoutlook.onmicrosoft.com/AzureAdApplicationManagementTestApp1" # Revert to ralph
            $result.ServicePrincipal.DisplayName | Should -Be "$appName"
        }
        
        AfterEach { 
            $removeApps = Get-MgApplication -Filter "DisplayName eq '$appName'"
            foreach( $app in $removeApps) { Remove-MgApplication -ApplicationId $app.Id }
        }
    }
}
