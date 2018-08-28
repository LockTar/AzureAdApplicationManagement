$ErrorActionPreference = "Stop"

$oldverbose = $VerbosePreference
$VerbosePreference = "continue"
$oldinformation = $InformationPreference
$InformationPreference = "continue"

$ApplicationName = "TestApplicationExtension"

try {
    & $PSScriptRoot"\Get-AzureAdApplication\v1\Get-AzureAdApplication.ps1" -ApplicationName $ApplicationName -FailOnError $True
}
catch {
    Write-Information "Application doesn't exist, let's create one"
    & $PSScriptRoot"\New-AzureAdApplication\v1\New-AzureAdApplication.ps1" -ApplicationName $ApplicationName -SignOnUrl "https://$ApplicationName.com"
    Start-Sleep -Seconds 10
}

$application = Get-AzureRmADApplication -DisplayName $ApplicationName

& $PSScriptRoot"\Set-AzureAdApplication\v1\Set-AzureAdApplication.ps1" `
    -ObjectId $application.ObjectId `
    -Name "$($ApplicationName)2" `
    -AppIdUri "https://ralphjansenoutlook.onmicrosoft.com/$($ApplicationName)2" `
    -HomePageUrl "https://www.homepage.com2" `
    -LogoutUrl "https://www.logout.com2" `
    -TermsOfServiceUrl "https://term.com2" `
    -PrivacyStatementUrl "https://privacystatement.com2" `
    -MultiTenant $True `
    -ResourceAccessFilePath "C:\" `
    -Owners @("bf41f70e-be3c-473a-b594-1e7c57b28da4", "2e5cb30e-7ce4-412f-82b9-70998ec8ac7d")

& $PSScriptRoot"\Set-AzureAdApplication\v1\Set-AzureAdApplication.ps1" `
    -ObjectId $application.ObjectId `
    -Name $ApplicationName `
    -AppIdUri "https://ralphjansenoutlook.onmicrosoft.com/TestApplicationExtension" `
    -HomePageUrl "https://www.homepage.com" `
    -LogoutUrl "https://www.logout.com" `
    -TermsOfServiceUrl "https://term.com" `
    -PrivacyStatementUrl "https://privacystatement.com" `
    -MultiTenant $False `
    -ResourceAccessFilePath "C:\" `
    -Owners @("bf41f70e-be3c-473a-b594-1e7c57b28da4", "2e5cb30e-7ce4-412f-82b9-70998ec8ac7d")

& $PSScriptRoot"\Remove-AzureAdApplication\v1\Remove-AzureAdApplication.ps1" -ObjectId $application.ObjectId

$VerbosePreference = $oldverbose
$InformationPreference = $oldinformation