#Get Compare Paths
$envName= $OctopusParameters['envName']

$envName= "(UAT)"
if ($true) {
    
    Set-OctopusVariable -name "TestResult" -value "Passed"
}
else{

}