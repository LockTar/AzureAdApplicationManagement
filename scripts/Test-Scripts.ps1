$ErrorActionPreference = "Stop"

$oldverbose = $VerbosePreference
$VerbosePreference = "continue"
$oldinformation = $InformationPreference
$InformationPreference = "continue"

$ApplicationName = "TestApplicationExtension"

try {
    & $PSScriptRoot"\Get-AzureAdApplication\v1\Get-AzureAdApplication.ps1" -ApplicationName $ApplicationName -FailIfNotFound $True
}
catch {
    Write-Information "Application doesn't exist, let's create one"
    & $PSScriptRoot"\New-AzureAdApplication\v1\New-AzureAdApplication.ps1" -ApplicationName $ApplicationName -SignOnUrl "https://$ApplicationName.com"# -AppIdUri "http://ralphjansenoutlook.onmicrosoft.com/$ApplicationName"
    Start-Sleep -Seconds 15
}

$application = Get-AzureRmADApplication -DisplayName $ApplicationName

try {
    #& $PSScriptRoot"\Set-AzureAdApplication\v1\Set-AzureAdApplication.ps1" `
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
#
    #Start-Sleep -Seconds 15
#
    #& $PSScriptRoot"\Set-AzureAdApplication\v1\Set-AzureAdApplication.ps1" `
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

    & $PSScriptRoot"\Remove-AzureAdApplication\v1\Remove-AzureAdApplication.ps1" -ObjectId $application.ObjectId
}
catch {
    Write-Verbose "Set failed so remove the application to clean up"
    & $PSScriptRoot"\Remove-AzureAdApplication\v1\Remove-AzureAdApplication.ps1" -ObjectId $application.ObjectId
    throw
}

$VerbosePreference = $oldverbose
$InformationPreference = $oldinformation