#DevOps_Compare-Configs – script contents:
# original Author: Cindy Muesing Date: 1/29/21

# Modified:  20210816 Kari Tornow

###############################################################################################
#$LoanAppModules = @('seLoanIntSL','seLoanExtSL','seLoanClient')
#$LoanAppModules = @('seLoanExtSL')

$comparePath1 = "H:/dryRun/deployDir" #$OctopusParameters['AppConfigSource']
$comparePath2 = "H:/dryRun//BackupsRobo" #$OctopusParameters['BackupDestination'] 
$compareOutput = "H:/dryRun//compareOutput" #OctopusParameters[CompareLocaion]   

function DevOps_Compare-Configs {
 #   [cmdletbinding()]
                #set variables
  #              $CompareDate = Read-Host 'What file date to compare? yyyymmdd' #Get-Date -format yyyyMMdd
   #             $ComputerNameSource = Read-host 'What computer to use as source?'
    #            $ComputerNameTarget = Read-host 'What computer to use as target?'
    foreach ($LoanAppModule in $LoanAppModules) {
    $ConfigDiff = Invoke-Command  {
        $appsetting= Compare-Object -ReferenceObject (Get-Content $comparePath1) -DifferenceObject (Get-Content $comparePath2)

 #       $appsetting= Compare-Object -ReferenceObject (Get-Content H:\PS\outputs\$($computernameSource)_$CompareDate.$LoanAppModule.appsettings.json)
 # -DifferenceObject (Get-Content H:\PS\outputs\$($computernameTarget)_$CompareDate.$LoanAppModule.appsettings.json)
  #      $appconfig= Compare-Object -ReferenceObject (Get-Content H:\PS\outputs\$($computernameSource)_$CompareDate.$LoanAppModule.app.config.json) -DifferenceObject (Get-Content H:\PS\outputs\$($computernameTarget)_$CompareDate.$LoanAppModule.app.config.json)
   #     $webconfig = Compare-Object -ReferenceObject (Get-Content H:\PS\outputs\$($computernameSource)_$CompareDate.$LoanAppModule.web.config) -DifferenceObject (Get-Content H:\PS\outputs\$($computernameTarget)_$CompareDate.$LoanAppModule.web.config)
    #    $nlog = Compare-Object -ReferenceObject (Get-Content H:\PS\outputs\$($computernameSource)_$CompareDate.$LoanAppModule.nlog.config) -DifferenceObject (Get-Content H:\PS\outputs\$($computernameTarget)_$CompareDate.$LoanAppModule.nlog.config)
     #   $bellco = Compare-Object -ReferenceObject (Get-Content H:\PS\outputs\$($computernameSource)_$CompareDate.$LoanAppModule.hosting.BELLCO.json) -DifferenceObject (Get-Content H:\PS\outputs\$($computernameTarget)_$CompareDate.$LoanAppModule.hosting.BELLCO.json)
      #  $bethpage = Compare-Object -ReferenceObject (Get-Content H:\PS\outputs\$($computernameSource)_$CompareDate.$LoanAppModule.hosting.BETHPAGE.json) -DifferenceObject (Get-Content H:\PS\outputs\$($computernameTarget)_$CompareDate.$LoanAppModule.hosting.BETHPAGE.json)
       # $secu = Compare-Object -ReferenceObject (Get-Content H:\PS\outputs\$($computernameSource)_$CompareDate.$LoanAppModule.hosting.SECU.json) -DifferenceObject (Get-Content H:\PS\outputs\$($computernameTarget)_$CompareDate.$LoanAppModule.hosting.SECU.json)
        
    return $appsetting, $appconfig,$webconfig,$nlog,$bellco, $bethpage, $secu}
    $ConfigDiff[0] | Out-File $compareOutput -Force

    #$ConfigDiff[0] | Out-File H:\PS\outputs\$($computernameSource)_$CompareDate.$LoanAppModule.appsettingsDiff_.txt -Force
    #$ConfigDiff[1] | Out-File H:\PS\outputs\$($computernameSource)_$CompareDate.$LoanAppModule.appconfigDiff_.txt -Force
    #$ConfigDiff[2] | Out-File H:\PS\outputs\$($computernameSource)_$CompareDate.$LoanAppModule.webconfigDiff_.txt -Force
    #$ConfigDiff[3] | Out-File H:\PS\outputs\$($computernameSource)_$CompareDate.$LoanAppModule.nlogDiff_.txt  -Force
    #$ConfigDiff[4] | Out-File H:\PS\outputs\$($computernameSource)_$CompareDate.$LoanAppModule.bellcoDiff_.txt -Force
    #$ConfigDiff[5] | Out-File H:\PS\outputs\$($computernameSource)_$CompareDate.$LoanAppModule.bethpageDiff_.txt -Force
    #$ConfigDiff[6] | Out-File H:\PS\outputs\$($computernameSource)_$CompareDate.$LoanAppModule.secuDiff_.txt -Force

    }
}
###############################################################################################

DevOps_Compare-Configs

