#Get Octopus Parameters varaibles
$envName = $OctopusParameters['envName']
$Path = $OctopusParameters['Path']

#Set Powershell Script unique varaibles
$MachineName = $env:COMPUTERNAME
$dotnetsdkversion = dotnet --list-sdks
$dotnetruntimes = dotnet --list-runtimes
$Output = "$Path/$envName$MachineName_$(Get-Date -format "yyyy-MM-dd").txt"

#Verfiy Host connection
Write-Host "Verifying connection to host"

#Verify Storage path
if(Test-Path -Path $Path) {
    Write-Host "Connected to - " $Path
} else {
    Write-host "Unable to connect to Source directory does not exist - " $Path
}

#Get .NET Core runtimes and asp.net and store to output txt file into network shard drive
Write-Host "Geting list of .NET Runtimes Installed"

#Create File
Out-File $Output
Add-Content -Path $Output -Value "SDK Version"
Add-Content -Path $Output -Value $dotnetsdkversion
Add-Content -Path $Output -Value "Runtimes"
Add-Content -Path $Output -Value $dotnetruntimes

