#set variables
$today = Get-Date -format yyyyMMdd
$ComputerName = hostname
#$LoanAppModule = 'blLoanClient'
#$LoanAppModule = 'bpLoanClient'
$LoanAppModule = 'seLoanClient'


Copy-Item C:\OTS\Applications\LoanApp\$LoanAppModule\app.config.json -Destination H:\PS\outputs\$($computername)_$today.$LoanAppModule.app.config.json -Force
Copy-Item C:\OTS\Applications\LoanApp\$LoanAppModule\web.config -Destination H:\PS\outputs\$($computername)_$today.$LoanAppModule.web.config -Force
