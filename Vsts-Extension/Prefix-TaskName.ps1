$fileToSearch = "task.json"
$filePath = "C:\Users\ralph\source\repos\AzureAdApplicationManagement2\Vsts-Extension"
$propertyName = "friendlyName"
$prefix = "Test - "

$filesFound = Get-ChildItem -Path $filePath -Filter $fileToSearch -Recurse -ErrorAction SilentlyContinue -Force

foreach ($file in $filesFound) {
    $pathToJson = $file.fullname
    Write-Verbose "Found file: $pathToJson"

    $json = Get-Content $pathToJson | ConvertFrom-Json

    $currentValue = $json.$propertyName
    $json.$propertyName = $prefix + $currentValue

    $json | ConvertTo-Json -Depth 100 | set-content $pathToJson
}