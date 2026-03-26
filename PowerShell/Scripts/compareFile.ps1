$comparePath1 = $OctopusParameters['comparePath1']
$comparePath2 = $OctopusParameters['comparePath1'] 
$compareOutputPath = $OctopusParameters['compareOutputPath']   
$compareOutputFile = $OctopusParameters['compareOutputFile']

Write-Host 'Compare path 1 is ' $comparePath1
Write-Host 'Compare path 2 is ' $comparePath2
Write-Host 'Compare output will be written to' $compareOutputPath "\" $compareOutputFile

if(Test-Path -Path $comparePath1) {

	if(Test-Path -Path $comparePath2) {

$comparePath1 = Get-ChildItem -Recurse -Path $comparePath1
$comparePath2 = Get-ChildItem -Recurse -Path $comparePath2

Compare-Object -ReferenceObject $comparePath1 -DifferenceObject $comparePath2 | Out-File $compareOutputFile

} else {
    Write-host "Compare Path 1 does not exist - " $comparePath2
}

} else {
Write-host "Compare Path 2 does not exist - " $comparePath1
}

Write-Host 'File have ben compared and out put can now be viewed in ' $compareOutputFile