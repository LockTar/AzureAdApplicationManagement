$ErrorActionPreference = "Stop"

$oldverbose = $VerbosePreference
$VerbosePreference = "continue"
$oldinformation = $InformationPreference
$InformationPreference = "continue"

$ApplicationName = "ApplicationManagementExtensionV3"

Get-Module Get-AadApplication | Remove-Module
Get-Module New-AadApplication | Remove-Module
Get-Module Set-AadApplication | Remove-Module
Get-Module Remove-AadApplication | Remove-Module

Import-Module $PSScriptRoot\Get-AzureAdApplication\v3\Get-AadApplication
Import-Module $PSScriptRoot\New-AzureAdApplication\v3\New-AadApplication.psm1
Import-Module $PSScriptRoot\Set-AzureAdApplication\v3\Set-AadApplication.psm1
Import-Module $PSScriptRoot\Remove-AzureAdApplication\v3\Remove-AadApplication.psm1

try {
    Get-AadApplication -ApplicationName $ApplicationName -FailIfNotFound $true
}
catch {
    Write-Information "Application doesn't exist, let's create one"
    New-AadApplication -ApplicationName $ApplicationName -HomePageUrl "https://$ApplicationName.com"# -AppIdUri "http://ralphjansenoutlook.onmicrosoft.com/$ApplicationName"
    Start-Sleep -Seconds 15
}

$application = Get-AadApplication -ApplicationName $ApplicationName
$application = $application.Application

try {
    Get-AadApplication -ApplicationName $ApplicationName
    
    # Set-AadApplication `
    #    -ObjectId $application.ObjectId `
    #    -Name "$($ApplicationName)2" `
    #    -AppIdUri "https://6e93a626-8aca-4dc1-9191-ce291b4b75a1/$($ApplicationName)2" `
    #    -HomePageUrl "https://www.homepage.com2" `
    #    -LogoutUrl "https://www.logout.com2" `
    #    -TermsOfServiceUrl "https://term.com2" `
    #    -PrivacyStatementUrl "https://privacystatement.com2" `
    #    -MultiTenant $False `
    #    -ResourceAccessFilePath $PSScriptRoot"\Test-RequiredResourceAccess.json" `
    #    -Owners @("bf41f70e-be3c-473a-b594-1e7c57b28da4", "2e5cb30e-7ce4-412f-82b9-70998ec8ac7d")

    #Start-Sleep -Seconds 15

    # Set-AadApplication `
    #    -ObjectId $application.ObjectId `
    #    -Name $ApplicationName `
    #    -AppIdUri "https://6e93a626-8aca-4dc1-9191-ce291b4b75a1/$ApplicationName" `
    #    -HomePageUrl "https://www.homepage.com" `
    #    -LogoutUrl "https://www.logout.com" `
    #    -TermsOfServiceUrl "https://term.com" `
    #    -PrivacyStatementUrl "https://privacystatement.com" `
    #    -MultiTenant $False `
    #    -ResourceAccessFilePath $PSScriptRoot"\Test-RequiredResourceAccess.json" `
    #    -Owners @("bf41f70e-be3c-473a-b594-1e7c57b28da4", "2e5cb30e-7ce4-412f-82b9-70998ec8ac7d")
#
    #Start-Sleep -Seconds 15

    Remove-AadApplication -ObjectId $application.ObjectId
}
catch {
    Write-Information "Script failed so remove the application so we can start fresh next time"
    $application
    Remove-AadApplication -ObjectId $application.ObjectId
}

$VerbosePreference = $oldverbose
$InformationPreference = $oldinformation