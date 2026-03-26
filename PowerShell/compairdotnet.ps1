#Get Octopus Parameters varaibles
$envName = $OctopusParameters['envName']
$ComparePathA = $OctopusParameters['ComparePathA']
$ComparePathB = $OctopusParameters['ComparePathB']
$Output = $OctopusParameters['CampareOutput']
$compareUAT = where { $_ -match "$ComparePathA/$(Get-Date -format "yyyy-MM-dd").txt"}
$comparePROD = where { $_ -match "$ComparePathB/$(Get-Date -format "yyyy-MM-dd").txt"}

#Set Powershell Script unique varaibles
$MachineName = $env:COMPUTERNAME
$Results = "$Output/MissingDotNET_$(Get-Date -format "yyyy-MM-dd").txt"

#Begin .NET Runtime Check
Write-Host "Checking for Missing/Unmatched .NET Runtimes"

#Compare .NET Runtime files
if(Compare-Object -ReferenceObject $(Get-Content $compareUAT) -DifferenceObject $(Get-Content $comparePROD)){
    Write-Host "All .NET Runtimes match"
    #Setup to output a set Octopus varaible
    Set-OctopusVariable -name "SendEmail" -value "false"
}
else {
    Write-Host "Missing .NET Runtimes"
    #Setup to output a set Octopus varaible
    Set-OctopusVariable -name "SendEmail" -value "true"
}