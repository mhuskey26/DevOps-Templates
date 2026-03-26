#set variables
$today = Get-Date -format yyyyMMdd
$ComputerName = hostname
#$LoanAppModule = 'blLoanIntSL'
#$LoanAppModule = 'bpLoanIntSL'
#$LoanAppModule = 'seLoanIntSL'
#$LoanAppModule = 'blLoanExtSL'
#$LoanAppModule = 'bpLoanExtSL'
$LoanAppModule = 'seLoanExtSL'


Copy-Item C:\OTS\Applications\LoanApp\$LoanAppModule\appsettings.json -Destination H:\PS\outputs\$($computername)_$today.$LoanAppModule.appsettings.json -Force
Copy-Item C:\OTS\Applications\LoanApp\$LoanAppModule\hosting.BELLCO.json -Destination H:\PS\outputs\$($computername)_$today.$LoanAppModule.hosting.BELLCO.json -Force
Copy-Item C:\OTS\Applications\LoanApp\$LoanAppModule\hosting.BETHPAGE.json -Destination H:\PS\outputs\$($computername)_$today.$LoanAppModule.hosting.BETHPAGE.json -Force
Copy-Item C:\OTS\Applications\LoanApp\$LoanAppModule\hosting.SECU.json -Destination H:\PS\outputs\$($computername)_$today.$LoanAppModule.hosting.SECU.json -Force
Copy-Item C:\OTS\Applications\LoanApp\$LoanAppModule\web.config -Destination H:\PS\outputs\$($computername)_$today.$LoanAppModule.web.config -Force
Copy-Item C:\OTS\Applications\LoanApp\$LoanAppModule\nlog.config -Destination H:\PS\outputs\$($computername)_$today.$LoanAppModule.nlog.config -Force

